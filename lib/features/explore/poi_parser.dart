import '../../core/calc/distance.dart';
import '../../core/enums.dart';

/// Parsing PURO dei dati POI di OpenStreetMap/Overpass, mapping delle
/// categorie e deduplicazione. Nessuna dipendenza da Flutter o dalla rete:
/// interamente testabile. Non trasforma dati mancanti in informazioni inventate.

/// Un punto d'interesse proposto da un provider esterno (OSM). Oggetto in
/// memoria: diventa una Location persistente solo se l'utente lo sceglie.
class PoiSuggestion {
  const PoiSuggestion({
    required this.provider,
    required this.externalId,
    required this.name,
    required this.lat,
    required this.lng,
    required this.category,
    this.address,
    this.description,
    this.website,
    this.openingHours,
    this.wikidata,
    this.fee,
  });

  final String provider;
  final String externalId;
  final String name;
  final double lat;
  final double lng;
  final PoiCategory category;
  final String? address;
  final String? description;
  final String? website;
  final String? openingHours;
  final String? wikidata;

  /// Tag OSM `fee`: `no` = gratuito, `yes` = a pagamento, altro così com'è.
  final String? fee;

  Map<String, dynamic> toJson() => {
    'provider': provider,
    'externalId': externalId,
    'name': name,
    'lat': lat,
    'lng': lng,
    'category': category.name,
    if (address != null) 'address': address,
    if (description != null) 'description': description,
    if (website != null) 'website': website,
    if (openingHours != null) 'openingHours': openingHours,
    if (wikidata != null) 'wikidata': wikidata,
    if (fee != null) 'fee': fee,
  };

  static PoiSuggestion? fromJson(Map<String, dynamic> j) {
    final lat = j['lat'];
    final lng = j['lng'];
    final name = j['name'];
    final id = j['externalId'];
    if (lat is! num || lng is! num || name is! String || id is! String) {
      return null;
    }
    return PoiSuggestion(
      provider: j['provider'] as String? ?? 'osm',
      externalId: id,
      name: name,
      lat: lat.toDouble(),
      lng: lng.toDouble(),
      category: PoiCategory.values.firstWhere(
        (c) => c.name == j['category'],
        orElse: () => PoiCategory.other,
      ),
      address: j['address'] as String?,
      description: j['description'] as String?,
      website: j['website'] as String?,
      openingHours: j['openingHours'] as String?,
      wikidata: j['wikidata'] as String?,
      fee: j['fee'] as String?,
    );
  }
}

/// Mappa i tag OSM alla categoria turistica, o `null` se il luogo non e'
/// turisticamente rilevante (verra' scartato). L'ordine dei controlli codifica
/// la priorita' fra categorie sovrapponibili.
PoiCategory? categoryForOsmTags(Map<String, dynamic> tags) {
  String? t(String k) => (tags[k] as String?)?.toLowerCase();
  final tourism = t('tourism');
  final historic = t('historic');
  final amenity = t('amenity');
  final leisure = t('leisure');
  final natural = t('natural');
  final building = t('building');
  final manMade = t('man_made');

  // Musei e cultura.
  if (tourism == 'museum' || tourism == 'gallery') return PoiCategory.museum;
  if (amenity == 'arts_centre' || amenity == 'theatre') {
    return PoiCategory.museum;
  }

  // Panorami.
  if (tourism == 'viewpoint') return PoiCategory.viewpoint;

  // Architettura e luoghi religiosi.
  if (amenity == 'place_of_worship') return PoiCategory.religious;
  if (historic != null &&
      const {
        'church',
        'monastery',
        'chapel',
        'cathedral',
        'shrine',
      }.contains(historic)) {
    return PoiCategory.religious;
  }

  // Monumenti e storia.
  if (historic != null &&
      const {
        'monument',
        'memorial',
        'castle',
        'ruins',
        'archaeological_site',
        'city_gate',
        'fort',
        'tower',
        'citywalls',
        'manor',
        'palace',
        'aqueduct',
      }.contains(historic)) {
    return PoiCategory.monument;
  }
  if (historic != null) {
    return PoiCategory.monument; // altri historic=* generici
  }

  // Natura e parchi.
  if (leisure != null &&
      const {'park', 'garden', 'nature_reserve'}.contains(leisure)) {
    return PoiCategory.nature;
  }
  if (natural != null &&
      const {
        'peak',
        'volcano',
        'waterfall',
        'beach',
        'cave_entrance',
        'spring',
        'cliff',
        'bay',
        'glacier',
      }.contains(natural)) {
    return PoiCategory.nature;
  }

  // Attrazioni (turismo generico).
  if (tourism != null &&
      const {
        'attraction',
        'theme_park',
        'zoo',
        'aquarium',
        'artwork',
      }.contains(tourism)) {
    return PoiCategory.attraction;
  }
  if (building != null &&
      const {
        'cathedral',
        'church',
        'chapel',
        'temple',
        'castle',
      }.contains(building)) {
    return PoiCategory.monument;
  }
  if (manMade != null &&
      const {'lighthouse', 'tower', 'obelisk'}.contains(manMade)) {
    return PoiCategory.attraction;
  }
  return null; // non turistico / non classificabile
}

