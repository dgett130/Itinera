import 'package:drift/drift.dart' show Value, Variable;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:itinera/core/enums.dart';
import 'package:itinera/core/id.dart';
import 'package:itinera/data/database.dart';
import 'package:itinera/data/seed.dart';
import 'package:itinera/features/itinerary/itinerary_repository.dart';

void main() {
  late AppDatabase db;
  late ItineraryRepository repo;
  late String tripId;
  late String dayId;

  Future<String?> outboxOp(String id) async {
    final row = await db
        .customSelect(
          'SELECT op FROM _outbox WHERE tbl = ? AND row_id = ?',
          variables: [Variable<String>('activities'), Variable<String>(id)],
        )
        .getSingleOrNull();
    return row?.read<String>('op');
  }

  Future<void> clearOutbox() => db.customStatement('DELETE FROM _outbox');

  Future<Activity> newActivity({
    String title = 'Galleria Borghese',
    String? locationId,
    String? routeId,
  }) async {
    final id = newId();
    await db
        .into(db.activities)
        .insert(
          ActivitiesCompanion.insert(
            id: id,
            dayId: dayId,
            tripId: tripId,
            title: title,
            startMinutes: const Value(600),
            endMinutes: const Value(660),
            costCents: const Value(1500),
            notes: const Value('Prenotato'),
            status: const Value(ActivityStatus.done),
            sortIndex: const Value(3),
            locationId: Value(locationId),
            routeId: Value(routeId),
          ),
        );
    return (db.select(
      db.activities,
    )..where((a) => a.id.equals(id))).getSingle();
  }

  Future<Activity?> read(String id) => (db.select(
    db.activities,
  )..where((a) => a.id.equals(id))).getSingleOrNull();

  setUp(() async {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    await AppSeed.ensureSeeded(db);
    repo = ItineraryRepository(db);
    tripId = newId();
    dayId = newId();
    await db
        .into(db.trips)
        .insert(TripsCompanion.insert(id: tripId, name: 'Roma'));
    await db
        .into(db.itineraryDays)
        .insert(
          ItineraryDaysCompanion.insert(
            id: dayId,
            tripId: tripId,
            date: Value(DateTime(2026, 10, 23)),
          ),
        );
  });

  tearDown(() => db.close());

  test('eliminare e ripristinare riporta la stessa riga', () async {
    final original = await newActivity();

    final removed = await repo.deleteActivity(original.id);
    expect(removed?.id, original.id);
    expect(await read(original.id), isNull);

    expect(await repo.restoreActivity(removed!), isTrue);

    final back = await read(original.id);
    expect(back, isNotNull);
    expect(back!.title, original.title);
    expect(back.dayId, original.dayId);
    expect(back.startMinutes, 600);
    expect(back.endMinutes, 660);
    expect(back.costCents, 1500);
    expect(back.notes, 'Prenotato');
    expect(back.status, ActivityStatus.done);
    expect(back.sortIndex, 3);
    expect(back.createdAt, original.createdAt);
  });

  test('il ripristino accoda un upsert, che annulla la delete', () async {
    final original = await newActivity();
    await clearOutbox();

    // Cancellazione non ancora spinta: la voce passa da delete a upsert.
    final removed = await repo.deleteActivity(original.id);
    expect(await outboxOp(original.id), 'delete');
    await repo.restoreActivity(removed!);
    expect(await outboxOp(original.id), 'upsert');

    // Cancellazione gia' spinta: coda vuota, il ripristino riaccoda l'upsert.
    final again = await repo.deleteActivity(original.id);
    await clearOutbox();
    await repo.restoreActivity(again!);
    expect(await outboxOp(original.id), 'upsert');
  });

  test('la riga tornata nel frattempo non viene sovrascritta', () async {
    final original = await newActivity();
    final removed = await repo.deleteActivity(original.id);

    // Stesso id, arrivato dal pull con le modifiche di un altro membro.
    await db
        .into(db.activities)
        .insert(
          ActivitiesCompanion.insert(
            id: original.id,
            dayId: dayId,
            tripId: tripId,
            title: 'Titolo più recente',
          ),
        );

    expect(await repo.restoreActivity(removed!), isTrue);
    expect((await read(original.id))!.title, 'Titolo più recente');
  });

  test('un luogo sparito nel frattempo diventa null, come la FK', () async {
    final locationId = newId();
    await db
        .into(db.locations)
        .insert(
          LocationsCompanion.insert(
            id: locationId,
            tripId: tripId,
            label: 'Roma',
          ),
        );
    final original = await newActivity(locationId: locationId);
    final removed = await repo.deleteActivity(original.id);
    await (db.delete(db.locations)..where((l) => l.id.equals(locationId))).go();

    expect(await repo.restoreActivity(removed!), isTrue);
    expect((await read(original.id))!.locationId, isNull);
  });

  test('se il giorno non esiste piu\' non ripristina e lo dice', () async {
    final original = await newActivity();
    final removed = await repo.deleteActivity(original.id);
    await (db.delete(db.itineraryDays)..where((d) => d.id.equals(dayId))).go();

    expect(await repo.restoreActivity(removed!), isFalse);
    expect(await read(original.id), isNull);
  });

  test('eliminare una riga che non esiste non fa nulla', () async {
    expect(await repo.deleteActivity('assente'), isNull);
  });
}
