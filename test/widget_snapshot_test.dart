import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:itinera/core/enums.dart';
import 'package:itinera/data/database.dart';
import 'package:itinera/features/homewidget/home_widget_sync.dart';
import 'package:itinera/features/homewidget/widget_snapshot.dart';

Trip _trip(String id, DateTime? start, DateTime? end) {
  final json = <String, dynamic>{
    'id': id,
    'name': 'Viaggio $id',
    'startDate': start?.millisecondsSinceEpoch,
    'endDate': end?.millisecondsSinceEpoch,
    'tripType': TripType.sea.name,
    'climate': Climate.values.first.name,
    'travelerCount': 1,
    'homeCurrency': 'EUR',
    'createdAt': 0,
    'updatedAt': 0,
  };
  return Trip.fromJson(json);
}

void main() {
  final now = DateTime(2026, 10, 31, 15);

  group('viaggio del widget', () {
    test('preferisce quello in corso al prossimo', () {
      final picked = pickWidgetTrip([
        _trip('futuro', DateTime(2026, 11, 5), DateTime(2026, 11, 9)),
        _trip('corso', DateTime(2026, 10, 30), DateTime(2026, 11, 2)),
      ], now);
      expect(picked?.id, 'corso');
    });

    test("l'ultimo giorno conta ancora come in corso", () {
      final picked = pickWidgetTrip([
        _trip('oggi', DateTime(2026, 10, 28), DateTime(2026, 10, 31)),
      ], now);
      expect(picked?.id, 'oggi');
    });

    test('ignora i conclusi e quelli senza date', () {
      final picked = pickWidgetTrip([
        _trip('finito', DateTime(2026, 9, 1), DateTime(2026, 9, 5)),
        _trip('senza', null, null),
      ], now);
      expect(picked, isNull);
    });

    test('tra due futuri sceglie il piu vicino', () {
      final picked = pickWidgetTrip([
        _trip('lontano', DateTime(2027, 1, 1), DateTime(2027, 1, 3)),
        _trip('vicino', DateTime(2026, 11, 1), DateTime(2026, 11, 3)),
      ], now);
      expect(picked?.id, 'vicino');
    });
  });

  group('collegamenti del widget', () {
    test('portano alla sezione giusta', () {
      expect(
        homeWidgetLinkToPath(Uri.parse('itinera-widget://trip/abc')),
        '/trip/abc',
      );
      expect(
        homeWidgetLinkToPath(Uri.parse('itinera-widget://trip/abc/packing')),
        '/trip/abc/packing',
      );
      expect(
        homeWidgetLinkToPath(Uri.parse('itinera-widget://trip/abc/itinerary')),
        '/trip/abc/itinerary',
      );
    });

    test('ignorano tutto il resto', () {
      expect(homeWidgetLinkToPath(null), isNull);
      expect(homeWidgetLinkToPath(Uri.parse('itinera-widget://home')), isNull);
      expect(homeWidgetLinkToPath(Uri.parse('https://trip/abc')), isNull);
    });
  });

  test('i dati per il widget hanno date e agenda leggibili', () {
    final snap = WidgetSnapshot(
      tripId: 'x',
      name: 'Sardegna',
      type: TripType.sea,
      start: DateTime(2026, 10, 3),
      end: DateTime(2026, 10, 8),
      packed: 23,
      total: 40,
      agenda: {
        '2026-10-03': [
          ['09:00', 'Spiaggia'],
        ],
      },
    );
    final data = snap.toData();
    expect(data['trip_start'], '2026-10-03');
    expect(data['packing'], 'valigia 23/40');
    expect(data['color_headline'], '#ffc21a');
    expect(jsonDecode(data['agenda']!)['2026-10-03'][0][1], 'Spiaggia');
  });
}
