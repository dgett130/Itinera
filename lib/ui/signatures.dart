import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'itinera_theme.dart';

/// Elementi decorativi "firma" degli stili di viaggio: l'eroe del viaggio e i
/// tratti caratteristici (curve di livello, perforazione, bagliore tramonto).

/// Intestazione a card del viaggio, resa in modo diverso per ogni stile.
class TripHero extends StatelessWidget {
  const TripHero({
    super.key,
    required this.title,
    required this.typeIcon,
    this.kicker,
    this.meta,
    this.height = 196,
    this.heroTag,
  });

  /// Nome del viaggio.
  final String title;

  /// Icona del tipo di viaggio.
  final IconData typeIcon;

  /// Piccola etichetta sopra il titolo (destinazione o stato).
  final String? kicker;

  /// Riga di meta-dati (date, viaggiatori), resa in monospace.
  final String? meta;

  final double height;

  /// Se valorizzato, lo sfondo del hero "vola" con un Hero condiviso
  /// (card della lista → dettaglio del viaggio).
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return ClipRRect(
      borderRadius: BorderRadius.circular(_radius(tokens.signature)),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _background(tokens),
            Positioned.fill(
              child: AnimatedHeroBackground(colors: tokens.heroGradient),
            ),
            Positioned.fill(child: CustomPaint(painter: _painter(tokens))),
            _foreground(context, tokens),
          ],
        ),
      ),
    );
  }

  double _radius(StyleSignature s) => switch (s) {
    StyleSignature.contour => 20,
    StyleSignature.ticket => 12,
    StyleSignature.gradient => 24,
  };

  /// Sfondo a gradiente; se [heroTag] e' impostato, vola con un Hero condiviso.
  Widget _background(ItineraTokens tokens) {
    final bg = DecoratedBox(
      decoration: BoxDecoration(gradient: tokens.heroLinearGradient),
    );
    return heroTag == null ? bg : Hero(tag: heroTag!, child: bg);
  }

  CustomPainter _painter(ItineraTokens tokens) => switch (tokens.signature) {
    StyleSignature.contour => ContourPainter(tokens.heroForeground),
    StyleSignature.ticket => TicketPainter(tokens.heroForeground),
    StyleSignature.gradient => SunsetGlowPainter(tokens.heroGradient),
  };

  Widget _foreground(BuildContext context, ItineraTokens tokens) {
    final fg = tokens.heroForeground;
    final muted = tokens.heroForegroundMuted;
    final display = tokens.displayFont;

    final kickerWidget = (kicker != null && kicker!.isNotEmpty)
        ? Text(
            kicker!.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: tokens.monoFont,
              color: muted,
              fontSize: 11,
              letterSpacing: 1.5,
            ),
          )
        : null;

    final metaWidget = (meta != null && meta!.isNotEmpty)
        ? Text(
            meta!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: tokens.monoFont,
              color: muted,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          )
        : null;

    final titleWidget = Text(
      title,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontFamily: display,
        color: fg,
        fontWeight: FontWeight.w600,
        fontSize: tokens.signature == StyleSignature.gradient ? 30 : 28,
        height: 1.02,
        letterSpacing: tokens.signature == StyleSignature.gradient ? -0.5 : 0,
      ),
    );

    final badge = Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: fg.withValues(alpha: 0.16),
        shape: BoxShape.circle,
      ),
      child: Icon(typeIcon, color: fg, size: 22),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (kickerWidget != null) ...[
                      kickerWidget,
                      const SizedBox(height: 6),
                    ],
                  ],
                ),
              ),
              badge,
            ],
          ),
          const Spacer(),
          titleWidget,
          if (metaWidget != null) ...[const SizedBox(height: 8), metaWidget],
        ],
      ),
    );
  }
}

/// Curve di livello da mappa topografica (stile Atlante).
class ContourPainter extends CustomPainter {
  ContourPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = color.withValues(alpha: 0.14);

    const lines = 7;
    for (var i = 0; i < lines; i++) {
      final path = Path();
      final baseY = size.height * (i / (lines - 1));
      final amp = 10.0 + (i % 3) * 6.0;
      final phase = i * 0.9;
      path.moveTo(0, baseY);
      for (double x = 0; x <= size.width; x += 8) {
        final y =
            baseY +
            math.sin((x / size.width) * math.pi * 3 + phase) * amp -
            size.height * 0.12;
        path.lineTo(x, y);
      }
      canvas.drawPath(path, paint);
    }

    // Punto "posizione" in basso a destra.
    final dot = Paint()..color = color.withValues(alpha: 0.9);
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = color.withValues(alpha: 0.5);
    final c = Offset(size.width - 34, size.height - 34);
    canvas.drawCircle(c, 4, dot);
    canvas.drawCircle(c, 11, ring);
  }

  @override
  bool shouldRepaint(covariant ContourPainter old) => old.color != color;
}

/// Motivo da carta d'imbarco: tratteggio orizzontale e perforazione ai lati.
class TicketPainter extends CustomPainter {
  TicketPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = color.withValues(alpha: 0.16)
      ..strokeWidth = 1;
    // Linea tratteggiata orizzontale a 2/3.
    final y = size.height * 0.62;
    const dash = 7.0;
    const gap = 6.0;
    for (double x = 16; x < size.width - 40; x += dash + gap) {
      canvas.drawLine(Offset(x, y), Offset(x + dash, y), line);
    }

    // Fori di perforazione lungo il bordo destro.
    final hole = Paint()..color = color.withValues(alpha: 0.18);
    for (double hy = 14; hy < size.height - 8; hy += 18) {
      canvas.drawCircle(Offset(size.width - 16, hy), 3, hole);
    }

