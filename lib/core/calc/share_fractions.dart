/// Quote di una spesa come frazioni del totale (0,33 = un terzo), sempre con
/// somma 1. Le usa la divisione "Per quota".
class ShareFractions {
  const ShareFractions._();

  /// Parti uguali tra [ids].
  static Map<String, double> equal(Iterable<String> ids) {
    final list = ids.toList();
    if (list.isEmpty) return const {};
    return {for (final id in list) id: 1 / list.length};
  }

  /// Porta qualunque insieme di pesi a frazioni con somma 1 (pesi tutti nulli
  /// = parti uguali). Serve anche per le spese salvate con pesi interi.
  static Map<String, double> normalize(Map<String, double> weights) {
    final total = weights.values.fold<double>(0, (a, w) => a + (w > 0 ? w : 0));
    if (total <= 0) return equal(weights.keys);
    return {
      for (final e in weights.entries)
        e.key: (e.value > 0 ? e.value : 0) / total,
    };
  }

  /// Una quota scritta a mano ("0,4", "0.4", ",25", "1"): sopra 1 diventa 1,
  /// null se non e' un numero.
  static double? parse(String text) {
    var t = text.trim().replaceAll(',', '.');
    if (t.startsWith('.')) t = '0$t';
    final v = double.tryParse(t);
    if (v == null || v.isNaN || v < 0) return null;
    return v > 1 ? 1 : v;
  }

  /// Imposta la quota di [id] a [value] (0..1) e divide quello che resta tra
  /// gli altri in proporzione a quanto avevano; se gli altri erano tutti a
  /// zero, in parti uguali. Con un solo viaggiatore la quota resta 1.
  static Map<String, double> set(
    Map<String, double> shares,
    String id,
    double value,
  ) {
    final others = [
      for (final k in shares.keys)
        if (k != id) k,
    ];
    if (others.isEmpty) return {id: 1};
    final v = value.clamp(0.0, 1.0);
    final rest = 1 - v;
    final othersTotal = others.fold<double>(0, (a, k) => a + shares[k]!);
    return {
      for (final k in shares.keys)
        k: k == id
            ? v
            : othersTotal <= 0
            ? rest / others.length
            : shares[k]! * rest / othersTotal,
    };
  }
}
