import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:itinera/core/enums.dart';
import 'package:itinera/core/id.dart';
import 'package:itinera/data/backup_service.dart';
import 'package:itinera/data/database.dart';
import 'package:itinera/data/seed.dart';
import 'package:itinera/features/explore/explore_repository.dart';
import 'package:itinera/features/explore/poi_discovery_service.dart';
import 'package:itinera/features/explore/poi_parser.dart';
import 'package:itinera/features/explore/sightseeing_route_repository.dart';
import 'package:itinera/features/trip/trip_repository.dart';

class _DummyPoiService implements PoiDiscoveryService {
  @override
  Future<List<PoiSuggestion>> search({
    required double lat,
    required double lng,
    required double radiusMeters,
  }) async => const [];
}

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
  });
  tearDown(() async => db.close());

  Future<String> makeTrip() async {
    final id = newId();
    await db.into(db.trips).insert(TripsCompanion.insert(id: id, name: 'Test'));
    return id;
  }

  Future<String> addLocation(
    String tripId,
    String label, {
    double? lat,
    double? lng,
  }) async {
    final id = newId();
    await db
        .into(db.locations)
        .insert(
          LocationsCompanion.insert(
            id: id,
            tripId: tripId,
            label: label,
            latitude: Value(lat),
            longitude: Value(lng),
          ),
        );
    return id;
  }

  PoiSuggestion poi(String id, String name, double lat, double lng) =>
      PoiSuggestion(
        provider: 'osm',
        externalId: id,
        name: name,
        lat: lat,
        lng: lng,
        category: PoiCategory.monument,
      );

  group('ExploreRepository.savePoi deduplica le Location', () {
    test('per external id, per nome+vicinanza, e crea i nuovi', () async {
      final repo = ExploreRepository(db, _DummyPoiService());
      final trip = await makeTrip();

      final id1 = await repo.savePoi(trip, poi('node/1', 'Duomo', 45.0, 9.0));
      // stesso external id -> stessa Location
      final id1b = await repo.savePoi(trip, poi('node/1', 'Duomo', 45.0, 9.0));
      expect(id1b, id1);
      // stesso nome, ~11 m -> dedup prudente
      final id1c = await repo.savePoi(
        trip,
        poi('node/2', ' DUOMO ', 45.0001, 9.0),
      );
      expect(id1c, id1);
      // luogo diverso -> nuova Location
      await repo.savePoi(trip, poi('node/3', 'Castello', 46.0, 10.0));

      final locs = await (db.select(
        db.locations,
      )..where((l) => l.tripId.equals(trip))).get();
      expect(locs.length, 2);
    });
  });

  group('SightseeingRouteRepository: salvataggio, riordino, cancellazione', () {
    test(
      'crea, riordina, aggiunge/rimuove tappe, elimina in cascata',
      () async {
        final repo = SightseeingRouteRepository(db);
        final trip = await makeTrip();
        final l1 = await addLocation(trip, 'A', lat: 45.0, lng: 9.0);
        final l2 = await addLocation(trip, 'B', lat: 45.1, lng: 9.1);
        final l3 = await addLocation(trip, 'C', lat: 45.2, lng: 9.2);

        final routeId = await repo.createRoute(
          tripId: trip,
          name: 'Giro',
          locationIds: [l1, l2, l3],
        );
        var stops = await repo.stopsFor(routeId);
        expect(stops.map((s) => s.locationId), [l1, l2, l3]);

        // riordino
        await repo.reorder(routeId, [stops[2].id, stops[0].id, stops[1].id]);
        stops = await repo.stopsFor(routeId);
        expect(stops.map((s) => s.locationId), [l3, l1, l2]);

        // aggiungi tappa
        final l4 = await addLocation(trip, 'D', lat: 45.3, lng: 9.3);
        await repo.addStop(routeId, trip, l4);
        expect((await repo.stopsFor(routeId)).length, 4);
        // aggiungere una tappa gia' presente non duplica
        await repo.addStop(routeId, trip, l4);
        expect((await repo.stopsFor(routeId)).length, 4);

        // rimuovi tappa
        final toRemove = (await repo.stopsFor(
          routeId,
        )).firstWhere((s) => s.locationId == l3);
        await repo.removeStop(toRemove.id);
        expect((await repo.stopsFor(routeId)).length, 3);

        // rinomina
        await repo.renameRoute(routeId, 'Nuovo nome');
        expect((await repo.getRoute(routeId))!.name, 'Nuovo nome');

        // elimina -> tappe cancellate in cascata
        await repo.deleteRoute(routeId);
        expect(await repo.getRoute(routeId), isNull);
        expect((await repo.stopsFor(routeId)), isEmpty);
      },
    );

    test('optimize/restore conserva e ripristina l\'ordine manuale', () async {
      final repo = SightseeingRouteRepository(db);
      final trip = await makeTrip();
      final l1 = await addLocation(trip, 'A', lat: 45.0, lng: 9.0);
      final l2 = await addLocation(trip, 'B', lat: 45.1, lng: 9.1);
      final routeId = await repo.createRoute(
        tripId: trip,
        name: 'R',
        locationIds: [l1, l2],
      );
      final stops = await repo.stopsFor(routeId);
      final manual = stops.map((s) => s.id).toList();

      await repo.applyOptimizedOrder(routeId, [manual[1], manual[0]]);
      expect((await repo.getRoute(routeId))!.optimized, isTrue);
      expect((await repo.stopsFor(routeId)).map((s) => s.id), [
        manual[1],
        manual[0],
      ]);

      await repo.restoreManualOrder(routeId);
      expect((await repo.getRoute(routeId))!.optimized, isFalse);
      expect((await repo.stopsFor(routeId)).map((s) => s.id), manual);
    });
  });

  group('addToItinerary (transazionale, deduplicato)', () {
    test('crea attivita\' senza orario e non duplica per giorno', () async {
      final repo = SightseeingRouteRepository(db);
      final trip = await makeTrip();
      final dayId = newId();
      await db
          .into(db.itineraryDays)
          .insert(ItineraryDaysCompanion.insert(id: dayId, tripId: trip));
      final l1 = await addLocation(trip, 'A', lat: 45.0, lng: 9.0);
      final l2 = await addLocation(trip, 'B', lat: 45.1, lng: 9.1);
      final routeId = await repo.createRoute(
        tripId: trip,
        name: 'R',
        locationIds: [l1, l2],
      );

      final added = await repo.addToItinerary(routeId, dayId, trip);
      expect(added, 2);
      final acts = await (db.select(
        db.activities,
      )..where((a) => a.dayId.equals(dayId))).get();
      expect(acts.length, 2);
      expect(acts.every((a) => a.startMinutes == null), isTrue);
      expect(acts.map((a) => a.locationId), containsAll([l1, l2]));
      // il percorso e' agganciato al giorno
      expect((await repo.getRoute(routeId))!.dayId, dayId);

      // seconda chiamata: entrambe gia' presenti -> nessuna nuova
      final added2 = await repo.addToItinerary(routeId, dayId, trip);
      expect(added2, 0);
      expect(
        (await (db.select(
          db.activities,
        )..where((a) => a.dayId.equals(dayId))).get()).length,
        2,
      );
    });
  });

  group('duplicateTrip copia luoghi (con metadati), percorsi e tappe', () {
    test('rimappa gli id delle tappe sui nuovi luoghi', () async {
      final tripRepo = TripRepository(db);
      final routeRepo = SightseeingRouteRepository(db);
      final trip = await makeTrip();
      // location con metadati POI
      final locId = newId();
      await db
          .into(db.locations)
          .insert(
            LocationsCompanion.insert(
              id: locId,
              tripId: trip,
              label: 'Duomo',
              latitude: const Value(45.0),
              longitude: const Value(9.0),
              source: const Value(LocationSource.osm),
              externalProvider: const Value('osm'),
              externalId: const Value('node/1'),
              poiCategory: const Value(PoiCategory.monument),
            ),
          );
      await routeRepo.createRoute(
        tripId: trip,
        name: 'Giro',
        mode: RouteTravelMode.car,
        returnToStart: true,
        locationIds: [locId],
      );

      final newTrip = await tripRepo.duplicateTrip(trip);
      final newLocs = await (db.select(
        db.locations,
      )..where((l) => l.tripId.equals(newTrip))).get();
      expect(newLocs.length, 1);
      expect(newLocs.first.externalId, 'node/1');
      expect(newLocs.first.poiCategory, PoiCategory.monument);

      final newRoutes = await routeRepo.watchRoutes(newTrip).first;
      expect(newRoutes.length, 1);
      expect(newRoutes.first.travelMode, RouteTravelMode.car);
      final newStops = await routeRepo.stopsFor(newRoutes.first.id);
      expect(newStops.length, 1);
      // la tappa punta al NUOVO luogo, non a quello originale
      expect(newStops.first.locationId, newLocs.first.id);
      expect(newStops.first.locationId, isNot(locId));
    });
  });

  group('backup', () {
    test('round-trip include percorsi e tappe', () async {
      await AppSeed.ensureSeeded(db);
      final routeRepo = SightseeingRouteRepository(db);
      final trip = await makeTrip();
      final l1 = await addLocation(trip, 'A', lat: 45.0, lng: 9.0);
      final l2 = await addLocation(trip, 'B', lat: 45.1, lng: 9.1);
      await routeRepo.createRoute(
        tripId: trip,
        name: 'Giro',
        locationIds: [l1, l2],
      );

      final json = await BackupService(db).exportJson();

      final target = AppDatabase.forExecutor(NativeDatabase.memory());
      await BackupService(target).importJson(json);
      final routes = await (target.select(target.sightseeingRoutes).get());
      final stops = await (target.select(target.sightseeingRouteStops).get());
      expect(routes.length, 1);
      expect(stops.length, 2);
      await target.close();
    });

    test(
      'importa un backup precedente (senza percorsi) senza errori',
      () async {
        await AppSeed.ensureSeeded(db);
        await makeTrip();
        // Simula un backup v1: esporta e rimuovi le chiavi introdotte dalla v2.
        final full =
            jsonDecode(await BackupService(db).exportJson())
                as Map<String, dynamic>;
        (full['tables'] as Map).remove('sightseeingRoutes');
        (full['tables'] as Map).remove('sightseeingRouteStops');
        full['backupVersion'] = 1;

        final target = AppDatabase.forExecutor(NativeDatabase.memory());
        await BackupService(target).importJson(jsonEncode(full));
        expect((await target.select(target.trips).get()).length, 1);
        expect((await target.select(target.sightseeingRoutes).get()), isEmpty);
        await target.close();
      },
    );
  });
}
