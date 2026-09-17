import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Personaggio del pannello "Novità".
///
/// Usa l'animazione **Lottie** `assets/lottie/hiker.json` se presente
/// (personaggio professionale); se il file manca, ripiega sul disegno a mano
/// ([_PainterHiker]). Così basta aggiungere il JSON per cambiare il personaggio,
/// senza rompere la build.
class StickmanHiker extends StatelessWidget {
  const StickmanHiker({super.key, this.fit = BoxFit.cover});

  /// Come riempire lo spazio disponibile (default: riempie il pannello).
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return Lottie.asset(
      'assets/lottie/hiker.json',
      width: double.infinity,
      height: double.infinity,
      fit: fit,
      animate: !reduce,
      errorBuilder: (context, error, stack) => LayoutBuilder(
        builder: (context, c) => Center(
          child: _PainterHiker(
            size: math.min(
              c.maxWidth.isFinite ? c.maxWidth : 150,
              c.maxHeight.isFinite ? c.maxHeight : 150,
            ),
          ),
        ),
      ),
    );
  }
}

/// Fallback disegnato a mano (CustomPainter) quando manca il Lottie.
class _PainterHiker extends StatefulWidget {
  const _PainterHiker({required this.size});
  final double size;

  @override
  State<_PainterHiker> createState() => _PainterHikerState();
}

class _PainterHikerState extends State<_PainterHiker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduce) {
      _c.stop();
      _c.value = 0.0;
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.square(widget.size),
        painter: _HikerPainter(_c),
      ),
    );
  }
}

class _HikerPainter extends CustomPainter {
  _HikerPainter(this.t) : super(repaint: t);
  final Animation<double> t;

  // Palette chibi outdoor (fissa, indipendente dal tema).
  static const _skin = Color(0xFFF6C79B);
  static const _skinDark = Color(0xFFE7B184);
  static const _cap = Color(0xFFE8654E);
  static const _capDark = Color(0xFFCF5340);
  static const _shirt = Color(0xFF2FA39F);
  static const _shorts = Color(0xFF33506B);
  static const _boots = Color(0xFF5A3E2B);
  static const _pack = Color(0xFFE7A93C);
  static const _packDark = Color(0xFFCB9330);
  static const _mat = Color(0xFFD9584A);
  static const _strap = Color(0xFF2C3E50);
  static const _phone = Color(0xFF2B2E33);
  static const _screen = Color(0xFF9BD8F0);
  static const _ink = Color(0xFF34495E);

  Paint _fill(Color c) => Paint()
    ..color = c
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;

