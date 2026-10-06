import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/calc/distance.dart';
import '../../core/enums.dart';
import '../../core/id.dart';
import '../../data/database.dart';
import 'poi_discovery_service.dart';
import 'poi_parser.dart';

/// Esito di una ricerca POI: distingue rete/cache e porta la data delle
/// proposte, cosi' la UI puo' mostrare "aggiornato il ...".
class PoiSearchOutcome {
  const PoiSearchOutcome({
    required this.pois,
    required this.fromCache,
    this.fetchedAt,
    this.stale = false,
  });

  final List<PoiSuggestion> pois;
  final bool fromCache;
  final DateTime? fetchedAt;

  /// True se la cache mostrata era scaduta ma la rete non e' disponibile.
  final bool stale;
}

/// Accesso ai dati della scoperta luoghi: cache POI locale (con scadenza) e
/// salvataggio dei POI scelti come Location persistenti (con deduplicazione).
class ExploreRepository {
  ExploreRepository(
    this._db,
    this._service, {
    Duration cacheTtl = const Duration(days: 7),
  }) : _cacheTtl = cacheTtl;

  final AppDatabase _db;
  final PoiDiscoveryService _service;
  final Duration _cacheTtl;

  /// Chiave di cache deterministica (coordinate arrotondate + raggio).
  String cacheKey(double lat, double lng, double radiusMeters) =>
      'osm|${lat.toStringAsFixed(3)}|${lng.toStringAsFixed(3)}|${radiusMeters.round()}';

  /// Cerca POI: prima la cache fresca, altrimenti la rete (e aggiorna la
  /// cache). Se la rete fallisce ma esiste una cache (anche scaduta) la
  /// mostra; altrimenti rilancia [PoiDiscoveryException].
  Future<PoiSearchOutcome> discover({
    required double lat,
    required double lng,
    required double radiusMeters,
    bool forceRefresh = false,
  }) async {
    final key = cacheKey(lat, lng, radiusMeters);
    final cached = await _readCache(key);
    final fresh =
        cached != null &&
        DateTime.now().difference(cached.fetchedAt) < _cacheTtl;
    if (!forceRefresh && fresh) {
      return PoiSearchOutcome(
        pois: cached.pois,
        fromCache: true,
        fetchedAt: cached.fetchedAt,
      );
    }
    try {
      final pois = await _service.search(
        lat: lat,
        lng: lng,
        radiusMeters: radiusMeters,
      );
      await _writeCache(key, pois);
      return PoiSearchOutcome(
        pois: pois,
        fromCache: false,
        fetchedAt: DateTime.now(),
      );
    } on PoiDiscoveryException {
      if (cached != null) {
        return PoiSearchOutcome(
          pois: cached.pois,
          fromCache: true,
          fetchedAt: cached.fetchedAt,
          stale: true,
        );
      }
      rethrow;
    }
  }

  Future<_CachedPois?> _readCache(String key) async {
    final row = await (_db.select(
      _db.poiCacheEntries,
    )..where((c) => c.cacheKey.equals(key))).getSingleOrNull();
    if (row == null) return null;
    final decoded = jsonDecode(row.payload);
    final pois = <PoiSuggestion>[];
    if (decoded is List) {
      for (final e in decoded) {
        if (e is Map) {
          final p = PoiSuggestion.fromJson(e.cast<String, dynamic>());
          if (p != null) pois.add(p);
        }
      }
    }
    return _CachedPois(pois, row.fetchedAt);
  }

  Future<void> _writeCache(String key, List<PoiSuggestion> pois) async {
    await _db
        .into(_db.poiCacheEntries)
        .insertOnConflictUpdate(
          PoiCacheEntriesCompanion.insert(
            cacheKey: key,
            payload: jsonEncode([for (final p in pois) p.toJson()]),
            fetchedAt: Value(DateTime.now()),
          ),
        );
  }

