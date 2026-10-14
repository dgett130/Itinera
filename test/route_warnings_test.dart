import 'package:flutter_test/flutter_test.dart';

import 'package:itinera/core/enums.dart';
import 'package:itinera/features/explore/opening_hours.dart';
import 'package:itinera/features/explore/route_schedule.dart';
import 'package:itinera/features/explore/route_warnings.dart';
import 'package:itinera/features/transport/routing_service.dart';

int _m(int h, [int m = 0]) => h * 60 + m;

void main() {
  group('OpeningHours.parse', () {
    test('giorni, intervalli e più fasce', () {
      final oh = OpeningHours.parse(
        'Mo-Fr 09:00-13:00,15:00-19:00; Sa 10:00-12:00',
      )!;
      expect(oh.isOpen(1, _m(10)), isTrue);
      expect(oh.isOpen(1, _m(14)), isFalse);
      expect(oh.opensAfter(1, _m(14)), _m(15));
      expect(oh.closedBefore(1, _m(14)), _m(13));
      expect(oh.closesAt(1, _m(16)), _m(19));
      expect(oh.isOpen(6, _m(11)), isTrue);
      expect(oh.closedAllDay(7), isTrue, reason: 'domenica mai nominata');
    });

    test('off, regole successive che sostituiscono, giorni a cavallo', () {
      final oh = OpeningHours.parse('Mo-Su 09:00-18:00; Tu off')!;
      expect(oh.closedAllDay(2), isTrue);
      expect(oh.isOpen(3, _m(9)), isTrue);
      final wrap = OpeningHours.parse('Fr-Mo 10:00-12:00')!;
      expect(
        [for (var d = 1; d <= 7; d++) wrap.isOpen(d, _m(11))],
        [true, false, false, false, true, true, true],
      );
    });

    test('senza giorni vale tutti i giorni; 24/7 sempre aperto', () {
      expect(OpeningHours.parse('08:00-20:00')!.isOpen(7, _m(8)), isTrue);
      final always = OpeningHours.parse('24/7')!;
      expect(always.isOpen(3, _m(3)), isTrue);
      expect(always.closesAt(3, _m(3)), isNull);
    });

    test('orari oltre la mezzanotte proseguono il giorno dopo', () {
      final oh = OpeningHours.parse('Fr 20:00-02:00')!;
      expect(oh.isOpen(5, _m(23)), isTrue);
      expect(oh.closesAt(5, _m(23)), _m(26));
      expect(oh.isOpen(6, _m(1)), isTrue);
      expect(oh.isOpen(6, _m(3)), isFalse);
    });

    test('prossima apertura: oggi, domani o tra qualche giorno', () {
      final oh = OpeningHours.parse('Tu-Sa 09:00-13:00,15:00-19:00')!;
      expect(oh.nextOpening(2, _m(14)), (0, _m(15)), reason: 'stesso giorno');
      expect(oh.nextOpening(2, _m(20)), (1, _m(9)), reason: 'domani');
      expect(oh.nextOpening(6, _m(20)), (3, _m(9)), reason: 'sab → mar');
      expect(oh.nextOpening(1, _m(10)), (1, _m(9)), reason: 'lun chiuso');
      // La fascia notturna che prosegue non è una "apertura".
      final night = OpeningHours.parse('Fr 20:00-02:00')!;
      expect(night.nextOpening(5, _m(3)), (0, _m(20)));
      expect(night.nextOpening(6, _m(1)), (6, _m(20)));
      expect(OpeningHours.parse('24/7')!.nextOpening(1, 0), isNull);
      expect(OpeningHours.parse('Mo off')!.nextOpening(1, 0), isNull);
    });

    test('regole solo per festivi ignorate', () {
      final oh = OpeningHours.parse('Mo-Su 09:00-19:00; PH off')!;
      expect(oh.isOpen(7, _m(10)), isTrue);
    });

    test('sintassi non supportata: null (orari da verificare)', () {
      for (final raw in [
        'Apr-Oct: Mo-Su 09:00-19:00',
        'Mo-Fr 09:00-18:00 "su prenotazione"',
        'sunrise-sunset',
        'Mo-Fr 10:00+',
        '',
      ]) {
        expect(OpeningHours.parse(raw), isNull, reason: raw);
      }
    });
  });

  group('routeWarnings', () {
    // Partenza 9:00: museo 9:00–10:30, 15' a piedi, chiesa 10:45–11:15.
    final schedule = buildSchedule(
      stops: const [
        ScheduleStop(hasCoords: true, visitMinutes: 90),
        ScheduleStop(hasCoords: true, visitMinutes: 30),
      ],
      legs: const [RouteLeg(1200, 900)],
    )!;

    List<RouteWarning> run(
      List<String?> hours, {
      int? start = 9 * 60,
      int? weekday = 1,
      List<int> visits = const [90, 30],
      WarningSettings settings = const WarningSettings(),
      RouteSchedule? s,
      RouteTravelMode mode = RouteTravelMode.walk,
    }) => routeWarnings(
      schedule: s ?? schedule,
      openingHours: hours,
      visitMinutes: visits,
      mode: mode,
      settings: settings,
      startMinutes: start,
      weekday: weekday,
    );

    test('apre più tardi, chiuso quel giorno, chiude durante la visita', () {
      final w = run(['Mo-Su 10:00-18:00', 'Tu-Su 09:00-12:00']);
      expect(w.map((x) => x.kind), [
        WarningKind.opensLater,
        WarningKind.closedDay,
      ]);
      expect(w.first.a, _m(10));
      expect(w.first.b, _m(9));
      expect(w.first.stopIndex, 0);

      final during = run(['Mo-Su 08:00-10:00', null]);
      expect(during.single.kind, WarningKind.closesDuringVisit);
      expect(during.single.a, _m(10));
    });

    test('già chiuso all\'arrivo', () {
      final w = run([null, 'Mo-Su 08:00-10:00']);
      expect(w.single.kind, WarningKind.closedEarlier);
      expect(w.single.a, _m(10));
      expect(w.single.b, _m(10, 45));
    });

    test('niente controlli orari senza partenza, senza data, se spenti o '
        'per le tappe "solo passaggio"', () {
      const hours = ['Tu-Su 09:00-12:00', null];
      expect(run(hours, start: null), isEmpty);
      expect(run(hours, weekday: null), isEmpty);
      expect(
        run(hours, settings: const WarningSettings(hours: false)),
        isEmpty,
      );
      expect(run(hours, visits: const [0, 30]), isEmpty);
    });

    test('giornata lunga, finisce tardi, tanta strada', () {
      final long = buildSchedule(
        stops: const [
          ScheduleStop(hasCoords: true, visitMinutes: 300),
          ScheduleStop(hasCoords: true, visitMinutes: 300),
        ],
        legs: const [RouteLeg(16000, 3600)],
      )!;
      final w = run(const [null, null], s: long, start: 10 * 60);
      expect(w.map((x) => x.kind), [
        WarningKind.lateEnd,
        WarningKind.longDay,
        WarningKind.farWalk,
      ]);
      expect(w[0].a, _m(21));
      expect(w[1].a, 660);
      expect(w[2].a, 16000);
      // In bici 16 km stanno sotto i 40 km.
      expect(
        run(
          const [null, null],
          s: long,
          start: 10 * 60,
          mode: RouteTravelMode.bike,
        ).map((x) => x.kind),
        isNot(contains(WarningKind.farBike)),
      );
      // Soglie dalle impostazioni.
      expect(
        run(
          const [null, null],
          s: long,
          start: 10 * 60,
          settings: const WarningSettings(
            lateEndMinutes: 22 * 60,
            longDayMinutes: 12 * 60,
            walkKm: 20,
          ),
        ),
        isEmpty,
      );
    });
  });

  test('WarningSettings: andata e ritorno, valori rovinati ai default', () {
    const s = WarningSettings(walk: false, walkKm: 12, lateEndMinutes: 1260);
    final back = WarningSettings.decode(s.encode());
    expect(back.walk, isFalse);
    expect(back.walkKm, 12);
    expect(back.lateEndMinutes, 1260);
    expect(back.bikeKm, 40);
    expect(WarningSettings.decode('rotto').walkKm, 15);
    expect(WarningSettings.decode('{"walkKm":"x"}').walkKm, 15);
  });
}
