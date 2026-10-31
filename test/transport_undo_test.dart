import 'package:drift/drift.dart' show Variable;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itinera/core/enums.dart';
import 'package:itinera/core/id.dart';
import 'package:itinera/data/database.dart';
import 'package:itinera/features/transport/transport_repository.dart';

void main() {
  late AppDatabase db;
  late TransportRepository repo;
  late String tripId;
  late String a;
  late String b;

  Future<String?> outboxOp(String tbl, String id) async {
    final row = await db
        .customSelect(
          'SELECT op FROM _outbox WHERE tbl = ? AND row_id = ?',
          variables: [Variable<String>(tbl), Variable<String>(id)],
        )
        .getSingleOrNull();
    return row?.read<String>('op');
  }

  // Come dopo un push riuscito: la coda è vuota.
  Future<void> drainOutbox() => db.customStatement('DELETE FROM _outbox');

  Future<CostItem> addExpense() async {
    await repo.addExpense(
      tripId: tripId,
      category: CostCategory.food,
      description: 'Cena',
      amountCents: 6000,
      payerId: a,
      splitMethod: SplitMethod.equal,
    );
    return db.select(db.costItems).getSingle();
  }

  setUp(() async {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    repo = TransportRepository(db);
    tripId = newId();
    a = newId();
    b = newId();
    await db
        .into(db.trips)
        .insert(TripsCompanion.insert(id: tripId, name: 'T'));
    for (final (id, name) in [(a, 'A'), (b, 'B')]) {
      await db
          .into(db.travelers)
          .insert(
            TravelersCompanion.insert(id: id, tripId: tripId, name: name),
          );
    }
  });

  tearDown(() => db.close());

  group('tratte', () {
    Future<TransportSegment> addSegment(String origin) async {
      await repo.addSegment(
        tripId: tripId,
        mode: TransportMode.ferry,
        originLabel: origin,
        manualCostCents: 18000,
        provider: 'Grimaldi',
      );
      return (await repo.watchSegments(tripId).first).last;
    }

    test('annullare rimette la stessa riga nella stessa posizione', () async {
      await addSegment('Uno');
      final due = await addSegment('Due');
      await addSegment('Tre');

      final deleted = await repo.deleteSegment(due.id);
      expect(
        (await repo.watchSegments(tripId).first).map((s) => s.originLabel),
        ['Uno', 'Tre'],
      );

      await repo.restoreSegment(deleted!);
      final after = await repo.watchSegments(tripId).first;
      expect(after.map((s) => s.originLabel), ['Uno', 'Due', 'Tre']);
      expect(after[1], due);
    });

    test('la delete ancora in coda diventa un upsert', () async {
      final s = await addSegment('Uno');
      await drainOutbox();

      final deleted = await repo.deleteSegment(s.id);
      expect(await outboxOp('transport_segments', s.id), 'delete');

      await repo.restoreSegment(deleted!);
      expect(await outboxOp('transport_segments', s.id), 'upsert');
    });

    test(
      'dopo un push della delete la riga torna in coda da spingere',
      () async {
        final s = await addSegment('Uno');
        final deleted = await repo.deleteSegment(s.id);
        await drainOutbox();

        await repo.restoreSegment(deleted!);
        expect(await outboxOp('transport_segments', s.id), 'upsert');
      },
    );

    test(
      'il collegamento delle spese alla tratta viene ripristinato',
      () async {
        final s = await addSegment('Uno');
        await repo.addExpense(
          tripId: tripId,
          category: CostCategory.ticket,
          amountCents: 100,
          splitMethod: SplitMethod.none,
          segmentId: s.id,
        );

        final deleted = await repo.deleteSegment(s.id);
        expect((await db.select(db.costItems).getSingle()).segmentId, isNull);

        await repo.restoreSegment(deleted!);
        expect((await db.select(db.costItems).getSingle()).segmentId, s.id);
      },
    );

    test('tratta inesistente o viaggio sparito: nessun effetto', () async {
      expect(await repo.deleteSegment('nessuna'), isNull);

      final s = await addSegment('Uno');
      final deleted = await repo.deleteSegment(s.id);
      await (db.delete(db.trips)..where((t) => t.id.equals(tripId))).go();

      await repo.restoreSegment(deleted!);
      expect(await db.select(db.transportSegments).get(), isEmpty);
    });
  });

  group('spese', () {
    test(
      'annullare rimette spesa, quote e rimborsi con gli stessi id',
      () async {
        final e = await addExpense();
        final splits = await repo.getSplits(e.id);
        final quotaB = splits.firstWhere((s) => s.travelerId == b);
        await repo.setSplitSettled(quotaB.id, true);
        final before = await repo.getSplits(e.id);
        final saldiPrima = (await repo.computeSettlement(tripId)).balances;

        final deleted = await repo.deleteExpense(e.id);
        expect(await db.select(db.costItems).get(), isEmpty);
        expect(await db.select(db.costSplits).get(), isEmpty);

        await repo.restoreExpense(deleted!);
        // Stessa riga: pagante, data di creazione e importo compresi.
        expect(await db.select(db.costItems).getSingle(), e);
        expect(await repo.getSplits(e.id), unorderedEquals(before));
        expect((await repo.computeSettlement(tripId)).balances, saldiPrima);
      },
    );

    test('anche le quote cancellate in cascata tornano da spingere', () async {
      final e = await addExpense();
      final splits = await repo.getSplits(e.id);
      await drainOutbox();

      final deleted = await repo.deleteExpense(e.id);
      expect(await outboxOp('cost_items', e.id), 'delete');
      expect(await outboxOp('cost_splits', splits.first.id), 'delete');

      await repo.restoreExpense(deleted!);
      expect(await outboxOp('cost_items', e.id), 'upsert');
      for (final s in splits) {
        expect(await outboxOp('cost_splits', s.id), 'upsert');
      }
    });

    test(
      'un viaggiatore sparito nel frattempo non blocca il ripristino',
      () async {
        final e = await addExpense();
        final deleted = await repo.deleteExpense(e.id);

        await repo.deleteTraveler(a);
        await repo.restoreExpense(deleted!);

        final restored = await db.select(db.costItems).getSingle();
        expect(restored.paidByTravelerId, isNull);
        expect((await repo.getSplits(e.id)).map((s) => s.travelerId), [b]);
      },
    );

    test('una tratta sparita nel frattempo non blocca il ripristino', () async {
      await repo.addSegment(tripId: tripId, mode: TransportMode.train);
      final segment = (await repo.watchSegments(tripId).first).single;
      await repo.addExpense(
        tripId: tripId,
        category: CostCategory.ticket,
        amountCents: 100,
        splitMethod: SplitMethod.none,
        segmentId: segment.id,
      );
      final e = await db.select(db.costItems).getSingle();
      final deleted = await repo.deleteExpense(e.id);

      await repo.deleteSegment(segment.id);
      await repo.restoreExpense(deleted!);

      expect((await db.select(db.costItems).getSingle()).segmentId, isNull);
    });

    test('annullare due volte non duplica nulla', () async {
      final e = await addExpense();
      final deleted = await repo.deleteExpense(e.id);

      await repo.restoreExpense(deleted!);
      await repo.restoreExpense(deleted);

      expect((await db.select(db.costItems).get()).length, 1);
      expect((await db.select(db.costSplits).get()).length, 2);
    });

    test('spesa inesistente: nessun effetto', () async {
      expect(await repo.deleteExpense('nessuna'), isNull);
    });
  });
}
