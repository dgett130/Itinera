import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

import 'itinera_theme.dart';

/// Il movimento di Cartolina (vedi la pagina "K · Movimento" delle maschere):
/// il poster e' vivo, tutto il resto e' carta. Ogni animazione si spegne con
/// "Riduci animazioni" di Android e nessuna blocca l'input.
class Motion {
  Motion._();

  /// Spunte, tocchi, selettori.
  static const fast = Duration(milliseconds: 120);

  /// Liste, cambio scheda, avvisi.
  static const standard = Duration(milliseconds: 240);

  /// Poster, fogli, passi del percorso.
  static const emphasis = Duration(milliseconds: 420);

  /// Apertura, valigia pronta.
  static const scene = Duration(milliseconds: 900);

  /// Pausa tra gli elementi di una cascata (al massimo [staggerMax] elementi).
  static const stagger = Duration(milliseconds: 40);
  static const staggerMax = 6;

  /// Molla per ingressi e cambi di forma (da usare con [emphasis]).
  static const Curve spring = _SpringCurve(
    stiffness: 260,
    damping: 22,
    seconds: 0.42,
  );

  /// Scatto per spunte e spilli (da usare con [standard]).
  static const Curve pop = _SpringCurve(
    stiffness: 420,
    damping: 18,
    seconds: 0.30,
  );

  /// Vero se l'utente ha chiesto di ridurre le animazioni.
  static bool off(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  /// [d], oppure zero con le animazioni ridotte.
  static Duration of(BuildContext context, Duration d) =>
      off(context) ? Duration.zero : d;
}

class _SpringCurve extends Curve {
  const _SpringCurve({
    required this.stiffness,
    required this.damping,
    required this.seconds,
  });

  final double stiffness;
  final double damping;
  final double seconds;

  @override
  double transformInternal(double t) {
    final sim = SpringSimulation(
      SpringDescription(mass: 1, stiffness: stiffness, damping: damping),
      0,
      1,
      0,
    );
    return sim.x(t * seconds);
  }
}

/// Ingresso in cascata: il figlio sale e appare con un ritardo legato a
/// [index]. Oltre [Motion.staggerMax] entra insieme agli ultimi.
class StaggerIn extends StatefulWidget {
  const StaggerIn({
    super.key,
    required this.child,
    this.index = 0,
    this.offset = 24,
  });

  final Widget child;
  final int index;

  /// Distanza di partenza in pixel, verso il basso.
  final double offset;

  @override
  State<StaggerIn> createState() => _StaggerInState();
}

class _StaggerInState extends State<StaggerIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: Motion.standard,
  );
  Timer? _delay;
  var _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (Motion.off(context)) {
      _c.value = 1;
      return;
    }
    final steps = math.min(widget.index, Motion.staggerMax);
    _delay = Timer(Motion.stagger * steps, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _delay?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) {
        final v = Curves.easeOutCubic.transform(_c.value);
        return Opacity(
          opacity: v,
          child: Transform.translate(
            offset: Offset(0, widget.offset * (1 - v)),
            child: child,
          ),
        );
      },
    );
  }
}

/// Numero che conta fino al nuovo valore quando cambia (al primo disegno e'
/// gia' fermo: si anima solo un cambiamento vero).
class CountUpText extends StatefulWidget {
  const CountUpText({
    super.key,
    required this.value,
    required this.format,
    this.style,
    this.maxLines,
  });

  final num value;
  final String Function(num value) format;
  final TextStyle? style;
  final int? maxLines;

  @override
  State<CountUpText> createState() => _CountUpTextState();
}

class _CountUpTextState extends State<CountUpText> {
  late num _from = widget.value;

  @override
  void didUpdateWidget(CountUpText old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) _from = old.value;
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(widget.value),
      tween: Tween(begin: 0, end: 1),
      duration: _from == widget.value
          ? Duration.zero
          : Motion.of(context, Motion.emphasis),
      curve: Curves.easeOutCubic,
      builder: (context, t, _) {
        final showing = t >= 1
            ? widget.value
            : _from + (widget.value - _from) * t;
        return Text(
          widget.format(showing),
          style: widget.style,
          maxLines: widget.maxLines,
        );
      },
    );
  }
}

