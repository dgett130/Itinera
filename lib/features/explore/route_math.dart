import 'package:latlong2/latlong.dart';

import '../../core/calc/distance.dart' as calc;
import '../../core/enums.dart';

/// Matematica PURA dei percorsi di visita: matrice delle distanze (Haversine),
/// ottimizzazione dell'ordine (nearest-neighbor + 2-opt) e stime di
/// percorrenza per mezzo. Nessuna dipendenza da Flutter o dalla rete:
/// interamente testabile e deterministica.

/// Distanza in metri tra due coordinate (Haversine). Delegata a [Distance]
/// per non duplicare la formula.
double haversineMeters(LatLng a, LatLng b) =>
    calc.Distance.haversineKm(
      a.latitude,
      a.longitude,
      b.latitude,
      b.longitude,
    ) *
    1000.0;

/// Matrice simmetrica delle distanze in metri.
List<List<double>> distanceMatrixMeters(List<LatLng> pts) {
  final n = pts.length;
  final m = List.generate(n, (_) => List<double>.filled(n, 0));
  for (var i = 0; i < n; i++) {
    for (var j = i + 1; j < n; j++) {
      final d = haversineMeters(pts[i], pts[j]);
      m[i][j] = d;
      m[j][i] = d;
    }
  }
  return m;
}

/// Lunghezza del percorso (metri) seguendo [order]. Se [returnToStart] chiude
/// l'anello aggiungendo il ritorno alla prima tappa.
double pathLengthMeters(
  List<int> order,
  List<List<double>> d, {
  bool returnToStart = false,
}) {
  if (order.length < 2) return 0;
  var total = 0.0;
  for (var i = 0; i < order.length - 1; i++) {
    total += d[order[i]][order[i + 1]];
  }
  if (returnToStart) total += d[order.last][order.first];
  return total;
}

/// Esito dell'ottimizzazione: permutazione degli indici e lunghezza (Haversine).
class OptimizedOrder {
  const OptimizedOrder(this.order, this.lengthMeters);
  final List<int> order;
  final double lengthMeters;
}

/// Ottimizza l'ordine delle tappe in modo DETERMINISTICO. Rispetta partenza
/// fissa ([fixedStart] = indice 0 bloccato) ed eventuale arrivo fisso
/// ([fixedEnd] = ultimo indice bloccato); [returnToStart] valuta l'anello.
///
/// Strategia: 2-opt seminato sia dall'ordine iniziale sia da un giro
/// nearest-neighbor; si sceglie il piu' corto. Poiche' il 2-opt sull'ordine
/// iniziale accetta solo scambi migliorativi, il risultato NON e' mai piu'
/// lungo dell'ordine di partenza secondo la matrice usata. Oltre [maxStops]
/// tappe l'ordine resta invariato (costo/comprensibilita').
OptimizedOrder optimizeRouteOrder({
  required List<LatLng> points,
  bool fixedStart = false,
  bool fixedEnd = false,
  bool returnToStart = false,
  int maxStops = 25,
}) {
  final n = points.length;
  final identity = List<int>.generate(n, (i) => i);
  if (n < 2) return OptimizedOrder(identity, 0);
  final d = distanceMatrixMeters(points);
  final identityLen = pathLengthMeters(
    identity,
    d,
    returnToStart: returnToStart,
  );
  if (n > maxStops) return OptimizedOrder(identity, identityLen);

  final fromIdentity = _twoOpt(
    identity,
    d,
    fixedEnd: fixedEnd,
    returnToStart: returnToStart,
  );
  final nn = _nearestNeighbor(d, n, fixedEnd: fixedEnd);
  final fromNN = _twoOpt(
    nn,
    d,
    fixedEnd: fixedEnd,
    returnToStart: returnToStart,
  );

  final lenId = pathLengthMeters(fromIdentity, d, returnToStart: returnToStart);
  final lenNN = pathLengthMeters(fromNN, d, returnToStart: returnToStart);
  if (lenNN + 1e-6 < lenId) return OptimizedOrder(fromNN, lenNN);
  return OptimizedOrder(fromIdentity, lenId);
}

/// Giro nearest-neighbor partendo dall'indice 0 (deterministico). Se
/// [fixedEnd] l'ultimo indice e' riservato come arrivo.
List<int> _nearestNeighbor(
  List<List<double>> d,
  int n, {
  required bool fixedEnd,
}) {
  final visited = List<bool>.filled(n, false);
  final order = <int>[0];
  visited[0] = true;
  final endIndex = fixedEnd ? n - 1 : -1;
  if (fixedEnd && endIndex != 0) visited[endIndex] = true;
  final target = fixedEnd ? n - 1 : n;
  while (order.length < target) {
    final last = order.last;
    var best = -1;
    var bestD = double.infinity;
    for (var j = 0; j < n; j++) {
      if (visited[j]) continue;
      if (d[last][j] < bestD) {
        bestD = d[last][j];
        best = j;
      }
    }
    if (best < 0) break;
    order.add(best);
    visited[best] = true;
  }
  if (fixedEnd && endIndex != 0) order.add(endIndex);
  return order;
}

