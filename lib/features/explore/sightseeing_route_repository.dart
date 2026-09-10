import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/enums.dart';
import '../../core/id.dart';
import '../../data/database.dart';

/// Accesso ai dati dei percorsi di visita (percorsi + tappe). Solo DB: il
/// calcolo online e l'ottimizzazione (che richiedono coordinate/rete) sono
/// orchestrati dal controller della UI.
class SightseeingRouteRepository {
  SightseeingRouteRepository(this._db);

  final AppDatabase _db;

  Stream<List<SightseeingRoute>> watchRoutes(String tripId) =>
      (_db.select(_db.sightseeingRoutes)
            ..where((r) => r.tripId.equals(tripId))
            ..orderBy([(r) => OrderingTerm(expression: r.createdAt)]))
          .watch();

  Stream<List<SightseeingRouteStop>> watchStops(String routeId) =>
      (_db.select(_db.sightseeingRouteStops)
            ..where((s) => s.routeId.equals(routeId))
            ..orderBy([(s) => OrderingTerm(expression: s.sequenceIndex)]))
          .watch();

  Future<SightseeingRoute?> getRoute(String id) => (_db.select(
    _db.sightseeingRoutes,
  )..where((r) => r.id.equals(id))).getSingleOrNull();

  Stream<SightseeingRoute?> watchRoute(String id) => (_db.select(
    _db.sightseeingRoutes,
  )..where((r) => r.id.equals(id))).watchSingleOrNull();

  Future<List<SightseeingRouteStop>> stopsFor(String routeId) =>
      (_db.select(_db.sightseeingRouteStops)
            ..where((s) => s.routeId.equals(routeId))
            ..orderBy([(s) => OrderingTerm(expression: s.sequenceIndex)]))
          .get();

  Future<String> createRoute({
    required String tripId,
    required String name,
    RouteTravelMode mode = RouteTravelMode.walk,
    List<String> locationIds = const [],
    bool returnToStart = false,
    bool fixedStart = false,
    String? dayId,
  }) async {
    final id = newId();
    await _db.transaction(() async {
      await _db
          .into(_db.sightseeingRoutes)
          .insert(
            SightseeingRoutesCompanion.insert(
              id: id,
              tripId: tripId,
              name: name,
              travelMode: Value(mode),
              returnToStart: Value(returnToStart),
              fixedStart: Value(fixedStart),
              dayId: Value(dayId),
            ),
          );
      for (var i = 0; i < locationIds.length; i++) {
        await _db
            .into(_db.sightseeingRouteStops)
            .insert(
              SightseeingRouteStopsCompanion.insert(
                id: newId(),
                routeId: id,
                tripId: tripId,
                locationId: locationIds[i],
                sequenceIndex: Value(i),
              ),
            );
      }
    });
    return id;
  }

