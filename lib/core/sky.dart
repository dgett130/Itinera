import 'dart:math' as math;

import 'calc/sun_times.dart';

/// Il momento del giorno del poster vivo (vedi FigCraft, pagine O e K).
enum SkyPhase {
  /// Sole su: il cielo e' il colore del tipo di viaggio.
  day,

  /// L'ora attorno ad alba e tramonto: bande calde, sole basso.
  golden,

  /// Appena dopo il tramonto o poco prima dell'alba: il cielo scurisce.
  evening,

  /// Luna e stelle.
  night,
}

/// Dove si trova il cielo in un istante: fase e intensita' dei passaggi, tutte
/// da 0 a 1 cosi' il disegno sfuma senza scatti.
class SkyMoment {
  const SkyMoment({
    required this.phase,
    this.warmth = 0,
    this.darkness = 0,
    this.sunDrop = 0,
  });

  final SkyPhase phase;

  /// Quanto sono calde le bande verso l'orizzonte.
  final double warmth;

  /// 0 giorno, 1 notte piena.
  final double darkness;

  /// 0 sole a mezzogiorno, 1 sole all'orizzonte.
  final double sunDrop;

  static const day = SkyMoment(phase: SkyPhase.day);

  /// L'ora d'oro dura un'ora prima del tramonto (e dopo l'alba).
  static const goldenMinutes = 60.0;

  /// La sera scurisce in 45 minuti (e l'alba schiarisce in altrettanti).
  static const eveningMinutes = 45.0;

  /// Il cielo a [nowUtc] con gli orari del sole di quel giorno.
  static SkyMoment at(DateTime nowUtc, SunTimes sun) {
    if (sun.alwaysUp) return day;
    if (sun.alwaysDown) {
      return const SkyMoment(phase: SkyPhase.night, darkness: 1);
    }
    final rise = sun.sunrise!, set = sun.sunset!;
    double minutes(DateTime a, DateTime b) =>
        a.difference(b).inSeconds / 60.0; // a - b
    final fromRise = minutes(nowUtc, rise);
    final toSet = minutes(set, nowUtc);

    if (fromRise < -eveningMinutes || toSet < -eveningMinutes) {
      return const SkyMoment(phase: SkyPhase.night, darkness: 1);
    }
    if (fromRise < 0) {
      // Prima dell'alba: schiarisce e si scalda.
      final t = 1 + fromRise / eveningMinutes; // 0 -> 1
      return SkyMoment(
        phase: SkyPhase.evening,
        darkness: 1 - t,
        warmth: t,
        sunDrop: 1,
      );
    }
    if (toSet < 0) {
      // Dopo il tramonto: scurisce, il caldo si spegne.
      final t = -toSet / eveningMinutes; // 0 -> 1
      return SkyMoment(
        phase: SkyPhase.evening,
        darkness: t,
        warmth: 1 - t,
        sunDrop: 1,
      );
    }
    final dayLength = minutes(set, rise);
    final arc = math.sin(math.pi * (fromRise / dayLength).clamp(0.0, 1.0));
    final drop = 1 - arc;
    final edge = math.min(fromRise, toSet);
    if (edge < goldenMinutes) {
      return SkyMoment(
        phase: SkyPhase.golden,
        warmth: 1 - edge / goldenMinutes,
        sunDrop: drop,
      );
    }
    return SkyMoment(phase: SkyPhase.day, sunDrop: drop);
  }

  @override
  bool operator ==(Object other) =>
      other is SkyMoment &&
      other.phase == phase &&
      other.warmth == warmth &&
      other.darkness == darkness &&
      other.sunDrop == sunDrop;

  @override
  int get hashCode => Object.hash(phase, warmth, darkness, sunDrop);
}

/// Il tempo che fa, raggruppato come lo disegna il poster.
enum WeatherKind {
  clear,
  partlyCloudy,
  cloudy,
  fog,
  drizzle,
  rain,
  snow,
  storm;

  /// Dai codici WMO di Open-Meteo.
  static WeatherKind fromWmo(int code) => switch (code) {
    0 => clear,
    1 || 2 => partlyCloudy,
    3 => cloudy,
    45 || 48 => fog,
    >= 51 && <= 57 => drizzle,
    (>= 61 && <= 67) || (>= 80 && <= 82) => rain,
    (>= 71 && <= 77) || 85 || 86 => snow,
    >= 95 && <= 99 => storm,
    _ => cloudy,
  };

  String get label => switch (this) {
    clear => 'sereno',
    partlyCloudy => 'poco nuvoloso',
    cloudy => 'nuvoloso',
    fog => 'nebbia',
    drizzle => 'pioviggine',
    rain => 'pioggia',
    snow => 'neve',
    storm => 'temporale',
  };

  /// Il cielo e' coperto: niente sole ne' stelle.
  bool get overcast => this != clear && this != partlyCloudy;

  /// Cade qualcosa: pioggia o neve.
  bool get falls =>
      this == drizzle || this == rain || this == snow || this == storm;
}
