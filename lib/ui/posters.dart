import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/enums.dart';
import 'itinera_theme.dart';
import 'motion.dart';
import 'poster_sky.dart';

/// I poster dei viaggi: scene a forme piatte, una per tipo di viaggio.
/// Disegnate in codice (niente immagini), quindi leggere e sempre offline.

/// Colori di una scena: lo sfondo del poster e cosa ci si scrive sopra.
class PosterColors {
  const PosterColors({
    required this.background,
    required this.foreground,
    required this.lowerForeground,
    required this.pill,
  });

  final Color background;

  /// Testo nella parte alta, sul cielo.
  final Color foreground;

  /// Testo nella parte bassa, sopra la scena.
  final Color lowerForeground;

  /// Sfondo della pillola con il conto alla rovescia (testo sempre inchiostro).
  final Color pill;

  /// Testo leggibile sul fondo (chiaro o scuro), per le icone della barra.
  Brightness get overlayBrightness =>
      foreground == Colors.white ? Brightness.dark : Brightness.light;
}

extension TripPosterStyle on TripType {
  PosterColors get posterColors => switch (this) {
    TripType.sea => const PosterColors(
      background: Cartolina.cobalto,
      foreground: Colors.white,
      lowerForeground: Colors.white,
      pill: Cartolina.sole,
    ),
    TripType.city => const PosterColors(
      background: Cartolina.corallo,
      foreground: Cartolina.inchiostro,
      lowerForeground: Colors.white,
      pill: Cartolina.sole,
    ),
    TripType.mountain => const PosterColors(
      background: Cartolina.sole,
      foreground: Cartolina.inchiostro,
      lowerForeground: Cartolina.inchiostro,
      pill: Colors.white,
    ),
    TripType.roadTrip => const PosterColors(
      background: Cartolina.laguna,
      foreground: Cartolina.inchiostro,
      lowerForeground: Colors.white,
      pill: Cartolina.sole,
    ),
    TripType.backpacking => const PosterColors(
      background: Cartolina.cobaltoScuro,
      foreground: Colors.white,
      lowerForeground: Cartolina.inchiostro,
      pill: Cartolina.sole,
    ),
    TripType.business => const PosterColors(
      background: Cartolina.inchiostro,
      foreground: Colors.white,
      lowerForeground: Colors.white,
      pill: Cartolina.sole,
    ),
    TripType.generic => const PosterColors(
      background: Cartolina.corallo,
      foreground: Cartolina.inchiostro,
      lowerForeground: Cartolina.inchiostro,
      pill: Cartolina.sole,
    ),
  };
}

/// Disegno della scena, ancorato in basso e proporzionato alla larghezza.
class PosterPainter extends CustomPainter {
  PosterPainter(
    this.type, {
    this.drift,
    this.sink,
    this.paintBackground = true,
    this.decor = true,
    this.sky,
    this.skyFrom,
    this.weather,
    this.fade,
  }) : super(repaint: Listenable.merge([drift, sink, weather, fade]));

  final TripType type;

  /// Deriva lenta delle onde (0..1, ciclica).
  final Animation<double>? drift;

  /// Quanto il sole e' tramontato (0..1), per lo scorrimento del dettaglio.
  final ValueListenable<double>? sink;

  /// Falso per animare il cielo a parte (es. cambio del tipo di viaggio).
  final bool paintBackground;

  /// Falso per togliere i dettagli che finirebbero sotto i testi del widget
  /// (la barca nel cielo del mare).
  final bool decor;

  /// Il cielo vivo (ora e meteo della destinazione); null = poster di sempre.
  final PosterSky? sky;

  /// Il cielo di prima, mentre [fade] lo porta a [sky].
  final PosterSky? skyFrom;

  /// Giro di [PosterSky.loop] per nuvole, pioggia, neve e stelle (0..1).
  final Animation<double>? weather;

  /// Dissolvenza da [skyFrom] a [sky] (0..1).
  final Animation<double>? fade;

  /// Larghezza e altezza su cui e' disegnata ogni scena.
  static const double _designWidth = 372;
  static const double _sceneHeight = 240;

  double get _fade => fade?.value ?? 1;

