import '../../core/calc/sun_times.dart';
import '../../core/sky.dart';
import '../../ui/poster_sky.dart';
import 'weather_report.dart';

/// Quale meteo mostra il poster di un viaggio.
enum WeatherWindow {
  /// Nessuno: solo l'ora del giorno (viaggio lontano o senza date).
  none,

  /// Il viaggio e' in corso: il tempo di adesso.
  now,

  /// Si parte entro una settimana: la previsione del giorno di partenza.
  departure,
}

/// Giorni di anticipo per cui si mostra la previsione della partenza.
const departureForecastDays = 7;

DateTime _day(DateTime d) => DateTime.utc(d.year, d.month, d.day);

/// Il viaggio e' gia' finito il giorno [today].
bool tripConcluded(DateTime? start, DateTime? end, DateTime today) {
  final last = end ?? start;
  return last != null && _day(last).isBefore(_day(today));
}

WeatherWindow weatherWindow(DateTime? start, DateTime? end, DateTime today) {
  if (start == null) return WeatherWindow.none;
  final t = _day(today), s = _day(start), e = _day(end ?? start);
  if (!t.isBefore(s) && !t.isAfter(e)) return WeatherWindow.now;
  final ahead = s.difference(t).inDays;
  if (ahead > 0 && ahead <= departureForecastDays) {
    return WeatherWindow.departure;
  }
  return WeatherWindow.none;
}

String _hm(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

/// Il cielo del poster a [nowUtc] per una destinazione in [lat], [lng].
/// Senza [report] (lontano, senza rete o meteo spento) restano l'ora del
/// giorno e gli orari del sole calcolati sul posto.
PosterSky buildPosterSky({
  required double lat,
  required double lng,
  required DateTime nowUtc,
  required WeatherWindow window,
  WeatherReport? report,
  DateTime? start,
  String? place,
}) {
  // Fuso della destinazione: dal meteo, altrimenti stimato dalla longitudine.
  final offset = Duration(
    seconds: report?.utcOffsetSeconds ?? (lng / 15).round() * 3600,
  );
  final local = nowUtc.toUtc().add(offset);
  final today = _day(local);
  final forecast = report?.day(today);
  final sun = forecast?.sunrise != null && forecast?.sunset != null
      ? SunTimes(sunrise: forecast!.sunrise, sunset: forecast.sunset)
      : SunTimes.forDay(today, lat, lng);
  final moment = SkyMoment.at(nowUtc.toUtc(), sun);

  WeatherKind? kind;
  int? temp;
  String? note;
  final where = (place == null || place.trim().isEmpty)
      ? 'A destinazione'
      : 'A ${place.split(',').first.trim()}';
  switch (window) {
    case WeatherWindow.now:
      kind = report?.currentKind;
      temp = report?.currentTemp?.round();
      final parts = ['$where sono le ${_hm(local)}'];
      if (sun.sunset case final set?) {
        parts.add('tramonto alle ${_hm(set.add(offset))}');
      }
      final tomorrow = report?.day(today.add(const Duration(days: 1)));
      if (tomorrow != null) {
        parts.add(
          'domani ${tomorrow.kind.label}, ${tomorrow.maxTemp.round()}°',
        );
      }
      note = parts.join(' · ');
    case WeatherWindow.departure:
      final d = start == null ? null : report?.day(_day(start));
      if (d != null) {
        kind = d.kind;
        temp = d.maxTemp.round();
        note =
            'Previsto per la partenza: ${d.kind.label}, '
            '${d.maxTemp.round()}° / ${d.minTemp.round()}°';
      }
    case WeatherWindow.none:
      break;
  }
  return PosterSky(
    moment: moment,
    weather: kind,
    temperature: temp,
    note: note,
  );
}
