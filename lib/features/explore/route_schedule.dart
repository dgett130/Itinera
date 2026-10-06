import '../../core/enums.dart';
import '../../core/visit_duration.dart';
import '../transport/routing_service.dart';

/// Scaletta PURA di un percorso: dai tratti tra le tappe e dalle durate di
/// visita ricava arrivi, uscite, fine e totali. Tempi in secondi dalla
/// partenza; l'orario si ottiene con [RouteSchedule.clock].

/// Durata di visita effettiva: quella scelta, altrimenti la predefinita per
/// categoria (0 = solo partenza/passaggio).
int effectiveVisitMinutes(int? chosen, PoiCategory? category) =>
    chosen ?? defaultVisitMinutes(category);

/// Una tappa vista dalla scaletta.
class ScheduleStop {
  const ScheduleStop({required this.hasCoords, required this.visitMinutes});

  /// Senza posizione la tappa non ha tratti: si visita "sul posto".
  final bool hasCoords;
  final int visitMinutes;
}

class StopTiming {
  const StopTiming(this.arriveSeconds, this.leaveSeconds, this.legBefore);
  final int arriveSeconds;
  final int leaveSeconds;

  /// Tratto percorso per arrivare qui (null per la prima tappa e per quelle
  /// senza posizione).
  final RouteLeg? legBefore;
}

class RouteSchedule {
  const RouteSchedule({
    required this.stops,
    required this.returnLeg,
    required this.endSeconds,
    required this.visitSeconds,
    required this.travelSeconds,
    required this.distanceMeters,
  });

  final List<StopTiming> stops;

  /// Ritorno alla prima tappa, se previsto.
  final RouteLeg? returnLeg;
  final int endSeconds;
  final int visitSeconds;
  final int travelSeconds;
  final double distanceMeters;

  /// Orario (minuti dalla mezzanotte) a [seconds] dalla partenza delle
  /// [startMinutes].
  static int clock(int startMinutes, int seconds) =>
      startMinutes + (seconds / 60).round();
}

/// Scaletta delle [stops] (nell'ordine del percorso) con i [legs] salvati.
/// Null se i tratti non corrispondono alle tappe (calcolo in corso o da
/// rifare): meglio nessun orario che orari sbagliati.
RouteSchedule? buildSchedule({
  required List<ScheduleStop> stops,
  required List<RouteLeg> legs,
  bool returnToStart = false,
}) {
  final coords = stops.where((s) => s.hasCoords).length;
  final expected = coords < 2 ? 0 : coords - 1 + (returnToStart ? 1 : 0);
  if (legs.length != expected) return null;

  var t = 0.0;
  var travel = 0.0;
  var visit = 0;
  var distance = 0.0;
  var next = 0;
  var seenCoords = false;
  final timings = <StopTiming>[];
  for (final s in stops) {
    RouteLeg? before;
    if (s.hasCoords) {
      if (seenCoords) {
        before = legs[next++];
        t += before.durationSeconds;
        travel += before.durationSeconds;
        distance += before.distanceMeters;
      }
      seenCoords = true;
    }
    final arrive = t.round();
    t += s.visitMinutes * 60;
    visit += s.visitMinutes * 60;
    timings.add(StopTiming(arrive, t.round(), before));
  }
  RouteLeg? back;
  if (returnToStart && expected > 0) {
    back = legs[next];
    t += back.durationSeconds;
    travel += back.durationSeconds;
    distance += back.distanceMeters;
  }
  return RouteSchedule(
    stops: timings,
    returnLeg: back,
    endSeconds: t.round(),
    visitSeconds: visit,
    travelSeconds: travel.round(),
    distanceMeters: distance,
  );
}