    // Aeroplano stilizzato tratteggiato in alto.
    final dashPaint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..strokeWidth = 1.4;
    final ty = size.height * 0.30;
    for (double x = 18; x < size.width * 0.5; x += 10) {
      canvas.drawLine(Offset(x, ty), Offset(x + 5, ty), dashPaint);
    }
  }

  @override
  bool shouldRepaint(covariant TicketPainter old) => old.color != color;
}

/// Bagliori radiali morbidi sopra il gradiente tramonto (stile Sunset).
class SunsetGlowPainter extends CustomPainter {
  SunsetGlowPainter(this.colors);
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final glow1 = Paint()
      ..shader =
          RadialGradient(
            colors: [Colors.white.withValues(alpha: 0.28), Colors.transparent],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.82, size.height * 0.18),
              radius: 120,
            ),
          );
    canvas.drawRect(Offset.zero & size, glow1);

    final glow2 = Paint()
      ..shader =
          RadialGradient(
            colors: [
              (colors.length > 1 ? colors.last : Colors.purple).withValues(
                alpha: 0.35,
              ),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.1, size.height * 1.0),
              radius: 160,
            ),
          );
    canvas.drawRect(Offset.zero & size, glow2);
  }

  @override
  bool shouldRepaint(covariant SunsetGlowPainter old) => old.colors != colors;
}

/// Bagliori morbidi per l'anteprima quadrata dello stile Sunset.
class SunsetPreviewPainter extends CustomPainter {
  SunsetPreviewPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final glow = Paint()
      ..shader =
          RadialGradient(
            colors: [color.withValues(alpha: 0.35), Colors.transparent],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.75, size.height * 0.2),
              radius: 40,
            ),
          );
    canvas.drawRect(Offset.zero & size, glow);
  }

  @override
  bool shouldRepaint(covariant SunsetPreviewPainter old) => old.color != color;
}

/// Divisore da biglietto: linea tratteggiata con due tacche laterali.
class PerforatedDivider extends StatelessWidget {
  const PerforatedDivider({super.key, this.color, this.notchColor});

  final Color? color;
  final Color? notchColor;

  @override
  Widget build(BuildContext context) {
    final c = color ?? context.tokens.hairline;
    final n = notchColor ?? Theme.of(context).scaffoldBackgroundColor;
    return SizedBox(
      height: 20,
      child: CustomPaint(
        size: Size.infinite,
        painter: _PerforationPainter(c, n),
      ),
    );
  }
}

class _PerforationPainter extends CustomPainter {
  _PerforationPainter(this.line, this.notch);
  final Color line;
  final Color notch;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    final notchPaint = Paint()..color = notch;
    // Tacche semicircolari ai bordi.
    canvas.drawCircle(Offset(0, y), 9, notchPaint);
    canvas.drawCircle(Offset(size.width, y), 9, notchPaint);

    final dash = Paint()
      ..color = line
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    for (double x = 14; x < size.width - 14; x += 12) {
      canvas.drawLine(Offset(x, y), Offset(x + 6, y), dash);
    }
  }

  @override
  bool shouldRepaint(covariant _PerforationPainter old) =>
      old.line != line || old.notch != notch;
}

/// Sfondo "aurora" animato: bagliori radiali morbidi che si spostano
/// lentamente, nei colori dello stile del viaggio. Sottile, per non coprire i
/// tratti-firma. Rispetta "Riduci animazioni" del sistema (fotogramma statico).
class AnimatedHeroBackground extends StatefulWidget {
  const AnimatedHeroBackground({super.key, required this.colors});
  final List<Color> colors;

  @override
  State<AnimatedHeroBackground> createState() => _AnimatedHeroBackgroundState();
}

class _AnimatedHeroBackgroundState extends State<AnimatedHeroBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 16),
  );

  @override
  void initState() {
    super.initState();
    _c.repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduce) {
      return CustomPaint(painter: _AuroraPainter(0, widget.colors));
    }
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, _) =>
            CustomPaint(painter: _AuroraPainter(_c.value, widget.colors)),
      ),
    );
  }
}

class _AuroraPainter extends CustomPainter {
  _AuroraPainter(this.t, this.colors);

  /// Avanzamento 0..1 del ciclo.
  final double t;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    if (colors.isEmpty) return;
    final tau = t * 2 * math.pi;
    final c0 = colors.first;
    final c1 = colors.length > 1 ? colors[1] : colors.first;
    final c2 = colors.last;
    _blob(
      canvas,
      size,
      cx: 0.25 + 0.12 * math.sin(tau),
      cy: 0.28 + 0.10 * math.cos(tau * 0.8),
      r: 0.55,
      color: c0,
    );
    _blob(
      canvas,
      size,
      cx: 0.80 + 0.10 * math.cos(tau * 1.1),
      cy: 0.34 + 0.12 * math.sin(tau * 1.3),
      r: 0.50,
      color: c1,
    );
    _blob(
      canvas,
      size,
      cx: 0.55 + 0.14 * math.sin(tau * 0.6 + 1),
      cy: 0.86 + 0.08 * math.cos(tau),
      r: 0.60,
      color: c2,
    );
  }

  void _blob(
    Canvas canvas,
    Size size, {
    required double cx,
    required double cy,
    required double r,
    required Color color,
  }) {
    final center = Offset(size.width * cx, size.height * cy);
    final radius = size.shortestSide * r;
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color.withValues(alpha: 0.28), color.withValues(alpha: 0.0)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _AuroraPainter old) =>
      old.t != t || old.colors != colors;
}
