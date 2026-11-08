import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/calc/cost_splitter.dart';
import '../../core/calc/share_fractions.dart';
import '../../core/enums.dart';
import '../../core/format.dart';
import '../../data/database.dart';
import '../../ui/itinera_theme.dart';
import '../../ui/widgets.dart';

/// Quote di una spesa divisa "Per quota": la frazione che paga ciascun
/// viaggiatore (0,33 = un terzo; 0 = escluso), sempre con somma 1. Spostando
/// un cursore il resto si divide tra gli altri. Vedi FigCraft, pagina N.
class ShareWeightsEditor extends StatelessWidget {
  const ShareWeightsEditor({
    super.key,
    required this.travelers,
    required this.shares,
    required this.amountCents,
    required this.payerId,
    required this.onChanged,
  });

  final List<Traveler> travelers;

  /// travelerId -> frazione (somma 1).
  final Map<String, double> shares;
  final int amountCents;
  final String? payerId;
  final ValueChanged<Map<String, double>> onChanged;

  /// Le quote iniziali: parti uguali.
  static Map<String, double> defaults(List<Traveler> travelers) =>
      ShareFractions.equal(travelers.map((t) => t.id));

  /// [shares] allineate ai viaggiatori di adesso (chi manca entra a zero),
  /// con somma 1: e' quello che si salva. Senza quote, parti uguali.
  static Map<String, double> resolve(
    List<Traveler> travelers,
    Map<String, double>? shares,
  ) => shares == null
      ? defaults(travelers)
      : ShareFractions.normalize({
          for (final t in travelers) t.id: shares[t.id] ?? 0,
        });

  @override
  Widget build(BuildContext context) {
    final current = resolve(travelers, shares);
    final split = CostSplitter.split(
      amountCents: amountCents,
      shares: [
        for (final t in travelers)
          SplitShare(travelerId: t.id, weight: current[t.id]!),
      ],
      method: SplitMethod.weighted,
      payerId: payerId,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Quote',
                style: context.texts.titleMedium?.copyWith(
                  fontFamily: context.tokens.displayFont,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              'Totale 1 · 0 = escluso',
              style: context.texts.bodySmall?.copyWith(
                color: context.scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (final t in travelers) ...[
          _Row(
            traveler: t,
            share: current[t.id]!,
            cents: split[t.id] ?? 0,
            enabled: travelers.length > 1,
            onChanged: (v) => onChanged(ShareFractions.set(current, t.id, v)),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.traveler,
    required this.share,
    required this.cents,
    required this.enabled,
    required this.onChanged,
  });

  final Traveler traveler;
  final double share;
  final int cents;
  final bool enabled;
  final ValueChanged<double> onChanged;

  static String _fraction(double v) =>
      v.toStringAsFixed(2).replaceAll('.', ',');

  @override
  Widget build(BuildContext context) {
    final excluded = share < 0.005;
    final name = traveler.isSelfUser ? '${traveler.name} (tu)' : traveler.name;
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 14, 4),
      decoration: BoxDecoration(
        color: context.scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.tokens.hairline),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Opacity(
                opacity: excluded ? 0.4 : 1,
                child: InitialAvatar(traveler.name, size: 36),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      overflow: TextOverflow.ellipsis,
                      style: context.texts.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      excluded ? 'escluso' : Fmt.currencyCents(cents),
                      style: context.texts.bodySmall?.copyWith(
                        color: context.scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              _FractionField(
                value: share,
                enabled: enabled,
                label: 'Quota di ${traveler.name}',
                onSubmitted: onChanged,
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Cartolina.laguna,
              thumbColor: Cartolina.laguna,
              inactiveTrackColor: context.tokens.hairline,
              overlayColor: Cartolina.laguna.withValues(alpha: 0.16),
              trackHeight: 4,
              showValueIndicator: ShowValueIndicator.never,
            ),
            child: Slider(
              value: share.clamp(0.0, 1.0),
              divisions: 100,
              semanticFormatterCallback: _fraction,
              onChanged: enabled
                  ? (v) {
                      // Uno scatto ogni 0,05, non a ogni centesimo.
                      if ((v * 100).round() % 5 == 0) {
                        HapticFeedback.selectionClick();
                      }
                      onChanged(v);
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

/// La quota scritta a mano: si conferma con Fatto o uscendo dal campo, e
/// allora gli altri si ricalcolano. Un valore non valido torna a quello di
/// prima.
class _FractionField extends StatefulWidget {
  const _FractionField({
    required this.value,
    required this.enabled,
    required this.label,
    required this.onSubmitted,
  });

  final double value;
  final bool enabled;
  final String label;
  final ValueChanged<double> onSubmitted;

  @override
  State<_FractionField> createState() => _FractionFieldState();
}

class _FractionFieldState extends State<_FractionField> {
  late final _ctrl = TextEditingController(text: _format(widget.value));
  final _focus = FocusNode();

  static String _format(double v) => v.toStringAsFixed(2).replaceAll('.', ',');

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (_focus.hasFocus) {
        // Si scrive sopra: tutto selezionato.
        _ctrl.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _ctrl.text.length,
        );
      } else {
        _submit();
      }
      setState(() {});
    });
  }

  @override
  void didUpdateWidget(_FractionField old) {
    super.didUpdateWidget(old);
    // Le quote cambiate dagli altri (cursori, ricalcolo) si vedono subito,
    // ma non mentre si sta scrivendo qui.
    if (!_focus.hasFocus && old.value != widget.value) {
      _ctrl.text = _format(widget.value);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _submit() {
    final v = ShareFractions.parse(_ctrl.text);
    if (v == null || (v - widget.value).abs() < 1e-9) {
      _ctrl.text = _format(widget.value);
      return;
    }
    HapticFeedback.selectionClick();
    widget.onSubmitted(v);
    _ctrl.text = _format(v);
  }

  @override
  Widget build(BuildContext context) {
    final focused = _focus.hasFocus;
    return Semantics(
      label: widget.label,
      child: SizedBox(
        width: 76,
        child: TextField(
          controller: _ctrl,
          focusNode: _focus,
          enabled: widget.enabled,
          textAlign: TextAlign.center,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.done,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
          ],
          onSubmitted: (_) => _focus.unfocus(),
          onTapOutside: (_) => _focus.unfocus(),
          style: context.texts.titleLarge?.copyWith(
            fontFamily: context.tokens.displayFont,
            fontWeight: FontWeight.w800,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: context.scheme.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 6,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: context.tokens.hairline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Cartolina.laguna,
                width: focused ? 2 : 1,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: context.tokens.hairline),
            ),
          ),
        ),
      ),
    );
  }
}
