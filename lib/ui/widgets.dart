import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'itinera_theme.dart';
import 'motion.dart';

/// Libreria di componenti riutilizzabili, coerenti con lo stile attivo.

/// Intestazione di sezione: titolo da manifesto + azione opzionale.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.trailing, this.padding});

  final String title;
  final Widget? trailing;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(4, 22, 4, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: context.texts.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Card di base, con bordo sottile e tocco opzionale.
class ItineraCard extends StatelessWidget {
  const ItineraCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.borderColor,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final Color? color;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scheme = context.scheme;
    final radius = BorderRadius.circular(20);
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
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

/// Tessera colorata da manifesto, con testi color inchiostro (o [foreground]):
/// valore grande, nome, nota e contenuto opzionale.
class PosterTile extends StatelessWidget {
  const PosterTile({
    super.key,
    required this.color,
    required this.title,
    this.value,
    this.note,
    this.child,
    this.onTap,
    this.foreground = Cartolina.inchiostro,
    this.borderColor,
    this.valueColor,
  });

  final Color color;
  final String title;

  /// Dato in grande (es. "23/40").
  final String? value;
  final String? note;

  /// Contenuto sotto i testi (es. barra di avanzamento).
  final Widget? child;
  final VoidCallback? onTap;
  final Color foreground;
  final Color? borderColor;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final texts = context.texts;
    return ItineraCard(
      color: color,
      borderColor: borderColor ?? Colors.transparent,
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value!,
                  maxLines: 1,
                  style: texts.displaySmall?.copyWith(
                    fontSize: 38,
                    height: 1.05,
                    color: valueColor ?? foreground,
                  ),
                ),
              ),
            ),
          Text(
            title,
            style: texts.titleMedium?.copyWith(
              fontSize: 19,
              height: 1.15,
              color: foreground,
            ),
          ),
          if (note != null) ...[
            const SizedBox(height: 4),
            Text(
              note!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: texts.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: foreground,
              ),
            ),
          ],
          if (child != null) ...[const SizedBox(height: 12), child!],
        ],
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
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
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
            fontFamily: mono ? tokens.labelFont : tokens.displayFont,
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
        // Nessuna altezza fissa: con IntrinsicHeight + stretch il separatore
        // prende l'altezza del contenuto ed e' centrato per costruzione.
        children.add(Container(width: 1, color: tokens.hairline));
      }
    }
    return ItineraCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}

/// Barra di avanzamento sottile con angoli arrotondati.
class MeterBar extends StatelessWidget {
  const MeterBar({
    super.key,
    required this.value,
    this.color,
    this.track,
    this.height = 8,
  });

  /// 0..1 (viene comunque limitato).
  final double value;
  final Color? color;

  /// Fondo della barra (default: la linea sottile del tema).
  final Color? track;
  final double height;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final v = value.isNaN ? 0.0 : value.clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: v),
        duration: Motion.of(context, Motion.standard),
        curve: Curves.easeOutCubic,
        builder: (context, value, _) => LinearProgressIndicator(
          value: value,
          minHeight: height,
          backgroundColor: track ?? tokens.hairline,
          valueColor: AlwaysStoppedAnimation<Color>(color ?? tokens.accent),
        ),
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
        borderRadius: BorderRadius.circular(20),
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
              fontFamily: tokens.labelFont,
              fontSize: 12,
              fontWeight: FontWeight.w600,
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tokens.hairline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: c.withValues(alpha: 0.8)),
          const SizedBox(width: 7),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: c,
              fontWeight: FontWeight.w500,
            ),
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
    this.color,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  /// Colore della tessera (default: la tinta dell'accento).
  final Color? color;
  final Color? iconColor;

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
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: color ?? tokens.accentSoft,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(icon, size: 48, color: iconColor ?? tokens.accent),
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
                style: context.texts.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
            if (action != null) ...[const SizedBox(height: 24), action!],
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
      title: 'Qualcosa è andato storto',
      message: '$error',
    );
  }
}

/// Colori di testata di un modulo del viaggio.
class ModuleStyle {
  const ModuleStyle(this.background, this.foreground);

