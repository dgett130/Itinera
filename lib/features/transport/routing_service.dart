import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../../core/enums.dart';

/// Un tratto del percorso tra due tappe consecutive.
class RouteLeg {
  const RouteLeg(this.distanceMeters, this.durationSeconds);
  final double distanceMeters;
  final double durationSeconds;
}

/// Risultato strutturato di un calcolo di percorso.
class RouteResult {
  const RouteResult({
    required this.geometry,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.source,
    required this.effectiveMode,
    this.legs = const [],
  });

  /// Geometria della polyline (in ordine). Con il routing stradale segue le
  /// strade; con la stima e' semplicemente la spezzata tra le tappe.
  final List<LatLng> geometry;
  final double distanceMeters;
  final double durationSeconds;

  /// Origine del dato: [DistanceSource.onlineRouting] (strada reale) oppure
  /// [DistanceSource.straightLine] (stima).
  final DistanceSource source;

  /// Mezzo effettivamente gestito dal provider per questo risultato.
  final RouteTravelMode effectiveMode;

  /// Tratti tra i waypoint consecutivi (uno in meno dei waypoint). Vuoto se
  /// il provider non li fornisce.
  final List<RouteLeg> legs;
}

/// Routing stradale via OSRM. Usa le istanze pubbliche FOSSGIS
/// (openstreetmap.de) che espongono profili reali **a piedi, in bici e in
/// auto** — cosi' ogni mezzo segue davvero le strade/sentieri, non la linea
/// d'aria. Nessuna chiave: uso in fair-use come per i tile OSM. Gli endpoint
/// sono configurabili. Offline/errore -> il chiamante ripiega su una stima.
class RoutingService {
  RoutingService({http.Client? client, Map<RouteTravelMode, String>? bases})
    : _client = client ?? http.Client(),
      _bases = bases ?? _defaultBases;

  final http.Client _client;
  final Map<RouteTravelMode, String> _bases;

  static const Map<RouteTravelMode, String> _defaultBases = {
    RouteTravelMode.walk: 'https://routing.openstreetmap.de/routed-foot',
    RouteTravelMode.bike: 'https://routing.openstreetmap.de/routed-bike',
    RouteTravelMode.car: 'https://routing.openstreetmap.de/routed-car',
  };

  /// Distanza stradale in km per auto tra due coordinate, o null se non
  /// disponibile (offline/errore). Mantenuta per compatibilita' col modulo
  /// trasporti.
  Future<double?> drivingDistanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) async {
    final base = _bases[RouteTravelMode.car]!;
    final uri = Uri.parse(
      '$base/route/v1/driving/$lon1,$lat1;$lon2,$lat2?overview=false',
    );
    try {
      final res = await _client.get(uri).timeout(const Duration(seconds: 15));
      if (res.statusCode != 200) return null;
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final routes = (json['routes'] as List?) ?? const [];
      if (routes.isEmpty) return null;
      final meters = (routes.first['distance'] as num?)?.toDouble();
      if (meters == null) return null;
      return meters / 1000.0;
    } catch (_) {
      return null;
    }
  }

  /// Percorso stradale reale che attraversa i [waypoints] in ordine, per il
  /// [mode] indicato (a piedi/bici/auto, ciascuno col proprio profilo OSRM).
  /// Ritorna null se ci sono meno di 2 tappe o in caso di offline/errore: in
  /// quel caso il chiamante usa la stima.
  Future<RouteResult?> route(
    List<LatLng> waypoints,
    RouteTravelMode mode,
  ) async {
    if (waypoints.length < 2) return null;
    final base = _bases[mode] ?? _bases[RouteTravelMode.car]!;
    final coords = waypoints
        .map((p) => '${p.longitude},${p.latitude}')
        .join(';');
    final uri = Uri.parse(
      '$base/route/v1/driving/$coords?overview=full&geometries=geojson',
    );
    try {
      final res = await _client.get(uri).timeout(const Duration(seconds: 20));
      if (res.statusCode != 200) return null;
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final routes = (json['routes'] as List?) ?? const [];
      if (routes.isEmpty) return null;
      final first = routes.first as Map<String, dynamic>;
      final distance = (first['distance'] as num?)?.toDouble();
      final duration = (first['duration'] as num?)?.toDouble();
      final geo = (first['geometry']?['coordinates'] as List?) ?? const [];
      final points = <LatLng>[];
      for (final c in geo) {
        if (c is List && c.length >= 2) {
          points.add(
            LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()),
          );
        }
      }
      if (distance == null || duration == null || points.isEmpty) return null;
      final legs = <RouteLeg>[
        for (final l in (first['legs'] as List?) ?? const [])
          if (l is Map)
            RouteLeg(
              (l['distance'] as num?)?.toDouble() ?? 0,
              (l['duration'] as num?)?.toDouble() ?? 0,
            ),
      ];
      return RouteResult(
        geometry: points,
        distanceMeters: distance,
        durationSeconds: duration,
        source: DistanceSource.onlineRouting,
        effectiveMode: mode,
        // Tratti incompleti = inutilizzabili per la scaletta: meglio nessuno.
        legs: legs.length == waypoints.length - 1 ? legs : const [],
      );
    } catch (_) {
      return null;
    }
  }

  void dispose() => _client.close();
}
