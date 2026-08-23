import 'package:drift/drift.dart';

import '../../core/enums.dart';
import '../../core/id.dart';
import '../../data/database.dart';

/// Accesso ai dati del modulo Valigia.
class PackingRepository {
  PackingRepository(this._db);

  final AppDatabase _db;

  Stream<List<PackingCategory>> watchCategories() {
    return (_db.select(_db.packingCategories)
          ..where((c) => c.isHidden.equals(false))
          ..orderBy([(c) => OrderingTerm(expression: c.sortOrder)]))
        .watch();
  }

  Stream<List<PackingItem>> watchItems(String tripId) {
    return (_db.select(_db.packingItems)
          ..where((i) => i.tripId.equals(tripId))
          ..orderBy([(i) => OrderingTerm(expression: i.sortOrder)]))
        .watch();
  }

  Stream<List<Bag>> watchBags(String tripId) {
    return (_db.select(_db.bags)
          ..where((b) => b.tripId.equals(tripId))
          ..orderBy([(b) => OrderingTerm(expression: b.sortOrder)]))
        .watch();
  }

  Stream<List<PackingTemplate>> watchTemplates() {
    return (_db.select(_db.packingTemplates)
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .watch();
  }

  Future<int> _nextItemOrder(String tripId) async {
    final items = await (_db.select(_db.packingItems)
          ..where((i) => i.tripId.equals(tripId)))
        .get();
    if (items.isEmpty) return 0;
    return items.map((i) => i.sortOrder).reduce((a, b) => a > b ? a : b) + 1;
  }

  Future<void> addItem({
    required String tripId,
    required String categoryId,
    required String name,
    String? bagId,
    int quantity = 1,
    int? unitWeightGrams,
    bool isEssential = false,
  }) async {
    await _db.into(_db.packingItems).insert(
          PackingItemsCompanion.insert(
            id: newId(),
            tripId: tripId,
            categoryId: categoryId,
            name: name,
            bagId: Value(bagId),
            quantity: Value(quantity),
            unitWeightGrams: Value(unitWeightGrams),
            isEssential: Value(isEssential),
            sortOrder: Value(await _nextItemOrder(tripId)),
          ),
        );
  }

  Future<void> updateItem(
    String id, {
    required String categoryId,
    required String name,
    String? bagId,
    required int quantity,
    int? unitWeightGrams,
    required bool isEssential,
  }) async {
    await (_db.update(_db.packingItems)..where((i) => i.id.equals(id))).write(
      PackingItemsCompanion(
        categoryId: Value(categoryId),
        name: Value(name),
        bagId: Value(bagId),
        quantity: Value(quantity),
        unitWeightGrams: Value(unitWeightGrams),
        isEssential: Value(isEssential),
      ),
    );
  }

  /// Spunta/despunta tutto: se non e' completo lo completa, altrimenti azzera.
  Future<void> togglePacked(PackingItem item) async {
    final newCount = item.packedCount >= item.quantity ? 0 : item.quantity;
    await (_db.update(_db.packingItems)..where((i) => i.id.equals(item.id)))
        .write(PackingItemsCompanion(packedCount: Value(newCount)));
  }

  Future<void> setPackedCount(String id, int count) async {
    await (_db.update(_db.packingItems)..where((i) => i.id.equals(id)))
        .write(PackingItemsCompanion(packedCount: Value(count)));
  }

  Future<void> deleteItem(String id) async {
    await (_db.delete(_db.packingItems)..where((i) => i.id.equals(id))).go();
  }

  // --- Bagagli ---

  Future<void> addBag({
    required String tripId,
    required String name,
    BagType type = BagType.hold,
    int tareWeightGrams = 0,
    int? maxWeightGrams,
  }) async {
    final bags = await watchBags(tripId).first;
    await _db.into(_db.bags).insert(
          BagsCompanion.insert(
            id: newId(),
            tripId: tripId,
            name: name,
            type: Value(type),
            tareWeightGrams: Value(tareWeightGrams),
            maxWeightGrams: Value(maxWeightGrams),
            sortOrder: Value(bags.length),
          ),
        );
  }

  Future<void> updateBag(
    String id, {
    required String name,
    required BagType type,
    required int tareWeightGrams,
    int? maxWeightGrams,
  }) async {
    await (_db.update(_db.bags)..where((b) => b.id.equals(id))).write(
      BagsCompanion(
        name: Value(name),
        type: Value(type),
        tareWeightGrams: Value(tareWeightGrams),
        maxWeightGrams: Value(maxWeightGrams),
      ),
    );
  }

  Future<void> deleteBag(String id) async {
    // Gli oggetti restano (bagId -> null via ON DELETE SET NULL).
    await (_db.delete(_db.bags)..where((b) => b.id.equals(id))).go();
  }

  // --- Template ---

  /// Applica un modello: aggiunge i suoi oggetti al viaggio, mappando la
  /// categoria per nome (fallback su "Varie" se assente).
  Future<int> applyTemplate(String tripId, String templateId) async {
    final tplItems = await (_db.select(_db.packingTemplateItems)
          ..where((t) => t.templateId.equals(templateId))
          ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
        .get();
    final categories = await _db.select(_db.packingCategories).get();
    final byName = {for (final c in categories) c.name: c.id};
    final fallback = byName['Varie'] ?? categories.first.id;

    var order = await _nextItemOrder(tripId);
    await _db.batch((b) {
      for (final t in tplItems) {
        b.insert(
          _db.packingItems,
          PackingItemsCompanion.insert(
            id: newId(),
            tripId: tripId,
            categoryId: byName[t.categoryName] ?? fallback,
            name: t.name,
            quantity: Value(t.baseQuantity),
            unitWeightGrams: Value(t.unitWeightGrams),
            isEssential: Value(t.isEssential),
            sortOrder: Value(order++),
          ),
        );
      }
    });
    return tplItems.length;
  }

  /// Salva la lista corrente del viaggio come nuovo modello utente.
  Future<void> saveAsTemplate(String tripId, String name) async {
    final items = await watchItems(tripId).first;
    final categories = await _db.select(_db.packingCategories).get();
    final byId = {for (final c in categories) c.id: c.name};

    final templateId = newId();
    await _db.into(_db.packingTemplates).insert(
          PackingTemplatesCompanion.insert(
            id: templateId,
            name: name,
            isBuiltIn: const Value(false),
          ),
        );
    var order = 0;
    await _db.batch((b) {
      for (final it in items) {
        b.insert(
          _db.packingTemplateItems,
          PackingTemplateItemsCompanion.insert(
            id: newId(),
            templateId: templateId,
            categoryName: byId[it.categoryId] ?? 'Varie',
            name: it.name,
            baseQuantity: Value(it.quantity),
            unitWeightGrams: Value(it.unitWeightGrams),
            isEssential: Value(it.isEssential),
            sortOrder: Value(order++),
          ),
        );
      }
    });
  }
}

/// Peso totale di una borsa: tara + somma(peso unitario x quantita').
/// [complete] e' false se qualche oggetto non ha peso (stima parziale).
class BagWeight {
  const BagWeight({required this.grams, required this.complete});
  final int grams;
  final bool complete;
}

BagWeight computeBagWeight(Bag bag, List<PackingItem> itemsInBag) {
  var total = bag.tareWeightGrams;
  var complete = true;
  for (final it in itemsInBag) {
    if (it.unitWeightGrams == null) {
      complete = false;
    } else {
      total += it.unitWeightGrams! * it.quantity;
    }
  }
  return BagWeight(grams: total, complete: complete);
}