  final Color background;
  final Color foreground;

  static const valigia = ModuleStyle(Cartolina.sole, Cartolina.inchiostro);
  static const costi = ModuleStyle(Cartolina.laguna, Cartolina.inchiostro);
  static const marcia = ModuleStyle(Cartolina.cobalto, Colors.white);
  static const luoghi = ModuleStyle(Cartolina.corallo, Cartolina.inchiostro);

  /// Inchiostro in chiaro; in scuro un blu che si stacca dallo sfondo.
  static ModuleStyle bacheca(BuildContext context) => ModuleStyle(
    Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF20255A)
        : Cartolina.inchiostro,
    Colors.white,
  );
}

/// Barra di stato leggibile sopra un fondo pieno.
SystemUiOverlayStyle overlayStyleOn(Color background) {
  return background.computeLuminance() > 0.35
      ? SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent)
      : SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent);
}

/// Testata colorata di un modulo: indietro, azioni, titolo da manifesto, nota
/// e contenuto opzionale (numeri, selettori). Va in cima a una [Column] dentro
/// uno `Scaffold` senza `AppBar`.
class ModuleHeader extends StatelessWidget {
  const ModuleHeader({
    super.key,
    required this.style,
    required this.title,
    this.note,
    this.actions = const [],
    this.child,
    this.showBack = true,
  });

  final ModuleStyle style;
  final String title;
  final String? note;
  final List<Widget> actions;

