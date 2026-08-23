import '../../data/database.dart';

/// Logica di dominio dell'itinerario (pura, testabile).
class ItineraryDomain {
  const ItineraryDomain._();

  /// Ordina le attivita' di un giorno per orario d'inizio, poi per sortIndex.
  /// Le attivita' senza orario vanno in fondo.
  static List<Activity> sortForDisplay(List<Activity> activities) {
    final list = [...activities];
    list.sort((a, b) {
      final sa = a.startMinutes ?? 1 << 20;
      final sb = b.startMinutes ?? 1 << 20;
      if (sa != sb) return sa.compareTo(sb);
      return a.sortIndex.compareTo(b.sortIndex);
    });
    return list;
  }

  /// Ids delle attivita' che si sovrappongono nel tempo con un'altra dello
  /// stesso giorno. Ignora quelle senza orario completo o con "ignora conflitto".
  static Set<String> conflictingIds(List<Activity> activities) {
    final timed = activities
        .where((a) =>
            a.startMinutes != null && a.endMinutes != null && !a.ignoreConflict)
        .toList();
    final conflicts = <String>{};
    for (var i = 0; i < timed.length; i++) {
      for (var j = i + 1; j < timed.length; j++) {
        final a = timed[i];
        final b = timed[j];
        if (_overlap(a.startMinutes!, a.endMinutes!, b.startMinutes!,
            b.endMinutes!)) {
          conflicts.add(a.id);
          conflicts.add(b.id);
        }
      }
    }
    return conflicts;
  }

  /// Due intervalli [s,e) si sovrappongono se s1 < e2 && s2 < e1.
  static bool _overlap(int s1, int e1, int s2, int e2) {
    return s1 < e2 && s2 < e1;
  }

  /// Durata pianificata totale del giorno (minuti), sommando le attivita' con
  /// orario di inizio e fine.
  static int plannedMinutes(List<Activity> activities) {
    var total = 0;
    for (final a in activities) {
      if (a.startMinutes != null && a.endMinutes != null) {
        final d = a.endMinutes! - a.startMinutes!;
        if (d > 0) total += d;
      }
    }
    return total;
  }

  /// Costo totale del giorno in centesimi.
  static int dayCostCents(List<Activity> activities) {
    return activities.fold<int>(0, (a, act) => a + (act.costCents ?? 0));
  }
}
