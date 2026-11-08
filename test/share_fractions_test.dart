import 'package:flutter_test/flutter_test.dart';
import 'package:itinera/core/calc/share_fractions.dart';

double sum(Map<String, double> m) => m.values.fold(0, (a, b) => a + b);

void main() {
  test('in tre, un terzo a testa', () {
    final s = ShareFractions.equal(['a', 'b', 'c']);
    expect(s['a'], closeTo(0.333, 0.001));
    expect(sum(s), closeTo(1, 1e-9));
  });

  test('alzando una quota il resto si divide in proporzione', () {
    final s = ShareFractions.set(
      ShareFractions.equal(['a', 'b', 'c']),
      'a',
      0.5,
    );
    expect(s['a'], 0.5);
    expect(s['b'], closeTo(0.25, 1e-9));
    expect(s['c'], closeTo(0.25, 1e-9));
    final t = ShareFractions.set({'a': 0.5, 'b': 0.4, 'c': 0.1}, 'a', 0);
    expect(t['b'], closeTo(0.8, 1e-9));
    expect(t['c'], closeTo(0.2, 1e-9));
  });

  test('se gli altri erano a zero, il resto va in parti uguali', () {
    final s = ShareFractions.set({'a': 1, 'b': 0, 'c': 0}, 'a', 0.4);
    expect(s['b'], closeTo(0.3, 1e-9));
    expect(s['c'], closeTo(0.3, 1e-9));
  });

  test('le quote scritte a mano accettano virgola e punto', () {
    expect(ShareFractions.parse('0,4'), 0.4);
    expect(ShareFractions.parse('0.25'), 0.25);
    expect(ShareFractions.parse(',5'), 0.5);
    expect(ShareFractions.parse('1'), 1);
    expect(ShareFractions.parse('3'), 1);
    expect(ShareFractions.parse(''), isNull);
    expect(ShareFractions.parse('abc'), isNull);
    expect(ShareFractions.parse('-0,2'), isNull);
  });

  test('da solo resta 1', () {
    expect(ShareFractions.set({'a': 1}, 'a', 0.3), {'a': 1});
  });

  test('i pesi salvati diventano frazioni', () {
    final s = ShareFractions.normalize({'a': 2, 'b': 1, 'c': 1});
    expect(s['a'], 0.5);
    expect(s['b'], 0.25);
    expect(ShareFractions.normalize({'a': 0, 'b': 0}), {'a': 0.5, 'b': 0.5});
  });
}
