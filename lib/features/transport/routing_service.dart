import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../../core/enums.dart';

/// Risultato strutturato di un calcolo di percorso.
class RouteResult {
  const RouteResult({
    required this.geometry,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.source,
    required this.effectiveMode,
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
}

/// Routing stradale via OSRM (demo pubblico, senza chiave). L'endpoint e'
/// configurabile; nessuna chiave segreta nel client.
///
/// ATTENZIONE (onesta' sui profili): il demo pubblico OSRM gestisce SOLO il
/// profilo `driving`. Percio' [route] restituisce un percorso reale solo per
/// [RouteTravelMode.car]; per piedi/bici ritorna `null` e il chiamante ripiega
/// su una stima etichettata. Non dichiariamo supportato cio' che il provider
/// non gestisce davvero.
class RoutingService {
  RoutingService({http.Client? client, String? osrmBase})
    : _client = client ?? http.Client(),
      _osrmBase = osrmBase ?? 'https://router.project-osrm.org';

  final http.Client _client;
  final String _osrmBase;

  /// Distanza stradale in km per auto tra due coordinate, o null se non
  /// disponibile (offline/errore). Mantenuta per compatibilita' col modulo
  /// trasporti.
  Future<double?> drivingDistanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) async {
    final uri = Uri.parse(
      '$_osrmBase/route/v1/driving/'
      '$lon1,$lat1;$lon2,$lat2?overview=false',
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

  /// Percorso stradale reale che attraversa i [waypoints] in ordine. Ritorna
  /// null se il mezzo non e' gestito online (piedi/bici), se ci sono meno di 2
  /// tappe o in caso di offline/errore: in tutti questi casi il chiamante usa
  /// la stima.
  Future<RouteResult?> route(
    List<LatLng> waypoints,
    RouteTravelMode mode,
  ) async {
    if (waypoints.length < 2) return null;
    if (mode != RouteTravelMode.car) return null; // solo 'driving' online
    final coords = waypoints
        .map((p) => '${p.longitude},${p.latitude}')
        .join(';');
    final uri = Uri.parse(
      '$_osrmBase/route/v1/driving/$coords'
      '?overview=full&geometries=geojson',
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
      return RouteResult(
        geometry: points,
        distanceMeters: distance,
        durationSeconds: duration,
        source: DistanceSource.onlineRouting,
        effectiveMode: RouteTravelMode.car,
      );
    } catch (_) {
      return null;
    }
  }

  void dispose() => _client.close();
}
