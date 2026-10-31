import 'dart:convert';

import 'package:flutter/material.dart';

import '../../core/enums.dart';
import '../../data/database.dart';
import '../../ui/itinera_theme.dart';
import '../../ui/posters.dart';

/// Il viaggio da mostrare nel widget: quello in corso, altrimenti il prossimo.
/// I viaggi senza date o gia' conclusi non si propongono.
Trip? pickWidgetTrip(List<Trip> trips, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  DateTime day(DateTime d) => DateTime(d.year, d.month, d.day);
  Trip? best;
  for (final t in trips) {
    final s = t.startDate;
    if (s == null) continue;
    final end = day(t.endDate ?? s);
    if (end.isBefore(today)) continue;
    if (best == null || s.isBefore(best.startDate!)) best = t;
  }
  return best;
}

/// Tutto quello che serve al widget nativo. Il conto dei giorni lo fa il widget
/// stesso, cosi' resta giusto anche se l'app non viene aperta.
class WidgetSnapshot {
  const WidgetSnapshot({
    required this.tripId,
    required this.name,
    required this.type,
    required this.start,
    required this.end,
    required this.packed,
    required this.total,
    required this.agenda,
  });

  final String tripId;
  final String name;
  final TripType type;
  final DateTime start;
  final DateTime end;
  final int packed;
  final int total;

  /// Per giorno ('2026-10-23'): righe [orario, titolo] in ordine.
  final Map<String, List<List<String>>> agenda;

  static String dayKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  static String _hex(Color c) =>
      '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

  /// Il titolo grande: giallo sui cieli scuri, come il resto del testo sui
  /// cieli chiari.
  static Color headlineColor(TripType type) {
    final fg = type.posterColors.foreground;
    return fg == Colors.white ? Cartolina.sole : fg;
  }

  /// Dati salvati per il widget (solo stringhe, le legge Kotlin).
  Map<String, String> toData() {
    final c = type.posterColors;
    return {
      'trip_id': tripId,
      'trip_name': name,
      'trip_type': type.name,
      'trip_start': dayKey(start),
      'trip_end': dayKey(end),
      'packing': total == 0 ? '' : 'valigia $packed/$total',
      'color_bg': _hex(c.background),
      'color_fg': _hex(c.foreground),
      'color_headline': _hex(headlineColor(type)),
      'color_lower': _hex(c.lowerForeground),
      'agenda': jsonEncode(agenda),
    };
  }

  /// Costruisce l'istantanea dai dati del viaggio.
  static WidgetSnapshot from({
    required Trip trip,
    required List<PackingItem> items,
    required List<ItineraryDay> days,
    required List<Activity> activities,
  }) {
    final start = trip.startDate!;
    final dateOf = {
      for (final d in days)
        if (d.date != null) d.id: d.date!,
    };
    final sorted =
        [
          for (final a in activities)
            if (dateOf.containsKey(a.dayId) &&
                a.status != ActivityStatus.skipped &&
                a.status != ActivityStatus.cancelled)
              a,
        ]..sort(
          (a, b) =>
              (a.startMinutes ?? 24 * 60).compareTo(b.startMinutes ?? 24 * 60),
        );
    final agenda = <String, List<List<String>>>{};
    for (final a in sorted) {
      final m = a.startMinutes;
      final time = m == null
          ? ''
          : '${(m ~/ 60).toString().padLeft(2, '0')}:'
                '${(m % 60).toString().padLeft(2, '0')}';
      (agenda[dayKey(dateOf[a.dayId]!)] ??= []).add([time, a.title]);
    }
    return WidgetSnapshot(
      tripId: trip.id,
      name: trip.name,
      type: trip.tripType,
      start: start,
      end: trip.endDate ?? start,
      packed: items
          .where((i) => i.quantity > 0 && i.packedCount >= i.quantity)
          .length,
      total: items.length,
      agenda: agenda,
    );
  }
}
