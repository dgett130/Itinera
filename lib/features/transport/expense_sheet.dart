import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/enum_labels.dart';
import '../../core/enums.dart';
import '../../core/format.dart';
import '../../data/database.dart';
import '../../ui/widgets.dart';
import 'transport_providers.dart';

/// Foglio di aggiunta/modifica di una spesa.
Future<void> showExpenseSheet(
  BuildContext context, {
  required String tripId,
  required List<Traveler> travelers,
  CostItem? existing,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _descCtrl.text = e.description ?? '';
      _amountCtrl.text = (e.amountCents / 100).toStringAsFixed(2).replaceAll('.', ',');
      _category = e.category;
      _payerId = e.paidByTravelerId;
      _split = e.splitMethod;
      _status = e.status;
    } else {
      _payerId = widget.travelers
          .where((t) => t.isSelfUser)
          .map((t) => t.id)
          .firstOrNull;
      if (widget.travelers.length < 2) _split = SplitMethod.none;
    }
  }

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
      );
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SheetHeader(isEdit ? 'Modifica spesa' : 'Nuova spesa'),
              const SizedBox(height: 16),
              DropdownButtonFormField<CostCategory>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Categoria'),
                items: [
                  for (final c in CostCategory.values)
                    DropdownMenuItem(
                      value: c,
                      child: Row(
                        children: [
                          Icon(c.icon, size: 20),
                          const SizedBox(width: 8),
                          Text(c.label),
                        ],
                      ),
                    ),
                ],
                onChanged: (v) => setState(() => _category = v ?? _category),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountCtrl,
                decoration: const InputDecoration(labelText: 'Importo (EUR)'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  final c = Fmt.parseMoneyToCents(v ?? '');
                  return (c == null || c <= 0) ? 'Importo non valido' : null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                decoration:
                    const InputDecoration(labelText: 'Descrizione (opzionale)'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                initialValue: _payerId,
                decoration: const InputDecoration(labelText: 'Pagato da'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Nessuno')),
                  for (final t in widget.travelers)
                    DropdownMenuItem(value: t.id, child: Text(t.name)),
                ],
                onChanged: (v) => setState(() => _payerId = v),
              ),
              const SizedBox(height: 12),
              SegmentedButton<CostStatus>(
                segments: const [
                  ButtonSegment(
                      value: CostStatus.estimate, label: Text('Stima')),
                  ButtonSegment(value: CostStatus.actual, label: Text('Reale')),
                ],
                selected: {_status},
                onSelectionChanged: (s) => setState(() => _status = s.first),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<SplitMethod>(
                initialValue: _split,
                decoration: const InputDecoration(labelText: 'Divisione'),
                items: [
                  for (final m in [
                    SplitMethod.equal,
                    SplitMethod.weighted,
                    SplitMethod.none,
                  ])
                    DropdownMenuItem(value: m, child: Text(m.label)),
                ],
                onChanged: (v) => setState(() => _split = v ?? _split),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (isEdit)
                    TextButton.icon(
                      onPressed: () async {
                        await ref
                            .read(transportRepositoryProvider)
                            .deleteExpense(widget.existing!.id);
                        if (context.mounted) Navigator.pop(context);
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Elimina'),
                    ),
                  const Spacer(),
                  FilledButton(onPressed: _save, child: const Text('Salva')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
