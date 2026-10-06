import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:itinera/core/id.dart';
import 'package:itinera/data/database.dart';
import 'package:itinera/data/sync/sync_mappers.dart';

/// Colonne dello schema v8 (start_minutes, legs, visit_minutes, fee): vanno
/// in push, e in pull si applicano solo se il server le restituisce.
void main() {
  late AppDatabase db;
  late Map<String, SyncTable> tables;
  late String tripId;
  late String locId;
  late String routeId;
  late String stopId;

  setUp(() async {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    tables = {for (final t in buildSyncTables(db)) t.name: t};
    tripId = newId();
    locId = newId();
    routeId = newId();
    stopId = newId();
    await db
        .into(db.trips)
        .insert(TripsCompanion.insert(id: tripId, name: 'Roma'));
    await db
        .into(db.locations)
        .insert(
          LocationsCompanion.insert(
            id: locId,
            tripId: tripId,
            label: 'Colosseo',
            fee: const Value('yes'),
          ),
        );
    await db
        .into(db.sightseeingRoutes)
        .insert(
          SightseeingRoutesCompanion.insert(
            id: routeId,
            tripId: tripId,
            name: 'Centro',
            startMinutes: const Value(540),
            legs: const Value('[{"m":600,"s":480}]'),
          ),
        );
    await db
        .into(db.sightseeingRouteStops)
        .insert(
          SightseeingRouteStopsCompanion.insert(
            id: stopId,
            routeId: routeId,
            tripId: tripId,
            locationId: locId,
            visitMinutes: const Value(0),
          ),
        );
  });

  tearDown(() => db.close());

  test('push: i campi nuovi sono inviati', () async {
    final r = await tables['sightseeing_routes']!.toRemote(db, routeId);
    expect(r!['start_minutes'], 540);
    expect(r['legs'], '[{"m":600,"s":480}]');
    final s = await tables['sightseeing_route_stops']!.toRemote(db, stopId);
    expect(s!['visit_minutes'], 0);
    final l = await tables['locations']!.toRemote(db, locId);
    expect(l!['fee'], 'yes');
  });

  test('pull da un server senza le colonne nuove: valori locali '
      'intatti', () async {
    for (final name in [
      'sightseeing_routes',
      'sightseeing_route_stops',
      'locations',
    ]) {
      final id = switch (name) {
        'sightseeing_routes' => routeId,
        'sightseeing_route_stops' => stopId,
        _ => locId,
      };
      final remote = await tables[name]!.toRemote(db, id);
      remote!
        ..remove('start_minutes')
        ..remove('legs')
        ..remove('visit_minutes')
        ..remove('fee');
      await tables[name]!.applyRemote(db, remote);
    }
    final route = await (db.select(
      db.sightseeingRoutes,
    )..where((r) => r.id.equals(routeId))).getSingle();
    expect(route.startMinutes, 540);
    expect(route.legs, isNotNull);
    final stop = await db.select(db.sightseeingRouteStops).getSingle();
    expect(stop.visitMinutes, 0);
    final loc = await db.select(db.locations).getSingle();
    expect(loc.fee, 'yes');
  });

  test('pull con le colonne nuove: valori applicati (anche null)', () async {
    final remote = await tables['sightseeing_routes']!.toRemote(db, routeId);
    remote!
      ..['start_minutes'] = 600
      ..['legs'] = null;
    await tables['sightseeing_routes']!.applyRemote(db, remote);
    final stopRemote = await tables['sightseeing_route_stops']!.toRemote(
      db,
      stopId,
    );
    stopRemote!['visit_minutes'] = 45;
    await tables['sightseeing_route_stops']!.applyRemote(db, stopRemote);

    final route = await (db.select(
      db.sightseeingRoutes,
    )..where((r) => r.id.equals(routeId))).getSingle();
    expect(route.startMinutes, 600);
    expect(route.legs, isNull);
    final stop = await db.select(db.sightseeingRouteStops).getSingle();
    expect(stop.visitMinutes, 45);
  });
}
