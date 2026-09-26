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
