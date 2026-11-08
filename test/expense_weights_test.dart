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
  late String c;

  Future<Map<String, (int, double)>> splitsOf(String costId) async {
    final splits = await repo.getSplits(costId);
    return {
      for (final s in splits) s.travelerId: (s.shareAmountCents, s.shareWeight),
    };
  }

  setUp(() async {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    repo = TransportRepository(db);
    tripId = newId();
    a = newId();
    b = newId();
    c = newId();
    await db
        .into(db.trips)
        .insert(TripsCompanion.insert(id: tripId, name: 'T'));
    for (final (id, name) in [(a, 'A'), (b, 'B'), (c, 'C')]) {
      await db
          .into(db.travelers)
          .insert(
            TravelersCompanion.insert(id: id, tripId: tripId, name: name),
          );
    }
  });

  tearDown(() => db.close());

  test(
    'le quote della spesa decidono la divisione e restano salvate',
    () async {
      final id = await repo.addExpense(
        tripId: tripId,
        category: CostCategory.food,
        amountCents: 2500,
        payerId: a,
        splitMethod: SplitMethod.weighted,
        weights: {a: 2, b: 1, c: 1},
      );
      final splits = await splitsOf(id);
      expect(splits[a], (1250, 2.0));
      expect(splits[b], (625, 1.0));
      expect(splits[c], (625, 1.0));
    },
  );

  test(
    'in tre con un terzo a testa il centesimo in piu va a chi paga',
    () async {
      final id = await repo.addExpense(
        tripId: tripId,
        category: CostCategory.food,
        amountCents: 1000,
        payerId: a,
        splitMethod: SplitMethod.weighted,
        weights: {a: 1 / 3, b: 1 / 3, c: 1 / 3},
      );
      final splits = await splitsOf(id);
      expect(splits[a]!.$1, 334);
      expect(splits[b]!.$1, 333);
      expect(splits[c]!.$1, 333);
    },
  );

  test('quota 0 esclude il viaggiatore', () async {
    final id = await repo.addExpense(
      tripId: tripId,
      category: CostCategory.food,
      amountCents: 1000,
      payerId: a,
      splitMethod: SplitMethod.weighted,
      weights: {a: 1, b: 1, c: 0},
    );
    final splits = await splitsOf(id);
    expect(splits[a]!.$1 + splits[b]!.$1, 1000);
    expect(splits[c], (0, 0.0));
  });

  test('modificando la spesa le quote si aggiornano', () async {
    final id = await repo.addExpense(
      tripId: tripId,
      category: CostCategory.food,
      amountCents: 3000,
      payerId: a,
      splitMethod: SplitMethod.equal,
    );
    await repo.updateExpense(
      id,
      tripId: tripId,
      category: CostCategory.food,
      amountCents: 3000,
      payerId: a,
      splitMethod: SplitMethod.weighted,
      status: CostStatus.actual,
      weights: {a: 3, b: 2, c: 1},
    );
    final splits = await splitsOf(id);
    expect(splits[a], (1500, 3.0));
    expect(splits[b], (1000, 2.0));
    expect(splits[c], (500, 1.0));
  });
}