  /// Contenuto sotto il titolo.
  final Widget? child;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final fg = style.foreground;
    final texts = context.texts;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyleOn(style.background),
      child: Container(
        decoration: BoxDecoration(
          color: style.background,
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(32),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: IconTheme(
              data: IconThemeData(color: fg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (showBack || actions.isNotEmpty)
                    SizedBox(
                      height: 48,
                      child: Row(
                        children: [
                          if (showBack)
                            Transform.translate(
                              offset: const Offset(-12, 0),
                              child: BackButton(color: fg),
                            ),
                          const Spacer(),
                          ...actions,
                        ],
                      ),
                    ),
                  Text(
                    title,
                    style: texts.displaySmall?.copyWith(
                      fontSize: 36,
                      height: 1.08,
                      color: fg,
                    ),
                  ),
                  if (note != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      note!,
                      style: texts.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: fg,
                      ),
                    ),
                  ],
                  if (child != null) ...[const SizedBox(height: 14), child!],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Testata senza colore: indietro, azioni e titolo grande. Per le schermate
/// fuori dal viaggio (Persone, Notifiche, Impostazioni...).
class PlainHeader extends StatelessWidget {
  const PlainHeader({
    super.key,
    required this.title,
    this.note,
    this.actions = const [],
    this.showBack = true,
    this.size = 36,
  });

  final String title;
  final String? note;
  final List<Widget> actions;
  final bool showBack;
  final double size;

  @override
  Widget build(BuildContext context) {
    final texts = context.texts;
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showBack || actions.isNotEmpty)
              SizedBox(
                height: 48,
                child: Row(
                  children: [
                    if (showBack)
                      Transform.translate(
                        offset: const Offset(-12, 0),
                        child: BackButton(color: context.scheme.onSurface),
                      ),
                    const Spacer(),
                    ...actions,
                  ],
                ),
              ),
            Text(
              title,
              style: texts.displaySmall?.copyWith(fontSize: size, height: 1.08),
            ),
            if (note != null) ...[
              const SizedBox(height: 6),
              Text(
                note!,
                style: texts.bodyMedium?.copyWith(
                  color: context.scheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Bottone flottante del modulo: pillola scura con il "+" del colore del
/// modulo ([tint]; in tema scuro il bottone e' giallo e il "+" inchiostro).
class CartolinaFab extends StatelessWidget {
  const CartolinaFab({
    super.key,
    required this.label,
    required this.onPressed,
    this.tint = Cartolina.sole,
    this.icon = Icons.add,
    this.heroTag,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color tint;
  final IconData icon;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    // Con la tastiera aperta starebbe sopra ai campi.
    final typing = View.of(context).viewInsets.bottom > 0;
    return AnimatedScale(
      scale: typing ? 0 : 1,
      duration: Motion.of(context, Motion.fast),
      child: FloatingActionButton.extended(
        heroTag: heroTag,
        onPressed: typing ? null : onPressed,
        icon: Icon(icon, color: dark ? Cartolina.inchiostro : tint),
        label: Text(label),
      ),
    );
  }
}

/// Tessera quadrata con icona.
class IconTile extends StatelessWidget {
  const IconTile(
    this.icon, {
    super.key,
    required this.color,
    this.iconColor = Cartolina.inchiostro,
    this.size = 48,
    this.round = false,
  });

  final IconData icon;
  final Color color;
  final Color iconColor;
  final double size;

  /// Cerchio invece del quadrato arrotondato (mezzi, categorie di luogo).
  final bool round;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(round ? size / 2 : size * 0.29),
      ),
      child: Icon(icon, size: size * 0.5, color: iconColor),
    );
  }
}

/// Cerchio con l'iniziale di una persona.
class InitialAvatar extends StatelessWidget {
  const InitialAvatar(
    this.name, {
    super.key,
    this.color,
    this.foreground,
    this.size = 48,
  });

  final String name;
  final Color? color;
  final Color? foreground;
  final double size;

  /// Colore stabile per nome, cosi' ognuno resta riconoscibile.
  static const _colors = [Cartolina.corallo, Cartolina.laguna, Cartolina.sole];

  @override
  Widget build(BuildContext context) {
    final trimmed = name.trim();
    final letter = trimmed.isEmpty
        ? '?'
        : trimmed.characters.first.toUpperCase();
    final bg = color ?? _colors[trimmed.hashCode.abs() % _colors.length];
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Text(
        letter,
        style: TextStyle(
          fontFamily: context.tokens.displayFont,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.46,
          color: foreground ?? Cartolina.inchiostro,
        ),
      ),
    );
  }
}

/// Selettore a pillola: la selezione scorre da una voce all'altra.
class PillSelector<T> extends StatelessWidget {
  const PillSelector({
    super.key,
    required this.items,
    required this.selected,
    required this.onChanged,
    this.track,
    this.pill,
    this.onPill,
    this.foreground,
    this.height = 48,
  });

  final Map<T, String> items;
  final T selected;
  final ValueChanged<T> onChanged;

  /// Colori: fondo, pillola, testo sulla pillola, testo delle altre voci.
  /// Di default seguono il bottone principale del tema.
  final Color? track;
  final Color? pill;
  final Color? onPill;
  final Color? foreground;
  final double height;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scheme = context.scheme;
    final button = Theme.of(context).filledButtonTheme.style;
    final pillColor =
        pill ?? button?.backgroundColor?.resolve(const {}) ?? scheme.primary;
    final onPillColor =
        onPill ??
        button?.foregroundColor?.resolve(const {}) ??
        scheme.onPrimary;
    final keys = items.keys.toList();
    final index = keys.indexOf(selected);
    return Container(
      height: height,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: track ?? scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(height / 2),
        border: track == null ? Border.all(color: tokens.hairline) : null,
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: Motion.of(context, Motion.standard),
            curve: Curves.easeOutCubic,
            alignment: Alignment(
              keys.length < 2 ? 0 : -1 + 2 * index / (keys.length - 1),
              0,
            ),
            child: FractionallySizedBox(
              widthFactor: 1 / keys.length,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: pillColor,
                  borderRadius: BorderRadius.circular(height / 2),
                ),
              ),
            ),
          ),
          Row(
            children: [
              for (final k in keys)
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: k == selected,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(height / 2),
                      onTap: () {
                        if (k != selected) {
                          HapticFeedback.selectionClick();
                          onChanged(k);
                        }
                      },
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: Motion.of(context, Motion.fast),
                          style: TextStyle(
                            fontFamily: tokens.displayFont,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: k == selected
                                ? onPillColor
                                : foreground ?? scheme.onSurface,
                          ),
                          child: Text(
                            items[k]!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
