import '../../core/enums.dart';
import '../../data/database.dart';
import 'itinerary_domain.dart';

/// Lo stato di un'attivita' nella scheda "Oggi" (vedi FigCraft, pagina P).
enum StepMark {
  /// Fatta: segnata a mano o finita col passare dell'ora.
  done,

  /// In corso adesso.
  now,

  /// Da fare, con un orario.
  todo,

  /// Senza orario e non ancora fatta: si spunta a mano.
  free,
}

/// Una riga della giornata.
class TodayStep {
  const TodayStep(this.activity, this.location, this.state);

  final Activity activity;
  final Location? location;
  final StepMark state;

  bool get timed => isTimed(activity);
  int get start => activity.startMinutes!;
  int get end => endOf(activity);

  static bool isTimed(Activity a) => a.startMinutes != null && !a.isAllDay;

  /// La fine: quella scritta, altrimenti un'ora dopo l'inizio (mai oltre la
  /// mezzanotte).
  static int endOf(Activity a) {
    final s = a.startMinutes!;
    final e = a.endMinutes;
    if (e != null && e > s) return e;
    if (e != null) return 24 * 60;
    return (s + 60).clamp(0, 24 * 60);
  }
}

/// Che cosa sta in evidenza nel riquadro colorato.
enum FocusKind {
  /// Nessuna attivita' nel giorno.
  free,

  /// La prossima attivita' con un orario (oggi).
  next,

  /// L'attivita' in corso (oggi).
  running,

  /// La prima senza orario ancora da fare.
  todo,

  /// La prima del giorno (domani).
  first,

  /// Tutto fatto: si guarda a domani.
  over,
}

/// La giornata di un viaggio, pronta per la scheda "Oggi".
class TodayPlan {
  const TodayPlan({
    required this.date,
    required this.dayNumber,
    required this.totalDays,
    required this.day,
    required this.steps,
    required this.focus,
    this.focusStep,
    this.minutes,
    this.progress,
    this.after,
    this.nowAfter,
    this.nowFraction = 0.5,
  });

  final DateTime date;
  final int dayNumber;
  final int totalDays;

  /// Il giorno dell'itinerario (null se l'itinerario non e' mai stato aperto).
  final ItineraryDay? day;
  final List<TodayStep> steps;

  final FocusKind focus;
  final TodayStep? focusStep;

  /// Minuti all'inizio ([FocusKind.next]) o alla fine ([FocusKind.running]).
  final int? minutes;

  /// Quanto e' passato dell'attivita' in corso, da 0 a 1.
  final double? progress;

  /// La successiva con un orario, dopo quella in corso.
  final TodayStep? after;

  /// Dove sta "adesso": null nessuna riga, -1 in cima, k dopo steps[k].
  final int? nowAfter;

  /// Dove sta "adesso" nello spazio tra le due righe, da 0 a 1.
  final double nowFraction;

  bool get isLast => dayNumber == totalDays;
  bool get isEmpty => steps.isEmpty;
  int get doneCount => steps.where((s) => s.state == StepMark.done).length;
  int get freeCount => steps.where((s) => s.state == StepMark.free).length;
  bool get anyTimed => steps.any((s) => s.timed);

