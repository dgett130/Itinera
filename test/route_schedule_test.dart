import 'package:flutter_test/flutter_test.dart';

import 'package:itinera/core/enums.dart';
import 'package:itinera/features/explore/route_schedule.dart';
import 'package:itinera/features/transport/routing_service.dart';

ScheduleStop _s(int visit, {bool coords = true}) =>
    ScheduleStop(hasCoords: coords, visitMinutes: visit);

void main() {
  test('durata effettiva: scelta, altrimenti predefinita per categoria', () {
    expect(effectiveVisitMinutes(20, PoiCategory.museum), 20);
    expect(effectiveVisitMinutes(0, PoiCategory.museum), 0);
    expect(effectiveVisitMinutes(null, PoiCategory.museum), 90);
    expect(effectiveVisitMinutes(null, null), 30);
  });

  test('arrivi e uscite da tratti e visite; totali', () {
    final s = buildSchedule(
      stops: [_s(60), _s(30), _s(45)],
      legs: const [RouteLeg(800, 600), RouteLeg(1200, 900)],
    )!;
    expect(s.stops.map((t) => t.arriveSeconds), [0, 4200, 6900]);
    expect(s.stops.map((t) => t.leaveSeconds), [3600, 6000, 9600]);
    expect(s.stops.first.legBefore, isNull);
    expect(s.stops[1].legBefore!.distanceMeters, 800);
    expect(s.endSeconds, 9600);
    expect(s.travelSeconds, 1500);
    expect(s.visitSeconds, 135 * 60);
    expect(s.distanceMeters, 2000);
    // 9:00 + 2 h 40 = 11:40.
    expect(RouteSchedule.clock(540, s.endSeconds), 700);
  });

  test('solo partenza (0 min) e ritorno alla prima tappa', () {
    final s = buildSchedule(
      stops: [_s(0), _s(60)],
      legs: const [RouteLeg(500, 300), RouteLeg(500, 360)],
      returnToStart: true,
    )!;
    expect(s.stops.map((t) => t.arriveSeconds), [0, 300]);
    expect(s.returnLeg!.durationSeconds, 360);
    expect(s.endSeconds, 300 + 3600 + 360);
  });

  test('tappa senza posizione: nessun tratto, si visita "sul posto"', () {
    final s = buildSchedule(
      stops: [_s(30), _s(15, coords: false), _s(30)],
      legs: const [RouteLeg(1000, 600)],
    )!;
    expect(s.stops[1].legBefore, isNull);
    expect(s.stops[1].arriveSeconds, 1800);
    expect(s.stops[2].legBefore, isNotNull);
    expect(s.stops[2].arriveSeconds, 1800 + 900 + 600);
  });

  test('tratti che non corrispondono alle tappe: nessuna scaletta', () {
    expect(buildSchedule(stops: [_s(30), _s(30)], legs: const []), isNull);
    expect(
      buildSchedule(
        stops: [_s(30), _s(30)],
        legs: const [RouteLeg(1, 1)],
        returnToStart: true,
      ),
      isNull,
    );
    // Una sola tappa: nessun tratto atteso, anche con il ritorno.
    final one = buildSchedule(
      stops: [_s(45)],
      legs: const [],
      returnToStart: true,
    )!;
    expect(one.endSeconds, 45 * 60);
    expect(one.returnLeg, isNull);
  });

  group('balancedSplitIndex', () {
    test('taglia dove le due parti durano più o meno uguali', () {
      // 3 h, 1 h, 1 h, 1 h (tratti da 10'): la prima tappa da sola pesa come
      // le altre tre insieme.
      final s = buildSchedule(
        stops: [_s(180), _s(60), _s(60), _s(60)],
        legs: const [RouteLeg(1, 600), RouteLeg(1, 600), RouteLeg(1, 600)],
      )!;
      expect(balancedSplitIndex(s), 1);

      final even = buildSchedule(
        stops: [_s(60), _s(60), _s(60), _s(60)],
        legs: const [RouteLeg(1, 600), RouteLeg(1, 600), RouteLeg(1, 600)],
      )!;
      expect(balancedSplitIndex(even), 2);
    });

    test('meno di 2 tappe: niente da dividere', () {
      expect(
        balancedSplitIndex(buildSchedule(stops: [_s(60)], legs: const [])!),
        isNull,
      );
    });
  });
}
