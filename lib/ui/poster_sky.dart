import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/enums.dart';
import '../core/sky.dart';
import 'itinera_theme.dart';
import 'posters.dart';

/// Il cielo vivo di un poster: l'ora della destinazione e il meteo vero.
/// La scena del tipo di viaggio resta quella; cambiano cielo, sole e luna,
/// e sopra passano nuvole, pioggia e neve. Vedi FigCraft, pagine O e K (file
/// 8 e 9).
@immutable
class PosterSky {
  const PosterSky({
    required this.moment,
    this.weather,
    this.temperature,
    this.note,
  });

  final SkyMoment moment;

  /// Null se il meteo non c'e' (lontano, senza rete o spento).
  final WeatherKind? weather;
  final int? temperature;

  /// Riga per la pagina del viaggio ("A Cagliari sono le 19:42 · ...").
  final String? note;

  static const sera = Color(0xFF2A2F7A);
  static const piombo = Color(0xFF46508A);
  static const temporale = Color(0xFF2C335F);
  static const pervinca = Color(0xFF8E9BD6);
  static const nebbia = Color(0xFFDDE3F2);
  static const nuvola = Color(0xFFE9ECF8);
  static const luna = Color(0xFFFFF6D8);

  /// Un ciclo di 36 s contiene un numero intero di gocce (0,9 s), fiocchi e
  /// luccichii: il giro ricomincia senza scatti.
  static const loop = Duration(seconds: 36);

  bool get isNight => moment.darkness >= 0.5;

  /// Cielo scuro: il titolo diventa bianco e la scena non deve avere niente di
  /// scuro che si confonda col cielo (vedi FigCraft, pagina O, fila 3).
  bool darkSky(TripType type) => top(type).computeLuminance() < 0.3;

  /// Le nuvole stanno dalla parte del cielo: sui cieli scuri un tono del cielo
  /// verso il pervinca, che lascia leggere il titolo bianco anche sopra; sui
  /// cieli chiari nuvola.
  Color cloudOn(TripType type) {
    final sky = top(type);
    if (sky.computeLuminance() >= 0.3) return nuvola;
    final c = Color.lerp(sky, pervinca, 0.45)!;
    return c.computeLuminance() <= 0.2
        ? c
        : Color.lerp(sky, piombo, 0.55)!;
  }

  /// Quando cambia, il cielo sfuma (900 ms) invece di saltare.
  Object get look => (moment.phase, weather);

  bool get _overcast => weather?.overcast ?? false;

  /// C'e' qualcosa che si muove (per accendere l'animazione).
  bool get moves =>
      weather != null && weather != WeatherKind.clear ||
      moment.darkness > 0 && !_overcast;

  /// Il colore del cielo in alto.
  Color top(TripType type) {
    final base = type.posterColors.background;
    final d = moment.darkness;
    final w = switch (weather) {
      WeatherKind.rain || WeatherKind.drizzle => piombo,
      WeatherKind.storm => temporale,
      WeatherKind.snow => pervinca,
      WeatherKind.fog => Color.lerp(base, nebbia, 0.55)!,
      WeatherKind.cloudy => Color.lerp(base, piombo, 0.3)!,
      _ => null,
    };
    if (w != null) return Color.lerp(w, Cartolina.inchiostro, d * 0.7)!;
    final evening = Color.lerp(base, sera, (d * 1.6).clamp(0.0, 1.0))!;
    return Color.lerp(
      evening,
      Cartolina.inchiostro,
      ((d - 0.6) / 0.4).clamp(0.0, 1.0),
    )!;
  }

  /// Il caldo verso l'orizzonte (giallo sui cieli corallo).
  static Color _warm(TripType type) =>
      type.posterColors.background == Cartolina.corallo
      ? Cartolina.sole
      : Cartolina.corallo;

  /// Colori delle scritte sopra questo cielo.
  PosterColors colorsFor(TripType type) {
    final c = type.posterColors;
    final sky = top(type);
    final dark = sky.computeLuminance() < 0.3;
    final fg = sky == c.background
        ? c.foreground
        : dark
        ? Colors.white
        : Cartolina.inchiostro;
    // Il Volo ha le scritte basse sulle nuvole, che col cielo scuro si fanno
    // pervinca; le altre scene le hanno sul paesaggio, che si scurisce di notte.
    final lowerWhite = type == TripType.generic ? dark : isNight;
    return PosterColors(
      background: sky,
      foreground: fg,
      lowerForeground: lowerWhite ? Colors.white : c.lowerForeground,
      pill: c.pill,
    );
  }

