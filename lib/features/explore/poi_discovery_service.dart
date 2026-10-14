import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/calc/distance.dart';
import 'poi_parser.dart';

/// Errore di ricerca POI: distingue il fallimento (rete/servizio) dal semplice
/// "nessun risultato" (lista vuota), cosi' la UI puo' mostrare stati diversi.
class PoiDiscoveryException implements Exception {
  const PoiDiscoveryException(this.message);
  final String message;
  @override
  String toString() => 'PoiDiscoveryException: $message';
}

/// Astrazione della scoperta di punti d'interesse. Client HTTP iniettabile per
/// i test; nessuna chiave segreta nel client.
abstract class PoiDiscoveryService {
  /// Cerca POI turistici entro [radiusMeters] dal centro. Ritorna i risultati
  /// gia' deduplicati e ordinati per distanza dal centro. Lancia
  /// [PoiDiscoveryException] su errore di rete/servizio.
  Future<List<PoiSuggestion>> search({
    required double lat,
    required double lng,
    required double radiusMeters,
  });

  /// Dati completi di un singolo elemento OSM ([osmType] "node", "way" o
  /// "relation") che si trova in [lat]/[lng]. Null se non è un luogo
  /// turistico, offline o in errore.
  Future<PoiSuggestion?> lookup(
    String osmType,
    int osmId, {
    required double lat,
    required double lng,
  });
}

/// Implementazione basata su OpenStreetMap via Overpass API. Endpoint
/// configurabile (nessuna chiave). Timeout e limite risultati applicati.
class OverpassPoiService implements PoiDiscoveryService {
  OverpassPoiService({
    http.Client? client,
    Uri? endpoint,
    this.limit = 80,
    this.timeout = const Duration(seconds: 30),
    this.retryDelay = const Duration(seconds: 1),
    this.osmApiBase = 'https://api.openstreetmap.org/api/0.6',
  }) : _client = client ?? http.Client(),
       _endpoint =
           endpoint ?? Uri.parse('https://overpass-api.de/api/interpreter');

  final http.Client _client;
  final Uri _endpoint;
  final int limit;
  final Duration timeout;

  /// Attesa prima del secondo tentativo di [lookup].
  final Duration retryDelay;

  /// API di OpenStreetMap per leggere un singolo elemento.
  final String osmApiBase;

  @override
  Future<List<PoiSuggestion>> search({
    required double lat,
    required double lng,
    required double radiusMeters,
  }) async {
    final query = buildOverpassQuery(
      lat: lat,
      lng: lng,
      radiusMeters: radiusMeters,
    );
    http.Response res;
    try {
      res = await _client
          .post(
            _endpoint,
            headers: {'User-Agent': 'Itinera/1.0 (personal app)'},
            body: {'data': query},
          )
          .timeout(timeout);
    } catch (e) {
      throw PoiDiscoveryException('rete non disponibile: $e');
    }
    if (res.statusCode != 200) {
      throw PoiDiscoveryException(
        'servizio non disponibile (${res.statusCode})',
      );
    }
    Map<String, dynamic> json;
    try {
      json = jsonDecode(res.body) as Map<String, dynamic>;
    } catch (e) {
      throw const PoiDiscoveryException('risposta non valida');
    }
    final pois = dedupePois(parseOverpass(json));
    pois.sort(
      (a, b) => Distance.haversineKm(
        lat,
        lng,
        a.lat,
        a.lng,
      ).compareTo(Distance.haversineKm(lat, lng, b.lat, b.lng)),
    );
    return pois.length > limit ? pois.sublist(0, limit) : pois;
  }

  /// Un singolo luogo si chiede all'API di OpenStreetMap, non a Overpass:
  /// risponde in un attimo ed è molto più affidabile per una lettura così
  /// piccola. Le coordinate arrivano da chi chiama (l'API non le dà per vie
  /// ed edifici).
  @override
  Future<PoiSuggestion?> lookup(
    String osmType,
    int osmId, {
    required double lat,
    required double lng,
  }) async {
    if (!const {'node', 'way', 'relation'}.contains(osmType)) return null;
    final uri = Uri.parse('$osmApiBase/$osmType/$osmId.json');
    // Un errore momentaneo: un secondo tentativo.
    for (var attempt = 0; attempt < 2; attempt++) {
      if (attempt > 0) await Future<void>.delayed(retryDelay);
      try {
        final res = await _client
            .get(uri, headers: {'User-Agent': 'Itinera/1.0 (personal app)'})
            .timeout(const Duration(seconds: 10));
        if (res.statusCode == 404 || res.statusCode == 410) return null;
        if (res.statusCode != 200) continue;
        final json = jsonDecode(res.body) as Map<String, dynamic>;
        final elements = (json['elements'] as List?) ?? const [];
        if (elements.isEmpty) return null;
        final tags = (elements.first as Map)['tags'];
        final pois = parseOverpass({
          'elements': [
            {
              'type': osmType,
              'id': osmId,
              'lat': lat,
              'lon': lng,
              'tags': tags ?? const {},
            },
          ],
        });
        // Risposta valida ma luogo non turistico: inutile riprovare.
        return pois.isEmpty ? null : pois.first;
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  void dispose() => _client.close();
}

/// Costruisce la query Overpass (pura). Considera node/way/relation e ricava
/// il centro anche per gli elementi non puntuali (`out center`). Include solo
/// tag realmente turistici.
String buildOverpassQuery({
  required double lat,
  required double lng,
  required double radiusMeters,
}) {
  final r = radiusMeters.round();
  final c = '$lat,$lng';
  final b = StringBuffer('[out:json][timeout:25];(');
  void all(String selector) {
    b.write('node$selector(around:$r,$c);');
    b.write('way$selector(around:$r,$c);');
    b.write('relation$selector(around:$r,$c);');
  }

  all('["tourism"]');
  all('["historic"]');
  all('["amenity"="place_of_worship"]');
  all('["leisure"~"^(park|garden|nature_reserve)\$"]');
  all(
    '["natural"~"^(peak|volcano|waterfall|beach|cave_entrance|spring|cliff|bay|glacier)\$"]',
  );
  all('["man_made"~"^(lighthouse|tower|obelisk)\$"]');
  b.write(');out center tags 200;');
  return b.toString();
}
