import 'package:flutter_test/flutter_test.dart';
import 'package:itinera/core/format.dart';

void main() {
  group('Fmt.parseDecimal', () {
    test('accetta la virgola decimale italiana', () {
      expect(Fmt.parseDecimal('7,5'), 7.5);
    });

    test('accetta il punto decimale', () {
      expect(Fmt.parseDecimal('7.5'), 7.5);
    });

    test('gestisce migliaia punto + decimale virgola', () {
      expect(Fmt.parseDecimal('1.234,56'), closeTo(1234.56, 1e-9));
    });

    test('stringa non numerica -> null', () {
      expect(Fmt.parseDecimal('abc'), isNull);
      expect(Fmt.parseDecimal(''), isNull);
    });
  });

  group('Fmt.parseMoneyToCents', () {
    test('1,89 -> 189 centesimi', () {
      expect(Fmt.parseMoneyToCents('1,89'), 189);
    });

    test('valore negativo -> null', () {
      expect(Fmt.parseMoneyToCents('-5'), isNull);
    });
  });

  group('Fmt.weightGrams', () {
    test('sotto il kg in grammi', () {
      expect(Fmt.weightGrams(850), '850 g');
    });

    test('sopra il kg in chilogrammi', () {
      expect(Fmt.weightGrams(1500), contains('kg'));
    });
  });

  group('Fmt.timeOfDayMinutes', () {
    test('formatta i minuti da mezzanotte', () {
      expect(Fmt.timeOfDayMinutes(570), '09:30');
      expect(Fmt.timeOfDayMinutes(0), '00:00');
      expect(Fmt.timeOfDayMinutes(null), '--:--');
    });
  });
}
