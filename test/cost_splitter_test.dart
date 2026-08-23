import 'package:flutter_test/flutter_test.dart';
import 'package:itinera/core/calc/cost_splitter.dart';
import 'package:itinera/core/enums.dart';

void main() {
  group('CostSplitter.split', () {
    test('parti uguali: la somma coincide, il resto va al pagante', () {
      final r = CostSplitter.split(
        amountCents: 1000,
        shares: const [
          SplitShare(travelerId: 'a'),
          SplitShare(travelerId: 'b'),
          SplitShare(travelerId: 'c'),
        ],
        method: SplitMethod.equal,
        payerId: 'b',
      );
      expect(r.values.fold<int>(0, (a, b) => a + b), 1000);
      expect(r['b'], 334); // il pagante assorbe il centesimo di resto
      expect(r['a'], 333);
      expect(r['c'], 333);
    });

    test('divisione pesata proporzionale', () {
      final r = CostSplitter.split(
        amountCents: 900,
        shares: const [
          SplitShare(travelerId: 'a', weight: 2),
          SplitShare(travelerId: 'b', weight: 1),
        ],
        method: SplitMethod.weighted,
        payerId: 'a',
      );
      expect(r.values.fold<int>(0, (a, b) => a + b), 900);
      expect(r['a'], 600);
      expect(r['b'], 300);
    });

    test('custom rispetta gli importi indicati', () {
      final r = CostSplitter.split(
        amountCents: 1000,
        shares: const [
          SplitShare(travelerId: 'a', customCents: 700),
          SplitShare(travelerId: 'b', customCents: 300),
        ],
        method: SplitMethod.custom,
      );
      expect(r['a'], 700);
      expect(r['b'], 300);
    });

    test('nessuna divisione ritorna vuoto', () {
      final r = CostSplitter.split(
        amountCents: 1000,
        shares: const [SplitShare(travelerId: 'a')],
        method: SplitMethod.none,
      );
      expect(r, isEmpty);
    });

    test('pesi tutti nulli ripiega su parti uguali', () {
      final r = CostSplitter.split(
        amountCents: 1000,
        shares: const [
          SplitShare(travelerId: 'a', weight: 0),
          SplitShare(travelerId: 'b', weight: 0),
        ],
        method: SplitMethod.weighted,
      );
      expect(r.values.fold<int>(0, (a, b) => a + b), 1000);
      expect(r['a'], 500);
      expect(r['b'], 500);
    });
  });

  group('CostSplitter.netBalances + settleUp', () {
    test('A anticipa 90 per tre, gli altri due gli devono 30 ciascuno', () {
      final expenses = [
        const ExpenseShare(
          payerId: 'a',
          amountCents: 9000,
          shares: {'a': 3000, 'b': 3000, 'c': 3000},
        ),
      ];
      final balances = CostSplitter.netBalances(expenses, ['a', 'b', 'c']);
      expect(balances['a'], 6000);
      expect(balances['b'], -3000);
      expect(balances['c'], -3000);

      final settlements = CostSplitter.settleUp(balances);
      // Tutti i debitori pagano il creditore A.
      final toA = settlements.where((s) => s.toTravelerId == 'a').toList();
      expect(toA.length, 2);
      expect(settlements.fold<int>(0, (sum, s) => sum + s.cents), 6000);
      for (final s in settlements) {
        expect(s.fromTravelerId, isIn(['b', 'c']));
      }
    });

    test('conti gia pari: nessun rimborso', () {
      final balances = {'a': 0, 'b': 0};
      expect(CostSplitter.settleUp(balances), isEmpty);
    });
  });
}
