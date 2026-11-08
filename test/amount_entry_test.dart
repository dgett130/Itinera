import 'package:flutter_test/flutter_test.dart';
import 'package:itinera/core/amount_entry.dart';

AmountEntry type(String keys) {
  var e = const AmountEntry();
  for (final k in keys.split('')) {
    e = e.press(k) ?? e;
  }
  return e;
}

void main() {
  test('cifre e virgola diventano centesimi', () {
    expect(type('1250').cents, 125000);
    expect(type('12,5').cents, 1250);
    expect(type('12,50').cents, 1250);
    expect(type('0,07').cents, 7);
    expect(const AmountEntry().cents, 0);
  });

  test('la virgola da sola diventa "0,"', () {
    expect(type(',').text, '0,');
    expect(type(',5').cents, 50);
  });

  test('rifiuta seconda virgola, terzo decimale e troppe cifre', () {
    expect(type('1,').press(','), isNull);
    expect(type('1,25').press('3'), isNull);
    expect(type('999999').press('9'), isNull);
    expect(type('999999,99').cents, 99999999);
  });

  test('niente zeri iniziali', () {
    expect(type('007').text, '7');
    expect(type('0,0').text, '0,0');
  });

  test('cancella un carattere alla volta', () {
    expect(type('12,5').backspace().text, '12,');
    expect(type('12,').backspace().text, '12');
    expect(const AmountEntry().backspace().text, '');
  });

  test('mostra migliaia e decimali come scritti', () {
    expect(type('1250').display, '1.250');
    expect(type('123456,5').display, '123.456,5');
    expect(type('12,').display, '12,');
    expect(const AmountEntry().display, '0');
  });
}
