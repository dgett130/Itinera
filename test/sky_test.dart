import 'package:flutter_test/flutter_test.dart';
import 'package:itinera/core/calc/sun_times.dart';
import 'package:itinera/core/sky.dart';

void main() {
  group('alba e tramonto', () {
    void near(DateTime? actual, DateTime expected) {
      expect(actual, isNotNull);
      expect(actual!.difference(expected).inMinutes.abs(), lessThan(6));
    }

    test('Roma al solstizio d\'estate', () {
      final s = SunTimes.forDay(DateTime(2026, 6, 21), 41.9, 12.5);
      near(s.sunrise, DateTime.utc(2026, 6, 21, 3, 36));
      near(s.sunset, DateTime.utc(2026, 6, 21, 18, 48));
    });

    test('Londra al solstizio d\'inverno', () {
      final s = SunTimes.forDay(DateTime(2026, 12, 21), 51.5, -0.13);
      near(s.sunrise, DateTime.utc(2026, 12, 21, 8, 4));
      near(s.sunset, DateTime.utc(2026, 12, 21, 15, 54));
    });

    test('notte polare e sole di mezzanotte', () {
      expect(
        SunTimes.forDay(DateTime(2026, 12, 21), 69.65, 18.96).alwaysDown,
        isTrue,
      );
      expect(
        SunTimes.forDay(DateTime(2026, 6, 21), 69.65, 18.96).alwaysUp,
        isTrue,
      );
    });
  });

  group('il cielo del momento', () {
    final sun = SunTimes(
      sunrise: DateTime.utc(2026, 6, 21, 4),
      sunset: DateTime.utc(2026, 6, 21, 19),
    );
    SkyMoment at(int h, [int m = 0]) =>
        SkyMoment.at(DateTime.utc(2026, 6, 21, h, m), sun);

    test('a mezzogiorno e\' giorno pieno, col sole alto', () {
      final s = at(11, 30);
      expect(s.phase, SkyPhase.day);
      expect(s.sunDrop, closeTo(0, 0.01));
      expect(at(16).sunDrop, greaterThan(at(14).sunDrop));
    });

    test('un\'ora prima del tramonto le bande si scaldano', () {
      expect(at(18).phase, SkyPhase.day);
      final s = at(18, 30);
      expect(s.phase, SkyPhase.golden);
      expect(s.warmth, closeTo(0.5, 0.01));
    });

    test('dopo il tramonto scurisce, poi e\' notte', () {
      final s = at(19, 15);
      expect(s.phase, SkyPhase.evening);
      expect(s.darkness, closeTo(1 / 3, 0.01));
      expect(at(20).phase, SkyPhase.night);
      expect(at(2).phase, SkyPhase.night);
    });

    test('prima dell\'alba schiarisce', () {
      final s = at(3, 30);
      expect(s.phase, SkyPhase.evening);
      expect(s.darkness, lessThan(1));
      expect(at(4, 30).phase, SkyPhase.golden);
    });
  });

  test('i codici WMO diventano il tempo del poster', () {
    expect(WeatherKind.fromWmo(0), WeatherKind.clear);
    expect(WeatherKind.fromWmo(2), WeatherKind.partlyCloudy);
    expect(WeatherKind.fromWmo(45), WeatherKind.fog);
    expect(WeatherKind.fromWmo(53), WeatherKind.drizzle);
    expect(WeatherKind.fromWmo(81), WeatherKind.rain);
    expect(WeatherKind.fromWmo(75), WeatherKind.snow);
    expect(WeatherKind.fromWmo(95), WeatherKind.storm);
    expect(WeatherKind.rain.overcast, isTrue);
    expect(WeatherKind.partlyCloudy.overcast, isFalse);
  });
}
