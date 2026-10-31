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
    return (_db.select(
      _db.packingTemplates,
    )..orderBy([(t) => OrderingTerm(expression: t.name)])).watch();
  }

  Future<int> _nextItemOrder(String tripId) async {
    final items = await (_db.select(
      _db.packingItems,
    )..where((i) => i.tripId.equals(tripId))).get();
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
    await _db
        .into(_db.packingItems)
        .insert(
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

  /// Spunta/despunta tutto: se non è completo lo completa, altrimenti azzera.
  Future<void> togglePacked(PackingItem item) async {
    final newCount = item.packedCount >= item.quantity ? 0 : item.quantity;
    await (_db.update(_db.packingItems)..where((i) => i.id.equals(item.id)))
        .write(PackingItemsCompanion(packedCount: Value(newCount)));
  }

  Future<void> setPackedCount(String id, int count) async {
    await (_db.update(_db.packingItems)..where((i) => i.id.equals(id))).write(
      PackingItemsCompanion(packedCount: Value(count)),
    );
  }

  /// Elimina un oggetto e ne restituisce la copia per [restoreItem] (null se
  /// non esiste più).
  Future<PackingItem?> deleteItem(String id) {
    return _db.transaction(() async {
      final item = await (_db.select(
        _db.packingItems,
      )..where((i) => i.id.equals(id))).getSingleOrNull();
      await (_db.delete(_db.packingItems)..where((i) => i.id.equals(id))).go();
      return item;
    });
  }

  /// Annulla [deleteItem]: la riga torna con lo stesso id e tutti i suoi dati.
  /// Il trigger riporta la voce di `_outbox` da 'delete' a 'upsert': il push
  /// azzera `deleted_at` anche se l'eliminazione era già arrivata su Supabase.
  /// Restituisce false se il viaggio non esiste più (niente da ripristinare).
  Future<bool> restoreItem(PackingItem item) {
    return _db.transaction(() async {
      if (!await _tripExists(item.tripId)) return false;
      // Il bagaglio può essere sparito nel frattempo (es. da un altro device).
      final bagId = item.bagId;
      final keepBag = bagId != null && await _bagExists(bagId);
      await _db
          .into(_db.packingItems)
          .insertOnConflictUpdate(
            keepBag ? item : item.copyWith(bagId: const Value(null)),
          );
      return true;
    });
  }

  Future<bool> _tripExists(String tripId) async {
    final row = await (_db.select(
      _db.trips,
    )..where((t) => t.id.equals(tripId))).getSingleOrNull();
    return row != null;
  }

  Future<bool> _bagExists(String bagId) async {
    final row = await (_db.select(
      _db.bags,
    )..where((b) => b.id.equals(bagId))).getSingleOrNull();
    return row != null;
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
    await _db
        .into(_db.bags)
        .insert(
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

  /// Elimina un bagaglio e restituisce quanto serve a [restoreBag] (null se
  /// non esiste più).
  Future<DeletedBag?> deleteBag(String id) {
    return _db.transaction(() async {
      final bag = await (_db.select(
        _db.bags,
      )..where((b) => b.id.equals(id))).getSingleOrNull();
      if (bag == null) return null;
      final items = await (_db.select(
        _db.packingItems,
      )..where((i) => i.bagId.equals(id))).get();
      // Gli oggetti restano (bagId -> null via ON DELETE SET NULL).
      await (_db.delete(_db.bags)..where((b) => b.id.equals(id))).go();
      return DeletedBag(bag: bag, itemIds: [for (final i in items) i.id]);
    });
  }

  /// Annulla [deleteBag]: il bagaglio torna con lo stesso id e riprende i suoi
  /// oggetti. Quelli spostati altrove o eliminati nel frattempo restano come
  /// sono. Restituisce false se il viaggio non esiste più.
  Future<bool> restoreBag(DeletedBag deleted) {
    return _db.transaction(() async {
      if (!await _tripExists(deleted.bag.tripId)) return false;
      await _db.into(_db.bags).insertOnConflictUpdate(deleted.bag);
      await (_db.update(_db.packingItems)
            ..where((i) => i.id.isIn(deleted.itemIds) & i.bagId.isNull()))
          .write(PackingItemsCompanion(bagId: Value(deleted.bag.id)));
      return true;
    });
  }

  // --- Template ---

  /// Applica un modello: aggiunge i suoi oggetti al viaggio, mappando la
  /// categoria per nome (fallback su "Varie" se assente).
  Future<int> applyTemplate(String tripId, String templateId) async {
    final tplItems =
        await (_db.select(_db.packingTemplateItems)
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
    await _db
        .into(_db.packingTemplates)
        .insert(
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

/// Bagaglio appena eliminato, con gli oggetti che conteneva: serve ad annullare.
class DeletedBag {
  const DeletedBag({required this.bag, required this.itemIds});
  final Bag bag;
  final List<String> itemIds;
}

/// Peso totale di una borsa: tara + somma(peso unitario x quantità).
/// [complete] è false se qualche oggetto non ha peso (stima parziale).
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
