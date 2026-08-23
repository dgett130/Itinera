import '../enums.dart';

/// Quota di un viaggiatore in una divisione di spesa.
class SplitShare {
  const SplitShare({
    required this.travelerId,
    this.weight = 1.0,
    this.customCents,
  });

  final String travelerId;

  /// Peso relativo (usato dal metodo [SplitMethod.weighted]).
  final double weight;

  /// Importo esatto in centesimi (usato dal metodo [SplitMethod.custom]).
  final int? customCents;
}

/// Una spesa gia' risolta: chi ha pagato e quanto deve ciascuno.
class ExpenseShare {
  const ExpenseShare({
    required this.payerId,
    required this.amountCents,
    required this.shares,
  });

  final String payerId;
  final int amountCents;

  /// travelerId -> centesimi dovuti.
  final Map<String, int> shares;
}

/// Un rimborso suggerito: [fromTravelerId] paga [cents] a [toTravelerId].
class Settlement {
  const Settlement({
    required this.fromTravelerId,
    required this.toTravelerId,
    required this.cents,
  });

  final String fromTravelerId;
  final String toTravelerId;
  final int cents;
}

/// Divisione delle spese e calcolo del "chi deve a chi".
///
/// Tutto in centesimi interi: la somma delle quote coincide *esattamente* con
/// l'importo (nessun centesimo perso o inventato). Il resto della divisione
/// viene assegnato con il metodo del resto piu' grande, dando la precedenza a
/// chi ha pagato.
class CostSplitter {
  const CostSplitter._();

  /// Divide [amountCents] tra le [shares] secondo [method].
  ///
  /// Ritorna una mappa travelerId -> centesimi la cui somma e' esattamente
  /// [amountCents] (per i metodi diversi da [SplitMethod.custom], dove invece
  /// si rispettano gli importi indicati).
  static Map<String, int> split({
    required int amountCents,
    required List<SplitShare> shares,
    required SplitMethod method,
    String? payerId,
  }) {
    if (method == SplitMethod.none || shares.isEmpty) {
      return const {};
    }
    if (method == SplitMethod.custom) {
      return {for (final s in shares) s.travelerId: s.customCents ?? 0};
    }

    // Pesi: 1 per tutti se equal, altrimenti il peso indicato.
    final weights = <String, double>{
      for (final s in shares)
        s.travelerId: method == SplitMethod.equal ? 1.0 : (s.weight <= 0 ? 0 : s.weight),
    };
    var totalWeight = weights.values.fold<double>(0, (a, b) => a + b);
    if (totalWeight <= 0) {
      // Pesi tutti nulli: ripiega su parti uguali.
      for (final k in weights.keys) {
        weights[k] = 1.0;
      }
      totalWeight = weights.length.toDouble();
    }

    final result = <String, int>{};
    final fractional = <String, double>{};
    var allocated = 0;
    for (final s in shares) {
      final exact = amountCents * (weights[s.travelerId]! / totalWeight);
      final floor = exact.floor();
      result[s.travelerId] = floor;
      fractional[s.travelerId] = exact - floor;
      allocated += floor;
    }

    var remainder = amountCents - allocated;
    if (remainder > 0) {
      // Ordine di assegnazione del resto: prima chi ha pagato, poi per parte
      // frazionaria decrescente (a parita', ordine stabile per travelerId).
      final order = shares.map((s) => s.travelerId).toList()
        ..sort((a, b) {
          if (a == payerId && b != payerId) return -1;
          if (b == payerId && a != payerId) return 1;
          final cmp = fractional[b]!.compareTo(fractional[a]!);
          return cmp != 0 ? cmp : a.compareTo(b);
        });
      var i = 0;
      while (remainder > 0) {
        final id = order[i % order.length];
        result[id] = result[id]! + 1;
        remainder--;
        i++;
      }
    }
    return result;
  }

  /// Saldo netto per viaggiatore (positivo = deve ricevere, negativo = deve dare).
  static Map<String, int> netBalances(
    Iterable<ExpenseShare> expenses,
    Iterable<String> travelerIds,
  ) {
    final balances = <String, int>{for (final id in travelerIds) id: 0};
    for (final e in expenses) {
      balances[e.payerId] = (balances[e.payerId] ?? 0) + e.amountCents;
      e.shares.forEach((id, cents) {
        balances[id] = (balances[id] ?? 0) - cents;
      });
    }
    return balances;
  }

  /// Dai saldi netti produce un insieme minimo di rimborsi.
  ///
  /// Algoritmo greedy: abbina iterativamente il maggior debitore al maggior
  /// creditore. Non garantisce l'ottimo assoluto (problema NP-hard) ma da'
  /// risultati minimi in pratica per gruppi piccoli.
  static List<Settlement> settleUp(Map<String, int> netBalanceCents) {
    final debtors = <MapEntry<String, int>>[]; // saldo negativo
    final creditors = <MapEntry<String, int>>[]; // saldo positivo
    netBalanceCents.forEach((id, bal) {
      if (bal < 0) debtors.add(MapEntry(id, -bal));
      if (bal > 0) creditors.add(MapEntry(id, bal));
    });
    debtors.sort((a, b) => b.value.compareTo(a.value));
    creditors.sort((a, b) => b.value.compareTo(a.value));

    final settlements = <Settlement>[];
    var i = 0;
    var j = 0;
    var debt = debtors.isNotEmpty ? debtors[0].value : 0;
    var credit = creditors.isNotEmpty ? creditors[0].value : 0;
    while (i < debtors.length && j < creditors.length) {
      final pay = debt < credit ? debt : credit;
      if (pay > 0) {
        settlements.add(Settlement(
          fromTravelerId: debtors[i].key,
          toTravelerId: creditors[j].key,
          cents: pay,
        ));
      }
      debt -= pay;
      credit -= pay;
      if (debt == 0) {
        i++;
        if (i < debtors.length) debt = debtors[i].value;
      }
      if (credit == 0) {
        j++;
        if (j < creditors.length) credit = creditors[j].value;
      }
    }
    return settlements;
  }
}
