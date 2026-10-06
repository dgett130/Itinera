/// Rende leggibili in italiano gli orari di apertura nel formato OpenStreetMap
/// (`opening_hours`), senza interpretarli: sostituisce giorni, mesi e parole
/// chiave e mette ogni regola su una riga. Es.
/// `Mo-Fr 09:00-18:00; Su off` → `Lun–Ven 09:00–18:00` / `Dom chiuso`.
///
/// Il calcolo "aperto/chiuso a un certo orario" è un'altra cosa (parser vero);
/// qui l'obiettivo è solo mostrare il testo senza gergo.
List<String> humanizeOpeningHours(String raw) {
  final text = raw.trim();
  if (text.isEmpty) return const [];
  if (text == '24/7') return const ['Sempre aperto'];

  return text
      .split(';')
      .map((r) => r.trim())
      .where((r) => r.isNotEmpty)
      .map(_humanizeRule)
      .toList();
}

const _days = {
  'Mo': 'Lun',
  'Tu': 'Mar',
  'We': 'Mer',
  'Th': 'Gio',
  'Fr': 'Ven',
  'Sa': 'Sab',
  'Su': 'Dom',
  'PH': 'festivi',
  'SH': 'vacanze scolastiche',
};

const _months = {
  'Jan': 'gen',
  'Feb': 'feb',
  'Mar': 'mar',
  'Apr': 'apr',
  'May': 'mag',
  'Jun': 'giu',
  'Jul': 'lug',
  'Aug': 'ago',
  'Sep': 'set',
  'Oct': 'ott',
  'Nov': 'nov',
  'Dec': 'dic',
};

String _humanizeRule(String rule) {
  var s = rule;
  // Commenti tra virgolette: tieni solo il testo.
  s = s.replaceAll('"', '');
  // Parole chiave.
  s = s.replaceAllMapped(
    RegExp(r'\b(off|closed)\b', caseSensitive: false),
    (_) => 'chiuso',
  );
  s = s.replaceAll('24/7', 'sempre aperto');
  // Mesi prima dei giorni ("Mar" è sia marzo sia martedì in italiano, ma in
  // OSM i mesi hanno 3 lettere e i giorni 2: nessuna ambiguità in ingresso).
  s = s.replaceAllMapped(
    RegExp(r'\b(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\b'),
    (m) => _months[m[1]]!,
  );
  s = s.replaceAllMapped(
    RegExp(r'\b(Mo|Tu|We|Th|Fr|Sa|Su|PH|SH)\b'),
    (m) => _days[m[1]]!,
  );
  // Intervalli: trattino "lungo" tra orari, giorni e mesi.
  s = s.replaceAllMapped(
    RegExp(r'(\d{1,2}:\d{2})\s*-\s*(\d{1,2}:\d{2})'),
    (m) => '${m[1]}–${m[2]}',
  );
  s = s.replaceAllMapped(
    RegExp(r'([A-Za-zàèé]{3})-([A-Za-zàèé]{3})'),
    (m) => '${m[1]}–${m[2]}',
  );
  s = s.replaceAll(RegExp(r',\s*'), ', ');
  s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (s.isEmpty) return s;
  return s[0].toUpperCase() + s.substring(1);
}

/// Orari di apertura OSM interpretati, per il sottoinsieme più comune:
/// giorni e intervalli di giorni (`Mo-Fr`, `Sa,Su`, anche `Fr-Mo`), più fasce
/// per giorno (`09:00-13:00,15:00-19:00`), orari oltre la mezzanotte,
/// `off`/`closed` e `24/7`. Le regole successive sostituiscono le precedenti
/// per i giorni che nominano; i giorni mai nominati sono chiusi.
///
/// Tutto il resto (mesi, settimane, alba/tramonto, commenti, `+`, `||`...)
/// rende [parse] null: meglio "orari da verificare" che orari inventati.
/// Le regole che riguardano SOLO festivi o vacanze (`PH`, `SH`) vengono
/// ignorate: non sappiamo quali giorni lo siano.
class OpeningHours {
  OpeningHours._(this._week, {this.always = false});

  /// Giorno della settimana (1 = lunedì) → fasce in minuti dalla mezzanotte;
  /// la fine può superare 1440 (apertura che passa la mezzanotte).
  final Map<int, List<(int, int)>> _week;
  final bool always;

