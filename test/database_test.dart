import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itinera/core/id.dart';
import 'package:itinera/data/database.dart';
import 'package:itinera/data/seed.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('il seed popola categorie e modelli di default', () async {
    await AppSeed.ensureSeeded(db);
    final packingCats = await db.select(db.packingCategories).get();
    final activityCats = await db.select(db.activityCategories).get();
    final templates = await db.select(db.packingTemplates).get();

    expect(packingCats.length, 8);
    expect(activityCats.length, 7);
    expect(templates.length, 5);
    expect(packingCats.every((c) => c.isSystem), isTrue);
  });

  test('il seed e idempotente (non duplica alla seconda chiamata)', () async {
    await AppSeed.ensureSeeded(db);
    await AppSeed.ensureSeeded(db);
    final packingCats = await db.select(db.packingCategories).get();
    expect(packingCats.length, 8);
  });

  test('eliminare un viaggio cancella in cascata bagagli e oggetti', () async {
    await AppSeed.ensureSeeded(db);
    final catId = (await db.select(db.packingCategories).get()).first.id;
    final tripId = newId();
    await db.into(db.trips).insert(
          TripsCompanion.insert(id: tripId, name: 'Test'),
        );
    final bagId = newId();
    await db.into(db.bags).insert(
          BagsCompanion.insert(id: bagId, tripId: tripId, name: 'Zaino'),
        );
    await db.into(db.packingItems).insert(
          PackingItemsCompanion.insert(
            id: newId(),
            tripId: tripId,
            categoryId: catId,
            name: 'Maglietta',
            bagId: Value(bagId),
          ),
        );

    expect((await db.select(db.packingItems).get()).length, 1);

    await (db.delete(db.trips)..where((t) => t.id.equals(tripId))).go();

    expect((await db.select(db.trips).get()), isEmpty);
    expect((await db.select(db.bags).get()), isEmpty);
    expect((await db.select(db.packingItems).get()), isEmpty);
  });

  test('eliminare un bagaglio scollega gli oggetti senza cancellarli',
      () async {
    await AppSeed.ensureSeeded(db);
    final catId = (await db.select(db.packingCategories).get()).first.id;
    final tripId = newId();
    await db.into(db.trips).insert(
          TripsCompanion.insert(id: tripId, name: 'Test'),
        );
    final bagId = newId();
    await db.into(db.bags).insert(
          BagsCompanion.insert(id: bagId, tripId: tripId, name: 'Zaino'),
        );
    final itemId = newId();
    await db.into(db.packingItems).insert(
          PackingItemsCompanion.insert(
            id: itemId,
            tripId: tripId,
            categoryId: catId,
            name: 'Maglietta',
            bagId: Value(bagId),
          ),
        );

    await (db.delete(db.bags)..where((t) => t.id.equals(bagId))).go();

    final items = await db.select(db.packingItems).get();
    expect(items.length, 1);
    expect(items.first.bagId, isNull); // scollegato, non eliminato
  });
}
