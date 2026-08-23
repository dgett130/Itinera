import 'dart:convert';

import 'package:http/http.dart' as http;

/// Calcolo della distanza stradale via OSRM (demo pubblico, senza chiave).
///
/// Richiede rete. Offline, il chiamante ripiega su haversine x fattore o
/// sull'inserimento manuale.
class RoutingService {
  RoutingService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Distanza stradale in km per auto tra due coordinate, o null se non
  /// disponibile (offline/errore).
  Future<double?> drivingDistanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) async {
    final uri = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/'
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

  void dispose() => _client.close();
}
