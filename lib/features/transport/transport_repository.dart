import 'package:drift/drift.dart';

import '../../core/calc/cost_splitter.dart';
import '../../core/enums.dart';
import '../../core/id.dart';
import '../../data/database.dart';

/// Valori di default per il calcolo carburante (da impostazioni globali).
class FuelDefaults {
  const FuelDefaults({
    required this.consumption,
    required this.unit,
    required this.priceCents,
    required this.fuelType,
  });
  final double consumption;
  final ConsumptionUnit unit;
  final int priceCents;
  final FuelType fuelType;
}

/// Esito del calcolo "chi deve a chi".
class SettlementResult {
  const SettlementResult({required this.balances, required this.settlements});
  final Map<String, int> balances;
  final List<Settlement> settlements;
}

/// Tratta appena eliminata, con quanto serve per annullare.
class DeletedSegment {
  const DeletedSegment({required this.segment, required this.linkedExpenseIds});
  final TransportSegment segment;

  /// Spese collegate: la cancellazione azzera il loro `segmentId` (SET NULL).
  final List<String> linkedExpenseIds;
}

/// Spesa appena eliminata, con le quote che se ne vanno in cascata.
class DeletedExpense {
  const DeletedExpense({required this.expense, required this.splits});
  final CostItem expense;
  final List<CostSplit> splits;
}

/// Accesso ai dati del modulo Trasporto/Viaggio.
class TransportRepository {
  TransportRepository(this._db);

  final AppDatabase _db;

  Stream<List<TransportSegment>> watchSegments(String tripId) {
    return (_db.select(_db.transportSegments)
          ..where((s) => s.tripId.equals(tripId))
          ..orderBy([(s) => OrderingTerm(expression: s.sequenceIndex)]))
        .watch();
  }

