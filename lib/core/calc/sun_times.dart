import 'dart:math' as math;

/// Alba e tramonto per un giorno e un luogo, calcolati senza rete (equazione
/// dell'alba, precisione di un paio di minuti). Orari in UTC.
class SunTimes {
  const SunTimes({
    this.sunrise,
    this.sunset,
    this.alwaysUp = false,
    this.alwaysDown = false,
  });

  final DateTime? sunrise;
  final DateTime? sunset;

  /// Sole di mezzanotte: non tramonta mai.
  final bool alwaysUp;

  /// Notte polare: non sorge mai.
  final bool alwaysDown;

  static const _j2000 = 2451545.0;
  static const _unixEpochJd = 2440587.5;
  static double _rad(double d) => d * math.pi / 180;
  static double _deg(double r) => r * 180 / math.pi;

  /// Il giorno [date] (conta solo anno, mese e giorno) a [lat], [lng] (gradi,
  /// est positivo).
  static SunTimes forDay(DateTime date, double lat, double lng) {
    final noonUtc = DateTime.utc(date.year, date.month, date.day, 12);
    final jd = noonUtc.millisecondsSinceEpoch / 86400000 + _unixEpochJd;
    final n = (jd - _j2000 + 0.0008).roundToDouble();
    final jStar = n - lng / 360;
    final m = (357.5291 + 0.98560028 * jStar) % 360;
    final mr = _rad(m);
    final c =
        1.9148 * math.sin(mr) +
        0.02 * math.sin(2 * mr) +
        0.0003 * math.sin(3 * mr);
    final lambda = _rad((m + c + 180 + 102.9372) % 360);
    final transit =
        _j2000 + jStar + 0.0053 * math.sin(mr) - 0.0069 * math.sin(2 * lambda);
    final sinDecl = math.sin(lambda) * math.sin(_rad(23.4397));
    final cosDecl = math.cos(math.asin(sinDecl));
    final phi = _rad(lat);
    final cosOmega =
        (math.sin(_rad(-0.833)) - math.sin(phi) * sinDecl) /
        (math.cos(phi) * cosDecl);
    if (cosOmega > 1) return const SunTimes(alwaysDown: true);
    if (cosOmega < -1) return const SunTimes(alwaysUp: true);
    final omega = _deg(math.acos(cosOmega));
    DateTime toUtc(double j) => DateTime.fromMillisecondsSinceEpoch(
      ((j - _unixEpochJd) * 86400000).round(),
      isUtc: true,
    );
    return SunTimes(
      sunrise: toUtc(transit - omega / 360),
      sunset: toUtc(transit + omega / 360),
    );
  }
}