  static const _dayCodes = {
    'Mo': 1,
    'Tu': 2,
    'We': 3,
    'Th': 4,
    'Fr': 5,
    'Sa': 6,
    'Su': 7,
  };
  static final _daySel = RegExp(
    r'^((?:Mo|Tu|We|Th|Fr|Sa|Su|PH|SH)(?:-(?:Mo|Tu|We|Th|Fr|Sa|Su))?'
    r'(?:,(?:Mo|Tu|We|Th|Fr|Sa|Su|PH|SH)(?:-(?:Mo|Tu|We|Th|Fr|Sa|Su))?)*)'
    r'(?:\s+(.*))?$',
  );
  static final _range = RegExp(r'^(\d{1,2}):(\d{2})\s*-\s*(\d{1,2}):(\d{2})$');

  static OpeningHours? parse(String? raw) {
    final text = raw?.trim() ?? '';
    if (text.isEmpty) return null;
    if (text == '24/7') return OpeningHours._(const {}, always: true);
    final week = <int, List<(int, int)>>{};
    var any = false;
    for (final part in text.split(';')) {
      final rule = part.trim();
      if (rule.isEmpty) continue;
      var days = const [1, 2, 3, 4, 5, 6, 7];
      var rest = rule;
      final m = _daySel.firstMatch(rule);
      if (m != null) {
        days = _days(m[1]!);
        rest = (m[2] ?? '').trim();
        if (days.isEmpty) continue; // solo festivi/vacanze
      }
      final intervals = _intervals(rest);
      if (intervals == null) return null;
      for (final d in days) {
        week[d] = intervals;
      }
      any = true;
    }
    return any ? OpeningHours._(week) : null;
  }

  static List<int> _days(String sel) {
    final out = <int>[];
    for (final item in sel.split(',')) {
      final ends = item.split('-');
      final a = _dayCodes[ends.first];
      if (a == null) continue; // PH / SH
      final b = ends.length > 1 ? _dayCodes[ends.last]! : a;
      var d = a;
      while (true) {
        if (!out.contains(d)) out.add(d);
        if (d == b) break;
        d = d == 7 ? 1 : d + 1;
      }
    }
    return out;
  }

  static List<(int, int)>? _intervals(String rest) {
    final r = rest.toLowerCase();
    if (r == 'off' || r == 'closed') return const [];
    if (r.isEmpty) return null;
    final out = <(int, int)>[];
    for (final piece in rest.split(',')) {
      final m = _range.firstMatch(piece.trim());
      if (m == null) return null;
      final h1 = int.parse(m[1]!), m1 = int.parse(m[2]!);
      final h2 = int.parse(m[3]!), m2 = int.parse(m[4]!);
      if (h1 > 24 || h2 > 24 || m1 > 59 || m2 > 59) return null;
      final start = h1 * 60 + m1;
      var end = h2 * 60 + m2;
      if (end <= start) end += 1440;
      out.add((start, end));
    }
    return out;
  }

  List<(int, int)> _on(int weekday) => _week[weekday] ?? const [];

  /// Fasce del giorno prima che continuano dopo la mezzanotte, riportate
  /// sui minuti di [weekday].
  List<(int, int)> _spill(int weekday) => [
    for (final (_, e) in _on(weekday == 1 ? 7 : weekday - 1))
      if (e > 1440) (0, e - 1440),
  ];

  List<(int, int)> _all(int weekday) => [..._spill(weekday), ..._on(weekday)];

  /// Aperto al minuto [minute] del giorno [weekday] (1 = lunedì)?
  bool isOpen(int weekday, int minute) =>
      always || _all(weekday).any((f) => minute >= f.$1 && minute < f.$2);

  /// Mai aperto in quel giorno.
  bool closedAllDay(int weekday) => !always && _all(weekday).isEmpty;

  /// Fine della fascia aperta in corso (null se chiuso o sempre aperto).
  int? closesAt(int weekday, int minute) {
    if (always) return null;
    for (final (s, e) in _all(weekday)) {
      if (minute >= s && minute < e) return e;
    }
    return null;
  }

  /// Prima apertura dopo [minute] nello stesso giorno.
  int? opensAfter(int weekday, int minute) {
    int? best;
    for (final (s, _) in _all(weekday)) {
      if (s > minute && (best == null || s < best)) best = s;
    }
    return best;
  }

  /// Ultima chiusura prima di [minute] nello stesso giorno.
  int? closedBefore(int weekday, int minute) {
    int? best;
    for (final (_, e) in _all(weekday)) {
      if (e <= minute && (best == null || e > best)) best = e;
    }
    return best;
  }
}
