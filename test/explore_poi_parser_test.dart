import 'package:flutter_test/flutter_test.dart';

import 'package:itinera/core/enums.dart';
import 'package:itinera/features/explore/poi_parser.dart';

void main() {
  group('categoryForOsmTags', () {
    test('mappa i tag principali', () {
      expect(categoryForOsmTags({'tourism': 'museum'}), PoiCategory.museum);
      expect(categoryForOsmTags({'tourism': 'gallery'}), PoiCategory.museum);
      expect(
        categoryForOsmTags({'tourism': 'viewpoint'}),
        PoiCategory.viewpoint,
      );
      expect(
        categoryForOsmTags({'amenity': 'place_of_worship'}),
        PoiCategory.religious,
      );
      expect(
        categoryForOsmTags({'historic': 'monument'}),
        PoiCategory.monument,
      );
      expect(categoryForOsmTags({'historic': 'castle'}), PoiCategory.monument);
      expect(categoryForOsmTags({'leisure': 'park'}), PoiCategory.nature);
      expect(categoryForOsmTags({'natural': 'peak'}), PoiCategory.nature);
      expect(
        categoryForOsmTags({'tourism': 'attraction'}),
        PoiCategory.attraction,
      );
    });

    test('scarta i tag non turistici', () {
      expect(categoryForOsmTags({'amenity': 'bar'}), isNull);
      expect(categoryForOsmTags({'shop': 'bakery'}), isNull);
      expect(categoryForOsmTags(const {}), isNull);
    });
  });

  group('parseOverpass', () {
    final fixture = {
      'elements': [
        {
          'type': 'node',
          'id': 1,
          'lat': 45.0,
          'lon': 7.0,
          'tags': {'name': 'Museo Egizio', 'tourism': 'museum'},
        },
        {
          'type': 'way',
          'id': 2,
          'center': {'lat': 45.1, 'lon': 7.1},
          'tags': {
            'name:it': 'Parco del Valentino',
            'name': 'Valentino Park',
            'leisure': 'park',
          },
        },
        {
          'type': 'relation',
          'id': 3,
          'center': {'lat': 45.2, 'lon': 7.2},
          'tags': {'name': 'Mole', 'historic': 'monument'},
        },
        // Non turistico -> scartato.
        {
          'type': 'node',
          'id': 4,
          'lat': 45.3,
          'lon': 7.3,
          'tags': {'name': 'Bar Sport', 'amenity': 'bar'},
        },
        // Senza nome -> scartato.
        {
          'type': 'node',
          'id': 5,
          'lat': 45.4,
          'lon': 7.4,
          'tags': {'tourism': 'museum'},
        },
        // Senza coordinate -> scartato.
        {
          'type': 'node',
          'id': 6,
          'tags': {'name': 'Fantasma', 'tourism': 'museum'},
        },
        'spazzatura',
        {'type': 'node'},
      ],
    };

    test('parsa node, way e relation validi', () {
      final pois = parseOverpass(fixture);
      expect(pois.length, 3);
      expect(
        pois.map((p) => p.externalId),
        containsAll(['node/1', 'way/2', 'relation/3']),
      );
    });

    test('preferisce name:it e ricava il centro per le geometrie', () {
      final way = parseOverpass(
        fixture,
      ).firstWhere((p) => p.externalId == 'way/2');
      expect(way.name, 'Parco del Valentino');
      expect(way.lat, 45.1);
      expect(way.category, PoiCategory.nature);
    });

    test('legge l\'ingresso (fee) e lo conserva nel JSON della cache', () {
      final p = parseOverpass({
        'elements': [
          {
            'type': 'node',
            'id': 9,
            'lat': 45.0,
            'lon': 7.0,
            'tags': {
              'name': 'Duomo',
              'amenity': 'place_of_worship',
              'fee': 'no',
            },
          },
        ],
      }).single;
      expect(p.fee, 'no');
      expect(PoiSuggestion.fromJson(p.toJson())!.fee, 'no');
    });

    test('risposta malformata -> lista vuota, nessun crash', () {
      expect(parseOverpass({'elements': 'nonlista'}), isEmpty);
      expect(parseOverpass(const {}), isEmpty);
      expect(parseOverpass({'elements': []}), isEmpty);
    });
  });

  group('dedupePois', () {
    PoiSuggestion poi(String id, String name, double lat, double lng) =>
        PoiSuggestion(
          provider: 'osm',
          externalId: id,
          name: name,
          lat: lat,
          lng: lng,
          category: PoiCategory.monument,
        );

    test('rimuove i duplicati per provider+externalId', () {
      final out = dedupePois([
        poi('node/1', 'Duomo', 45.0, 9.0),
        poi('node/1', 'Duomo', 45.0, 9.0),
      ]);
      expect(out.length, 1);
    });

    test('rimuove i duplicati per nome normalizzato + vicinanza', () {
      final out = dedupePois([
        poi('node/1', 'Duomo', 45.0, 9.0),
        poi('node/2', '  DUOMO ', 45.00005, 9.00005), // ~7 m
      ]);
      expect(out.length, 1);
    });

    test('mantiene omonimi lontani', () {
      final out = dedupePois([
        poi('node/1', 'Duomo', 45.0, 9.0),
        poi('node/2', 'Duomo', 43.0, 11.0),
      ]);
      expect(out.length, 2);
    });
  });
}