  /// Il giorno [date] del viaggio. Con [nowMinutes] e' oggi (minuti dalla
  /// mezzanotte all'ora della destinazione); senza, un giorno da venire.
  /// Saltate e annullate non compaiono.
  static TodayPlan of({
    required DateTime tripStart,
    required DateTime tripEnd,
    required DateTime date,
    required List<ItineraryDay> days,
    required List<Activity> activities,
    required List<Location> locations,
    int? nowMinutes,
  }) {
    final day = _dayOn(days, date);
    final byId = {for (final l in locations) l.id: l};
    final list = ItineraryDomain.sortForDisplay([
      for (final a in activities)
        if (day != null &&
            a.dayId == day.id &&
            a.status != ActivityStatus.skipped &&
            a.status != ActivityStatus.cancelled)
          a,
    ]);
    final today = nowMinutes != null;
    final now = nowMinutes ?? 0;
    final steps = [
      for (final a in list)
        TodayStep(a, byId[a.locationId], _stateOf(a, today ? now : null)),
    ];
    final number = _days(tripStart, date) + 1;
    final total = _days(tripStart, tripEnd) + 1;

    TodayPlan plan(
      FocusKind focus, {
      TodayStep? step,
      int? minutes,
      double? progress,
      TodayStep? after,
      int? nowAfter,
      double nowFraction = 0.5,
    }) => TodayPlan(
      date: date,
      dayNumber: number,
      totalDays: total,
      day: day,
      steps: steps,
      focus: focus,
      focusStep: step,
      minutes: minutes,
      progress: progress,
      after: after,
      nowAfter: nowAfter,
      nowFraction: nowFraction,
    );

    if (steps.isEmpty) return plan(FocusKind.free);
    TodayStep? firstFree;
    for (final s in steps) {
      if (s.state == StepMark.free) {
        firstFree = s;
        break;
      }
    }
    if (!today) {
      final first = steps.firstWhere(
        (s) => s.state != StepMark.done,
        orElse: () => steps.first,
      );
      return plan(FocusKind.first, step: first);
    }

    final running = steps.indexWhere((s) => s.state == StepMark.now);
    final future = steps.indexWhere((s) => s.timed && s.state == StepMark.todo);
    if (running >= 0) {
      final r = steps[running];
      final span = r.end - r.start;
      TodayStep? after;
      for (final s in steps.skip(running + 1)) {
        if (s.timed && s.state == StepMark.todo) {
          after = s;
          break;
        }
      }
      return plan(
        FocusKind.running,
        step: r,
        minutes: r.end - now,
        progress: span <= 0 ? 0 : ((now - r.start) / span).clamp(0.0, 1.0),
        after: after,
      );
    }
    if (future >= 0) {
      final next = steps[future];
      final prev = future == 0 ? null : steps[future - 1];
      final from = prev != null && prev.timed ? prev.end : next.start - 180;
      final gap = next.start - from;
      return plan(
        FocusKind.next,
        step: next,
        minutes: next.start - now,
        nowAfter: future - 1,
        nowFraction: gap <= 0 ? 0.5 : ((now - from) / gap).clamp(0.0, 1.0),
      );
    }
    // Le attivita' con l'orario sono passate: "adesso" dopo l'ultima.
    final lastTimed = steps.lastIndexWhere((s) => s.timed);
    if (firstFree != null) {
      return plan(
        FocusKind.todo,
        step: firstFree,
        nowAfter: lastTimed >= 0 ? lastTimed : null,
      );
    }
    return plan(FocusKind.over);
  }

  static StepMark _stateOf(Activity a, int? now) {
    if (a.status == ActivityStatus.done) return StepMark.done;
    if (!TodayStep.isTimed(a)) return StepMark.free;
    if (now == null) return StepMark.todo;
    if (now >= TodayStep.endOf(a)) return StepMark.done;
    if (now >= a.startMinutes!) return StepMark.now;
    return StepMark.todo;
  }

  static ItineraryDay? _dayOn(List<ItineraryDay> days, DateTime date) {
    for (final d in days) {
      final x = d.date;
      if (x != null &&
          x.year == date.year &&
          x.month == date.month &&
          x.day == date.day) {
        return d;
      }
    }
    return null;
  }

  static int _days(DateTime from, DateTime to) => DateTime.utc(
    to.year,
    to.month,
    to.day,
  ).difference(DateTime.utc(from.year, from.month, from.day)).inDays;

  /// Il giorno [date] e' dentro il viaggio.
  static bool within(DateTime? start, DateTime? end, DateTime date) {
    if (start == null) return false;
    final d = _days(start, date);
    return d >= 0 && d <= _days(start, end ?? start);
  }
}

/// "tra 25 min", "tra 2 ore", "tra 1 ora e 10 min"; "adesso" sotto il minuto.
String inMinutes(int minutes) {
  if (minutes <= 0) return 'adesso';
  if (minutes < 60) return 'tra $minutes min';
  final h = minutes ~/ 60, m = minutes % 60;
  final hours = h == 1 ? '1 ora' : '$h ore';
  return m == 0 ? 'tra $hours' : 'tra $hours e $m min';
}
