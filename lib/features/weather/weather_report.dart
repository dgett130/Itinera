import '../../core/sky.dart';

/// Il tempo di un giorno nella destinazione.
class WeatherDay {
  const WeatherDay({
    required this.date,
    required this.code,
    required this.maxTemp,
    required this.minTemp,
    this.sunrise,
    this.sunset,
  });

  /// Il giorno locale della destinazione (solo anno, mese, giorno).
  final DateTime date;
  final int code;
  final double maxTemp;
  final double minTemp;

  /// Orari in UTC; null nei giorni senza alba o tramonto.
  final DateTime? sunrise;
  final DateTime? sunset;

  WeatherKind get kind => WeatherKind.fromWmo(code);

  Map<String, Object?> toJson() => {
    'date': date.toIso8601String(),
    'code': code,
    'max': maxTemp,
    'min': minTemp,
    'rise': sunrise?.millisecondsSinceEpoch,
    'set': sunset?.millisecondsSinceEpoch,
  };

  static WeatherDay fromJson(Map<String, Object?> j) => WeatherDay(
    date: DateTime.parse(j['date']! as String),
    code: j['code']! as int,
    maxTemp: (j['max']! as num).toDouble(),
    minTemp: (j['min']! as num).toDouble(),
    sunrise: _utc(j['rise']),
    sunset: _utc(j['set']),
  );

  static DateTime? _utc(Object? ms) =>
      ms is int ? DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true) : null;
}

/// Meteo attuale e prossimi giorni della destinazione (Open-Meteo).
class WeatherReport {
  const WeatherReport({
    required this.fetchedAt,
    required this.utcOffsetSeconds,
    this.currentTemp,
    this.currentCode,
    this.days = const [],
  });

  final DateTime fetchedAt;

  /// Fuso della destinazione, per l'ora locale.
  final int utcOffsetSeconds;
  final double? currentTemp;
  final int? currentCode;
  final List<WeatherDay> days;

  WeatherKind? get currentKind =>
      currentCode == null ? null : WeatherKind.fromWmo(currentCode!);

  /// Il giorno locale [date] (anno, mese, giorno), se previsto.
  WeatherDay? day(DateTime date) {
    for (final d in days) {
      if (d.date.year == date.year &&
          d.date.month == date.month &&
          d.date.day == date.day) {
        return d;
      }
    }
    return null;
  }

  /// Risposta di `api.open-meteo.com/v1/forecast` con `timeformat=unixtime` e
  /// `timezone=auto` (campi `current` e `daily`).
  static WeatherReport fromOpenMeteo(Map<String, Object?> json, DateTime now) {
    final offset = (json['utc_offset_seconds'] as num?)?.toInt() ?? 0;
    final current = json['current'] as Map<String, Object?>?;
    final daily = json['daily'] as Map<String, Object?>?;
    final days = <WeatherDay>[];
    if (daily != null) {
      List<Object?> col(String k) => (daily[k] as List?) ?? const [];
      final time = col('time');
      final code = col('weather_code');
      final max = col('temperature_2m_max');
      final min = col('temperature_2m_min');
      final rise = col('sunrise');
      final set = col('sunset');
      DateTime? utc(List<Object?> c, int i) => i < c.length && c[i] is num
          ? DateTime.fromMillisecondsSinceEpoch(
              (c[i]! as num).toInt() * 1000,
              isUtc: true,
            )
          : null;
      for (var i = 0; i < time.length; i++) {
        if (i >= code.length || code[i] is! num) continue;
        // La mezzanotte locale, riportata al giorno della destinazione.
        final local = DateTime.fromMillisecondsSinceEpoch(
          ((time[i]! as num).toInt() + offset) * 1000,
          isUtc: true,
        );
        days.add(
          WeatherDay(
            date: DateTime.utc(local.year, local.month, local.day),
            code: (code[i]! as num).toInt(),
            maxTemp: (max.elementAtOrNull(i) as num?)?.toDouble() ?? 0,
            minTemp: (min.elementAtOrNull(i) as num?)?.toDouble() ?? 0,
            sunrise: utc(rise, i),
            sunset: utc(set, i),
          ),
        );
      }
    }
    return WeatherReport(
      fetchedAt: now,
      utcOffsetSeconds: offset,
      currentTemp: (current?['temperature_2m'] as num?)?.toDouble(),
      currentCode: (current?['weather_code'] as num?)?.toInt(),
      days: days,
    );
  }

  Map<String, Object?> toJson() => {
    'at': fetchedAt.millisecondsSinceEpoch,
    'offset': utcOffsetSeconds,
    'temp': currentTemp,
    'code': currentCode,
    'days': [for (final d in days) d.toJson()],
  };

  static WeatherReport fromJson(Map<String, Object?> j) => WeatherReport(
    fetchedAt: DateTime.fromMillisecondsSinceEpoch(j['at']! as int),
    utcOffsetSeconds: j['offset']! as int,
    currentTemp: (j['temp'] as num?)?.toDouble(),
    currentCode: j['code'] as int?,
    days: [
      for (final d in (j['days'] as List? ?? const []))
        WeatherDay.fromJson((d as Map).cast<String, Object?>()),
    ],
  );
}
