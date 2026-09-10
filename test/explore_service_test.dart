import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:itinera/features/explore/poi_discovery_service.dart';

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
}