  // Arto "capsula": tratto spesso a estremi tondi.
  void _limb(Canvas c, Offset a, Offset b, Color color, double w) {
    c.drawLine(
      a,
      b,
      Paint()
        ..color = color
        ..strokeWidth = w
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final ph = t.value * 2 * math.pi;
    final bob = math.sin(ph * 2) * s * 0.012;
    final cx = s * 0.5;

    // --- Ombra a terra (non ondeggia) -------------------------------------
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, s * 0.88),
        width: s * 0.46,
        height: s * 0.065,
      ),
      _fill(const Color(0x1F000000)),
    );

    // Marcia: piedi alternati.
    final liftL = math.max(0.0, math.sin(ph)) * s * 0.05;
    final liftR = math.max(0.0, math.sin(ph + math.pi)) * s * 0.05;
    final hipY = s * 0.66 + bob;
    final footY = s * 0.85;

    // --- Gambe (dietro al busto) ------------------------------------------
    _leg(canvas, Offset(cx - s * 0.055, hipY), Offset(cx - s * 0.07, footY - liftL), s);
    _leg(canvas, Offset(cx + s * 0.055, hipY), Offset(cx + s * 0.07, footY - liftR), s);

    // --- Zaino DIETRO (sbuca dai lati e sopra le spalle) ------------------
    // Disegnato PRIMA del busto: il torso copre il centro, lo zaino resta
    // visibile solo ai bordi -> si legge come "dietro".
    final packCy = s * 0.56 + bob;
    // Sacco a pelo arrotolato in cima, dietro le spalle.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, s * 0.415 + bob), width: s * 0.30, height: s * 0.06),
        Radius.circular(s * 0.03),
      ),
      _fill(_mat),
    );
    // Corpo dello zaino (più largo del busto).
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, packCy), width: s * 0.36, height: s * 0.30),
        Radius.circular(s * 0.07),
      ),
      _fill(_pack),
    );
    // Tasche laterali che sbucano ai fianchi.
    for (final dir in [-1, 1]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx + dir * s * 0.155, packCy + s * 0.03),
            width: s * 0.06,
            height: s * 0.13,
          ),
          Radius.circular(s * 0.02),
        ),
        _fill(_packDark),
      );
    }

    // --- Busto (maglietta) -------------------------------------------------
    final torso = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, s * 0.585 + bob), width: s * 0.24, height: s * 0.26),
      Radius.circular(s * 0.10),
    );
    canvas.drawRRect(torso, _fill(_shirt));
    // Spallacci.
    _limb(canvas, Offset(cx - s * 0.07, s * 0.47 + bob), Offset(cx - s * 0.055, s * 0.66 + bob), _strap, s * 0.03);
    _limb(canvas, Offset(cx + s * 0.07, s * 0.47 + bob), Offset(cx + s * 0.055, s * 0.66 + bob), _strap, s * 0.03);

    // --- Braccia che reggono il GPS: manica (maglietta) + avambraccio pelle,
    //     coerenti con le gambe (pantaloncino + polpaccio pelle).
    final shoulderY = s * 0.52 + bob;
    final handY = s * 0.585 + bob + math.sin(ph * 2) * s * 0.004;
    for (final dir in [-1, 1]) {
      final shoulder = Offset(cx + dir * s * 0.10, shoulderY);
      final elbow = Offset(cx + dir * s * 0.085, s * 0.565 + bob);
      final hand = Offset(cx + dir * s * 0.045, handY);
      _limb(canvas, shoulder, elbow, _shirt, s * 0.055);
      _limb(canvas, elbow, hand, _skin, s * 0.045);
    }
    // Mani.
    canvas.drawCircle(Offset(cx - s * 0.045, handY), s * 0.028, _fill(_skin));
    canvas.drawCircle(Offset(cx + s * 0.045, handY), s * 0.028, _fill(_skin));
    // GPS/telefono.
    final gps = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, handY - s * 0.01), width: s * 0.13, height: s * 0.10),
      Radius.circular(s * 0.02),
    );
    canvas.drawRRect(gps, _fill(_phone));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, handY - s * 0.01), width: s * 0.10, height: s * 0.065),
        Radius.circular(s * 0.012),
      ),
      _fill(_screen),
    );

    // --- Testa + cappellino + faccia --------------------------------------
    final headC = Offset(cx, s * 0.30 + bob);
    final r = s * 0.155;
    canvas.drawCircle(headC, r, _fill(_skin));
    // Orecchio.
    canvas.drawCircle(Offset(headC.dx + r * 0.95, headC.dy + r * 0.15), s * 0.022, _fill(_skinDark));
    // Cappellino (calotta sopra) + visiera.
    final headRect = Rect.fromCircle(center: headC, radius: r);
    final capPath = Path()
      ..moveTo(headC.dx - r, headC.dy - r * 0.05)
      ..arcTo(headRect, math.pi, math.pi, false)
      ..lineTo(headC.dx + r, headC.dy - r * 0.05)
      ..close();
    canvas.drawPath(capPath, _fill(_cap));
    // Bordino del cappellino.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(headC.dx, headC.dy - r * 0.02), width: r * 2.05, height: s * 0.03),
        Radius.circular(s * 0.02),
      ),
      _fill(_capDark),
    );
    // Visiera verso sinistra.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(headC.dx - r * 0.9, headC.dy - r * 0.02), width: s * 0.10, height: s * 0.028),
        Radius.circular(s * 0.014),
      ),
      _fill(_capDark),
    );
    // Occhi (guardano il GPS: leggermente in basso).
    final eyeY = headC.dy + r * 0.28;
    canvas.drawCircle(Offset(headC.dx - r * 0.32, eyeY), s * 0.016, _fill(_ink));
    canvas.drawCircle(Offset(headC.dx + r * 0.32, eyeY), s * 0.016, _fill(_ink));
    // Guance.
    canvas.drawCircle(Offset(headC.dx - r * 0.55, eyeY + r * 0.28), s * 0.018, _fill(const Color(0x33E8654E)));
    canvas.drawCircle(Offset(headC.dx + r * 0.55, eyeY + r * 0.28), s * 0.018, _fill(const Color(0x33E8654E)));
    // Sorriso.
    canvas.drawArc(
      Rect.fromCenter(center: Offset(headC.dx, eyeY + r * 0.30), width: r * 0.7, height: r * 0.5),
      0.15 * math.pi,
      0.7 * math.pi,
      false,
      Paint()
        ..color = _ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.014
        ..strokeCap = StrokeCap.round,
    );

  }

  void _leg(Canvas c, Offset hip, Offset foot, double s) {
    final knee = Offset((hip.dx + foot.dx) / 2, (hip.dy + foot.dy) / 2);
    // Coscia (pantaloncino) + polpaccio (pelle).
    _limb(c, hip, knee, _shorts, s * 0.062);
    _limb(c, knee, foot, _skin, s * 0.05);
    // Scarponcino.
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(foot.dx - s * 0.01, foot.dy), width: s * 0.075, height: s * 0.045),
        Radius.circular(s * 0.02),
      ),
      _fill(_boots),
    );
  }

  @override
  bool shouldRepaint(covariant _HikerPainter old) => false;
}
