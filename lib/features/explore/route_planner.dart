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
    if (online != null) return online;
    final est = estimateTravel(
      orderedPoints: orderedPoints,
      mode: mode,
      returnToStart: returnToStart,
    );
    return RouteResult(
      geometry: waypoints,
      distanceMeters: est.distanceMeters,
      durationSeconds: est.durationSeconds,
      source: DistanceSource.straightLine,
      effectiveMode: mode,
    );
  }
}