  /// Icona del meteo per pillole e scritte.
  IconData get icon => switch (weather) {
    WeatherKind.clear || null => isNight ? Icons.nightlight : Icons.wb_sunny,
    WeatherKind.partlyCloudy => isNight ? Icons.nights_stay : Icons.wb_cloudy,
    WeatherKind.cloudy => Icons.cloud,
    WeatherKind.fog => Icons.foggy,
    WeatherKind.drizzle || WeatherKind.rain => Icons.water_drop,
    WeatherKind.snow => Icons.ac_unit,
    WeatherKind.storm => Icons.thunderstorm,
  };

  // --- Disegno ---------------------------------------------------------------

  /// Il cielo a tutta area, con le bande calde di alba e tramonto.
  void paintSky(Canvas c, Size size, TripType type) {
    final sky = top(type);
    c.drawRect(Offset.zero & size, Paint()..color = sky);
    final warmth = moment.warmth;
    if (warmth <= 0 || _overcast) return;
    // Bande piatte dall'alto verso l'orizzonte della scena.
    final s = size.width / 372;
    final horizon = size.height - (240 - 118) * s;
    final from = horizon - 150 * s * (0.5 + warmth / 2);
    const n = 7;
    final warm = _warm(type);
    final step = (horizon - from) / n;
    for (var i = 0; i < n; i++) {
      final t = (i + 1) / n * warmth;
      c.drawRect(
        Rect.fromLTWH(0, from + i * step, size.width, step + 1),
        Paint()..color = Color.lerp(sky, warm, t)!,
      );
    }
    c.drawRect(
      Rect.fromLTRB(0, horizon, size.width, size.height),
      Paint()..color = Color.lerp(sky, warm, warmth)!,
    );
  }

  /// Stelle e nuvole, dietro la scena. Coordinate di scena (372 di larghezza,
  /// origine in cima alla scena: il cielo sopra ha y negativa fino a -[above]).
  void paintBehind(
    Canvas c,
    TripType type,
    double above,
    double t,
    double opacity,
  ) {
    final d = moment.darkness;
    if (d > 0 && !_overcast) {
      final star = Paint();
      for (final s in _stars) {
        final y = -above + s.y * (above + 150);
        final tw =
            0.55 + 0.45 * math.sin(2 * math.pi * (t * s.cycles + s.phase));
        star.color = Colors.white.withValues(alpha: d * tw * opacity);
        c.drawCircle(Offset(s.x, y), s.r, star);
      }
    }
    final clouds = switch (weather) {
      WeatherKind.partlyCloudy => const [(210.0, -62.0, 1.0)],
      WeatherKind.cloudy => const [
        (200.0, -40.0, 1.25),
        (30.0, -84.0, 0.9),
        (120.0, -6.0, 0.8),
      ],
      WeatherKind.drizzle ||
      WeatherKind.rain ||
      WeatherKind.storm => const [(200.0, 10.0, 1.3), (20.0, -40.0, 0.85)],
      WeatherKind.snow => const [(170.0, -70.0, 1.1)],
      _ => const <(double, double, double)>[],
    };
    if (clouds.isEmpty) return;
    final fill = cloudOn(type);
    final paint = Paint()..color = fill.withValues(alpha: opacity);
    for (final (i, (x, y, k)) in clouds.indexed) {
      // Deriva lenta avanti e indietro, ognuna col suo passo.
      final dx = math.sin(2 * math.pi * (t + i * 0.37)) * 18;
      _cloud(c, x + dx, y, k, paint);
    }
  }

