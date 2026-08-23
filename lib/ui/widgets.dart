import 'package:flutter/material.dart';

import 'itinera_theme.dart';

/// Libreria di componenti riutilizzabili, coerenti con lo stile attivo.

/// Intestazione di sezione: etichetta in maiuscoletto monospace + azione.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.trailing, this.padding});

  final String title;
  final Widget? trailing;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(4, 20, 4, 10),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: tokens.accent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                fontFamily: tokens.monoFont,
                fontSize: 12,
                letterSpacing: 1.4,
                fontWeight: FontWeight.w700,
                color: context.scheme.onSurfaceVariant,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Card di base con bordo sottile e tocco opzionale.
class ItineraCard extends StatelessWidget {
  const ItineraCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.borderColor,
    this.accentEdge,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final Color? color;
  final Color? borderColor;

  /// Se valorizzato, disegna una barretta d'accento sul lato sinistro.
  final Color? accentEdge;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scheme = context.scheme;
    final radius = BorderRadius.circular(16);
    Widget content;

    if (accentEdge != null) {
      // La barretta d'accento e' un elemento posizionato in uno Stack: lo Stack
      // si dimensiona sul contenuto (non-positioned), evitando il collasso ad
      // altezza zero che accadeva con un Row a cross-axis "stretch" dentro una
      // lista ad altezza non vincolata.
      content = Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Padding(padding: padding, child: child),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 4,
            child: ColoredBox(color: accentEdge!),
          ),
        ],
      );
    } else {
      content = Padding(padding: padding, child: child);
    }

    return Material(
      color: color ?? scheme.surfaceContainerLow,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: borderColor ?? tokens.hairline),
          ),
          child: content,
        ),
      ),
    );
  }
}

/// Riquadro statistica: valore grande + etichetta.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.accent,
    this.mono = false,
  });

  final String value;
  final String label;
  final IconData? icon;
  final Color? accent;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scheme = context.scheme;
    final c = accent ?? scheme.onSurface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: tokens.accent),
          const SizedBox(height: 8),
        ],
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: mono ? tokens.monoFont : tokens.displayFont,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: c,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11.5,
            color: scheme.onSurfaceVariant,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

/// Striscia di [StatTile] separati da divisori verticali sottili.
class StatStrip extends StatelessWidget {
  const StatStrip({super.key, required this.tiles});

  final List<StatTile> tiles;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final children = <Widget>[];
    for (var i = 0; i < tiles.length; i++) {
      children.add(Expanded(child: tiles[i]));
      if (i != tiles.length - 1) {
        children.add(Container(width: 1, height: 40, color: tokens.hairline));
      }
    }
    return ItineraCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: children),
    );
  }
}

/// Barra di avanzamento sottile con angoli arrotondati.
class MeterBar extends StatelessWidget {
  const MeterBar({
    super.key,
    required this.value,
    this.color,
    this.height = 8,
  });

  /// 0..1 (viene comunque limitato).
  final double value;
  final Color? color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final v = value.isNaN ? 0.0 : value.clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: LinearProgressIndicator(
        value: v,
        minHeight: height,
        backgroundColor: tokens.hairline,
        valueColor:
            AlwaysStoppedAnimation<Color>(color ?? tokens.accent),
      ),
    );
  }
}

/// Piccola pillola monospace per micro-dati (codici, coordinate, quantita').
class MonoTag extends StatelessWidget {
  const MonoTag(this.text, {super.key, this.color, this.background, this.icon});

  final String text;
  final Color? color;
  final Color? background;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scheme = context.scheme;
    final fg = color ?? scheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background ?? scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: tokens.hairline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontFamily: tokens.monoFont,
              fontSize: 11,
              letterSpacing: 0.3,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

/// Pillola con icona + etichetta (per meta-dati leggibili).
class InfoPill extends StatelessWidget {
  const InfoPill(this.icon, this.label, {super.key, this.tone});

  final IconData icon;
  final String label;
  final Color? tone;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scheme = context.scheme;
    final c = tone ?? scheme.onSurface;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: tokens.hairline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: c.withValues(alpha: 0.8)),
          const SizedBox(width: 7),
          Text(
            label,
            style: TextStyle(fontSize: 13, color: c, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

/// Stato vuoto: icona in badge, titolo, messaggio, azione opzionale.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scheme = context.scheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: tokens.accentSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: tokens.accent),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.texts.titleLarge,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: context.texts.bodyMedium
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Maniglia dei bottom sheet + titolo, per un aspetto coerente.
class SheetHeader extends StatelessWidget {
  const SheetHeader(this.title, {super.key, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: context.tokens.hairline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Row(
          children: [
            Expanded(child: Text(title, style: context.texts.titleLarge)),
            ?trailing,
          ],
        ),
      ],
    );
  }
}

/// Indicatore di caricamento centrato, coerente con l'accento.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(color: context.tokens.accent),
    );
  }
}

/// Vista d'errore semplice e leggibile.
class ErrorView extends StatelessWidget {
  const ErrorView(this.error, {super.key});
  final Object error;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.error_outline,
      title: 'Qualcosa e\' andato storto',
      message: '$error',
    );
  }
}
