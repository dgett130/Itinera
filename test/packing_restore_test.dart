import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itinera/core/id.dart';
import 'package:itinera/data/database.dart';
import 'package:itinera/data/seed.dart';
import 'package:itinera/features/packing/packing_repository.dart';

void main() {
  late AppDatabase db;
  late PackingRepository repo;
  late String catId;
  late String tripId;

  setUp(() async {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    repo = PackingRepository(db);
    await AppSeed.ensureSeeded(db);
    catId = (await db.select(db.packingCategories).get()).first.id;
    tripId = newId();
    await db
        .into(db.trips)
        .insert(TripsCompanion.insert(id: tripId, name: 'Test'));
  });

  tearDown(() async {
    await db.close();
  });

  Future<String> addBag(String name) async {
    final id = newId();
    await db
        .into(db.bags)
        .insert(
          BagsCompanion.insert(
            id: id,
            tripId: tripId,
            name: name,
            tareWeightGrams: const Value(3200),
            maxWeightGrams: const Value(23000),
            sortOrder: const Value(4),
          ),
        );
    return id;
  }

  Future<String> addItem(String name, {String? bagId}) async {
    final id = newId();
    await db
        .into(db.packingItems)
        .insert(
          PackingItemsCompanion.insert(
            id: id,
            tripId: tripId,
            categoryId: catId,
            name: name,
            bagId: Value(bagId),
            quantity: const Value(3),
            packedCount: const Value(2),
            unitWeightGrams: const Value(150),
            isEssential: const Value(true),
            sortOrder: const Value(7),
          ),
        );
    return id;
  }

  Future<PackingItem?> item(String id) => (db.select(
    db.packingItems,
  )..where((i) => i.id.equals(id))).getSingleOrNull();

  Future<Bag?> bag(String id) =>
      (db.select(db.bags)..where((b) => b.id.equals(id))).getSingleOrNull();

  /// Operazione in coda per il push (null = niente in coda).
  Future<String?> outboxOp(String table, String id) async {
    final row = await db
        .customSelect(
          'SELECT op FROM _outbox WHERE tbl = ? AND row_id = ?',
          variables: [Variable<String>(table), Variable<String>(id)],
        )
        .getSingleOrNull();
    return row?.read<String>('op');
  }

  group('oggetti', () {
    test('il ripristino riporta la riga identica', () async {
      final bagId = await addBag('Stiva');
      final id = await addItem('Magliette', bagId: bagId);
      final before = await item(id);

      final deleted = await repo.deleteItem(id);
      expect(await item(id), isNull);
      expect(deleted, before);

      expect(await repo.restoreItem(deleted!), isTrue);
      expect(await item(id), before);
    });

    test('la coda torna da delete a upsert', () async {
      final id = await addItem('Magliette');
      final deleted = await repo.deleteItem(id);
      expect(await outboxOp('packing_items', id), 'delete');

      await repo.restoreItem(deleted!);
      expect(await outboxOp('packing_items', id), 'upsert');
    });

    test('vale anche se il delete era già spinto (coda vuota)', () async {
      final id = await addItem('Magliette');
      final deleted = await repo.deleteItem(id);
      await db.customStatement('DELETE FROM _outbox');

      await repo.restoreItem(deleted!);
      expect(await outboxOp('packing_items', id), 'upsert');
    });

    test('se il bagaglio non esiste più resta senza borsa', () async {
      final bagId = await addBag('Stiva');
      final id = await addItem('Magliette', bagId: bagId);
      final deleted = await repo.deleteItem(id);
      await repo.deleteBag(bagId);

      expect(await repo.restoreItem(deleted!), isTrue);
      expect((await item(id))!.bagId, isNull);
    });

    test('se il viaggio non esiste più non fa nulla', () async {
      final id = await addItem('Magliette');
      final deleted = await repo.deleteItem(id);
      await (db.delete(db.trips)..where((t) => t.id.equals(tripId))).go();

      expect(await repo.restoreItem(deleted!), isFalse);
      expect(await item(id), isNull);
    });

    test('eliminare un oggetto già sparito restituisce null', () async {
      expect(await repo.deleteItem('nessuno'), isNull);
    });
  });

  group('bagagli', () {
    test('il ripristino riporta il bagaglio e ricollega gli oggetti', () async {
      final bagId = await addBag('Stiva');
      final a = await addItem('Magliette', bagId: bagId);
      final b = await addItem('Costume', bagId: bagId);
      final fuori = await addItem('Passaporto');
      final before = await bag(bagId);

      final deleted = await repo.deleteBag(bagId);
      expect(await bag(bagId), isNull);
      expect((await item(a))!.bagId, isNull);
      expect(deleted!.itemIds, unorderedEquals([a, b]));

      expect(await repo.restoreBag(deleted), isTrue);
      expect(await bag(bagId), before);
      expect((await item(a))!.bagId, bagId);
      expect((await item(b))!.bagId, bagId);
      expect((await item(fuori))!.bagId, isNull);
    });

    test('bagaglio e oggetti tornano in coda come upsert', () async {
      final bagId = await addBag('Stiva');
      final a = await addItem('Magliette', bagId: bagId);
      final deleted = await repo.deleteBag(bagId);
      await db.customStatement(
        "DELETE FROM _outbox WHERE tbl = 'packing_items'",
      );
      expect(await outboxOp('bags', bagId), 'delete');

      await repo.restoreBag(deleted!);
      expect(await outboxOp('bags', bagId), 'upsert');
      expect(await outboxOp('packing_items', a), 'upsert');
    });

    test('non tocca gli oggetti spostati o eliminati nel frattempo', () async {
      final bagId = await addBag('Stiva');
      final altra = await addBag('Zaino');
      final spostato = await addItem('Magliette', bagId: bagId);
      final eliminato = await addItem('Costume', bagId: bagId);
      final deleted = await repo.deleteBag(bagId);

      await repo.updateItem(
        spostato,
        categoryId: catId,
        name: 'Magliette',
        bagId: altra,
        quantity: 3,
        isEssential: true,
      );
      await repo.deleteItem(eliminato);

      await repo.restoreBag(deleted!);
      expect((await item(spostato))!.bagId, altra);
      expect(await item(eliminato), isNull);
    });

    test('se il viaggio non esiste più non fa nulla', () async {
      final bagId = await addBag('Stiva');
      final deleted = await repo.deleteBag(bagId);
      await (db.delete(db.trips)..where((t) => t.id.equals(tripId))).go();

      expect(await repo.restoreBag(deleted!), isFalse);
      expect(await bag(bagId), isNull);
    });
  });
}
