import 'dart:math' as math;

/// Calcolo distanze offline (nessuna rete).
///
/// La distanza in linea d'aria (haversine) e' il fallback quando non c'e'
/// una distanza stradale online in cache: va sempre moltiplicata per un
/// [detourFactor] (>1) per approssimare il percorso reale su strada.
class Distance {
  Distance._();

  static const double earthRadiusKm = 6371.0088;

  /// Distanza in linea d'aria in km tra due coordinate (gradi decimali).
  static double haversineKm(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    final dLat = _toRad(lat2 - lat1);
    final dLng = _toRad(lng2 - lng1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(lat1)) *
            math.cos(_toRad(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  /// Stima della distanza su strada = linea d'aria x fattore percorso.
  static double roadEstimateKm(
    double lat1,
    double lng1,
    double lat2,
    double lng2, {
    double detourFactor = 1.3,
  }) {
    return haversineKm(lat1, lng1, lat2, lng2) * detourFactor;
  }

  static double _toRad(double deg) => deg * math.pi / 180.0;
}