  @override
  void paint(Canvas canvas, Size size) {
    final sky = this.sky;
    if (paintBackground) {
      if (sky == null) {
        canvas.drawRect(
          Offset.zero & size,
          Paint()..color = type.posterColors.background,
        );
      } else {
        // Il cielo nuovo sfuma sopra quello di prima.
        final from = skyFrom;
        if (from != null && _fade < 1) {
          from.paintSky(canvas, size, type);
          canvas.saveLayer(
            Offset.zero & size,
            Paint()..color = Color.fromRGBO(0, 0, 0, _fade),
          );
          sky.paintSky(canvas, size, type);
          canvas.restore();
        } else {
          sky.paintSky(canvas, size, type);
        }
      }
    }
    final s = size.width / _designWidth;
    final above = size.height / s - _sceneHeight;
    final t = weather?.value ?? 0.37;
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.translate(0, size.height - _sceneHeight * s);
    canvas.scale(s);
    sky?.paintBehind(canvas, type, above, t, _fade);
    // Col buio (e sotto la pioggia) la scena si scurisce un poco.
    final dim = sky == null
        ? 0.0
        : math.max(
            0.38 * sky.moment.darkness,
            (sky.weather?.overcast ?? false) ? 0.14 : 0.0,
          );
    if (dim > 0) {
      canvas.saveLayer(
        const Rect.fromLTRB(-40, -600, 412, 240),
        Paint()
          ..colorFilter = ColorFilter.mode(
            Cartolina.inchiostro.withValues(alpha: dim),
            BlendMode.srcATop,
          ),
      );
    }
    _scene(canvas);
    if (dim > 0) canvas.restore();
    _paintMoons(canvas);
    if (sky != null) _overDim(canvas, sky);
    sky?.paintFront(canvas, above, t, _fade);
    canvas.restore();
  }

  void _scene(Canvas canvas) {
    switch (type) {
      case TripType.sea:
        _sea(canvas);
      case TripType.city:
        _city(canvas);
      case TripType.mountain:
        _mountain(canvas);
      case TripType.roadTrip:
        _road(canvas);
      case TripType.backpacking:
        _camp(canvas);
      case TripType.business:
        _skyline(canvas);
      case TripType.generic:
        _flight(canvas);
    }
  }

  /// Il sole (o, col buio, la luna) di una scena: scende con l'ora, si fa
  /// grande al tramonto e sparisce sotto un cielo coperto.
  void _sun(Canvas c, double x, double y, double r, [Color? color]) {
    final paint = _fill(color ?? Cartolina.sole);
    final sky = this.sky;
    if (sky == null) {
      c.drawCircle(Offset(x, y + _sunDown), r, paint);
      return;
    }
    if (sky.weather?.overcast ?? false) return;
    final m = sky.moment;
    // Dopo il tramonto il sole affonda dietro la scena mentre scurisce.
    final drop = m.sunDrop * 34 + m.darkness * 90;
    if (m.darkness < 1) {
      c.drawCircle(
        Offset(x, y + _sunDown + drop),
        r * (1 + 0.18 * m.warmth),
        paint,
      );
    }
    if (m.darkness > 0.05) {
      // La luna si disegna dopo, fuori dal velo che scurisce la scena.
      _moons.add((Offset(x, y + _sunDown - 40), r * 0.65));
    }
  }

  /// Lune in attesa di [_paintMoons] (una per scena).
  final List<(Offset, double)> _moons = [];

  /// Falce di luna ritagliata: niente disco d'ombra da intonare al cielo.
  void _paintMoons(Canvas c) {
    final a = sky?.moment.darkness ?? 0;
    for (final (center, r) in _moons) {
      final moon = Path.combine(
        PathOperation.difference,
        Path()..addOval(Rect.fromCircle(center: center, radius: r)),
        Path()..addOval(
          Rect.fromCircle(
            center: center + Offset(r * 0.45, -r * 0.3),
            radius: r * 0.9,
          ),
        ),
      );
      c.drawPath(moon, _fill(PosterSky.luna.withValues(alpha: a)));
    }
    _moons.clear();
  }

  /// Sopra il velo che scurisce la scena: cio' che deve restare acceso o
  /// staccarsi dal cielo scuro.
  void _overDim(Canvas c, PosterSky sky) {
    switch (type) {
      // Di notte le finestre accese tornano gialle.
      case TripType.city when sky.isNight:
        final lit = _fill(Cartolina.sole);
        for (final w in _cityWindows) {
          c.drawRect(w & const Size(7, 11), lit);
        }
      case TripType.business when sky.isNight:
        _skylineWindows(c, litOnly: true);
      case TripType.backpacking:
        _campMoon(c);
      case TripType.generic when _darkSky:
        _plane(c, PosterSky.nuvola, PosterSky.pervinca);
      default:
        break;
    }
  }