  Future<void> renameRoute(String id, String name) async {
    await (_db.update(
      _db.sightseeingRoutes,
    )..where((r) => r.id.equals(id))).write(
      SightseeingRoutesCompanion(
        name: Value(name),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> deleteRoute(String id) async {
    await (_db.delete(
      _db.sightseeingRoutes,
    )..where((r) => r.id.equals(id))).go();
  }

  Future<void> setMode(String routeId, RouteTravelMode mode) =>
      _patch(routeId, SightseeingRoutesCompanion(travelMode: Value(mode)));

  Future<void> setReturnToStart(String routeId, bool v) =>
      _patch(routeId, SightseeingRoutesCompanion(returnToStart: Value(v)));

  Future<void> setFixedStart(String routeId, bool v) =>
      _patch(routeId, SightseeingRoutesCompanion(fixedStart: Value(v)));

  /// Aggiunge una tappa (evita di duplicare la stessa Location nel percorso).
  Future<void> addStop(String routeId, String tripId, String locationId) async {
    final stops = await stopsFor(routeId);
    if (stops.any((s) => s.locationId == locationId)) return;
    final next = stops.isEmpty
        ? 0
        : stops.map((s) => s.sequenceIndex).reduce((a, b) => a > b ? a : b) + 1;
    await _db
        .into(_db.sightseeingRouteStops)
        .insert(
          SightseeingRouteStopsCompanion.insert(
            id: newId(),
            routeId: routeId,
            tripId: tripId,
            locationId: locationId,
            sequenceIndex: Value(next),
          ),
        );
    await _touch(routeId);
  }

  Future<void> removeStop(String stopId) async {
    final stop = await (_db.select(
      _db.sightseeingRouteStops,
    )..where((s) => s.id.equals(stopId))).getSingleOrNull();
    await (_db.delete(
      _db.sightseeingRouteStops,
    )..where((s) => s.id.equals(stopId))).go();
    if (stop != null) await _touch(stop.routeId);
  }

  /// Riscrive `sequenceIndex` secondo il nuovo ordine visuale. Se [markManual]
  /// marca il percorso come non ottimizzato (ordine imposto dall'utente).
  Future<void> reorder(
    String routeId,
    List<String> orderedStopIds, {
    bool markManual = true,
  }) async {
    await _db.transaction(() async {
      for (var i = 0; i < orderedStopIds.length; i++) {
        await (_db.update(_db.sightseeingRouteStops)
              ..where((s) => s.id.equals(orderedStopIds[i])))
            .write(SightseeingRouteStopsCompanion(sequenceIndex: Value(i)));
      }
      if (markManual) {
        await (_db.update(
          _db.sightseeingRoutes,
        )..where((r) => r.id.equals(routeId))).write(
          SightseeingRoutesCompanion(
            optimized: const Value(false),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }
    });
  }

  /// Applica un ordine ottimizzato, conservando prima l'ordine manuale (se non
  /// gia' conservato) per poterlo ripristinare.
  Future<void> applyOptimizedOrder(
    String routeId,
    List<String> orderedStopIds,
  ) async {
    final route = await getRoute(routeId);
    if (route == null) return;
    final current = await stopsFor(routeId);
    await _db.transaction(() async {
      if (!route.optimized || route.lastManualOrder == null) {
        final manual = jsonEncode(current.map((s) => s.id).toList());
        await (_db.update(_db.sightseeingRoutes)
              ..where((r) => r.id.equals(routeId)))
            .write(SightseeingRoutesCompanion(lastManualOrder: Value(manual)));
      }
      for (var i = 0; i < orderedStopIds.length; i++) {
        await (_db.update(_db.sightseeingRouteStops)
              ..where((s) => s.id.equals(orderedStopIds[i])))
            .write(SightseeingRouteStopsCompanion(sequenceIndex: Value(i)));
      }
      await (_db.update(
        _db.sightseeingRoutes,
      )..where((r) => r.id.equals(routeId))).write(
        SightseeingRoutesCompanion(
          optimized: const Value(true),
          updatedAt: Value(DateTime.now()),
        ),
      );
    });
  }

  /// Ripristina l'ultimo ordine manuale salvato (se presente).
  Future<void> restoreManualOrder(String routeId) async {
    final route = await getRoute(routeId);
    final raw = route?.lastManualOrder;
    if (raw == null) return;
    final ids = (jsonDecode(raw) as List).map((e) => e as String).toList();
    await reorder(routeId, ids, markManual: false);
    await _patch(
      routeId,
      const SightseeingRoutesCompanion(optimized: Value(false)),
    );
  }

  /// Salva l'esito di un calcolo (distanza/durata/geometria/fonte).
  Future<void> saveComputation(
    String routeId, {
    required int distanceMeters,
    required int durationSeconds,
    required String geometryJson,
    required DistanceSource source,
  }) async {
    await _patch(
      routeId,
      SightseeingRoutesCompanion(
        distanceMeters: Value(distanceMeters),
        durationSeconds: Value(durationSeconds),
        geometry: Value(geometryJson),
        calcSource: Value(source),
      ),
    );
  }

  /// Aggancia il percorso a [dayId] come UNICO evento della tabella di marcia:
  /// crea una sola attivita' che rappresenta il percorso (Activities.routeId),
  /// senza orario (tutto il giorno). Idempotente: se l'evento del percorso e'
  /// gia' nel giorno aggiorna solo l'aggancio. Ritorna 1 se creato, 0 se
  /// gia' presente. Transazionale.
  Future<int> addToItinerary(
    String routeId,
    String dayId,
    String tripId,
  ) async {
    final route = await getRoute(routeId);
    if (route == null) return 0;
    return _db.transaction(() async {
      final existing =
          await (_db.select(_db.activities)..where(
                (a) => a.dayId.equals(dayId) & a.routeId.equals(routeId),
              ))
              .getSingleOrNull();
      // Aggancia comunque il percorso al giorno.
      await (_db.update(
        _db.sightseeingRoutes,
      )..where((r) => r.id.equals(routeId))).write(
        SightseeingRoutesCompanion(
          dayId: Value(dayId),
          updatedAt: Value(DateTime.now()),
        ),
      );
      if (existing != null) return 0;
      final all = await (_db.select(
        _db.activities,
      )..where((a) => a.dayId.equals(dayId))).get();
      final sort = all.isEmpty
          ? 0
          : all.map((a) => a.sortIndex).reduce((a, b) => a > b ? a : b) + 1;
      await _db
          .into(_db.activities)
          .insert(
            ActivitiesCompanion.insert(
              id: newId(),
              dayId: dayId,
              tripId: tripId,
              title: route.name,
              isAllDay: const Value(true),
              routeId: Value(routeId),
              sortIndex: Value(sort),
            ),
          );
      return 1;
    });
  }

  Future<void> _patch(String routeId, SightseeingRoutesCompanion patch) async {
    await (_db.update(_db.sightseeingRoutes)
          ..where((r) => r.id.equals(routeId)))
        .write(patch.copyWith(updatedAt: Value(DateTime.now())));
  }

  Future<void> _touch(String routeId) =>
      _patch(routeId, const SightseeingRoutesCompanion());
}
