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

  Future<void> deleteSegment(String id) async {
    await (_db.delete(_db.transportSegments)..where((s) => s.id.equals(id)))
        .go();
  }

  // --- Viaggiatori ---

  Future<void> addTraveler(String tripId, String name) async {
    await _db.transaction(() async {
      final existing = await (_db.select(_db.travelers)
            ..where((t) => t.tripId.equals(tripId)))
          .get();
      await _db.into(_db.travelers).insert(
            TravelersCompanion.insert(
              id: newId(),
              tripId: tripId,
              name: name,
              sortOrder: Value(existing.length),
            ),
          );
      // Le spese divise in parti uguali / per quota vanno ridistribuite tra i
      // viaggiatori aggiornati.
      await _rewriteVariableSplits(tripId);
    });
  }

  Future<void> renameTraveler(String id, String name) async {
    await (_db.update(_db.travelers)..where((t) => t.id.equals(id)))
        .write(TravelersCompanion(name: Value(name)));
  }

  Future<void> deleteTraveler(String id, String tripId) async {
    await _db.transaction(() async {
      await (_db.delete(_db.travelers)..where((t) => t.id.equals(id))).go();
      await _rewriteVariableSplits(tripId);
    });
  }

  /// Ricalcola le quote delle spese a divisione "uguale"/"per quota" per il
  /// viaggio, in base all'insieme corrente di viaggiatori. Le spese con
  /// divisione personalizzata o non divise non vengono toccate.
  Future<void> _rewriteVariableSplits(String tripId) async {
    final travelers = await (_db.select(_db.travelers)
          ..where((t) => t.tripId.equals(tripId)))
        .get();
    final expenses = await (_db.select(_db.costItems)
          ..where((c) => c.tripId.equals(tripId)))
        .get();
    for (final e in expenses) {
      if (e.splitMethod != SplitMethod.equal &&
          e.splitMethod != SplitMethod.weighted) {
        continue;
      }
      await (_db.delete(_db.costSplits)
            ..where((s) => s.costItemId.equals(e.id)))
          .go();
      if (travelers.isEmpty) continue;
      final shares = travelers
          .map((t) => SplitShare(travelerId: t.id, weight: t.shareWeight))
          .toList();
      final split = CostSplitter.split(
        amountCents: e.amountCents,
        shares: shares,
        method: e.splitMethod,
        payerId: e.paidByTravelerId,
      );
      for (final entry in split.entries) {
        await _db.into(_db.costSplits).insert(
              CostSplitsCompanion.insert(
                id: newId(),
                costItemId: e.id,
                travelerId: entry.key,
                shareAmountCents: Value(entry.value),
              ),
            );
      }
    }
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

  Future<void> deleteExpense(String costId) async {
    await (_db.delete(_db.costItems)..where((c) => c.id.equals(costId))).go();
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
