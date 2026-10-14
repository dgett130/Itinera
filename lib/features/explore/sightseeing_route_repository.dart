import 'dart:convert';
import 'dart:math' as math;

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/enums.dart';
import '../../core/id.dart';
import '../../data/database.dart';
import 'geo_codec.dart';
import 'route_schedule.dart';

/// Tappa appena tolta, con quanto serve per annullare la rimozione.
class RemovedStop {
  const RemovedStop({required this.stop, this.location});
  final SightseeingRouteStop stop;

  /// Valorizzato se, togliendo la tappa, anche il luogo è stato eliminato
  /// (non era usato altrove).
  final Location? location;
}

/// Tappa appena spostata in un altro percorso, con quanto serve per
/// annullare lo spostamento.
class MovedStop {
  const MovedStop({
    required this.stop,
    required this.fromIndex,
    required this.merged,
  });

  /// La tappa com'era prima dello spostamento (percorso, ordine, visita).
  final SightseeingRouteStop stop;

  /// Posizione nel percorso di partenza.
  final int fromIndex;

  /// Il luogo era già una tappa del percorso di arrivo: la tappa è stata solo
  /// tolta da qui (niente doppioni).
  final bool merged;
}

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

  /// Tutte le tappe del viaggio (per i conteggi nella pagina iniziale).
  Stream<List<SightseeingRouteStop>> watchTripStops(String tripId) =>
      (_db.select(
        _db.sightseeingRouteStops,
      )..where((s) => s.tripId.equals(tripId))).watch();

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
    await _syncEvent(id);
  }

  /// Elimina il percorso e i suoi luoghi non usati altrove: nel modello a
  /// percorsi un luogo esiste solo come tappa, un orfano sarebbe invisibile.
  Future<void> deleteRoute(String id) async {
    await _db.transaction(() async {
      final locIds = (await stopsFor(id)).map((s) => s.locationId).toSet();
      await (_db.delete(
        _db.sightseeingRoutes,
      )..where((r) => r.id.equals(id))).go();
      for (final l in locIds) {
        await _deleteLocationIfOrphan(l);
      }
    });
  }

  /// Elimina un percorso rimasto senza tappe (bozza abbandonata).
  Future<void> deleteIfEmpty(String id) async {
    if ((await stopsFor(id)).isEmpty) await deleteRoute(id);
  }

  Future<Location?> _deleteLocationIfOrphan(String locationId) async {
    final inStop =
        await (_db.select(_db.sightseeingRouteStops)
              ..where((s) => s.locationId.equals(locationId))
              ..limit(1))
            .getSingleOrNull();
    if (inStop != null) return null;
    final inActivity =
        await (_db.select(_db.activities)
              ..where((a) => a.locationId.equals(locationId))
              ..limit(1))
            .getSingleOrNull();
    if (inActivity != null) return null;
    final loc = await (_db.select(
      _db.locations,
    )..where((l) => l.id.equals(locationId))).getSingleOrNull();
    if (loc == null) return null;
    await (_db.delete(
      _db.locations,
    )..where((l) => l.id.equals(locationId))).go();
    return loc;
  }

  Future<void> setMode(String routeId, RouteTravelMode mode) =>
      _patch(routeId, SightseeingRoutesCompanion(travelMode: Value(mode)));

  Future<void> setReturnToStart(String routeId, bool v) =>
      _patch(routeId, SightseeingRoutesCompanion(returnToStart: Value(v)));

  Future<void> setFixedStart(String routeId, bool v) =>
      _patch(routeId, SightseeingRoutesCompanion(fixedStart: Value(v)));

  /// "Parti da": porta [stopId] in testa e blocca la partenza. Se la vecchia
  /// partenza era "solo partenza" torna una tappa normale (visita predefinita).
  Future<void> setStart(String routeId, String stopId) async {
    final stops = await stopsFor(routeId);
    if (!stops.any((s) => s.id == stopId)) return;
    await _db.transaction(() async {
      final old = stops.first;
      if (old.id != stopId && old.visitMinutes == 0) {
        await (_db.update(
          _db.sightseeingRouteStops,
        )..where((s) => s.id.equals(old.id))).write(
          const SightseeingRouteStopsCompanion(visitMinutes: Value(null)),
        );
      }
      final ids = [
        stopId,
        ...stops.map((s) => s.id).where((id) => id != stopId),
      ];
      await reorder(routeId, ids);
      await setFixedStart(routeId, true);
    });
  }

  /// "Parti dalla tappa più comoda": sblocca la partenza. Una tappa "solo
  /// partenza" potrebbe finire a metà giro, quindi torna una tappa normale.
  Future<void> clearStart(String routeId) async {
    final stops = await stopsFor(routeId);
    await _db.transaction(() async {
      if (stops.isNotEmpty && stops.first.visitMinutes == 0) {
        await (_db.update(
          _db.sightseeingRouteStops,
        )..where((s) => s.id.equals(stops.first.id))).write(
          const SightseeingRouteStopsCompanion(visitMinutes: Value(null)),
        );
      }
      await setFixedStart(routeId, false);
    });
  }

  /// Durata della visita di una tappa (null = predefinita, 0 = solo partenza).
  Future<void> setVisitMinutes(String stopId, int? minutes) async {
    final stop = await (_db.select(
      _db.sightseeingRouteStops,
    )..where((s) => s.id.equals(stopId))).getSingleOrNull();
    if (stop == null) return;
    await (_db.update(_db.sightseeingRouteStops)
          ..where((s) => s.id.equals(stopId)))
        .write(SightseeingRouteStopsCompanion(visitMinutes: Value(minutes)));
    await _touch(stop.routeId);
    await _syncEvent(stop.routeId);
  }

  /// Ora di partenza (minuti dalla mezzanotte); null = senza orario.
  Future<void> setStartMinutes(String routeId, int? minutes) async {
    await _patch(
      routeId,
      SightseeingRoutesCompanion(startMinutes: Value(minutes)),
    );
    await _syncEvent(routeId);
  }

  /// Scaletta dai dati salvati (null se i tratti vanno ricalcolati).
  Future<RouteSchedule?> scheduleFor(SightseeingRoute route) async {
    final stops = await stopsFor(route.id);
    final locs = await (_db.select(
      _db.locations,
    )..where((l) => l.id.isIn(stops.map((s) => s.locationId)))).get();
    final byId = {for (final l in locs) l.id: l};
    return buildSchedule(
      stops: [
        for (final s in stops)
          if (byId[s.locationId] case final l?)
            ScheduleStop(
              hasCoords: l.latitude != null && l.longitude != null,
              visitMinutes: effectiveVisitMinutes(
                s.visitMinutes,
                l.poiCategory,
              ),
            ),
      ],
      legs: decodeLegs(route.legs),
      returnToStart: route.returnToStart,
    );
  }

  /// Tiene allineato l'evento del percorso nella tabella di marcia: titolo
  /// e, con l'ora di partenza, inizio e fine dalla scaletta (senza orario
  /// resta "tutto il giorno"). Scrive solo se qualcosa è cambiato.
  Future<void> _syncEvent(String routeId) async {
    final event =
        await (_db.select(_db.activities)
              ..where((a) => a.routeId.equals(routeId))
              ..limit(1))
            .getSingleOrNull();
    if (event == null) return;
    final route = await getRoute(routeId);
    if (route == null) return;
    final start = route.startMinutes;
    int? end;
    if (start != null) {
      final schedule = await scheduleFor(route);
      // Tratti da ricalcolare: tengo la durata attuale finché non arrivano.
      final oldStart = event.startMinutes;
      final oldEnd = event.endMinutes;
      end = schedule != null
          ? RouteSchedule.clock(start, schedule.endSeconds)
          : (oldStart != null && oldEnd != null)
          ? start + (oldEnd - oldStart)
          : null;
      if (end != null) end = math.min(end, 23 * 60 + 59);
    }
    if (event.title == route.name &&
        event.startMinutes == start &&
        event.endMinutes == end &&
        event.isAllDay == (start == null)) {
      return;
    }
    await (_db.update(
      _db.activities,
    )..where((a) => a.id.equals(event.id))).write(
      ActivitiesCompanion(
        title: Value(route.name),
        startMinutes: Value(start),
        endMinutes: Value(end),
        isAllDay: Value(start == null),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Aggiunge una tappa in coda (evita di duplicare la stessa Location nel
  /// percorso). Ritorna false se il luogo era già una tappa.
  Future<bool> addStop(String routeId, String tripId, String locationId) async {
    final stops = await stopsFor(routeId);
    if (stops.any((s) => s.locationId == locationId)) return false;
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
    return true;
  }

  /// Toglie una tappa; se il luogo non è usato altrove lo elimina. Ritorna
  /// ciò che serve per [restoreStop] (null se la tappa non esiste).
  Future<RemovedStop?> removeStop(String stopId) async {
    return _db.transaction(() async {
      final stop = await (_db.select(
        _db.sightseeingRouteStops,
      )..where((s) => s.id.equals(stopId))).getSingleOrNull();
      if (stop == null) return null;
      await (_db.delete(
        _db.sightseeingRouteStops,
      )..where((s) => s.id.equals(stopId))).go();
      final loc = await _deleteLocationIfOrphan(stop.locationId);
      await _touch(stop.routeId);
      return RemovedStop(stop: stop, location: loc);
    });
  }

  /// Sposta la tappa in coda a [targetRouteId]. Se quel percorso ha già lo
  /// stesso luogo, la tappa viene solo tolta da qui. Una tappa "solo
  /// partenza" diventa una tappa normale (in coda non è più la partenza).
  /// Ritorna null se non c'è niente da spostare.
  Future<MovedStop?> moveStop(String stopId, String targetRouteId) async {
    final moved = await _db.transaction(() async {
      final stop = await (_db.select(
        _db.sightseeingRouteStops,
      )..where((s) => s.id.equals(stopId))).getSingleOrNull();
      if (stop == null || stop.routeId == targetRouteId) return null;
      final source = await stopsFor(stop.routeId);
      final fromIndex = source.indexWhere((s) => s.id == stopId);
      final target = await stopsFor(targetRouteId);
      final merged = target.any((s) => s.locationId == stop.locationId);
      if (merged) {
        await (_db.delete(
          _db.sightseeingRouteStops,
        )..where((s) => s.id.equals(stopId))).go();
      } else {
        await (_db.update(
          _db.sightseeingRouteStops,
        )..where((s) => s.id.equals(stopId))).write(
          SightseeingRouteStopsCompanion(
            routeId: Value(targetRouteId),
            sequenceIndex: Value(target.length),
            visitMinutes: stop.visitMinutes == 0
                ? const Value(null)
                : const Value.absent(),
          ),
        );
      }
      await _reindex(stop.routeId);
      await _touch(stop.routeId);
      await _touch(targetRouteId);
      return MovedStop(stop: stop, fromIndex: fromIndex, merged: merged);
    });
    if (moved != null) {
      await _syncEvent(moved.stop.routeId);
      await _syncEvent(targetRouteId);
    }
    return moved;
  }

  /// Annulla [moveStop]: la tappa torna nel suo percorso, nella stessa
  /// posizione e com'era (anche se era stata tolta perché già presente).
  Future<void> undoMove(MovedStop m, String targetRouteId) async {
    await _db.transaction(() async {
      final ids = [
        for (final s in await stopsFor(m.stop.routeId))
          if (s.id != m.stop.id) s.id,
      ];
      await _db.into(_db.sightseeingRouteStops).insertOnConflictUpdate(m.stop);
      ids.insert(m.fromIndex.clamp(0, ids.length), m.stop.id);
      for (var i = 0; i < ids.length; i++) {
        await (_db.update(_db.sightseeingRouteStops)
              ..where((s) => s.id.equals(ids[i])))
            .write(SightseeingRouteStopsCompanion(sequenceIndex: Value(i)));
      }
      await _reindex(targetRouteId);
      await _touch(m.stop.routeId);
      await _touch(targetRouteId);
    });
    await _syncEvent(m.stop.routeId);
    await _syncEvent(targetRouteId);
  }

  /// Rinumera le tappe 0..n-1 mantenendo l'ordine (dopo una rimozione).
  Future<void> _reindex(String routeId) async {
    final stops = await stopsFor(routeId);
    for (var i = 0; i < stops.length; i++) {
      if (stops[i].sequenceIndex == i) continue;
      await (_db.update(_db.sightseeingRouteStops)
            ..where((s) => s.id.equals(stops[i].id)))
          .write(SightseeingRouteStopsCompanion(sequenceIndex: Value(i)));
    }
  }

  /// Annulla [removeStop]: rimette luogo (se eliminato) e tappa nella stessa
  /// posizione, con gli stessi id.
  Future<void> restoreStop(RemovedStop removed) async {
    await _db.transaction(() async {
      final loc = removed.location;
      if (loc != null) {
        await _db.into(_db.locations).insertOnConflictUpdate(loc);
      }
      final ids = (await stopsFor(
        removed.stop.routeId,
      )).map((s) => s.id).toList();
      await _db
          .into(_db.sightseeingRouteStops)
          .insertOnConflictUpdate(removed.stop);
      final at = removed.stop.sequenceIndex.clamp(0, ids.length);
      ids.insert(at, removed.stop.id);
      for (var i = 0; i < ids.length; i++) {
        await (_db.update(_db.sightseeingRouteStops)
              ..where((s) => s.id.equals(ids[i])))
            .write(SightseeingRouteStopsCompanion(sequenceIndex: Value(i)));
      }
      await _touch(removed.stop.routeId);
    });
  }

  /// Migrazione dei vecchi "luoghi salvati" (modello pre-redesign): i luoghi
  /// scelti da "Luoghi e percorsi" che non sono tappe né usati da attività
  /// vengono raccolti in una bozza [name]. Id DETERMINISTICI (UUID v5), così
  /// più dispositivi o membri producono la stessa bozza invece di duplicarla.
  /// Idempotente. Ritorna l'id del percorso, o null se non c'era nulla.
  Future<String?> ensureSavedPlacesRoute(String tripId, String name) async {
    return _db.transaction(() async {
      final used = <String>{
        for (final s in await (_db.select(
          _db.sightseeingRouteStops,
        )..where((s) => s.tripId.equals(tripId))).get())
          s.locationId,
        for (final a in await (_db.select(
          _db.activities,
        )..where((a) => a.tripId.equals(tripId))).get())
          ?a.locationId,
      };
      final candidates =
          await (_db.select(_db.locations)
                ..where(
                  (l) =>
                      l.tripId.equals(tripId) &
                      l.source.isIn([
                        LocationSource.osm.name,
                        LocationSource.mapPick.name,
                      ]),
                )
                ..orderBy([(l) => OrderingTerm(expression: l.label)]))
              .get();
      final todo = candidates.where((l) => !used.contains(l.id)).toList();
      if (todo.isEmpty) return null;

      const uuid = Uuid();
      final routeId = uuid.v5(Namespace.url.value, 'itinera:saved:$tripId');
      await _db
          .into(_db.sightseeingRoutes)
          .insertOnConflictUpdate(
            SightseeingRoutesCompanion.insert(
              id: routeId,
              tripId: tripId,
              name: name,
            ),
          );
      var next = (await stopsFor(routeId)).length;
      for (final l in todo) {
        await _db
            .into(_db.sightseeingRouteStops)
            .insertOnConflictUpdate(
              SightseeingRouteStopsCompanion.insert(
                id: uuid.v5(
                  Namespace.url.value,
                  'itinera:stop:$routeId:${l.id}',
                ),
                routeId: routeId,
                tripId: tripId,
                locationId: l.id,
                sequenceIndex: Value(next++),
              ),
            );
      }
      return routeId;
    });
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

  /// Salva l'esito di un calcolo (distanza/durata/geometria/tratti/fonte).
  Future<void> saveComputation(
    String routeId, {
    required int distanceMeters,
    required int durationSeconds,
    required String geometryJson,
    required DistanceSource source,
    String? legsJson,
  }) async {
    await _patch(
      routeId,
      SightseeingRoutesCompanion(
        distanceMeters: Value(distanceMeters),
        durationSeconds: Value(durationSeconds),
        geometry: Value(geometryJson),
        calcSource: Value(source),
        legs: Value(legsJson),
      ),
    );
    await _syncEvent(routeId);
  }

  /// Aggancia il percorso a [dayId] come UNICO evento della tabella di marcia:
  /// crea una sola attivita' che rappresenta il percorso (Activities.routeId),
  /// con l'orario della scaletta se c'è l'ora di partenza (altrimenti tutto
  /// il giorno). Idempotente. Ritorna 1 se creato, 2 se
  /// spostato da un altro giorno, 0 se gia' presente nel giorno.
  /// Transazionale.
  Future<int> addToItinerary(
    String routeId,
    String dayId,
    String tripId,
  ) async {
    final route = await getRoute(routeId);
    if (route == null) return 0;
    final result = await _db.transaction(() async {
      // Un percorso = un evento: se è già in un altro giorno lo SPOSTO
      // (prima veniva duplicato).
      final existing =
          await (_db.select(_db.activities)
                ..where((a) => a.routeId.equals(routeId))
                ..limit(1))
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
      final all = await (_db.select(
        _db.activities,
      )..where((a) => a.dayId.equals(dayId))).get();
      final sort = all.isEmpty
          ? 0
          : all.map((a) => a.sortIndex).reduce((a, b) => a > b ? a : b) + 1;
      if (existing != null) {
        if (existing.dayId == dayId) return 0;
        await (_db.update(
          _db.activities,
        )..where((a) => a.id.equals(existing.id))).write(
          ActivitiesCompanion(
            dayId: Value(dayId),
            sortIndex: Value(sort),
            updatedAt: Value(DateTime.now()),
          ),
        );
        return 2;
      }
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
    await _syncEvent(routeId);
    return result;
  }

  Future<void> _patch(String routeId, SightseeingRoutesCompanion patch) async {
    await (_db.update(_db.sightseeingRoutes)
          ..where((r) => r.id.equals(routeId)))
        .write(patch.copyWith(updatedAt: Value(DateTime.now())));
  }

  Future<void> _touch(String routeId) =>
      _patch(routeId, const SightseeingRoutesCompanion());
}