  static void _cloud(Canvas c, double x, double y, double k, Paint p) {
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y + 28 * k, 120 * k, 28 * k),
        Radius.circular(14 * k),
      ),
      p,
    );
    for (final (cx, cy, r) in const [
      (34.0, 30.0, 20.0),
      (64.0, 22.0, 26.0),
      (94.0, 32.0, 18.0),
    ]) {
      c.drawCircle(Offset(x + cx * k, y + cy * k), r * k, p);
    }
  }

  /// Pioggia, neve, nebbia e lampi, davanti alla scena (stesse coordinate di
  /// [paintBehind]).
  void paintFront(Canvas c, double above, double t, double opacity) {
    final h = above + 240;
    switch (weather) {
      case WeatherKind.drizzle || WeatherKind.rain || WeatherKind.storm:
        final n = switch (weather) {
          WeatherKind.drizzle => 22,
          WeatherKind.storm => 60,
          _ => 46,
        };
        final drop = Paint()
          ..color = Colors.white.withValues(
            alpha: (weather == WeatherKind.drizzle ? 0.45 : 0.62) * opacity,
          )
          ..strokeWidth = weather == WeatherKind.drizzle ? 1.6 : 2.2
          ..strokeCap = StrokeCap.round;
        for (final r in _drops.take(n)) {
          // 40 passaggi per giro: una goccia attraversa in 0,9 s.
          final y = ((r.phase + t * 40) % 1) * (h + 40) - 30 - above;
          final x = (r.x - (y + above) * 0.4) % 412 - 20;
          c.drawLine(Offset(x, y), Offset(x - r.len * 0.4, y + r.len), drop);
        }
        if (weather == WeatherKind.storm && (t * 3) % 1 < 0.02) {
          // Lampo raro, ogni 12 s.
          c.drawRect(
            Rect.fromLTWH(-20, -above, 412, h),
            Paint()..color = Colors.white.withValues(alpha: 0.14 * opacity),
          );
          c.drawPath(
            Path()
              ..moveTo(262, -40)
              ..lineTo(244, 6)
              ..lineTo(258, 6)
              ..lineTo(240, 58)
              ..lineTo(276, -2)
              ..lineTo(262, -2)
              ..lineTo(278, -40)
              ..close(),
            Paint()..color = Cartolina.sole.withValues(alpha: opacity),
          );
        }
      case WeatherKind.snow:
        final flake = Paint()
          ..color = Colors.white.withValues(alpha: 0.95 * opacity);
        for (final f in _flakes) {
          // I grandi davanti e piu' veloci: 6, 7,2 o 9 s di caduta.
          final y = ((f.phase + t * f.cycles) % 1) * (h + 20) - 10 - above;
          final x = f.x + math.sin(2 * math.pi * (t * 18 + f.sway)) * 6;
          c.drawCircle(Offset(x, y), f.r, flake);
        }
      case WeatherKind.fog:
        final veil = Paint()
          ..color = Colors.white.withValues(alpha: 0.26 * opacity);
        for (final (i, y) in const [-20.0, 34.0, 88.0].indexed) {
          final dx = math.sin(2 * math.pi * (t + i * 0.3)) * 20;
          c.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(-40 + dx + i * 30, y, 300, 22),
              const Radius.circular(11),
            ),
            veil,
          );
        }
      default:
        break;
    }
  }

  // Posizioni fisse, generate una volta: il disegno e' stabile.
  static final _stars = _seeded(
    1,
    24,
    (r) => _Star(
      x: 12 + r.nextDouble() * 348,
      y: r.nextDouble(),
      r: const [1.4, 1.8, 2.3][r.nextInt(3)],
      cycles: const [9, 12, 15, 18][r.nextInt(4)],
      phase: r.nextDouble(),
    ),
  );
  static final _drops = _seeded(
    2,
    60,
    (r) => _Drop(
      x: r.nextDouble() * 412,
      phase: r.nextDouble(),
      len: 12 + r.nextDouble() * 10,
    ),
  );
  static final _flakes = _seeded(3, 48, (r) {
    final size = r.nextInt(3);
    return _Flake(
      x: r.nextDouble() * 372,
      phase: r.nextDouble(),
      sway: r.nextDouble(),
      r: const [2.0, 2.6, 3.4][size],
      cycles: const [4, 5, 6][size],
    );
  });

  static List<T> _seeded<T>(int seed, int n, T Function(math.Random) make) {
    final r = math.Random(seed);
    return List.generate(n, (_) => make(r), growable: false);
  }

  @override
  bool operator ==(Object other) =>
      other is PosterSky &&
      other.moment == moment &&
      other.weather == weather &&
      other.temperature == temperature &&
      other.note == note;

  @override
  int get hashCode => Object.hash(moment, weather, temperature, note);
}

class _Star {
  const _Star({
    required this.x,
    required this.y,
    required this.r,
    required this.cycles,
    required this.phase,
  });
  final double x, y, r, phase;
  final int cycles;
}

class _Drop {
  const _Drop({required this.x, required this.phase, required this.len});
  final double x, phase, len;
}

class _Flake {
  const _Flake({
    required this.x,
    required this.phase,
    required this.sway,
    required this.r,
    required this.cycles,
  });
  final double x, phase, sway, r;
  final int cycles;
}
