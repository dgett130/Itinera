import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../l10n/app_localizations.dart';
import '../../ui/itinera_theme.dart';
import '../../ui/motion.dart';
import '../../ui/widgets.dart';
import 'stickman_hiker.dart';
import 'whats_new_data.dart';

/// Pannello "Novità" mostrato una volta dopo ogni aggiornamento: un poster di
/// montagna a tutta larghezza col camminatore e l'elenco delle novità.
class WhatsNewSheet extends StatelessWidget {
  const WhatsNewSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HikerPoster(title: l10n.whatsNewTitle),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
              itemCount: kWhatsNewItems.length,
              separatorBuilder: (_, _) => const SizedBox(height: 14),
              itemBuilder: (context, i) {
                final row = _ItemRow(item: kWhatsNewItems[i], index: i);
                return i < Motion.staggerMax
                    ? StaggerIn(index: i + 1, child: row)
                    : row;
              },
            ),
          ),
          SafeArea(
            top: false,
            minimum: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.whatsNewGotIt),
            ),
          ),
        ],
      ),
    );
  }
}

/// Il poster in testa al pannello: all'apertura il sole sale dietro le cime e
/// il camminatore Lottie cammina sul prato. Dell'animazione resta solo il
/// personaggio: lo sfondo e il sentiero li disegna il poster.
class _HikerPoster extends StatelessWidget {
  const _HikerPoster({required this.title});

  final String title;

  static final _characterOnly = LottieDelegates(
    values: [
      ValueDelegate.opacity(const ['BG_TRAVELER_01', '**'], value: 0),
      ValueDelegate.opacity(const ['Route Outlines Comp 1', '**'], value: 0),
    ],
  );

  @override
  Widget build(BuildContext context) {
    const ink = Cartolina.inchiostro;
    return SizedBox(
      height: 210,
      child: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Motion.of(context, Motion.scene),
              curve: Curves.easeOutCubic,
              builder: (context, rise, _) =>
                  CustomPaint(painter: _MountainPainter(rise)),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 22,
            height: 128,
            child: Lottie.asset(
              'assets/lottie/hiker.json',
              fit: BoxFit.contain,
              delegates: _characterOnly,
              animate: !Motion.off(context),
              errorBuilder: (_, _, _) =>
                  const StickmanHiker(fit: BoxFit.contain),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: 44,
              height: 4,
              margin: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                color: ink.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Positioned(
            left: 20,
            top: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.texts.displaySmall?.copyWith(
                    fontSize: 38,
                    height: 1.1,
                    color: ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Versione $kWhatsNewVersion',
                  style: context.texts.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: ink,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Corallo, sole che sale dietro le cime, due montagne e un prato laguna.
class _MountainPainter extends CustomPainter {
  const _MountainPainter(this.rise);

  /// Quanto e' salito il sole (0..1).
  final double rise;

  static const double _designWidth = 412;
  static const double _designHeight = 210;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Cartolina.corallo);
    final s = size.width / _designWidth;
    canvas.save();
    canvas.translate(0, size.height - _designHeight * s);
    canvas.scale(s);
    canvas.drawCircle(
      Offset(319, 57 + (1 - rise) * 70),
      31,
      Paint()..color = Cartolina.sole,
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, 156)
        ..lineTo(150, 100)
        ..lineTo(214, 134)
        ..lineTo(296, 72)
        ..lineTo(412, 148)
        ..lineTo(412, _designHeight)
        ..lineTo(0, _designHeight)
        ..close(),
      Paint()..color = Cartolina.cobalto,
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, 176)
        ..cubicTo(90, 160, 200, 180, 412, 154)
        ..lineTo(412, _designHeight)
        ..lineTo(0, _designHeight)
        ..close(),
      Paint()..color = Cartolina.laguna,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MountainPainter old) => old.rise != rise;
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item, required this.index});
  final WhatsNewItem item;
  final int index;

  /// Le tessere girano sui colori del manifesto.
  static const _tiles = [
    (Cartolina.sole, Cartolina.inchiostro),
    (Cartolina.laguna, Cartolina.inchiostro),
    (Cartolina.corallo, Cartolina.inchiostro),
    (Cartolina.cobalto, Colors.white),
  ];

  @override
  Widget build(BuildContext context) {
    final (color, iconColor) = _tiles[index % _tiles.length];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconTile(item.icon, color: color, iconColor: iconColor, size: 44),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.title, style: context.texts.titleMedium),
              const SizedBox(height: 2),
              Text(
                item.body,
                style: context.texts.bodySmall?.copyWith(
                  color: context.scheme.onSurfaceVariant,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
