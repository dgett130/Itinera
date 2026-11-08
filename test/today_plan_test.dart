import 'package:flutter_test/flutter_test.dart';
import 'package:itinera/core/enums.dart';
import 'package:itinera/data/database.dart';
import 'package:itinera/features/itinerary/today_plan.dart';
import 'package:itinera/features/weather/live_sky.dart';

// Weekend a Roma, 23-26 ottobre (le maschere della pagina P).
final _start = DateTime(2026, 10, 23);
final _end = DateTime(2026, 10, 26);
final _sat = DateTime(2026, 10, 25);
final _sun = DateTime(2026, 10, 26);

final _days = [
  for (var i = 0; i < 4; i++)
    ItineraryDay(
      id: 'd$i',
      tripId: 't',
      date: DateTime(2026, 10, 23 + i),
      dayIndex: i,
      sortIndex: i,
    ),
];

int _hm(String s) =>
    int.parse(s.substring(0, 2)) * 60 + int.parse(s.substring(3));

Activity _a(
  String id,
  String day,
  String? start, {
  String? end,
  String? loc,
  ActivityStatus status = ActivityStatus.planned,
  int sort = 0,
}) => Activity(
  id: id,
  dayId: day,
  tripId: 't',
  title: id,
  startMinutes: start == null ? null : _hm(start),
  endMinutes: end == null ? null : _hm(end),
  isAllDay: false,
  locationId: loc,
  currency: 'EUR',
  status: status,
  ignoreConflict: false,
  sortIndex: sort,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

final _roma = [
  _a('Colazione', 'd2', '09:00', end: '10:00', loc: 'l1'),
  _a('Capitolini', 'd2', '10:30', end: '12:30'),
  _a('Roscioli', 'd2', '13:00', end: '14:30'),
  _a('Borghese', 'd2', '16:30', end: '18:30'),
  _a('Trastevere', 'd2', '20:00'),
];

final _loc = Location(
  id: 'l1',
  tripId: 't',
  label: 'Passeggiata del Gianicolo',
  source: LocationSource.values.first,
);

TodayPlan _plan(List<Activity> acts, {DateTime? date, String? now}) =>
    TodayPlan.of(
      tripStart: _start,
      tripEnd: _end,
      date: date ?? _sat,
      days: _days,
      activities: acts,
      locations: [_loc],
      nowMinutes: now == null ? null : _hm(now),
    );

void main() {
  test('giorno del viaggio e date dentro il viaggio', () {
    final p = _plan(_roma, now: '08:35');
    expect((p.dayNumber, p.totalDays, p.isLast), (3, 4, false));
    expect(_plan(_roma, date: _sun).isLast, isTrue);
    expect(TodayPlan.within(_start, _end, DateTime(2026, 10, 26, 23)), isTrue);
    expect(TodayPlan.within(_start, _end, DateTime(2026, 10, 27)), isFalse);
    expect(TodayPlan.within(_start, _end, DateTime(2026, 10, 22)), isFalse);
    expect(TodayPlan.within(null, null, _sat), isFalse);
  });

  test('mattina: adesso in cima, la prima in evidenza col suo luogo', () {
    final p = _plan(_roma, now: '08:35');
    expect(p.focus, FocusKind.next);
    expect(p.focusStep!.activity.id, 'Colazione');
    expect(p.focusStep!.location?.label, 'Passeggiata del Gianicolo');
    expect(p.minutes, 25);
    expect(p.nowAfter, -1);
    expect(p.steps.every((s) => s.state == StepMark.todo), isTrue);
  });

  test('pomeriggio: le passate fatte, adesso tra Roscioli e Borghese', () {
    final p = _plan(_roma, now: '15:50');
    expect(p.focus, FocusKind.next);
    expect(p.focusStep!.activity.id, 'Borghese');
    expect(p.minutes, 40);
    expect(p.nowAfter, 2);
    // 14:30 -> 16:30, alle 15:50 e' a due terzi.
    expect(p.nowFraction, closeTo(80 / 120, 1e-9));
    expect(p.steps.map((s) => s.state).toList(), [
      StepMark.done,
      StepMark.done,
      StepMark.done,
      StepMark.todo,
      StepMark.todo,
    ]);
  });

  test('in corso: quanto manca alla fine, la barra e la successiva', () {
    final p = _plan(_roma, now: '13:40');
    expect(p.focus, FocusKind.running);
    expect(p.focusStep!.activity.id, 'Roscioli');
    expect(p.minutes, 50);
    expect(p.progress, closeTo(40 / 90, 1e-9));
    expect(p.after!.activity.id, 'Borghese');
    expect(p.nowAfter, isNull);
    expect(p.steps[2].state, StepMark.now);
  });

  test("senza fine un'attivita' dura un'ora", () {
    expect(_plan(_roma, now: '20:30').focus, FocusKind.running);
    expect(_plan(_roma, now: '21:00').focus, FocusKind.over);
  });

  test('sera: tutto fatto, si guarda a domani', () {
    final p = _plan(_roma, now: '22:10');
    expect(p.focus, FocusKind.over);
    expect(p.doneCount, 5);
  });

  test('senza orari: la prima da fare, si spuntano a mano', () {
    final acts = [
      _a('Trevi', 'd2', null, status: ActivityStatus.done, sort: 0),
      _a('Pantheon', 'd2', null, sort: 1),
      _a('Giolitti', 'd2', null, sort: 2),
    ];
    final p = _plan(acts, now: '11:00');
    expect(p.focus, FocusKind.todo);
    expect(p.focusStep!.activity.id, 'Pantheon');
    expect(p.freeCount, 2);
    expect(p.anyTimed, isFalse);
    expect(p.nowAfter, isNull);
  });

  test('quelle con orario passate lasciano il posto a quelle senza', () {
    final acts = [
      _a('Mattina', 'd2', '09:00', end: '10:00'),
      _a('Quando capita', 'd2', null),
    ];
    final p = _plan(acts, now: '12:00');
    expect(p.focus, FocusKind.todo);
    expect(p.focusStep!.activity.id, 'Quando capita');
    expect(p.nowAfter, 0);
  });

  test('giornata libera; saltate e annullate non contano', () {
    final acts = [
      _a('Saltata', 'd2', '10:00', status: ActivityStatus.skipped),
      _a('Annullata', 'd2', '11:00', status: ActivityStatus.cancelled),
      _a('Altro giorno', 'd1', '11:00'),
    ];
    final p = _plan(acts, now: '09:00');
    expect(p.focus, FocusKind.free);
    expect(p.isEmpty, isTrue);
  });

  test('domani: niente adesso, la prima del giorno', () {
    final acts = [
      _a('Treno', 'd3', '19:40'),
      _a('Vaticani', 'd3', '09:30', end: '12:30'),
    ];
    final p = _plan(acts, date: _sun);
    expect(p.focus, FocusKind.first);
    expect(p.focusStep!.activity.id, 'Vaticani');
    expect(p.nowAfter, isNull);
    expect(p.steps.every((s) => s.state == StepMark.todo), isTrue);
  });

  test('quanto manca, in parole', () {
    expect(inMinutes(0), 'adesso');
    expect(inMinutes(25), 'tra 25 min');
    expect(inMinutes(60), 'tra 1 ora');
    expect(inMinutes(120), 'tra 2 ore');
    expect(inMinutes(70), 'tra 1 ora e 10 min');
  });

  group('ora della destinazione', () {
    final now = DateTime.utc(2026, 7, 1, 10, 15);
    test('col fuso del meteo', () {
      final t = destinationNow(now, 139.7, offsetSeconds: 9 * 3600);
      expect((t.day, t.hour, t.minute), (1, 19, 15));
    });

    test('senza meteo, lontano: dalla longitudine', () {
      final t = destinationNow(now, -74, offsetSeconds: null);
      // New York stimata a -5 (l'ora legale non si sa).
      expect((t.hour, t.minute), (5, 15));
    });
  });
}
