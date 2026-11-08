import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/enum_labels.dart';
import '../../core/enums.dart';
import '../../core/format.dart';
import '../../data/database.dart';
import '../../ui/itinera_theme.dart';
import '../../ui/motion.dart';
import '../../ui/widgets.dart';
import '../../core/calc/share_fractions.dart';
import 'share_weights_editor.dart';
import 'transport_providers.dart';

/// Foglio di aggiunta/modifica di una spesa. Con [fromFab] si apre dal bottone
/// flottante.
Future<void> showExpenseSheet(
  BuildContext context, {
  required String tripId,
  required List<Traveler> travelers,
  CostItem? existing,
  bool fromFab = false,
}) {
  return showCartolinaSheet<void>(
    context: context,
    fromFab: fromFab,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: _ExpenseForm(
        tripId: tripId,
        travelers: travelers,
        existing: existing,
      ),
    ),
  );
}

class _ExpenseForm extends ConsumerStatefulWidget {
  const _ExpenseForm({
    required this.tripId,
    required this.travelers,
    this.existing,
  });
  final String tripId;
  final List<Traveler> travelers;
  final CostItem? existing;

  @override
  ConsumerState<_ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends ConsumerState<_ExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  CostCategory _category = CostCategory.food;
  String? _payerId;
  SplitMethod _split = SplitMethod.equal;
  CostStatus _status = CostStatus.actual;

  /// Quote di questa spesa (solo "Per quota"); null = quelle predefinite.
  Map<String, double>? _weights;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _descCtrl.text = e.description ?? '';
      _amountCtrl.text = (e.amountCents / 100)
          .toStringAsFixed(2)
          .replaceAll('.', ',');
      _category = e.category;
      _payerId = e.paidByTravelerId;
      _split = e.splitMethod;
      _status = e.status;
      if (e.splitMethod == SplitMethod.weighted) _loadWeights(e.id);
    } else {
      _payerId = widget.travelers
          .where((t) => t.isSelfUser)
          .map((t) => t.id)
          .firstOrNull;
      if (widget.travelers.length < 2) _split = SplitMethod.none;
    }
  }

  /// Le quote salvate sulla spesa da modificare.
  Future<void> _loadWeights(String costId) async {
    final splits = await ref
        .read(transportRepositoryProvider)
        .getSplits(costId);
    if (!mounted || splits.isEmpty) return;
    setState(() {
      // Le spese salvate con pesi interi (2, 1, 1) diventano frazioni.
      _weights = ShareFractions.normalize({
        for (final s in splits) s.travelerId: s.shareWeight,
      });
    });
  }

  Map<String, double>? get _splitWeights => _split == SplitMethod.weighted
      ? ShareWeightsEditor.resolve(widget.travelers, _weights)
      : null;

  @override
  void dispose() {
    _descCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final cents = Fmt.parseMoneyToCents(_amountCtrl.text);
    if (cents == null || cents <= 0) return;
    final repo = ref.read(transportRepositoryProvider);
    final desc = _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim();

    if (widget.existing == null) {
      await repo.addExpense(
        tripId: widget.tripId,
        category: _category,
        description: desc,
        amountCents: cents,
        payerId: _payerId,
        splitMethod: _split,
        status: _status,
        weights: _splitWeights,
      );
    } else {
      await repo.updateExpense(
        widget.existing!.id,
        tripId: widget.tripId,
        category: _category,
        description: desc,
        amountCents: cents,
        payerId: _payerId,
        splitMethod: _split,
        status: _status,
        weights: _splitWeights,
      );
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    final repo = ref.read(transportRepositoryProvider);
    final deleted = await repo.deleteExpense(widget.existing!.id);
    if (!mounted) return;
    if (deleted != null) {
      showUndoSnackBar(
        context,
        message: 'Spesa eliminata',
        onUndo: () => repo.restoreExpense(deleted),
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SheetHeader(isEdit ? 'Modifica spesa' : 'Nuova spesa'),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: DropdownButtonFormField<CostCategory>(
                    initialValue: _category,
                    isExpanded: true,
                    style: context.texts.bodyLarge,
                    decoration: const InputDecoration(labelText: 'Categoria'),
                    // Chiuso solo il nome: l'icona resta nel menu.
                    selectedItemBuilder: (context) => [
                      for (final c in CostCategory.values)
                        Text(c.label, overflow: TextOverflow.ellipsis),
                    ],
                    items: [
                      for (final c in CostCategory.values)
                        DropdownMenuItem(
                          value: c,
                          child: Row(
                            children: [
                              Icon(c.icon, size: 20),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  c.label,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                    onChanged: (v) =>
                        setState(() => _category = v ?? _category),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _amountCtrl,
                    decoration: const InputDecoration(labelText: 'Importo (€)'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (v) {
                      final c = Fmt.parseMoneyToCents(v ?? '');
                      return (c == null || c <= 0)
                          ? 'Importo non valido'
                          : null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                labelText: 'Descrizione (opzionale)',
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              initialValue: _payerId,
              isExpanded: true,
              style: context.texts.bodyLarge,
              decoration: const InputDecoration(labelText: 'Pagato da'),
              items: [
                const DropdownMenuItem(value: null, child: Text('Nessuno')),
                for (final t in widget.travelers)
                  DropdownMenuItem(
                    value: t.id,
                    child: Text(t.name, overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: (v) => setState(() => _payerId = v),
            ),
            const SizedBox(height: 12),
            PillSelector<CostStatus>(
              items: const {
                CostStatus.estimate: 'Stima',
                CostStatus.actual: 'Reale',
              },
              selected: _status,
              onChanged: (s) => setState(() => _status = s),
            ),
            const SizedBox(height: 14),
            Text(
              'Divisione',
              style: context.texts.titleSmall?.copyWith(fontSize: 15.5),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final m in const [
                  SplitMethod.equal,
                  SplitMethod.weighted,
                  SplitMethod.none,
                ])
                  _Choice(
                    label: m.label,
                    selected: _split == m,
                    onTap: () => setState(() => _split = m),
                  ),
              ],
            ),
            AnimatedSize(
              duration: Motion.of(context, Motion.standard),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child:
                  _split == SplitMethod.weighted && widget.travelers.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(top: 14),
                      // L'anteprima segue l'importo mentre si scrive.
                      child: ValueListenableBuilder(
                        valueListenable: _amountCtrl,
                        builder: (context, value, _) => ShareWeightsEditor(
                          travelers: widget.travelers,
                          shares: ShareWeightsEditor.resolve(
                            widget.travelers,
                            _weights,
                          ),
                          amountCents: Fmt.parseMoneyToCents(value.text) ?? 0,
                          payerId: _payerId,
                          onChanged: (w) => setState(() => _weights = w),
                        ),
                      ),
                    )
                  : const SizedBox(width: double.infinity),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (isEdit) ...[
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: context.tokens.warning,
                        side: BorderSide(
                          color: context.tokens.warning,
                          width: 1.5,
                        ),
                      ),
                      onPressed: _delete,
                      child: const Text('Elimina'),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: FilledButton(
                    onPressed: _save,
                    child: const Text('Salva'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Scelta a pillola: laguna quando è selezionata.
class _Choice extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      selectedColor: Cartolina.laguna,
      labelStyle: context.texts.labelLarge?.copyWith(
        color: selected ? Cartolina.inchiostro : context.scheme.onSurface,
      ),
      side: BorderSide(
        color: selected ? Colors.transparent : context.tokens.hairline,
      ),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      onSelected: (_) => onTap(),
    );
  }
}
