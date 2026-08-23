import 'package:intl/intl.dart';

/// Formattazione e parsing sensibili al locale italiano.
///
/// Regola d'oro dell'app: internamente si lavora con interi (centesimi, grammi)
/// e si formatta solo in visualizzazione. Il parsing accetta la virgola
/// decimale italiana (es. "7,5").
class Fmt {
  Fmt._();

  static const String locale = 'it_IT';

  static final NumberFormat _currency =
      NumberFormat.currency(locale: locale, symbol: '€');
  static final NumberFormat _decimal1 = NumberFormat('#,##0.0', locale);
  static final NumberFormat _decimal2 = NumberFormat('#,##0.00', locale);
  static final DateFormat _date = DateFormat('dd/MM/yyyy', locale);
  static final DateFormat _dateShort = DateFormat('EEE d MMM', locale);
  static final DateFormat _dayMonth = DateFormat('d MMMM', locale);

  /// Centesimi -> "1.234,56 EUR".
  static String currencyCents(int cents) => _currency.format(cents / 100.0);

  /// Grammi -> "1,5 kg" (o "850 g" sotto il chilo).
  static String weightGrams(int grams) {
    if (grams < 1000) return '$grams g';
    return '${_decimal1.format(grams / 1000.0)} kg';
  }

  static String distanceKm(double km) => '${_decimal1.format(km)} km';

  static String liters(double l) => '${_decimal2.format(l)} L';

  static String date(DateTime d) => _date.format(d);

  static String dateShort(DateTime d) => _dateShort.format(d);

  static String dayMonth(DateTime d) => _dayMonth.format(d);

  /// Minuti-da-mezzanotte -> "09:30". Ritorna "--:--" se null.
  static String timeOfDayMinutes(int? minutes) {
    if (minutes == null) return '--:--';
    final h = (minutes ~/ 60).toString().padLeft(2, '0');
    final m = (minutes % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// Interpreta un numero inserito dall'utente accettando la virgola decimale.
  ///
  /// Gestisce sia "1.234,56" (formato IT) sia "1234.56". Ritorna null se non
  /// interpretabile come numero.
  static double? parseDecimal(String raw) {
    var s = raw.trim();
    if (s.isEmpty) return null;
    final hasComma = s.contains(',');
    final hasDot = s.contains('.');
    if (hasComma && hasDot) {
      // Assunzione: il punto e' separatore delle migliaia, la virgola decimale.
      s = s.replaceAll('.', '').replaceAll(',', '.');
    } else if (hasComma) {
      s = s.replaceAll(',', '.');
    }
    return double.tryParse(s);
  }

  /// Come [parseDecimal] ma per importi: ritorna centesimi interi.
  static int? parseMoneyToCents(String raw) {
    final v = parseDecimal(raw);
    if (v == null || !v.isFinite || v < 0) return null;
    return (v * 100).round();
  }
}
