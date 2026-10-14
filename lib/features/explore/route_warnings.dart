import 'dart:convert';

import '../../core/enums.dart';
import 'opening_hours.dart';
import 'route_schedule.dart';

/// Avvisi PURI su un percorso pianificato: luoghi chiusi all'arrivo,
/// giornata lunga o che finisce tardi, tanta strada a piedi o in bici.
/// Le soglie sono preferenze del dispositivo ([WarningSettings]).

/// Quali avvisi mostrare e con quali soglie (preferenza locale, non
/// sincronizzata). I default sono quelli concordati nella specifica.
class WarningSettings {
  const WarningSettings({
    this.hours = true,
    this.lateEnd = true,
    this.lateEndMinutes = 20 * 60,
    this.longDay = true,
    this.longDayMinutes = 9 * 60,
    this.walk = true,
    this.walkKm = 15,
    this.bike = true,
    this.bikeKm = 40,
  });

  final bool hours;
  final bool lateEnd;
  final int lateEndMinutes;
  final bool longDay;
  final int longDayMinutes;
  final bool walk;
  final int walkKm;
  final bool bike;
  final int bikeKm;

  WarningSettings copyWith({
    bool? hours,
    bool? lateEnd,
    int? lateEndMinutes,
    bool? longDay,
    int? longDayMinutes,
    bool? walk,
    int? walkKm,
    bool? bike,
    int? bikeKm,
  }) => WarningSettings(
    hours: hours ?? this.hours,
    lateEnd: lateEnd ?? this.lateEnd,
    lateEndMinutes: lateEndMinutes ?? this.lateEndMinutes,
    longDay: longDay ?? this.longDay,
    longDayMinutes: longDayMinutes ?? this.longDayMinutes,
    walk: walk ?? this.walk,
    walkKm: walkKm ?? this.walkKm,
    bike: bike ?? this.bike,
    bikeKm: bikeKm ?? this.bikeKm,
  );

  String encode() => jsonEncode({
    'hours': hours,
    'lateEnd': lateEnd,
    'lateEndMinutes': lateEndMinutes,
    'longDay': longDay,
    'longDayMinutes': longDayMinutes,
    'walk': walk,
    'walkKm': walkKm,
    'bike': bike,
    'bikeKm': bikeKm,
  });

  /// Valori mancanti o rovinati tornano ai default.
  static WarningSettings decode(String? raw) {
    const d = WarningSettings();
    if (raw == null || raw.isEmpty) return d;
    try {
      final j = jsonDecode(raw);
      if (j is! Map) return d;
      bool b(String k, bool v) => j[k] is bool ? j[k] as bool : v;
      int i(String k, int v) => j[k] is int ? j[k] as int : v;
      return WarningSettings(
        hours: b('hours', d.hours),
        lateEnd: b('lateEnd', d.lateEnd),
        lateEndMinutes: i('lateEndMinutes', d.lateEndMinutes),
        longDay: b('longDay', d.longDay),
        longDayMinutes: i('longDayMinutes', d.longDayMinutes),
        walk: b('walk', d.walk),
        walkKm: i('walkKm', d.walkKm),
        bike: b('bike', d.bike),
        bikeKm: i('bikeKm', d.bikeKm),
      );
    } catch (_) {
      return d;
    }
  }
}

enum WarningKind {
  /// Il luogo è chiuso tutto il giorno.
  closedDay,

  /// Chiuso all'arrivo, apre più tardi ([a] = apertura, [b] = arrivo).
  opensLater,

  /// Già chiuso all'arrivo ([a] = chiusura, [b] = arrivo).
  closedEarlier,

  /// Chiude prima della fine della visita ([a] = chiusura).
  closesDuringVisit,

  /// La giornata finisce dopo la soglia ([a] = orario di fine).
  lateEnd,

  /// La giornata dura più della soglia ([a] = minuti totali).
  longDay,

  /// Tanta strada a piedi / in bici ([a] = metri).
  farWalk,
  farBike,
}

class RouteWarning {
  const RouteWarning(this.kind, {this.stopIndex, this.a, this.b});
  final WarningKind kind;

  /// Tappa interessata (null per gli avvisi sulla giornata).
  final int? stopIndex;
  final int? a;
  final int? b;
}

/// Avvisi per la scaletta [schedule]. [openingHours] è allineato alle tappe
/// (orari OSM grezzi); [weekday] (1 = lunedì) serve agli orari ed è null se
/// il giorno non ha una data. Senza [startMinutes] niente controlli d'orario.
List<RouteWarning> routeWarnings({
  required RouteSchedule schedule,
  required List<String?> openingHours,
  required List<int> visitMinutes,
  required RouteTravelMode mode,
  required WarningSettings settings,
  int? startMinutes,
  int? weekday,
}) {
  final out = <RouteWarning>[];
  final start = startMinutes;
  if (settings.hours && start != null && weekday != null) {
    for (var i = 0; i < schedule.stops.length; i++) {
      // Solo partenza o passaggio: nessuna visita, nessun orario da rispettare.
      if (i >= visitMinutes.length || visitMinutes[i] == 0) continue;
      final oh = OpeningHours.parse(
        i < openingHours.length ? openingHours[i] : null,
      );
      if (oh == null) continue;
      final t = schedule.stops[i];
      var arrive = RouteSchedule.clock(start, t.arriveSeconds);
      var leave = RouteSchedule.clock(start, t.leaveSeconds);
      var wd = weekday;
      // Arrivo dopo la mezzanotte: conta il giorno dopo.
      while (arrive >= 1440) {
        arrive -= 1440;
        leave -= 1440;
        wd = wd == 7 ? 1 : wd + 1;
      }
      if (oh.closedAllDay(wd)) {
        out.add(RouteWarning(WarningKind.closedDay, stopIndex: i));
      } else if (!oh.isOpen(wd, arrive)) {
        final opens = oh.opensAfter(wd, arrive);
        final closed = oh.closedBefore(wd, arrive);
        if (opens != null) {
          out.add(
            RouteWarning(
              WarningKind.opensLater,
              stopIndex: i,
              a: opens,
              b: arrive,
            ),
          );
        } else {
          out.add(
            RouteWarning(
              WarningKind.closedEarlier,
              stopIndex: i,
              a: closed,
              b: arrive,
            ),
          );
        }
      } else {
        final closes = oh.closesAt(wd, arrive);
        if (closes != null && closes < leave) {
          out.add(
            RouteWarning(
              WarningKind.closesDuringVisit,
              stopIndex: i,
              a: closes,
            ),
          );
        }
      }
    }
  }
  if (settings.lateEnd && start != null) {
    final end = RouteSchedule.clock(start, schedule.endSeconds);
    if (end > settings.lateEndMinutes) {
      out.add(RouteWarning(WarningKind.lateEnd, a: end));
    }
  }
  // Minuti interi come nel totale mostrato (che tronca i secondi).
  final totalMinutes = schedule.endSeconds ~/ 60;
  if (settings.longDay && totalMinutes > settings.longDayMinutes) {
    out.add(RouteWarning(WarningKind.longDay, a: totalMinutes));
  }
  final meters = schedule.distanceMeters.round();
  if (mode == RouteTravelMode.walk &&
      settings.walk &&
      meters > settings.walkKm * 1000) {
    out.add(RouteWarning(WarningKind.farWalk, a: meters));
  }
  if (mode == RouteTravelMode.bike &&
      settings.bike &&
      meters > settings.bikeKm * 1000) {
    out.add(RouteWarning(WarningKind.farBike, a: meters));
  }
  return out;
}
