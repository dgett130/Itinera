import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:latlong2/latlong.dart';

import 'package:itinera/core/enums.dart';
import 'package:itinera/features/explore/geo_codec.dart';
import 'package:itinera/features/explore/route_math.dart';
import 'package:itinera/features/explore/route_planner.dart';
import 'package:itinera/features/transport/routing_service.dart';

// Quattro punti sulla stessa longitudine, in ordine "a zig-zag".
const _zigzag = [
  LatLng(41.89, 12.48),
  LatLng(41.95, 12.48),
  LatLng(41.90, 12.48),
  LatLng(41.96, 12.48),
];

String _osrmBody(List<List<num>> legs) => jsonEncode({
  'routes': [
    {
      'distance': legs.fold<num>(0, (a, l) => a + l[0]),
      'duration': legs.fold<num>(0, (a, l) => a + l[1]),
      'geometry': {
        'coordinates': [
          [12.48, 41.89],
          [12.48, 41.95],
        ],
      },
      'legs': [
        for (final l in legs) {'distance': l[0], 'duration': l[1]},
      ],
    },
  ],
});

void main() {
  group('tratti: codifica JSON', () {
    test('andata e ritorno arrotondando a metri e secondi', () {
      final s = encodeLegs(const [RouteLeg(600.4, 479.6), RouteLeg(1200, 900)]);
      expect(s, '[{"m":600,"s":480},{"m":1200,"s":900}]');
      final legs = decodeLegs(s);
      expect(legs.map((l) => l.distanceMeters), [600, 1200]);
      expect(legs.map((l) => l.durationSeconds), [480, 900]);
    });

    test('input assente o rovinato: nessun tratto, nessun crash', () {
      expect(decodeLegs(null), isEmpty);
      expect(decodeLegs(''), isEmpty);
      expect(decodeLegs('non json'), isEmpty);
      expect(decodeLegs('{"m":1}'), isEmpty);
      expect(decodeLegs('[{"m":"x","s":1},{"m":5,"s":6}]'), hasLength(1));
    });
  });

  group('estimateLegs', () {
    test('un tratto per coppia; la somma coincide con la stima totale', () {
      final legs = estimateLegs(waypoints: _zigzag, mode: RouteTravelMode.walk);
      expect(legs, hasLength(3));
      final total = estimateTravel(
        orderedPoints: _zigzag,
        mode: RouteTravelMode.walk,
      );
      expect(
        legs.fold(0.0, (a, l) => a + l.distanceMeters),
        closeTo(total.distanceMeters, 0.01),
      );
      expect(
        legs.fold(0.0, (a, l) => a + l.durationSeconds),
        closeTo(total.durationSeconds, 0.01),
      );
    });
  });

  group('suggestFasterOrder', () {
    test('meno di 3 tappe: nessun suggerimento', () {
      expect(
        suggestFasterOrder(
          points: _zigzag.take(2).toList(),
          mode: RouteTravelMode.walk,
        ),
        isNull,
      );
    });

    test('zig-zag: propone un ordine migliore con il risparmio', () {
      final s = suggestFasterOrder(
        points: _zigzag,
        mode: RouteTravelMode.walk,
        fixedStart: true,
      );
      expect(s, isNotNull);
      expect(s!.order, [0, 2, 1, 3]);
      // ~10 km in meno di zig-zag a piedi: ben piu' di un'ora risparmiata.
      expect(s.savedSeconds, greaterThan(3600));
    });

    test('con la partenza fissa la prima tappa non cambia', () {
      final pts = [
        const LatLng(41.93, 12.48),
        const LatLng(41.89, 12.48),
        const LatLng(41.96, 12.48),
        const LatLng(41.90, 12.48),
      ];
      final fixed = suggestFasterOrder(
        points: pts,
        mode: RouteTravelMode.walk,
        fixedStart: true,
      );
      expect(fixed!.order.first, 0);
      final free = suggestFasterOrder(points: pts, mode: RouteTravelMode.walk);
      expect(free!.order.first, isNot(0), reason: 'partire da un estremo');
      expect(free.savedSeconds, greaterThan(fixed.savedSeconds));
    });

    test('ordine già ottimo o risparmio minimo: nessun suggerimento', () {
      expect(
        suggestFasterOrder(
          points: [_zigzag[0], _zigzag[2], _zigzag[1], _zigzag[3]],
          mode: RouteTravelMode.walk,
          fixedStart: true,
        ),
        isNull,
      );
      // Punti vicinissimi: il guadagno sta sotto i 2 minuti.
      expect(
        suggestFasterOrder(
          points: const [
            LatLng(41.9000, 12.48),
            LatLng(41.9010, 12.48),
            LatLng(41.9003, 12.48),
          ],
          mode: RouteTravelMode.car,
          fixedStart: true,
        ),
        isNull,
      );
    });
  });

  group('RoutingService: tratti OSRM', () {
    test('legge un tratto per coppia di waypoint', () async {
      final client = MockClient(
        (_) async => http.Response(
          _osrmBody([
            [600, 480],
            [900, 700],
          ]),
          200,
        ),
      );
      final res = await RoutingService(
        client: client,
      ).route(_zigzag.take(3).toList(), RouteTravelMode.walk);
      expect(res, isNotNull);
      expect(res!.legs.map((l) => l.distanceMeters), [600, 900]);
      expect(res.legs.map((l) => l.durationSeconds), [480, 700]);
    });

    test('tratti incompleti: scartati', () async {
      final client = MockClient(
        (_) async => http.Response(
          _osrmBody([
            [600, 480],
          ]),
          200,
        ),
      );
      final res = await RoutingService(
        client: client,
      ).route(_zigzag.take(3).toList(), RouteTravelMode.walk);
      expect(res!.legs, isEmpty);
    });
  });

  group('RoutePlanner', () {
    test('offline: stima tratto per tratto, ritorno compreso', () async {
      final client = MockClient((_) async => http.Response('boom', 500));
      final res = await RoutePlanner(
        RoutingService(client: client),
      ).plan(_zigzag, RouteTravelMode.walk, returnToStart: true);
      expect(res.source, DistanceSource.straightLine);
      expect(res.legs, hasLength(4));
      expect(
        res.legs.fold(0.0, (a, l) => a + l.durationSeconds),
        closeTo(res.durationSeconds, 0.01),
      );
    });

    test('online senza tratti: totali della strada, tratti stimati', () async {
      final client = MockClient(
        (_) async => http.Response(_osrmBody(const []), 200),
      );
      final res = await RoutePlanner(
        RoutingService(client: client),
      ).plan(_zigzag.take(3).toList(), RouteTravelMode.walk);
      expect(res.source, DistanceSource.onlineRouting);
      expect(res.legs, hasLength(2));
    });
  });
}