/// Oscilla due volte ogni volta che [trigger] passa da falso a vero.
class ShakeOnTrue extends StatefulWidget {
  const ShakeOnTrue({super.key, required this.trigger, required this.child});

  final bool trigger;
  final Widget child;

  @override
  State<ShakeOnTrue> createState() => _ShakeOnTrueState();
}

class _ShakeOnTrueState extends State<ShakeOnTrue>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: Motion.emphasis,
  );

  @override
  void didUpdateWidget(ShakeOnTrue old) {
    super.didUpdateWidget(old);
    if (widget.trigger && !old.trigger && !Motion.off(context)) {
      _c.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) {
        final dx = math.sin(_c.value * math.pi * 4) * 6 * (1 - _c.value);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
    );
  }
}

/// Spunta rotonda: scatta quando viene segnata.
class CheckDot extends StatelessWidget {
  const CheckDot({super.key, required this.checked, this.size = 28});

  final bool checked;
  final double size;

  @override
  Widget build(BuildContext context) {
    final on = context.scheme.onSurface;
    return AnimatedScale(
      scale: checked ? 1 : 0.94,
      duration: Motion.of(context, Motion.standard),
      curve: Motion.pop,
      child: AnimatedContainer(
        duration: Motion.of(context, Motion.fast),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: checked ? Cartolina.sole : Colors.transparent,
          border: checked ? null : Border.all(color: on, width: 1.5),
        ),
        child: checked
            ? Icon(Icons.check, size: size * 0.6, color: Cartolina.inchiostro)
            : null,
      ),
    );
  }
}

/// Segnaposto di caricamento che respira.
class Skeleton extends StatefulWidget {
  const Skeleton({super.key, this.width, this.height = 16, this.radius = 8});

  final double? width;
  final double height;
  final double radius;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (Motion.off(context)) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = context.tokens.hairline;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) => Opacity(
        opacity: 0.55 + 0.45 * Curves.easeInOut.transform(_c.value),
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(widget.radius),
          ),
        ),
      ),
    );
  }
}

/// Foglio dal basso col movimento di Cartolina. Con [fromFab] il foglio si
/// apre dal bottone in basso a destra: il ritaglio parte dalla sua forma e si
/// allarga fino al foglio intero.
Future<T?> showCartolinaSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool fromFab = false,
  bool isScrollControlled = true,
  bool useSafeArea = true,
  bool showDragHandle = false,
}) {
  final reduced = Motion.off(context);
  // Chiuso il foglio, la tastiera non deve riaprirsi sul campo di prima.
  FocusManager.instance.primaryFocus?.unfocus();
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    useSafeArea: useSafeArea,
    showDragHandle: showDragHandle,
    // Col bottone che si apre, lo sfondo lo disegna il ritaglio.
    backgroundColor: fromFab && !reduced ? Colors.transparent : null,
    elevation: fromFab && !reduced ? 0 : null,
    sheetAnimationStyle: AnimationStyle(
      duration: reduced ? Duration.zero : Motion.emphasis,
      reverseDuration: reduced ? Duration.zero : Motion.standard,
    ),
    builder: (context) => fromFab && !reduced
        ? _FabReveal(child: builder(context))
        : builder(context),
  );
}

