import 'dart:convert';

import 'package:http/http.dart' as http;

/// Un luogo suggerito dall'autocomplete.
class PlaceResult {
  const PlaceResult({
    required this.label,
    required this.latitude,
    required this.longitude,
    this.country,
    this.countryCode,
  });

  final String label;
  final double latitude;
  final double longitude;
  final String? country;
  final String? countryCode;
}

/// Ricerca luoghi (geocoding/autocomplete) tramite Photon (OpenStreetMap).
///
/// Gratuito e senza chiave. Richiede rete: quando si e' offline ritorna una
/// lista vuota e la UI ripiega sull'inserimento manuale.
class GeocodingService {
  GeocodingService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static final Uri _endpoint = Uri.parse('https://photon.komoot.io/api/');

  Future<List<PlaceResult>> search(String query, {int limit = 6}) async {
    final q = query.trim();
    if (q.length < 3) return const [];
    final uri = _endpoint.replace(queryParameters: {
      'q': q,
      'lang': 'it',
      'limit': '$limit',
    });
    try {
      final res = await _client
          .get(uri, headers: {'User-Agent': 'Itinera/1.0 (personal app)'})
          .timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return const [];
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final features = (json['features'] as List?) ?? const [];
      final results = <PlaceResult>[];
      for (final f in features) {
        final props = (f['properties'] as Map?)?.cast<String, dynamic>() ?? {};
        final coords = (f['geometry']?['coordinates'] as List?);
        if (coords == null || coords.length < 2) continue;
        results.add(PlaceResult(
          label: _buildLabel(props),
          longitude: (coords[0] as num).toDouble(),
          latitude: (coords[1] as num).toDouble(),
          country: props['country'] as String?,
          countryCode: (props['countrycode'] as String?)?.toUpperCase(),
        ));
      }
      return results;
    } catch (_) {
      return const []; // offline o errore -> fallback manuale
    }
  }

  /// Reverse geocoding: da coordinate a un'etichetta leggibile.
  Future<String?> reverse(double lat, double lon) async {
    final uri = Uri.parse('https://photon.komoot.io/reverse').replace(
      queryParameters: {'lat': '$lat', 'lon': '$lon', 'lang': 'it'},
    );
    try {
      final res = await _client
          .get(uri, headers: {'User-Agent': 'Itinera/1.0 (personal app)'})
          .timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return null;
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final features = (json['features'] as List?) ?? const [];
      if (features.isEmpty) return null;
      final props =
          (features.first['properties'] as Map?)?.cast<String, dynamic>() ?? {};
      return _buildLabel(props);
    } catch (_) {
      return null;
    }
  }

  String _buildLabel(Map<String, dynamic> props) {
    final parts = <String>[];
    final name = props['name'] as String?;
    final city = props['city'] as String?;
    final state = props['state'] as String?;
    final country = props['country'] as String?;
    if (name != null) parts.add(name);
    if (city != null && city != name) parts.add(city);
    if (parts.isEmpty && state != null) parts.add(state);
    if (country != null) parts.add(country);
    return parts.join(', ');
  }

  void dispose() => _client.close();
}
