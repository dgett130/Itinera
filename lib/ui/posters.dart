import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/enums.dart';
import 'itinera_theme.dart';
import 'motion.dart';

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
  }) : super(repaint: Listenable.merge([drift, sink]));

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

  /// Larghezza e altezza su cui e' disegnata ogni scena.
  static const double _designWidth = 372;
  static const double _sceneHeight = 240;

  @override
  void paint(Canvas canvas, Size size) {
    if (paintBackground) {
      canvas.drawRect(
        Offset.zero & size,
        Paint()..color = type.posterColors.background,
      );
    }
    final s = size.width / _designWidth;
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.translate(0, size.height - _sceneHeight * s);
    canvas.scale(s);
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
    canvas.restore();
  }

  static Paint _fill(Color c) => Paint()..color = c;

  /// Discesa del sole in unita' di scena.
  double get _sunDown => (sink?.value ?? 0) * 150;

  void _sea(Canvas c) {
    c.drawCircle(Offset(290, 100 + _sunDown), 54, _fill(Cartolina.sole));
    final wave = math.sin((drift?.value ?? 0) * 2 * math.pi);
    if (decor) {
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
    c.drawCircle(Offset(300, 62 + _sunDown), 38, _fill(Cartolina.sole));
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
    const windows = [
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
    for (final w in windows) {
      c.drawRect(w & const Size(7, 11), _fill(Cartolina.sole));
    }
  }

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
    c.drawCircle(Offset(280, 64 + _sunDown), 44, _fill(Cartolina.sole));
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
    c.drawCircle(Offset(304, 84 + _sunDown), 34, _fill(Cartolina.sole));
    c.drawCircle(Offset(290, 76 + _sunDown), 30, _fill(Cartolina.cobaltoScuro));
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

  void _skyline(Canvas c) {
    c.drawCircle(Offset(70, 70 + _sunDown), 36, _fill(Cartolina.corallo));
    const towers = [
      (0.0, 120.0, 64.0),
      (70.0, 60.0, 58.0),
      (134.0, 132.0, 52.0),
      (192.0, 28.0, 66.0),
      (264.0, 96.0, 50.0),
      (320.0, 64.0, 52.0),
    ];
    for (final (x, top, w) in towers) {
      c.drawRect(Rect.fromLTWH(x, top, w, 240 - top), _fill(Cartolina.cobalto));
      for (var yy = top + 14; yy < 228; yy += 26) {
        for (var xx = x + 10; xx < x + w - 12; xx += 18) {
          // Alcune finestre accese, in modo stabile.
          final lit = ((xx * 7 + yy * 3).toInt() % 5) < 2;
          c.drawRect(
            Rect.fromLTWH(xx, yy, 9, 13),
            _fill(lit ? Cartolina.sole : Cartolina.cobaltoScuro),
          );
        }
      }
    }
    // Fascia bassa pulita, per i testi.
    c.drawRect(
      const Rect.fromLTWH(0, 152, 372, 88),
      _fill(Cartolina.cobaltoScuro),
    );
  }

  void _flight(Canvas c) {
    c.drawCircle(Offset(66, 116 + _sunDown), 54, _fill(Cartolina.sole));
    final cloud = _fill(Colors.white);
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
    // Scia tratteggiata che sale verso l'aereo.
    final trail = _fill(Cartolina.cobalto);
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
    final plane = _fill(Cartolina.inchiostro);
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
      oldDelegate.decor != decor;
}

/// La scena del viaggio a tutta area (senza testi).
class PosterArt extends StatefulWidget {
  const PosterArt({
    super.key,
    required this.type,
    this.alive = false,
    this.sink,
    this.paintBackground = true,
  });

  final TripType type;

  /// Il poster e' vivo: il mare deriva lentamente finche' resta in vista.
  final bool alive;

  /// Discesa del sole (0..1), legata allo scorrimento.
  final ValueListenable<double>? sink;
  final bool paintBackground;

  @override
  State<PosterArt> createState() => _PosterArtState();
}

class _PosterArtState extends State<PosterArt>
    with SingleTickerProviderStateMixin {
  late final AnimationController _drift = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 14),
  );

  bool get _moves =>
      widget.alive && widget.type == TripType.sea && !Motion.off(context);

  void _sync() {
    if (_moves) {
      if (!_drift.isAnimating) _drift.repeat();
    } else {
      _drift.stop();
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
    _sync();
  }

  @override
  void dispose() {
    _drift.dispose();
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
