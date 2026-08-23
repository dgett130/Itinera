import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itinera/core/enums.dart';
import 'package:itinera/core/id.dart';
import 'package:itinera/data/database.dart';
import 'package:itinera/features/transport/transport_repository.dart';

void main() {
  late AppDatabase db;
  late TransportRepository repo;
  final tripId = newId();
  final a = newId();
  final b = newId();
  final c = newId();

  setUp(() async {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    repo = TransportRepository(db);
    await db.into(db.trips).insert(TripsCompanion.insert(id: tripId, name: 'T'));
    for (final (id, name, self) in [(a, 'A', true), (b, 'B', false), (c, 'C', false)]) {
      await db.into(db.travelers).insert(TravelersCompanion.insert(
            id: id,
            tripId: tripId,
            name: name,
            isSelfUser: Value(self),
          ));
    }
  });

  tearDown(() => db.close());

  test('divisione equa: B e C devono 30 ciascuno ad A', () async {
    await repo.addExpense(
      tripId: tripId,
      category: CostCategory.food,
      amountCents: 9000,
      payerId: a,
      splitMethod: SplitMethod.equal,
    );
    final s = await repo.computeSettlement(tripId);
    expect(s.balances[a], 6000);
    expect(s.balances[b], -3000);
    expect(s.balances[c], -3000);
    expect(s.settlements.length, 2);
    expect(s.settlements.fold<int>(0, (t, e) => t + e.cents), 6000);
  });

  test('saldando la quota di B, resta solo C a dovere ad A', () async {
    await repo.addExpense(
      tripId: tripId,
      category: CostCategory.food,
      amountCents: 9000,
      payerId: a,
      splitMethod: SplitMethod.equal,
    );
    final splits = await repo.getSplits(
      (await db.select(db.costItems).getSingle()).id,
    );
    final bSplit = splits.firstWhere((s) => s.travelerId == b);
    await repo.setSplitSettled(bSplit.id, true);

    final s = await repo.computeSettlement(tripId);
    expect(s.balances[b], 0); // B ha saldato: non deve piu' nulla
    expect(s.balances[c], -3000);
    expect(s.balances[a], 3000);
    expect(s.settlements.length, 1);
    expect(s.settlements.single.fromTravelerId, c);
    expect(s.settlements.single.toTravelerId, a);
    expect(s.settlements.single.cents, 3000);
  });

  test('saldando l\'intera spesa, nessuno deve piu\' nulla', () async {
    await repo.addExpense(
      tripId: tripId,
      category: CostCategory.food,
      amountCents: 9000,
      payerId: a,
      splitMethod: SplitMethod.equal,
    );
    final expenseId = (await db.select(db.costItems).getSingle()).id;
    await repo.setExpenseSettled(expenseId, true);

    final s = await repo.computeSettlement(tripId);
    expect(s.settlements, isEmpty);
  });
}