  /// Cielo scuro (titolo bianco): l'aereo e la scia si schiariscono.
  bool get _darkSky => sky?.darkSky(type) ?? false;

  static Paint _fill(Color c) => Paint()..color = c;

  /// Discesa del sole in unita' di scena.
  double get _sunDown => (sink?.value ?? 0) * 150;

  void _sea(Canvas c) {
    _sun(c, 290, 100, 54);
    final wave = math.sin((drift?.value ?? 0) * 2 * math.pi);
    if (decor && !(sky?.isNight ?? false)) {
      c.save();
      c.translate(0, wave * 2);
      c.drawPath(
        Path()
          ..moveTo(74, 44)
          ..lineTo(74, 80)
          ..lineTo(112, 80)
          ..close(),
        _fill(Colors.white),
      );
      c.drawPath(
        Path()
          ..moveTo(48, 86)
          ..lineTo(114, 86)
          ..lineTo(102, 104)
          ..lineTo(60, 104)
          ..close(),
        _fill(Cartolina.corallo),
      );
      c.restore();
    }
    // Le onde sbordano ai lati per poter derivare senza scoprire il cielo.
    c.save();
    c.translate(wave * 10, 0);
    c.drawPath(
      Path()
        ..moveTo(-30, 118)
        ..lineTo(0, 110)
        ..cubicTo(60, 88, 124, 88, 186, 110)
        ..cubicTo(248, 132, 312, 132, 372, 110)
        ..lineTo(402, 102)
        ..lineTo(402, 240)
        ..lineTo(-30, 240)
        ..close(),
      _fill(Cartolina.laguna),
    );
    c.restore();
    c.save();
    c.translate(-wave * 6, 0);
    c.drawPath(
      Path()
        ..moveTo(-30, 150)
        ..lineTo(0, 146)
        ..cubicTo(90, 134, 120, 158, 186, 146)
        ..cubicTo(252, 134, 300, 134, 372, 146)
        ..lineTo(402, 150)
        ..lineTo(402, 240)
        ..lineTo(-30, 240)
        ..close(),
      _fill(Cartolina.cobaltoScuro),
    );
    c.restore();
  }