class _FabReveal extends StatelessWidget {
  const _FabReveal({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final animation = ModalRoute.of(context)?.animation;
    if (animation == null) return child;
    final theme = Theme.of(context);
    final sheetColor =
        theme.bottomSheetTheme.backgroundColor ?? theme.colorScheme.surface;
    final fabColor =
        theme.floatingActionButtonTheme.backgroundColor ??
        theme.colorScheme.primary;
    final bottom = MediaQuery.viewPaddingOf(context).bottom;
    // La struttura resta identica a ogni frame, per non perdere il focus dei
    // campi del foglio; a fine apertura i valori diventano neutri.
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final opening = animation.status == AnimationStatus.forward;
        final raw = animation.value.clamp(0.0, 1.0);
        // Stessa curva del foglio: la traslazione qui sotto ne annulla la
        // salita, cosi' il foglio resta fermo e si apre solo il ritaglio.
        final slide = Easing.legacyDecelerate.transform(raw);
        final t = opening ? Curves.easeOutCubic.transform(raw) : 1.0;
        return FractionalTranslation(
          translation: Offset(0, opening ? slide - 1 : 0),
          child: ClipPath(
            clipper: _FabRevealClipper(t, bottom),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Color.lerp(
                  fabColor,
                  sheetColor,
                  (t * 2.5).clamp(0.0, 1.0),
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: Opacity(
                opacity: ((t - 0.35) / 0.45).clamp(0.0, 1.0),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FabRevealClipper extends CustomClipper<Path> {
  const _FabRevealClipper(this.t, this.bottom);

  final double t;

  /// Spazio della barra di sistema sotto al bottone.
  final double bottom;

  @override
  Path getClip(Size size) {
    final end = Offset.zero & size;
    if (t >= 1) return Path()..addRect(end);
    // Dalla forma del bottone (in basso a destra) al foglio intero.
    final start = Rect.fromLTWH(
      size.width - 152,
      size.height - 72 - bottom,
      136,
      56,
    );
    final rect = Rect.lerp(start, end, t)!;
    return Path()
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(28)));
  }

  @override
  bool shouldReclip(_FabRevealClipper old) =>
      old.t != t || old.bottom != bottom;
}

/// Avviso con "Annulla" e barra del tempo che si consuma.
void showUndoSnackBar(
  BuildContext context, {
  required String message,
  required VoidCallback onUndo,
  Duration duration = const Duration(seconds: 5),
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  HapticFeedback.selectionClick();
  messenger.showSnackBar(
    SnackBar(
      duration: duration,
      padding: EdgeInsets.zero,
      content: _UndoContent(
        message: message,
        duration: duration,
        onUndo: () {
          messenger.hideCurrentSnackBar();
          onUndo();
        },
      ),
    ),
  );
}

class _UndoContent extends StatelessWidget {
  const _UndoContent({
    required this.message,
    required this.duration,
    required this.onUndo,
  });

  final String message;
  final Duration duration;
  final VoidCallback onUndo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).snackBarTheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 6, 2),
            child: Row(
              children: [
                Expanded(child: Text(message)),
                TextButton.icon(
                  onPressed: onUndo,
                  icon: Icon(
                    Icons.undo,
                    size: 18,
                    color: theme.actionTextColor,
                  ),
                  label: Text(
                    'Annulla',
                    style: TextStyle(
                      color: theme.actionTextColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 1, end: 0),
            duration: duration,
            builder: (context, v, _) => Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: v,
                child: Container(height: 4, color: theme.actionTextColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Coriandoli sopra a tutto, per i traguardi. Non blocca i tocchi.
void showConfetti(BuildContext context) {
  if (Motion.off(context)) return;
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) =>
        IgnorePointer(child: _Confetti(onDone: () => entry.remove())),
  );
  overlay.insert(entry);
}

class _Confetti extends StatefulWidget {
  const _Confetti({required this.onDone});

  final VoidCallback onDone;

  @override
  State<_Confetti> createState() => _ConfettiState();
}

class _ConfettiState extends State<_Confetti>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..forward().whenComplete(widget.onDone);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.infinite, painter: _ConfettiPainter(_c));
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.t) : super(repaint: t);

  final Animation<double> t;

  static const _colors = [
    Cartolina.corallo,
    Cartolina.cobalto,
    Cartolina.laguna,
    Cartolina.inchiostro,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(7);
    final v = t.value;
    final origin = Offset(size.width / 2, size.height * 0.22);
    for (var i = 0; i < 36; i++) {
      final angle = rnd.nextDouble() * math.pi * 2;
      final speed = 90 + rnd.nextDouble() * 190;
      final spin = rnd.nextDouble() * 12;
      final color = _colors[i % _colors.length];
      // Scoppio verso l'esterno, poi caduta.
      final burst = Curves.easeOutCubic.transform(math.min(v * 2.5, 1));
      final fall = v * v * size.height * 0.9;
      final p =
          origin +
          Offset(math.cos(angle), math.sin(angle)) * speed * burst +
          Offset(0, fall);
      final opacity = v < 0.7 ? 1.0 : (1 - v) / 0.3;
      canvas.save();
      canvas.translate(p.dx, p.dy);
      canvas.rotate(spin * v * math.pi);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-5, -8, 10, 16),
          const Radius.circular(3),
        ),
        Paint()..color = color.withValues(alpha: opacity.clamp(0.0, 1.0)),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => false;
}
