import '../../core/format.dart';
import '../../data/database.dart';

/// Stato del viaggio rispetto a oggi, in parole ("tra 9 giorni", "in corso").
String tripStatusLabel(Trip trip, {DateTime? now}) {
  final n = now ?? DateTime.now();
  final today = DateTime(n.year, n.month, n.day);
  final s = trip.startDate;
  final e = trip.endDate;
  if (s == null) return 'da pianificare';
  final start = DateTime(s.year, s.month, s.day);
  final end = e == null ? start : DateTime(e.year, e.month, e.day);
  if (today.isBefore(start)) {
    final days = start.difference(today).inDays;
    return days == 1 ? 'domani' : 'tra $days giorni';
  }
  if (!today.isAfter(end)) return 'in corso';
  return 'concluso';
}

/// Il viaggio e' finito prima di oggi?
bool tripIsPast(Trip trip, {DateTime? now}) {
  final n = now ?? DateTime.now();
  final e = trip.endDate;
  return e != null && e.isBefore(DateTime(n.year, n.month, n.day));
}

/// Meta e date in una riga ("Iglesias · 23 ottobre – 28 ottobre").
String tripPlaceLine(Trip trip) {
  final parts = <String>[];
  if (trip.destination != null && trip.destination!.isNotEmpty) {
    parts.add(trip.destination!);
  } else if (trip.country != null && trip.country!.isNotEmpty) {
    parts.add(trip.country!);
  }
  final s = trip.startDate;
  final e = trip.endDate;
  if (s != null && e != null) {
    parts.add('${Fmt.dayMonth(s)} – ${Fmt.dayMonth(e)}');
  } else if (s != null) {
    parts.add(Fmt.dayMonth(s));
  }
  return parts.join(' · ');
}