/// 2-opt: inverte ripetutamente i segmenti interni finche' migliorano. La
/// posizione 0 resta sempre l'ancora di partenza; con [fixedEnd] anche
/// l'ultima posizione e' bloccata.
List<int> _twoOpt(
  List<int> order,
  List<List<double>> d, {
  required bool fixedEnd,
  required bool returnToStart,
}) {
  final n = order.length;
  if (n < 4) return [...order];
  var best = [...order];
  var bestLen = pathLengthMeters(best, d, returnToStart: returnToStart);
  final hi = fixedEnd ? n - 2 : n - 1;
  var improved = true;
  while (improved) {
    improved = false;
    for (var i = 1; i <= hi - 1; i++) {
      for (var k = i + 1; k <= hi; k++) {
        final cand = [...best];
        _reverse(cand, i, k);
        final len = pathLengthMeters(cand, d, returnToStart: returnToStart);
        if (len + 1e-6 < bestLen) {
          best = cand;
          bestLen = len;
          improved = true;
        }
      }
    }
  }
  return best;
}

void _reverse(List<int> a, int i, int k) {
  while (i < k) {
    final t = a[i];
    a[i] = a[k];
    a[k] = t;
    i++;
    k--;
  }
}

// --- Stime di percorrenza per mezzo (offline) ------------------------------

/// Profilo di stima di un mezzo: velocita' media e fattore di deviazione
/// (linea d'aria -> percorso reale). Valori documentati e usati SOLO quando il
/// routing stradale online non e' disponibile.
class TravelModeProfile {
  const TravelModeProfile(this.speedKmh, this.detourFactor);
  final double speedKmh;
  final double detourFactor;
}

const Map<RouteTravelMode, TravelModeProfile> travelModeProfiles = {
  RouteTravelMode.walk: TravelModeProfile(4.8, 1.25),
  RouteTravelMode.bike: TravelModeProfile(15.0, 1.30),
  RouteTravelMode.car: TravelModeProfile(40.0, 1.40),
};

/// Distanza e durata stimate (linea d'aria x fattore, poi / velocita').
class TravelEstimate {
  const TravelEstimate(this.distanceMeters, this.durationSeconds);
  final double distanceMeters;
  final double durationSeconds;
}

TravelEstimate estimateTravel({
  required List<LatLng> orderedPoints,
  required RouteTravelMode mode,
  bool returnToStart = false,
}) {
  final profile =
      travelModeProfiles[mode] ?? travelModeProfiles[RouteTravelMode.walk]!;
  var straight = 0.0;
  for (var i = 0; i < orderedPoints.length - 1; i++) {
    straight += haversineMeters(orderedPoints[i], orderedPoints[i + 1]);
  }
  if (returnToStart && orderedPoints.length > 1) {
    straight += haversineMeters(orderedPoints.last, orderedPoints.first);
  }
  final distance = straight * profile.detourFactor;
  final speedMs = profile.speedKmh * 1000 / 3600;
  final duration = speedMs > 0 ? distance / speedMs : 0.0;
  return TravelEstimate(distance, duration);
}

/// Stima tratto per tratto tra punti consecutivi di [waypoints].
List<TravelEstimate> estimateLegs({
  required List<LatLng> waypoints,
  required RouteTravelMode mode,
}) => [
  for (var i = 0; i < waypoints.length - 1; i++)
    estimateTravel(orderedPoints: [waypoints[i], waypoints[i + 1]], mode: mode),
];

// --- Suggerimento "ordine più veloce" --------------------------------------

/// Un ordine migliore di quello attuale, con il risparmio stimato.
class OrderSuggestion {
  const OrderSuggestion(this.order, this.savedSeconds);

  /// Permutazione degli indici dei punti.
  final List<int> order;

  /// Tempo di spostamento risparmiato (stima con il profilo del mezzo).
  final double savedSeconds;
}

/// Propone un ordine più veloce di quello attuale solo se conviene davvero:
/// almeno [minSavedSeconds] e almeno [minSavedRatio] del tragitto. Con meno di
/// 3 tappe non c'e' niente da riordinare. Rispetta partenza fissa e anello.
OrderSuggestion? suggestFasterOrder({
  required List<LatLng> points,
  required RouteTravelMode mode,
  bool fixedStart = false,
  bool returnToStart = false,
  double minSavedSeconds = 120,
  double minSavedRatio = 0.05,
}) {
  if (points.length < 3) return null;
  final d = distanceMatrixMeters(points);
  final identity = List<int>.generate(points.length, (i) => i);
  final current = pathLengthMeters(identity, d, returnToStart: returnToStart);
  var opt = optimizeRouteOrder(
    points: points,
    fixedStart: true,
    returnToStart: returnToStart,
  );
  if (!fixedStart && !returnToStart) {
    // Senza partenza fissa anche la prima tappa puo' cambiare: provo ogni
    // punto come inizio e tengo il giro piu' corto.
    for (var s = 1; s < points.length; s++) {
      final rotated = [s, ...identity.where((i) => i != s)];
      final o = optimizeRouteOrder(
        points: [for (final i in rotated) points[i]],
        fixedStart: true,
      );
      if (o.lengthMeters + 1e-6 < opt.lengthMeters) {
        opt = OptimizedOrder([
          for (final i in o.order) rotated[i],
        ], o.lengthMeters);
      }
    }
  }
  final savedMeters = current - opt.lengthMeters;
  if (savedMeters <= 0 || current <= 0) return null;
  final profile =
      travelModeProfiles[mode] ?? travelModeProfiles[RouteTravelMode.walk]!;
  final speedMs = profile.speedKmh * 1000 / 3600;
  final savedSeconds = savedMeters * profile.detourFactor / speedMs;
  if (savedSeconds < minSavedSeconds) return null;
  if (savedMeters / current < minSavedRatio) return null;
  return OrderSuggestion(opt.order, savedSeconds);
}