  Stream<List<Traveler>> watchTravelers(String tripId) {
    return (_db.select(_db.travelers)
          ..where((t) => t.tripId.equals(tripId))
          ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
        .watch();
  }

  Stream<List<CostItem>> watchExpenses(String tripId) {
    return (_db.select(_db.costItems)
          ..where((c) => c.tripId.equals(tripId))
          ..orderBy([
            (c) => OrderingTerm(
                expression: c.createdAt, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  Stream<List<Vehicle>> watchVehicles() {
    return (_db.select(_db.vehicles)
          ..where((v) => v.isArchived.equals(false))
          ..orderBy([(v) => OrderingTerm(expression: v.name)]))
        .watch();
  }

  Future<FuelDefaults> getFuelDefaults() async {
    final row = await (_db.select(_db.appSettings)
          ..where((s) => s.id.equals(1)))
        .getSingleOrNull();
    return FuelDefaults(
      consumption: row?.defaultFuelConsumption ?? 6.5,
      unit: ConsumptionUnit.lPer100km,
      priceCents: row?.defaultFuelPriceCents ?? 185,
      fuelType: row?.defaultFuelType ?? FuelType.petrol,
    );
  }

  // --- Tratte ---

  Future<void> addSegment({
    required String tripId,
    required TransportMode mode,
    String originLabel = '',
    String destinationLabel = '',
    double? originLat,
    double? originLng,
    double? destinationLat,
    double? destinationLng,
    double? distanceKm,
    DistanceSource distanceSource = DistanceSource.manual,
    bool isRoundTrip = false,
    double? consumption,
    ConsumptionUnit? consumptionUnit,
    int? fuelPriceCents,
    int? manualCostCents,
    String? provider,
    String? bookingRef,
    String? notes,
  }) async {
    final existing = await watchSegments(tripId).first;
    await _db.into(_db.transportSegments).insert(
          TransportSegmentsCompanion.insert(
            id: newId(),
            tripId: tripId,
            sequenceIndex: Value(existing.length),
            mode: Value(mode),
            originLabel: Value(originLabel),
            destinationLabel: Value(destinationLabel),
            originLat: Value(originLat),
            originLng: Value(originLng),
            destinationLat: Value(destinationLat),
            destinationLng: Value(destinationLng),
            distanceKm: Value(distanceKm),
            distanceSource: Value(distanceSource),
            isRoundTrip: Value(isRoundTrip),
            consumptionSnapshot: Value(consumption),
            consumptionUnitSnapshot: Value(consumptionUnit),
            fuelPriceCentsSnapshot: Value(fuelPriceCents),
            manualCostCents: Value(manualCostCents),
            provider: Value(provider),
            bookingRef: Value(bookingRef),
            notes: Value(notes),
          ),
        );
  }

  Future<void> updateSegment(
    String id, {
    required TransportMode mode,
    required String originLabel,
    required String destinationLabel,
    double? originLat,
    double? originLng,
    double? destinationLat,
    double? destinationLng,
    double? distanceKm,
    DistanceSource distanceSource = DistanceSource.manual,
    required bool isRoundTrip,
    double? consumption,
    ConsumptionUnit? consumptionUnit,
    int? fuelPriceCents,
    int? manualCostCents,
    String? provider,
    String? bookingRef,
    String? notes,
  }) async {
    await (_db.update(_db.transportSegments)..where((s) => s.id.equals(id)))
        .write(
      TransportSegmentsCompanion(
        mode: Value(mode),
        originLabel: Value(originLabel),
        destinationLabel: Value(destinationLabel),
        originLat: Value(originLat),
        originLng: Value(originLng),
        destinationLat: Value(destinationLat),
        destinationLng: Value(destinationLng),
        distanceKm: Value(distanceKm),
        distanceSource: Value(distanceSource),
        isRoundTrip: Value(isRoundTrip),
        consumptionSnapshot: Value(consumption),
        consumptionUnitSnapshot: Value(consumptionUnit),
        fuelPriceCentsSnapshot: Value(fuelPriceCents),
        manualCostCents: Value(manualCostCents),
        provider: Value(provider),
        bookingRef: Value(bookingRef),
        notes: Value(notes),
      ),
    );
  }

  /// Elimina una tratta. Ritorna ciò che serve per [restoreSegment] (null se
  /// la tratta non esiste).
  Future<DeletedSegment?> deleteSegment(String id) {
    return _db.transaction(() async {
      final segment = await (_db.select(_db.transportSegments)
            ..where((s) => s.id.equals(id)))
          .getSingleOrNull();
      if (segment == null) return null;
      final linked = await (_db.select(_db.costItems)
            ..where((c) => c.segmentId.equals(id)))
          .get();
      await (_db.delete(_db.transportSegments)..where((s) => s.id.equals(id)))
          .go();
      return DeletedSegment(
        segment: segment,
        linkedExpenseIds: [for (final c in linked) c.id],
      );
    });
  }

  /// Annulla [deleteSegment]: stessa riga e stesso id. L'inserimento porta la
  /// riga in `_outbox` come upsert, che sostituisce la delete in coda o, se
  /// già spinta, azzera `deleted_at` sul server. Se nel frattempo il viaggio
  /// è sparito non fa nulla.
  Future<void> restoreSegment(DeletedSegment deleted) async {
    final s = deleted.segment;
    await _db.transaction(() async {
      if (!await _tripExists(s.tripId)) return;
      var vehicleId = s.vehicleId;
      if (vehicleId != null &&
          await (_db.select(_db.vehicles)
                    ..where((v) => v.id.equals(vehicleId!)))
                  .getSingleOrNull() ==
              null) {
        vehicleId = null;
      }
      await _db
          .into(_db.transportSegments)
          .insertOnConflictUpdate(s.copyWith(vehicleId: Value(vehicleId)));
      if (deleted.linkedExpenseIds.isEmpty) return;
      await (_db.update(_db.costItems)
            ..where(
              (c) =>
                  c.id.isIn(deleted.linkedExpenseIds) & c.segmentId.isNull(),
            ))
          .write(CostItemsCompanion(segmentId: Value(s.id)));
    });
  }

  Future<bool> _tripExists(String tripId) async =>
      await (_db.select(_db.trips)..where((t) => t.id.equals(tripId)))
          .getSingleOrNull() !=
      null;

  // --- Viaggiatori ---

  Future<void> addTraveler(String tripId, String name) async {
    final existing = await watchTravelers(tripId).first;
    await _db.into(_db.travelers).insert(
          TravelersCompanion.insert(
            id: newId(),
            tripId: tripId,
            name: name,
            sortOrder: Value(existing.length),
          ),
        );
  }

  Future<void> renameTraveler(String id, String name) async {
    await (_db.update(_db.travelers)..where((t) => t.id.equals(id)))
        .write(TravelersCompanion(name: Value(name)));
  }

  Future<void> deleteTraveler(String id) async {
    await (_db.delete(_db.travelers)..where((t) => t.id.equals(id))).go();
  }

  // --- Veicoli ---

  Future<void> addVehicle({
    required String name,
    required FuelType fuelType,
    required double consumption,
    required ConsumptionUnit unit,
  }) async {
    await _db.into(_db.vehicles).insert(
          VehiclesCompanion.insert(
            id: newId(),
            name: name,
            fuelType: Value(fuelType),
            consumptionValue: Value(consumption),
            consumptionUnit: Value(unit),
          ),
        );
  }

  // --- Spese e divisione ---

  Future<void> addExpense({
    required String tripId,
    required CostCategory category,
    String? description,
    required int amountCents,
    String? payerId,
    required SplitMethod splitMethod,
    CostStatus status = CostStatus.actual,
    String? segmentId,
  }) async {
    final costId = newId();
    await _db.transaction(() async {
      await _db.into(_db.costItems).insert(
            CostItemsCompanion.insert(
              id: costId,
              tripId: tripId,
              category: Value(category),
              description: Value(description),
              amountCents: Value(amountCents),
              status: Value(status),
              paidByTravelerId: Value(payerId),
              splitMethod: Value(splitMethod),
              segmentId: Value(segmentId),
              date: Value(DateTime.now()),
            ),
          );
      await _writeSplits(costId, tripId, amountCents, splitMethod, payerId);
    });
  }

  Future<void> updateExpense(
    String costId, {
    required String tripId,
    required CostCategory category,
    String? description,
    required int amountCents,
    String? payerId,
    required SplitMethod splitMethod,
    required CostStatus status,
  }) async {
    await _db.transaction(() async {
      await (_db.update(_db.costItems)..where((c) => c.id.equals(costId)))
          .write(
        CostItemsCompanion(
          category: Value(category),
          description: Value(description),
          amountCents: Value(amountCents),
          status: Value(status),
          paidByTravelerId: Value(payerId),
          splitMethod: Value(splitMethod),
        ),
      );
      await (_db.delete(_db.costSplits)
            ..where((s) => s.costItemId.equals(costId)))
          .go();
      await _writeSplits(costId, tripId, amountCents, splitMethod, payerId);
    });
  }

  Future<void> _writeSplits(
    String costId,
    String tripId,
    int amountCents,
    SplitMethod method,
    String? payerId,
  ) async {
    if (method == SplitMethod.none) return;
    final travelers = await watchTravelers(tripId).first;
    if (travelers.isEmpty) return;
    final shares = travelers
        .map((t) => SplitShare(travelerId: t.id, weight: t.shareWeight))
        .toList();
    final split = CostSplitter.split(
      amountCents: amountCents,
      shares: shares,
      method: method,
      payerId: payerId,
    );
    await _db.batch((b) {
      split.forEach((travelerId, cents) {
        b.insert(
          _db.costSplits,
          CostSplitsCompanion.insert(
            id: newId(),
            costItemId: costId,
            travelerId: travelerId,
            shareAmountCents: Value(cents),
          ),
        );
      });
    });
  }

  /// Elimina una spesa (le quote vanno via in cascata). Ritorna ciò che serve
  /// per [restoreExpense] (null se la spesa non esiste).
  Future<DeletedExpense?> deleteExpense(String costId) {
    return _db.transaction(() async {
      final expense = await (_db.select(_db.costItems)
            ..where((c) => c.id.equals(costId)))
          .getSingleOrNull();
      if (expense == null) return null;
      final splits = await getSplits(costId);
      await (_db.delete(_db.costItems)..where((c) => c.id.equals(costId))).go();
      return DeletedExpense(expense: expense, splits: splits);
    });
  }

  /// Annulla [deleteExpense]: spesa e quote tornano con gli stessi id, data di
  /// creazione e rimborsi (vedi [restoreSegment] per il sync). Se nel frattempo
  /// è sparito un viaggiatore, la sua quota non torna e la spesa resta senza
  /// pagante; se è sparita la tratta collegata, resta senza tratta.
  Future<void> restoreExpense(DeletedExpense deleted) async {
    final e = deleted.expense;
    await _db.transaction(() async {
      if (!await _tripExists(e.tripId)) return;
      final travelerIds = {
        for (final t in await watchTravelers(e.tripId).first) t.id,
      };
      final segmentId = e.segmentId;
      final segmentAlive = segmentId != null &&
          await (_db.select(_db.transportSegments)
                    ..where((s) => s.id.equals(segmentId)))
                  .getSingleOrNull() !=
              null;
      await _db.into(_db.costItems).insertOnConflictUpdate(
            e.copyWith(
              paidByTravelerId: Value(
                travelerIds.contains(e.paidByTravelerId)
                    ? e.paidByTravelerId
                    : null,
              ),
              segmentId: Value(segmentAlive ? segmentId : null),
            ),
          );
      for (final split in deleted.splits) {
        if (!travelerIds.contains(split.travelerId)) continue;
        await _db.into(_db.costSplits).insertOnConflictUpdate(split);
      }
    });
  }

  // --- Rimborsi ---

  Future<List<CostSplit>> getSplits(String costItemId) {
    return (_db.select(_db.costSplits)
          ..where((s) => s.costItemId.equals(costItemId)))
        .get();
  }

  /// Segna (o annulla) come rimborsata la quota di un viaggiatore.
  Future<void> setSplitSettled(String splitId, bool settled) async {
    await (_db.update(_db.costSplits)..where((s) => s.id.equals(splitId)))
        .write(CostSplitsCompanion(settled: Value(settled)));
  }

  /// Segna (o annulla) come rimborsata l'intera spesa (tutte le quote).
  Future<void> setExpenseSettled(String costItemId, bool settled) async {
    await (_db.update(_db.costSplits)
          ..where((s) => s.costItemId.equals(costItemId)))
        .write(CostSplitsCompanion(settled: Value(settled)));
  }

  /// Calcola saldi netti e rimborsi minimi tra i viaggiatori.
  Future<SettlementResult> computeSettlement(String tripId) async {
    final expenses = await watchExpenses(tripId).first;
    final travelers = await watchTravelers(tripId).first;
    final shares = <ExpenseShare>[];
    for (final e in expenses) {
      if (e.paidByTravelerId == null) continue;
      final splits = await (_db.select(_db.costSplits)
            ..where((s) => s.costItemId.equals(e.id)))
          .get();
      if (splits.isEmpty) continue;
      // Le quote gia' rimborsate escono dal conteggio: chi le ha saldate non
      // deve piu' nulla e il pagante ha gia' ricevuto quella parte.
      final unsettled = splits.where((s) => !s.settled).toList();
      if (unsettled.isEmpty) continue;
      final settledSum = splits
          .where((s) => s.settled)
          .fold<int>(0, (a, s) => a + s.shareAmountCents);
      shares.add(ExpenseShare(
        payerId: e.paidByTravelerId!,
        amountCents: e.amountCents - settledSum,
        shares: {for (final s in unsettled) s.travelerId: s.shareAmountCents},
      ));
    }
    final balances =
        CostSplitter.netBalances(shares, travelers.map((t) => t.id));
    final settlements = CostSplitter.settleUp(balances);
    return SettlementResult(balances: balances, settlements: settlements);
  }
}
