import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:itinera/features/explore/poi_discovery_service.dart';
import 'package:itinera/features/places/geocoding_service.dart';

void main() {
  final validBody = jsonEncode({
    'elements': [
      {
        'type': 'node',
        'id': 1,
        'lat': 45.0,
        'lon': 7.0,
        'tags': {'name': 'Museo', 'tourism': 'museum'},
      },
      {
        'type': 'way',
        'id': 2,
        'center': {'lat': 45.1, 'lon': 7.1},
        'tags': {'name': 'Parco', 'leisure': 'park'},
      },
    ],
  });

  test('risposta valida -> POI parsati e ordinati per distanza', () async {
    final client = MockClient((req) async => http.Response(validBody, 200));
    final svc = OverpassPoiService(client: client);
    final pois = await svc.search(lat: 45.0, lng: 7.0, radiusMeters: 5000);
    expect(pois.length, 2);
    // Il museo (coincidente col centro) e' il piu' vicino.
    expect(pois.first.externalId, 'node/1');
  });

  test('HTTP non-200 -> PoiDiscoveryException', () async {
    final client = MockClient((req) async => http.Response('boom', 500));
    final svc = OverpassPoiService(client: client);
    await expectLater(
      svc.search(lat: 45, lng: 7, radiusMeters: 5000),
      throwsA(isA<PoiDiscoveryException>()),
    );
  });

  test('corpo non JSON -> PoiDiscoveryException', () async {
    final client = MockClient((req) async => http.Response('<html>', 200));
    final svc = OverpassPoiService(client: client);
    await expectLater(
      svc.search(lat: 45, lng: 7, radiusMeters: 5000),
      throwsA(isA<PoiDiscoveryException>()),
    );
  });

  test('timeout -> PoiDiscoveryException', () async {
    final client = MockClient((req) async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      return http.Response(validBody, 200);
    });
    final svc = OverpassPoiService(
      client: client,
      timeout: const Duration(milliseconds: 1),
    );
    await expectLater(
      svc.search(lat: 45, lng: 7, radiusMeters: 5000),
      throwsA(isA<PoiDiscoveryException>()),
    );
  });

  group('lookup di un singolo luogo OSM', () {
    String osmBody(String type, Map<String, String> tags) => jsonEncode({
      'elements': [
        {'type': type, 'id': 77, 'tags': tags},
      ],
    });

    test('dati completi dall\'API OSM; coordinate da chi chiama', () async {
      Uri? asked;
      final client = MockClient((req) async {
        asked = req.url;
        return http.Response(
          osmBody('way', {
            'name': 'Galleria Borghese',
            'tourism': 'museum',
            'opening_hours': 'Tu-Su 09:00-19:00',
            'fee': 'yes',
            'wikidata': 'Q841506',
          }),
          200,
        );
      });
      final poi = await OverpassPoiService(
        client: client,
      ).lookup('way', 77, lat: 41.914, lng: 12.492);
      expect(asked?.path, endsWith('/way/77.json'));
      expect(poi!.externalId, 'way/77');
      expect(poi.lat, 41.914);
      expect(poi.lng, 12.492);
      expect(poi.openingHours, 'Tu-Su 09:00-19:00');
      expect(poi.fee, 'yes');
      expect(poi.wikidata, 'Q841506');
    });

    test(
      'luogo non turistico, non trovato, errore, rete assente o tipo strano: '
      'null',
      () async {
        Future<Object?> run(
          Future<http.Response> Function(http.Request) h, [
          String type = 'node',
        ]) => OverpassPoiService(
          client: MockClient(h),
          retryDelay: Duration.zero,
        ).lookup(type, 1, lat: 1, lng: 1);
        final street = osmBody('node', {
          'name': 'Via Roma',
          'highway': 'residential',
        });
        expect(await run((_) async => http.Response(street, 200)), isNull);
        expect(await run((_) async => http.Response('', 404)), isNull);
        expect(await run((_) async => http.Response('boom', 500)), isNull);
        expect(await run((_) async => throw Exception('offline')), isNull);
        expect(await run((_) async => http.Response('', 200), 'area'), isNull);
      },
    );

    test('un errore momentaneo: il secondo tentativo va', () async {
      var calls = 0;
      final client = MockClient((_) async {
        calls++;
        if (calls == 1) return http.Response('troppe richieste', 429);
        return http.Response(
          osmBody('node', {'name': 'Museo', 'tourism': 'museum'}),
          200,
        );
      });
      final poi = await OverpassPoiService(
        client: client,
        retryDelay: Duration.zero,
      ).lookup('node', 77, lat: 41.9, lng: 12.5);
      expect(poi?.name, 'Museo');
      expect(calls, 2);
    });
  });

  test('Photon: il risultato porta tipo e id OpenStreetMap', () async {
    final client = MockClient(
      (_) async => http.Response(
        jsonEncode({
          'features': [
            {
              'geometry': {
                'coordinates': [12.49, 41.91],
              },
              'properties': {
                'name': 'Galleria Borghese',
                'city': 'Roma',
                'country': 'Italia',
                'osm_type': 'W',
                'osm_id': 77,
              },
            },
            {
              'geometry': {
                'coordinates': [12.5, 41.9],
              },
              'properties': {'name': 'Senza id'},
            },
          ],
        }),
        200,
      ),
    );
    final results = await GeocodingService(client: client).search('Borghese');
    expect(results.first.osmType, 'way');
    expect(results.first.osmId, 77);
    expect(results.last.osmType, isNull);
    expect(results.last.osmId, isNull);
  });
}
