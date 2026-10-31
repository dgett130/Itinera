import 'package:flutter/material.dart';

import 'itinera_theme.dart';
import 'motion.dart';

/// Apertura dell'app: il sole sorge dalle onde e la scena svanisce sulla prima
/// schermata. Una volta per avvio; un tocco la chiude subito.
class SunriseSplash extends StatefulWidget {
  const SunriseSplash({super.key, required this.child});

  final Widget child;

  @override
  State<SunriseSplash> createState() => _SunriseSplashState();
}

class _SunriseSplashState extends State<SunriseSplash>
    with SingleTickerProviderStateMixin {
  static const _total = Duration(milliseconds: 1900);

  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: _total,
  );
  var _done = false;
  var _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (Motion.off(context)) {
      _done = true;
      return;
    }
    _c.forward().whenComplete(() {
      if (mounted) setState(() => _done = true);
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  /// Salta alla dissolvenza finale.
  void _skip() {
    if (_c.value < 0.8) _c.forward(from: 0.8);
  }

  @override
  Widget build(BuildContext context) {
    if (_done) return widget.child;
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _skip,
          child: ExcludeSemantics(
            child: AnimatedBuilder(
              animation: _c,
              builder: (context, _) {
                final t = _c.value;
                final fadeOut = t < 0.8 ? 1.0 : (1 - t) / 0.2;
                final titleIn = Curves.easeOut.transform(
                  ((t - 0.28) / 0.22).clamp(0.0, 1.0),
                );
                return Opacity(
                  opacity: fadeOut,
                  child: CustomPaint(
                    painter: _SunrisePainter(t),
                    child: Align(
                      alignment: const Alignment(0, -0.42),
                      child: Opacity(
                        opacity: titleIn,
                        child: Transform.translate(
                          offset: Offset(0, -14 * (1 - titleIn)),
                          child: Text(
                            'Itinera',
                            textDirection: TextDirection.ltr,
                            style: TextStyle(
                              inherit: false,
                              fontFamily: context.tokens.displayFont,
                              fontWeight: FontWeight.w800,
                              fontSize: 54,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _SunrisePainter extends CustomPainter {
  _SunrisePainter(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    canvas.drawRect(Offset.zero & size, Paint()..color = Cartolina.cobalto);

    // Il sole sale nella prima metà, con la molla.
    final rise = Motion.spring.transform((t / 0.55).clamp(0.0, 1.0));
    final r = w * 0.15;
    final sunY = h * 0.78 + (h * 0.52 - h * 0.78) * rise;
    canvas.drawCircle(Offset(w / 2, sunY), r, Paint()..color = Cartolina.sole);

    // Le onde si abbassano appena mentre il sole sale.
    final top = h * 0.66 + h * 0.02 * rise;
    canvas.drawPath(
      Path()
        ..moveTo(0, top)
        ..cubicTo(
          w * 0.16,
          top - h * 0.04,
          w * 0.34,
          top - h * 0.04,
          w * 0.5,
          top,
        )
        ..cubicTo(w * 0.66, top + h * 0.04, w * 0.84, top + h * 0.04, w, top)
        ..lineTo(w, h)
        ..lineTo(0, h)
        ..close(),
      Paint()..color = Cartolina.laguna,
    );
    final low = top + h * 0.08;
    canvas.drawPath(
      Path()
        ..moveTo(0, low)
        ..cubicTo(
          w * 0.24,
          low - h * 0.016,
          w * 0.32,
          low + h * 0.012,
          w * 0.5,
          low,
        )
        ..cubicTo(w * 0.68, low - h * 0.012, w * 0.8, low - h * 0.016, w, low)
        ..lineTo(w, h)
        ..lineTo(0, h)
        ..close(),
      Paint()..color = Cartolina.cobaltoScuro,
    );
  }

  @override
  bool shouldRepaint(_SunrisePainter old) => old.t != t;
}
