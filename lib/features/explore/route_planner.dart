import 'package:latlong2/latlong.dart';

import '../../core/enums.dart';
import '../transport/routing_service.dart';
import 'route_math.dart';

/// Pianifica il calcolo di un percorso: usa il routing stradale reale quando
/// disponibile (auto), altrimenti ripiega su una stima chiaramente etichettata
/// (piedi/bici, o offline). Ritorna sempre un [RouteResult].
class RoutePlanner {
  RoutePlanner(this._routing);
  final RoutingService _routing;

  Future<RouteResult> plan(
    List<LatLng> orderedPoints,
    RouteTravelMode mode, {
    bool returnToStart = false,
  }) async {
    if (orderedPoints.length < 2) {
      return RouteResult(
        geometry: orderedPoints,
        distanceMeters: 0,
        durationSeconds: 0,
        source: DistanceSource.straightLine,
        effectiveMode: mode,
      );
    }
    final waypoints = <LatLng>[
      ...orderedPoints,
      if (returnToStart) orderedPoints.first,
    ];
    final online = await _routing.route(waypoints, mode);
    if (online != null && online.legs.isNotEmpty) return online;
    // Senza tratti dal provider, stima tratto per tratto (la somma coincide
    // con la stima dell'intero percorso).
    final legs = [
      for (final e in estimateLegs(waypoints: waypoints, mode: mode))
        RouteLeg(e.distanceMeters, e.durationSeconds),
    ];
    if (online != null) {
      return RouteResult(
        geometry: online.geometry,
        distanceMeters: online.distanceMeters,
        durationSeconds: online.durationSeconds,
        source: online.source,
        effectiveMode: online.effectiveMode,
        legs: legs,
      );
    }
    return RouteResult(
      geometry: waypoints,
      distanceMeters: legs.fold(0.0, (a, l) => a + l.distanceMeters),
      durationSeconds: legs.fold(0.0, (a, l) => a + l.durationSeconds),
      source: DistanceSource.straightLine,
      effectiveMode: mode,
      legs: legs,
    );
  }
}