  /// Tutti i luoghi salvati del viaggio (reattivo).
  Stream<List<Location>> watchSavedLocations(String tripId) => (_db.select(
    _db.locations,
  )..where((l) => l.tripId.equals(tripId))).watch();

  /// Salva un POI come Location, evitando i duplicati: prima per
  /// (provider, externalId), poi in modo prudente per nome + vicinanza.
  /// Ritorna l'id della Location (nuova o gia' esistente).
  Future<String> savePoi(String tripId, PoiSuggestion p) async {
    final existing =
        await (_db.select(_db.locations)..where(
              (l) =>
                  l.tripId.equals(tripId) &
                  l.externalProvider.equals(p.provider) &
                  l.externalId.equals(p.externalId),
            ))
            .getSingleOrNull();
    if (existing != null) return existing.id;

    final all = await (_db.select(
      _db.locations,
    )..where((l) => l.tripId.equals(tripId))).get();
    for (final l in all) {
      if (l.latitude != null &&
          l.longitude != null &&
          _norm(l.label) == _norm(p.name) &&
          Distance.haversineKm(l.latitude!, l.longitude!, p.lat, p.lng) *
                  1000 <=
              60) {
        return l.id;
      }
    }

    final id = newId();
    await _db
        .into(_db.locations)
        .insert(
          LocationsCompanion.insert(
            id: id,
            tripId: tripId,
            label: p.name,
            latitude: Value(p.lat),
            longitude: Value(p.lng),
            placeType: const Value(PlaceType.poi),
            source: const Value(LocationSource.osm),
            externalProvider: Value(p.provider),
            externalId: Value(p.externalId),
            poiCategory: Value(p.category),
            address: Value(p.address),
            description: Value(p.description),
            website: Value(p.website),
            openingHours: Value(p.openingHours),
            wikidata: Value(p.wikidata),
            fee: Value(p.fee),
          ),
        );
    return id;
  }

  /// Salva un luogo scelto manualmente (mappa/inserimento) come Location.
  Future<String> saveManualLocation(
    String tripId, {
    required String label,
    double? latitude,
    double? longitude,
    LocationSource source = LocationSource.mapPick,
  }) async {
    final id = newId();
    await _db
        .into(_db.locations)
        .insert(
          LocationsCompanion.insert(
            id: id,
            tripId: tripId,
            label: label,
            latitude: Value(latitude),
            longitude: Value(longitude),
            placeType: const Value(PlaceType.poi),
            source: Value(source),
          ),
        );
    return id;
  }

  /// Aggiorna le note personali di un luogo (stringa vuota = nessuna nota).
  Future<void> updateLocationNotes(String locationId, String notes) async {
    final trimmed = notes.trim();
    await (_db.update(
      _db.locations,
    )..where((l) => l.id.equals(locationId))).write(
      LocationsCompanion(notes: Value(trimmed.isEmpty ? null : trimmed)),
    );
  }

  /// Elimina un luogo salvato SOLO se non e' usato da tappe di percorso o
  /// attivita' (evita cancellazioni a cascata inattese). Ritorna false se in
  /// uso.
  Future<bool> deleteSavedLocation(String locationId) async {
    final inRoute =
        await (_db.select(_db.sightseeingRouteStops)
              ..where((s) => s.locationId.equals(locationId))
              ..limit(1))
            .getSingleOrNull();
    if (inRoute != null) return false;
    final inActivity =
        await (_db.select(_db.activities)
              ..where((a) => a.locationId.equals(locationId))
              ..limit(1))
            .getSingleOrNull();
    if (inActivity != null) return false;
    await (_db.delete(
      _db.locations,
    )..where((l) => l.id.equals(locationId))).go();
    return true;
  }
}

class _CachedPois {
  _CachedPois(this.pois, this.fetchedAt);
  final List<PoiSuggestion> pois;
  final DateTime fetchedAt;
}

String _norm(String s) =>
    s.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
