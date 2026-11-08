import 'package:flutter_test/flutter_test.dart';
import 'package:itinera/core/enums.dart';
import 'package:itinera/core/sky.dart';
import 'package:itinera/features/weather/live_sky.dart';
import 'package:itinera/features/weather/weather_report.dart';
import 'package:itinera/ui/itinera_theme.dart';
import 'package:itinera/ui/poster_sky.dart';

void main() {
  // Cagliari, 21 giugno 2026: fuso +2, alba 03:58 UTC, tramonto 18:52 UTC.
  final json = <String, Object?>{
    'utc_offset_seconds': 7200,
    'current': {'temperature_2m': 26.6, 'weather_code': 61},
    'daily': {
      'time': [1782000000 - 7200, 1782086400 - 7200],
      'weather_code': [61, 3],
      'temperature_2m_max': [27.0, 24.4],
      'temperature_2m_min': [19.0, 18.2],
      'sunrise': [1782014280, 1782100700],
      'sunset': [1782067920, 1782154340],
    },
  };

  test('la risposta di Open-Meteo diventa giorni locali', () {
    final r = WeatherReport.fromOpenMeteo(json, DateTime(2026, 6, 21));
    expect(r.currentKind, WeatherKind.rain);
    expect(r.days.length, 2);
    expect(r.days.first.date, DateTime.utc(2026, 6, 21));
    expect(
      r.days.first.sunset,
      DateTime.fromMillisecondsSinceEpoch(1782067920000, isUtc: true),
    );
    final back = WeatherReport.fromJson(r.toJson());
    expect(back.days.last.maxTemp, 24.4);
    expect(back.utcOffsetSeconds, 7200);
  });

  group('finestra del meteo', () {
    final today = DateTime(2026, 6, 21);
    test('in corso, in partenza, lontano, concluso', () {
      expect(
        weatherWindow(DateTime(2026, 6, 20), DateTime(2026, 6, 25), today),
        WeatherWindow.now,
      );
      expect(
        weatherWindow(DateTime(2026, 6, 25), DateTime(2026, 6, 30), today),
        WeatherWindow.departure,
      );
      expect(
        weatherWindow(DateTime(2026, 7, 25), null, today),
        WeatherWindow.none,
      );
      expect(weatherWindow(null, null, today), WeatherWindow.none);
      expect(
        tripConcluded(DateTime(2026, 6, 1), DateTime(2026, 6, 20), today),
        isTrue,
      );
      expect(
        tripConcluded(DateTime(2026, 6, 1), DateTime(2026, 6, 21), today),
        isFalse,
      );
    });
  });

  test('viaggio in corso: meteo di adesso e riga con ora e tramonto', () {
    final report = WeatherReport.fromOpenMeteo(json, DateTime(2026, 6, 21));
    final sky = buildPosterSky(
      lat: 39.22,
      lng: 9.12,
      nowUtc: DateTime.utc(2026, 6, 21, 18, 10),
      window: WeatherWindow.now,
      report: report,
      place: 'Cagliari, Italia',
    );
    expect(sky.weather, WeatherKind.rain);
    expect(sky.temperature, 27);
    expect(sky.moment.phase, SkyPhase.golden);
    expect(
      sky.note,
      startsWith('A Cagliari sono le 20:10 · tramonto alle 20:52'),
    );
    expect(sky.note, endsWith('domani nuvoloso, 24°'));
  });

  test('senza meteo resta l\'ora del giorno, calcolata sul posto', () {
    final sky = buildPosterSky(
      lat: 39.22,
      lng: 9.12,
      nowUtc: DateTime.utc(2026, 6, 21, 23),
      window: WeatherWindow.none,
    );
    expect(sky.weather, isNull);
    expect(sky.moment.phase, SkyPhase.night);
    expect(sky.note, isNull);
  });

  test('i colori delle scritte seguono il cielo', () {
    final night = buildPosterSky(
      lat: 39.22,
      lng: 9.12,
      nowUtc: DateTime.utc(2026, 6, 21, 23),
      window: WeatherWindow.none,
    );
    // La montagna ha le scritte inchiostro sul giallo: di notte diventano bianche.
    final c = night.colorsFor(TripType.mountain);
    expect(c.background, Cartolina.inchiostro);
    expect(c.foreground.toARGB32(), 0xFFFFFFFF);
    final noon = buildPosterSky(
      lat: 39.22,
      lng: 9.12,
      nowUtc: DateTime.utc(2026, 6, 21, 10),
      window: WeatherWindow.none,
    );
    expect(noon.colorsFor(TripType.mountain).foreground, Cartolina.inchiostro);
    expect(noon.colorsFor(TripType.mountain).background, Cartolina.sole);
  });

  test('col cielo scuro niente si confonde: nuvole e scritte del Volo', () {
    const night = PosterSky(
      moment: SkyMoment(phase: SkyPhase.night, darkness: 1),
      weather: WeatherKind.cloudy,
    );
    const rainyDay = PosterSky(
      moment: SkyMoment.day,
      weather: WeatherKind.rain,
    );
    const noon = PosterSky(moment: SkyMoment.day);
    for (final sky in [night, rainyDay]) {
      for (final type in TripType.values) {
        expect(sky.darkSky(type), isTrue);
        // Le nuvole si staccano dal cielo ma lasciano leggere il titolo bianco.
        final cloud = sky.cloudOn(type).computeLuminance();
        expect(cloud, lessThanOrEqualTo(0.2));
        expect(cloud, greaterThan(sky.top(type).computeLuminance()));
      }
      // Il Volo ha le scritte basse sulle nuvole, pervinca col cielo scuro.
      expect(
        sky.colorsFor(TripType.generic).lowerForeground.toARGB32(),
        0xFFFFFFFF,
      );
    }
    expect(noon.darkSky(TripType.generic), isFalse);
    expect(
      noon.colorsFor(TripType.generic).lowerForeground,
      Cartolina.inchiostro,
    );
  });
}