  void _city(Canvas c) {
    _sun(c, 300, 62, 38);
    // Sullo sfondo: case, cupola con lanterna e campanile.
    c.drawPath(
      Path()
        ..moveTo(0, 150)
        ..lineTo(0, 112)
        ..lineTo(34, 112)
        ..lineTo(34, 100)
        ..lineTo(70, 100)
        ..lineTo(70, 112)
        ..lineTo(92, 112)
        ..lineTo(92, 100)
        ..lineTo(98, 100)
        ..cubicTo(98, 72, 116, 52, 130, 48)
        ..lineTo(130, 30)
        ..lineTo(126, 30)
        ..lineTo(136, 14)
        ..lineTo(146, 30)
        ..lineTo(142, 30)
        ..lineTo(142, 48)
        ..cubicTo(156, 52, 174, 72, 174, 100)
        ..lineTo(180, 100)
        ..lineTo(180, 108)
        ..lineTo(212, 108)
        ..lineTo(212, 38)
        ..lineTo(208, 38)
        ..lineTo(229, 12)
        ..lineTo(250, 38)
        ..lineTo(246, 38)
        ..lineTo(246, 104)
        ..lineTo(290, 104)
        ..lineTo(290, 92)
        ..lineTo(330, 92)
        ..lineTo(330, 110)
        ..lineTo(372, 110)
        ..lineTo(372, 150)
        ..close(),
      _fill(Cartolina.cobalto),
    );
    // Aperture ad arco: cella campanaria e tamburo della cupola.
    const openings = [
      (219.0, 72.0, 7.0, 16.0),
      (232.0, 72.0, 7.0, 16.0),
      (225.0, 104.0, 8.0, 12.0),
      (106.0, 122.0, 10.0, 10.0),
      (124.0, 122.0, 10.0, 10.0),
      (142.0, 122.0, 10.0, 10.0),
      (160.0, 122.0, 10.0, 10.0),
    ];
    for (final (x, bottom, w, h) in openings) {
      c.drawPath(
        Path()
          ..moveTo(x, bottom)
          ..lineTo(x, bottom - h)
          ..cubicTo(x, bottom - h - 6, x + w, bottom - h - 6, x + w, bottom - h)
          ..lineTo(x + w, bottom)
          ..close(),
        _fill(Cartolina.corallo),
      );
    }
    // Costoloni della cupola.
    c.drawPath(
      Path()
        ..moveTo(136, 50)
        ..cubicTo(128, 62, 124, 80, 124, 100)
        ..moveTo(136, 50)
        ..cubicTo(144, 62, 148, 80, 148, 100),
      Paint()
        ..color = Cartolina.cobaltoScuro
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    // In primo piano: i tetti, che proseguono nella fascia per i testi.
    c.drawPath(
      Path()
        ..moveTo(0, 240)
        ..lineTo(0, 134)
        ..lineTo(24, 114)
        ..lineTo(48, 134)
        ..lineTo(48, 122)
        ..lineTo(96, 122)
        ..lineTo(96, 134)
        ..lineTo(118, 116)
        ..lineTo(140, 134)
        ..lineTo(140, 126)
        ..lineTo(188, 126)
        ..lineTo(210, 110)
        ..lineTo(232, 126)
        ..lineTo(232, 134)
        ..lineTo(270, 134)
        ..lineTo(292, 114)
        ..lineTo(314, 134)
        ..lineTo(314, 124)
        ..lineTo(372, 124)
        ..lineTo(372, 240)
        ..close(),
      _fill(Cartolina.cobaltoScuro),
    );
    for (final w in _cityWindows) {
      c.drawRect(w & const Size(7, 11), _fill(Cartolina.sole));
    }
  }

  static const _cityWindows = [
    Offset(12, 136),
    Offset(30, 136),
    Offset(62, 130),
    Offset(80, 130),
    Offset(110, 136),
    Offset(126, 136),
    Offset(156, 132),
    Offset(172, 132),
    Offset(202, 128),
    Offset(218, 128),
    Offset(284, 130),
    Offset(298, 130),
    Offset(330, 130),
    Offset(350, 130),
  ];

  void _mountain(Canvas c) {
    c.drawPath(
      Path()
        ..moveTo(0, 240)
        ..lineTo(130, 54)
        ..lineTo(198, 140)
        ..lineTo(262, 28)
        ..lineTo(372, 240)
        ..close(),
      _fill(Cartolina.cobalto),
    );
    c.drawPath(
      Path()
        ..moveTo(262, 28)
        ..lineTo(290, 82)
        ..lineTo(268, 72)
        ..lineTo(252, 88)
        ..lineTo(236, 74)
        ..close(),
      _fill(Colors.white),
    );
    c.drawPath(
      Path()
        ..moveTo(0, 148)
        ..cubicTo(100, 112, 220, 176, 372, 138)
        ..lineTo(372, 240)
        ..lineTo(0, 240)
        ..close(),
      _fill(Cartolina.laguna),
    );
  }

  void _road(Canvas c) {
    _sun(c, 280, 64, 44);
    c.drawPath(
      Path()
        ..moveTo(0, 120)
        ..cubicTo(90, 70, 190, 124, 372, 92)
        ..lineTo(372, 240)
        ..lineTo(0, 240)
        ..close(),
      _fill(Cartolina.cobalto),
    );
    c.drawPath(
      Path()
        ..moveTo(166, 104)
        ..lineTo(194, 104)
        ..lineTo(330, 240)
        ..lineTo(46, 240)
        ..close(),
      _fill(Cartolina.inchiostro),
    );
    final dash = _fill(Cartolina.sole);
    for (final (y, h, w) in const [
      (122.0, 14.0, 3.0),
      (150.0, 20.0, 5.0),
      (188.0, 30.0, 7.0),
    ]) {
      c.drawRect(Rect.fromLTWH(186 - w / 2 + (y - 122) * 0.06, y, w, h), dash);
    }
  }

  void _camp(Canvas c) {
    final star = _fill(Colors.white);
    for (final (x, y, r) in const [
      (56.0, 40.0, 2.0),
      (150.0, 16.0, 2.5),
      (226.0, 56.0, 1.8),
      (330.0, 30.0, 2.4),
      (96.0, 84.0, 1.6),
    ]) {
      c.drawCircle(Offset(x, y), r, star);
    }
    // Col cielo vivo la luna si disegna sopra il velo della notte.
    if (sky == null) _campMoon(c);
    c.drawPath(
      Path()
        ..moveTo(0, 170)
        ..cubicTo(110, 118, 240, 170, 372, 132)
        ..lineTo(372, 240)
        ..lineTo(0, 240)
        ..close(),
      _fill(Cartolina.laguna),
    );
    c.drawPath(
      Path()
        ..moveTo(218, 84)
        ..lineTo(292, 176)
        ..lineTo(144, 176)
        ..close(),
      _fill(Cartolina.corallo),
    );
    c.drawPath(
      Path()
        ..moveTo(218, 118)
        ..lineTo(244, 176)
        ..lineTo(192, 176)
        ..close(),
      _fill(Cartolina.inchiostro),
    );
  }

  /// La falce del campeggio, ritagliata: niente disco d'ombra che si veda su
  /// un cielo diverso dal suo.
  void _campMoon(Canvas c) {
    final y = 84 + _sunDown;
    c.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addOval(Rect.fromCircle(center: Offset(304, y), radius: 34)),
        Path()
          ..addOval(Rect.fromCircle(center: Offset(290, y - 8), radius: 30)),
      ),
      _fill(Cartolina.sole),
    );
  }

  void _skyline(Canvas c) {
    _sun(c, 70, 70, 36, Cartolina.corallo);
    for (final (x, top, w) in _towers) {
      c.drawRect(Rect.fromLTWH(x, top, w, 240 - top), _fill(Cartolina.cobalto));
    }
    _skylineWindows(c);
    // Fascia bassa pulita, per i testi.
    c.drawRect(
      const Rect.fromLTWH(0, 152, 372, 88),
      _fill(Cartolina.cobaltoScuro),
    );
  }

  static const _towers = [
    (0.0, 120.0, 64.0),
    (70.0, 60.0, 58.0),
    (134.0, 132.0, 52.0),
    (192.0, 28.0, 66.0),
    (264.0, 96.0, 50.0),
    (320.0, 64.0, 52.0),
  ];

  /// Le finestre dei grattacieli (sopra la fascia bassa); [litOnly] per
  /// ridisegnare solo quelle accese.
  void _skylineWindows(Canvas c, {bool litOnly = false}) {
    for (final (x, top, w) in _towers) {
      for (var yy = top + 14; yy < 228; yy += 26) {
        if (litOnly && yy + 13 > 152) continue;
        for (var xx = x + 10; xx < x + w - 12; xx += 18) {
          // Alcune finestre accese, in modo stabile.
          final lit = ((xx * 7 + yy * 3).toInt() % 5) < 2;
          if (litOnly && !lit) continue;
          c.drawRect(
            Rect.fromLTWH(xx, yy, 9, 13),
            _fill(lit ? Cartolina.sole : Cartolina.cobaltoScuro),
          );
        }
      }
    }
  }

  void _flight(Canvas c) {
    _sun(c, 66, 116, 54);
    // Col cielo scuro le nuvole si fanno pervinca: le scritte bianche sopra.
    final cloud = _fill(_darkSky ? PosterSky.pervinca : Colors.white);
    for (final (x, y, r) in const [
      (0.0, 228.0, 44.0),
      (64.0, 214.0, 52.0),
      (132.0, 232.0, 42.0),
      (196.0, 218.0, 50.0),
      (262.0, 232.0, 44.0),
      (330.0, 214.0, 56.0),
    ]) {
      c.drawCircle(Offset(x, y), r, cloud);
    }
    // Col cielo scuro aereo e scia chiari, sopra il velo (_overDim).
    if (!_darkSky) _plane(c, Cartolina.inchiostro, Cartolina.cobalto);
  }

  /// Scia tratteggiata che sale verso l'aereo, e l'aereo.
  void _plane(Canvas c, Color color, Color trailColor) {
    final trail = _fill(trailColor);
    for (var i = 0; i < 7; i++) {
      final t = i / 7;
      final x = 96 + t * 170;
      final y = 150 - math.sin(t * math.pi / 2) * 92;
      c.save();
      c.translate(x, y);
      c.rotate(-0.5 + t * 0.2);
      c.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-8, -2.5, 16, 5),
          const Radius.circular(2.5),
        ),
        trail,
      );
      c.restore();
    }
    // Aereo.
    c.save();
    c.translate(300, 46);
    c.rotate(-0.42);
    final plane = _fill(color);
    c.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-34, -6, 68, 12),
        const Radius.circular(6),
      ),
      plane,
    );
    c.drawPath(
      Path()
        ..moveTo(6, -4)
        ..lineTo(-14, -30)
        ..lineTo(-4, -30)
        ..lineTo(20, -4)
        ..close(),
      plane,
    );
    c.drawPath(
      Path()
        ..moveTo(6, 4)
        ..lineTo(-14, 30)
        ..lineTo(-4, 30)
        ..lineTo(20, 4)
        ..close(),
      plane,
    );
    c.drawPath(
      Path()
        ..moveTo(-28, -4)
        ..lineTo(-38, -18)
        ..lineTo(-31, -18)
        ..lineTo(-20, -4)
        ..close(),
      plane,
    );
    c.restore();
  }

  @override
  bool shouldRepaint(PosterPainter oldDelegate) =>
      oldDelegate.type != type ||
      oldDelegate.drift != drift ||
      oldDelegate.sink != sink ||
      oldDelegate.paintBackground != paintBackground ||
      oldDelegate.decor != decor ||
      oldDelegate.sky != sky ||
      oldDelegate.skyFrom != skyFrom ||
      oldDelegate.weather != weather ||
      oldDelegate.fade != fade;
}