/// Trasforma una risposta Overpass (JSON gia' decodificato) in POI validi.
/// Considera node (lat/lon), way e relation (center). Accetta solo elementi
/// con nome e coordinate valide; scarta il resto senza inventare dati.
List<PoiSuggestion> parseOverpass(Map<String, dynamic> json) {
  final elements = json['elements'];
  if (elements is! List) return const [];
  final out = <PoiSuggestion>[];
  for (final e in elements) {
    if (e is! Map) continue;
    final type = e['type'];
    final id = e['id'];
    if (type is! String || id == null) continue;
    final tags = (e['tags'] as Map?)?.cast<String, dynamic>() ?? const {};
    final name = _pickName(tags);
    if (name == null || name.trim().isEmpty) continue;
    final coords = _coordsFor(e);
    if (coords == null) continue;
    final category = categoryForOsmTags(tags);
    if (category == null) continue;
    out.add(
      PoiSuggestion(
        provider: 'osm',
        externalId: '$type/$id',
        name: name.trim(),
        lat: coords[0],
        lng: coords[1],
        category: category,
        address: _address(tags),
        description: _first(tags, const ['description:it', 'description']),
        website: _first(tags, const ['website', 'contact:website', 'url']),
        openingHours: tags['opening_hours'] as String?,
        wikidata: tags['wikidata'] as String?,
        fee: tags['fee'] as String?,
      ),
    );
  }
  return out;
}

/// Rimuove i duplicati: prima per (provider, externalId), poi in modo prudente
/// per nome normalizzato + vicinanza (<= [mergeMeters]).
List<PoiSuggestion> dedupePois(
  List<PoiSuggestion> pois, {
  double mergeMeters = 60,
}) {
  final seenIds = <String>{};
  final kept = <PoiSuggestion>[];
  for (final p in pois) {
    final idKey = '${p.provider}/${p.externalId}';
    if (!seenIds.add(idKey)) continue;
    final dup = kept.any(
      (k) =>
          _norm(k.name) == _norm(p.name) &&
          Distance.haversineKm(k.lat, k.lng, p.lat, p.lng) * 1000 <=
              mergeMeters,
    );
    if (dup) continue;
    kept.add(p);
  }
  return kept;
}

String? _pickName(Map<String, dynamic> tags) =>
    (tags['name:it'] as String?) ?? (tags['name'] as String?);

List<double>? _coordsFor(Map e) {
  final lat = e['lat'];
  final lon = e['lon'];
  if (lat is num && lon is num) return [lat.toDouble(), lon.toDouble()];
  final center = e['center'];
  if (center is Map) {
    final clat = center['lat'];
    final clon = center['lon'];
    if (clat is num && clon is num) return [clat.toDouble(), clon.toDouble()];
  }
  return null;
}

String? _first(Map<String, dynamic> tags, List<String> keys) {
  for (final k in keys) {
    final v = tags[k];
    if (v is String && v.trim().isNotEmpty) return v.trim();
  }
  return null;
}

String? _address(Map<String, dynamic> tags) {
  final street = tags['addr:street'] as String?;
  final number = tags['addr:housenumber'] as String?;
  final city = tags['addr:city'] as String?;
  final parts = <String>[];
  if (street != null) parts.add(number != null ? '$street $number' : street);
  if (city != null) parts.add(city);
  return parts.isEmpty ? null : parts.join(', ');
}

String _norm(String s) =>
    s.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
