import 'package:drift/drift.dart' show OrderingTerm, Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:itinera/core/enums.dart';
import 'package:itinera/core/id.dart';
import 'package:itinera/data/database.dart';
import 'package:itinera/data/seed.dart';
import 'package:itinera/features/explore/sightseeing_route_repository.dart';

void main() {
  late AppDatabase db;
  late SightseeingRouteRepository repo;
  late String tripId;

  Future<String> loc(
    String label, {
    LocationSource source = LocationSource.osm,
  }) async {
    final id = newId();
    await db
        .into(db.locations)
        .insert(
          LocationsCompanion.insert(
            id: id,
            tripId: tripId,
            label: label,
            latitude: const Value(41.9),
            longitude: const Value(12.5),
            source: Value(source),
          ),
        );
    return id;
  }

  Future<List<String>> order(String routeId) async =>
      (await (db.select(db.sightseeingRouteStops)
                ..where((s) => s.routeId.equals(routeId))
                ..orderBy([(s) => OrderingTerm(expression: s.sequenceIndex)]))
              .get())
          .map((s) => s.locationId)
          .toList();

  Future<Set<String>> locationIds() async =>
      (await db.select(db.locations).get()).map((l) => l.id).toSet();

  setUp(() async {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    await AppSeed.ensureSeeded(db);
    repo = SightseeingRouteRepository(db);
    tripId = newId();
    await db
        .into(db.trips)
        .insert(TripsCompanion.insert(id: tripId, name: 'Roma'));
  });

  tearDown(() => db.close());

  test('togliere una tappa elimina il luogo se non usato altrove, e si '
      'può annullare nella stessa posizione', () async {
    final a = await loc('A');
    final b = await loc('B');
    final c = await loc('C');
    final r = await repo.createRoute(
      tripId: tripId,
      name: 'R',
      locationIds: [a, b, c],
    );
    final stopB = (await repo.stopsFor(r))[1];

    final removed = await repo.removeStop(stopB.id);
    expect(removed?.location?.id, b);
    expect(await order(r), [a, c]);
    expect(await locationIds(), {a, c});

    await repo.restoreStop(removed!);
    expect(await order(r), [a, b, c]);
    expect(await locationIds(), {a, b, c});
  });

  test('togliere una tappa NON elimina un luogo usato da un altro '
      'percorso', () async {
    final a = await loc('A');
    final r1 = await repo.createRoute(
      tripId: tripId,
      name: 'R1',
      locationIds: [a],
    );
    await repo.createRoute(tripId: tripId, name: 'R2', locationIds: [a]);

    final removed = await repo.removeStop((await repo.stopsFor(r1)).single.id);
    expect(removed?.location, isNull);
    expect(await locationIds(), {a});
  });

  test('eliminare un percorso elimina anche i suoi luoghi orfani', () async {
    final a = await loc('A');
    final shared = await loc('Condiviso');
    final r1 = await repo.createRoute(
      tripId: tripId,
      name: 'R1',
      locationIds: [a, shared],
    );
    await repo.createRoute(tripId: tripId, name: 'R2', locationIds: [shared]);

    await repo.deleteRoute(r1);
    expect(await locationIds(), {shared});
  });

  test('deleteIfEmpty elimina solo i percorsi senza tappe', () async {
    final a = await loc('A');
    final empty = await repo.createRoute(tripId: tripId, name: 'Vuoto');
    final full = await repo.createRoute(
      tripId: tripId,
      name: 'Pieno',
      locationIds: [a],
    );
    await repo.deleteIfEmpty(empty);
    await repo.deleteIfEmpty(full);
    expect(await repo.getRoute(empty), isNull);
    expect(await repo.getRoute(full), isNotNull);
  });

  group('migrazione "Luoghi salvati"', () {
    test('raccoglie solo i luoghi di Luoghi e percorsi non ancora usati; '
        'è idempotente e deterministica', () async {
      final orphan1 = await loc('Colosseo');
      final orphan2 = await loc('Pin', source: LocationSource.mapPick);
      final inRoute = await loc('Pantheon');
      await loc('Stazione', source: LocationSource.transportLeg);
      final forActivity = await loc('Ristorante');
      await repo.createRoute(tripId: tripId, name: 'R', locationIds: [inRoute]);
      final dayId = newId();
      await db
          .into(db.itineraryDays)
          .insert(ItineraryDaysCompanion.insert(id: dayId, tripId: tripId));
      await db
          .into(db.activities)
          .insert(
            ActivitiesCompanion.insert(
              id: newId(),
              dayId: dayId,
              tripId: tripId,
              title: 'Cena',
              locationId: Value(forActivity),
            ),
          );

      final id1 = await repo.ensureSavedPlacesRoute(tripId, 'Luoghi salvati');
      final id2 = await repo.ensureSavedPlacesRoute(tripId, 'Luoghi salvati');

      expect(id1, isNotNull);
      expect(
        id2,
        isNull,
        reason: 'secondo giro: nulla di nuovo da raccogliere',
      );
      expect((await order(id1!)).toSet(), {orphan1, orphan2});

      // Stesso viaggio su un altro dispositivo => stesso id di percorso.
      final other = AppDatabase.forExecutor(NativeDatabase.memory());
      await AppSeed.ensureSeeded(other);
      await other
          .into(other.trips)
          .insert(TripsCompanion.insert(id: tripId, name: 'Roma'));
      await other
          .into(other.locations)
          .insert(
            LocationsCompanion.insert(
              id: orphan1,
              tripId: tripId,
              label: 'Colosseo',
              source: const Value(LocationSource.osm),
            ),
          );
      final otherId = await SightseeingRouteRepository(
        other,
      ).ensureSavedPlacesRoute(tripId, 'Luoghi salvati');
      expect(otherId, id1);
      await other.close();
    });

    test('nessun luogo da migrare: nessun percorso creato', () async {
      expect(await repo.ensureSavedPlacesRoute(tripId, 'X'), isNull);
      expect(await db.select(db.sightseeingRoutes).get(), isEmpty);
    });
  });

  test('aggiungere all\'itinerario un percorso già in un altro giorno lo '
      'SPOSTA (niente doppioni)', () async {
    final a = await loc('A');
    final r = await repo.createRoute(
      tripId: tripId,
      name: 'R',
      locationIds: [a],
    );
    final d1 = newId();
    final d2 = newId();
    for (final d in [d1, d2]) {
      await db
          .into(db.itineraryDays)
          .insert(ItineraryDaysCompanion.insert(id: d, tripId: tripId));
    }

    expect(await repo.addToItinerary(r, d1, tripId), 1);
    expect(await repo.addToItinerary(r, d1, tripId), 0);
    expect(await repo.addToItinerary(r, d2, tripId), 2);

    final events = await (db.select(
      db.activities,
    )..where((x) => x.routeId.equals(r))).get();
    expect(events, hasLength(1));
    expect(events.single.dayId, d2);
    expect((await repo.getRoute(r))?.dayId, d2);
  });

  group('"Parti da"', () {
    Future<List<SightseeingRouteStop>> stops(String r) => repo.stopsFor(r);

    test('scegliere la partenza la porta in testa e la blocca', () async {
      final a = await loc('A');
      final b = await loc('B');
      final c = await loc('C');
      final r = await repo.createRoute(
        tripId: tripId,
        name: 'R',
        locationIds: [a, b, c],
      );
      final stopC = (await stops(r)).last;

      await repo.setStart(r, stopC.id);
      expect(await order(r), [c, a, b]);
      expect((await repo.getRoute(r))!.fixedStart, isTrue);
    });

    test('"solo partenza" torna una tappa normale se cambia la partenza o '
        'la partenza si sblocca', () async {
      final a = await loc('A');
      final b = await loc('B');
      final r = await repo.createRoute(
        tripId: tripId,
        name: 'R',
        locationIds: [a, b],
      );
      var s = await stops(r);
      await repo.setStart(r, s.first.id);
      await repo.setVisitMinutes(s.first.id, 0);
      expect((await stops(r)).first.visitMinutes, 0);

      await repo.setStart(r, s.last.id);
      s = await stops(r);
      expect(s.map((x) => x.locationId), [b, a]);
      expect(s.last.visitMinutes, isNull, reason: 'A non è più la partenza');

      await repo.setVisitMinutes(s.first.id, 0);
      await repo.clearStart(r);
      expect((await repo.getRoute(r))!.fixedStart, isFalse);
      expect((await stops(r)).first.visitMinutes, isNull);
    });
  });

  group('evento nella tabella di marcia allineato al percorso', () {
    late String r;
    late String day;

    Future<Activity> event() => (db.select(
      db.activities,
    )..where((a) => a.routeId.equals(r))).getSingle();

    setUp(() async {
      final a = await loc('A');
      final b = await loc('B');
      r = await repo.createRoute(
        tripId: tripId,
        name: 'R',
        locationIds: [a, b],
      );
      // Due tappe "altro" (30' ciascuna) e 10' di cammino tra loro.
      await repo.saveComputation(
        r,
        distanceMeters: 600,
        durationSeconds: 600,
        geometryJson: '[]',
        source: DistanceSource.onlineRouting,
        legsJson: '[{"m":600,"s":600}]',
      );
      day = newId();
      await db
          .into(db.itineraryDays)
          .insert(ItineraryDaysCompanion.insert(id: day, tripId: tripId));
    });

    test('senza orario resta "tutto il giorno"', () async {
      await repo.addToItinerary(r, day, tripId);
      final e = await event();
      expect(e.isAllDay, isTrue);
      expect(e.startMinutes, isNull);
    });

    test('con la partenza: inizio e fine dalla scaletta; seguono le '
        'modifiche', () async {
      await repo.setStartMinutes(r, 9 * 60);
      await repo.addToItinerary(r, day, tripId);
      var e = await event();
      expect(e.isAllDay, isFalse);
      expect(e.startMinutes, 540);
      expect(e.endMinutes, 540 + 30 + 10 + 30);

      final first = (await repo.stopsFor(r)).first;
      await repo.setVisitMinutes(first.id, 0);
      e = await event();
      expect(e.endMinutes, 540 + 10 + 30, reason: 'solo partenza');

      await repo.renameRoute(r, 'Centro storico');
      expect((await event()).title, 'Centro storico');

      await repo.setStartMinutes(r, null);
      e = await event();
      expect(e.isAllDay, isTrue);
      expect(e.startMinutes, isNull);
      expect(e.endMinutes, isNull);
    });

    test('tratti da ricalcolare: la durata resta quella di prima', () async {
      await repo.setStartMinutes(r, 9 * 60);
      await repo.addToItinerary(r, day, tripId);
      await repo.addStop(r, tripId, await loc('C'));
      await repo.setStartMinutes(r, 10 * 60);
      final e = await event();
      expect(e.startMinutes, 600);
      expect(e.endMinutes, 600 + 70);
    });
  });

  group('sposta tappa in un altro percorso', () {
    test("va in coda al percorso di arrivo; da qui sparisce e l'ordine "
        'resta compatto; Annulla la rimette al suo posto', () async {
      final a = await loc('A');
      final b = await loc('B');
      final c = await loc('C');
      final d = await loc('D');
      final from = await repo.createRoute(
        tripId: tripId,
        name: 'Da',
        locationIds: [a, b, c],
      );
      final to = await repo.createRoute(
        tripId: tripId,
        name: 'A',
        locationIds: [d],
      );
      final stopB = (await repo.stopsFor(from))[1];

      final moved = await repo.moveStop(stopB.id, to);
      expect(moved, isNotNull);
      expect(moved!.merged, isFalse);
      expect(await order(from), [a, c]);
      expect(await order(to), [d, b]);
      expect((await repo.stopsFor(from)).map((s) => s.sequenceIndex), [0, 1]);

      await repo.undoMove(moved, to);
      expect(await order(from), [a, b, c]);
      expect(await order(to), [d]);
    });

    test('luogo già nel percorso di arrivo: niente doppioni; Annulla lo '
        'rimette', () async {
      final a = await loc('A');
      final b = await loc('B');
      final from = await repo.createRoute(
        tripId: tripId,
        name: 'Da',
        locationIds: [a, b],
      );
      final to = await repo.createRoute(
        tripId: tripId,
        name: 'A',
        locationIds: [b],
      );
      final stopB = (await repo.stopsFor(from))[1];

      final moved = await repo.moveStop(stopB.id, to);
      expect(moved!.merged, isTrue);
      expect(await order(from), [a]);
      expect(await order(to), [b]);

      await repo.undoMove(moved, to);
      expect(await order(from), [a, b]);
      expect(await order(to), [b]);
    });

    test('"solo partenza" diventa una tappa normale; stesso percorso o tappa '
        'inesistente: niente da fare', () async {
      final a = await loc('A');
      final b = await loc('B');
      final from = await repo.createRoute(
        tripId: tripId,
        name: 'Da',
        locationIds: [a, b],
      );
      final to = await repo.createRoute(tripId: tripId, name: 'A');
      final first = (await repo.stopsFor(from)).first;
      await repo.setVisitMinutes(first.id, 0);

      final moved = await repo.moveStop(first.id, to);
      expect((await repo.stopsFor(to)).single.visitMinutes, isNull);
      await repo.undoMove(moved!, to);
      expect((await repo.stopsFor(from)).first.visitMinutes, 0);

      expect(await repo.moveStop(first.id, from), isNull);
      expect(await repo.moveStop('nessuna', to), isNull);
    });

    test(
      'gli eventi nella tabella di marcia seguono le nuove durate',
      () async {
        final a = await loc('A');
        final b = await loc('B');
        final from = await repo.createRoute(
          tripId: tripId,
          name: 'Da',
          locationIds: [a, b],
        );
        final to = await repo.createRoute(tripId: tripId, name: 'A');
        final day = newId();
        await db
            .into(db.itineraryDays)
            .insert(ItineraryDaysCompanion.insert(id: day, tripId: tripId));
        await repo.setStartMinutes(from, 9 * 60);
        await repo.addToItinerary(from, day, tripId);
        Future<Activity> event() => (db.select(
          db.activities,
        )..where((x) => x.routeId.equals(from))).getSingle();
        // Due tappe da 30' e 1' di cammino: 9:00–10:01.
        await repo.saveComputation(
          from,
          distanceMeters: 0,
          durationSeconds: 0,
          geometryJson: '[]',
          source: DistanceSource.straightLine,
          legsJson: '[{"m":100,"s":60}]',
        );
        expect((await event()).endMinutes, 540 + 30 + 1 + 30);

        await repo.moveStop((await repo.stopsFor(from)).last.id, to);
        await repo.saveComputation(
          from,
          distanceMeters: 0,
          durationSeconds: 0,
          geometryJson: '[]',
          source: DistanceSource.straightLine,
          legsJson: '[]',
        );
        expect((await event()).endMinutes, 540 + 30);
      },
    );
  });

  group('dividi da qui', () {
    test('le tappe da quella in poi vanno, in ordine, in una bozza nuova con '
        'lo stesso mezzo; Annulla rimette tutto', () async {
      final a = await loc('A');
      final b = await loc('B');
      final c = await loc('C');
      final d = await loc('D');
      final r = await repo.createRoute(
        tripId: tripId,
        name: 'Centro',
        locationIds: [a, b, c, d],
      );
      await repo.setMode(r, RouteTravelMode.bike);
      final stops = await repo.stopsFor(r);

      final split = await repo.splitRoute(r, stops[2].id, 'Centro (2)');
      expect(split, isNotNull);
      expect(await order(r), [a, b]);
      expect(await order(split!.newRouteId), [c, d]);
      final created = (await repo.getRoute(split.newRouteId))!;
      expect(created.name, 'Centro (2)');
      expect(created.travelMode, RouteTravelMode.bike);
      expect(created.dayId, isNull, reason: 'bozza da programmare');
      expect(
        (await repo.stopsFor(split.newRouteId)).map((s) => s.sequenceIndex),
        [0, 1],
      );

      await repo.undoSplit(r, split);
      expect(await order(r), [a, b, c, d]);
      expect(await repo.getRoute(split.newRouteId), isNull);
    });

    test('dalla prima tappa o da una tappa che non c\'è: niente', () async {
      final a = await loc('A');
      final b = await loc('B');
      final r = await repo.createRoute(
        tripId: tripId,
        name: 'R',
        locationIds: [a, b],
      );
      final first = (await repo.stopsFor(r)).first;
      expect(await repo.splitRoute(r, first.id, 'R (2)'), isNull);
      expect(await repo.splitRoute(r, 'nessuna', 'R (2)'), isNull);
      expect(await db.select(db.sightseeingRoutes).get(), hasLength(1));
    });
  });

  test('saveComputation salva anche i tratti', () async {
    final a = await loc('A');
    final r = await repo.createRoute(
      tripId: tripId,
      name: 'R',
      locationIds: [a],
    );
    await repo.saveComputation(
      r,
      distanceMeters: 600,
      durationSeconds: 480,
      geometryJson: '[]',
      source: DistanceSource.onlineRouting,
      legsJson: '[{"m":600,"s":480}]',
    );
    expect((await repo.getRoute(r))!.legs, '[{"m":600,"s":480}]');
  });
}