/// La scena del viaggio a tutta area (senza testi).
class PosterArt extends StatefulWidget {
  const PosterArt({
    super.key,
    required this.type,
    this.alive = false,
    this.sink,
    this.paintBackground = true,
    this.sky,
  });

  final TripType type;

  /// Il cielo vivo; null = poster di sempre.
  final PosterSky? sky;

  /// Il poster e' vivo: il mare deriva lentamente finche' resta in vista.
  final bool alive;

  /// Discesa del sole (0..1), legata allo scorrimento.
  final ValueListenable<double>? sink;
  final bool paintBackground;

  @override
  State<PosterArt> createState() => _PosterArtState();
}

class _PosterArtState extends State<PosterArt> with TickerProviderStateMixin {
  late final AnimationController _drift = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 14),
  );

  /// Nuvole, pioggia, neve e stelle.
  late final AnimationController _weather = AnimationController(
    vsync: this,
    duration: PosterSky.loop,
  );

  /// Dissolvenza quando il cielo cambia aspetto (arriva il meteo, scende la
  /// sera...).
  late final AnimationController _fade = AnimationController(
    vsync: this,
    duration: Motion.scene,
    value: 1,
  );
  PosterSky? _from;

  bool get _moves =>
      widget.alive && widget.type == TripType.sea && !Motion.off(context);

  bool get _weatherMoves =>
      widget.alive && (widget.sky?.moves ?? false) && !Motion.off(context);

  void _sync() {
    if (_moves) {
      if (!_drift.isAnimating) _drift.repeat();
    } else {
      _drift.stop();
    }
    if (_weatherMoves) {
      if (!_weather.isAnimating) _weather.repeat();
    } else {
      _weather.stop();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(PosterArt old) {
    super.didUpdateWidget(old);
    final before = old.sky, now = widget.sky;
    if (before != null &&
        now != null &&
        before.look != now.look &&
        !Motion.off(context)) {
      _from = before;
      _fade.forward(from: 0);
    }
    _sync();
  }

  @override
  void dispose() {
    _drift.dispose();
    _weather.dispose();
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: PosterPainter(
          widget.type,
          drift: widget.alive && widget.type == TripType.sea ? _drift : null,
          sink: widget.sink,
          paintBackground: widget.paintBackground,
          sky: widget.sky,
          skyFrom: _from,
          weather: widget.sky == null ? null : _weather,
          fade: widget.sky == null ? null : _fade,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

/// Il poster che vola dalla home alla testata del viaggio: gli angoli si
/// raddrizzano durante il volo.
class PosterHero extends StatelessWidget {
  const PosterHero({super.key, required this.tripId, required this.child});

  final String tripId;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'trip-hero-$tripId',
      createRectTween: (begin, end) => RectTween(begin: begin, end: end),
      flightShuttleBuilder: (context, animation, direction, from, to) {
        final hero = (direction == HeroFlightDirection.push ? to : from).widget;
        return AnimatedBuilder(
          animation: animation,
          child: (hero as Hero).child,
          builder: (context, child) => ClipRRect(
            borderRadius: BorderRadius.circular(24 * (1 - animation.value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// Pillola da manifesto (es. "tra 9 giorni").
class PosterPill extends StatelessWidget {
  const PosterPill(this.text, {super.key, this.color = Cartolina.sole});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: ShapeDecoration(color: color, shape: const StadiumBorder()),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: context.tokens.displayFont,
          fontWeight: FontWeight.w700,
          fontSize: 15,
          height: 1.2,
          color: Cartolina.inchiostro,
        ),
      ),
    );
  }
}
