/// Importo scritto col tastierino della spesa rapida: cifre, una virgola e al
/// massimo due decimali. Immutabile: ogni tasto restituisce un nuovo valore,
/// oppure null se il tasto non si puo' accettare (terzo decimale, seconda
/// virgola, troppe cifre).
class AmountEntry {
  const AmountEntry([this.text = '']);

  /// Quello che si e' digitato, con la virgola italiana ("12,5").
  final String text;

  /// Fino a 999.999 euro: abbastanza per qualunque spesa di viaggio.
  static const maxIntDigits = 6;

  bool get isEmpty => text.isEmpty;

  bool get _hasComma => text.contains(',');

  String get _intPart => _hasComma ? text.substring(0, text.indexOf(',')) : text;

  String get _decimals => _hasComma ? text.substring(text.indexOf(',') + 1) : '';

  /// Aggiunge una cifra ("0".."9") o la virgola.
  AmountEntry? press(String key) {
    if (key == ',') {
      if (_hasComma) return null;
      return AmountEntry(text.isEmpty ? '0,' : '$text,');
    }
    if (key.length != 1 || !'0123456789'.contains(key)) return null;
    if (_hasComma) {
      return _decimals.length >= 2 ? null : AmountEntry('$text$key');
    }
    // Niente zeri iniziali: "0" seguito da una cifra diventa quella cifra.
    if (text == '0') return AmountEntry(key);
    if (text.length >= maxIntDigits) return null;
    return AmountEntry('$text$key');
  }

  /// Cancella l'ultimo carattere.
  AmountEntry backspace() =>
      text.isEmpty ? this : AmountEntry(text.substring(0, text.length - 1));

  /// L'importo in centesimi.
  int get cents {
    final whole = int.tryParse(_intPart) ?? 0;
    final dec = int.tryParse(_decimals.padRight(2, '0')) ?? 0;
    return whole * 100 + dec;
  }

  /// "1.250,5": separatore delle migliaia e decimali come scritti.
  String get display {
    final digits = _intPart.isEmpty ? '0' : _intPart;
    final grouped = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) grouped.write('.');
      grouped.write(digits[i]);
    }
    return _hasComma ? '$grouped,$_decimals' : grouped.toString();
  }
}
