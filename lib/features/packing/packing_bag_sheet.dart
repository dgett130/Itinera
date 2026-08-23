import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/enum_labels.dart';
import '../../core/enums.dart';
import '../../core/format.dart';
import '../../data/database.dart';
import '../../ui/widgets.dart';
import 'packing_providers.dart';

/// Foglio di aggiunta/modifica di un bagaglio.
Future<void> showPackingBagSheet(
  BuildContext context, {
  required String tripId,
  Bag? existing,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: _BagForm(tripId: tripId, existing: existing),
    ),
  );
}

class _BagForm extends ConsumerStatefulWidget {
  const _BagForm({required this.tripId, this.existing});
  final String tripId;
  final Bag? existing;

  @override
  ConsumerState<_BagForm> createState() => _BagFormState();
}

class _BagFormState extends ConsumerState<_BagForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _tareCtrl;
  late final TextEditingController _maxCtrl;
  late BagType _type;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _tareCtrl = TextEditingController(
      text: e != null && e.tareWeightGrams > 0
          ? _kg(e.tareWeightGrams)
          : '',
    );
    _maxCtrl = TextEditingController(
      text: e?.maxWeightGrams != null ? _kg(e!.maxWeightGrams!) : '',
    );
    _type = e?.type ?? BagType.hold;
  }

  String _kg(int grams) => (grams / 1000).toStringAsFixed(1).replaceAll('.', ',');

  @override
  void dispose() {
    _nameCtrl.dispose();
    _tareCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  int _toGrams(String raw) {
    final v = Fmt.parseDecimal(raw);
    if (v == null || v < 0) return 0;
    return (v * 1000).round();
  }

  int? _toGramsNullable(String raw) {
    if (raw.trim().isEmpty) return null;
    final v = Fmt.parseDecimal(raw);
    if (v == null || v <= 0) return null;
    return (v * 1000).round();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final repo = ref.read(packingRepositoryProvider);
    final name = _nameCtrl.text.trim();
    final tare = _toGrams(_tareCtrl.text);
    final max = _toGramsNullable(_maxCtrl.text);

    if (widget.existing == null) {
      await repo.addBag(
        tripId: widget.tripId,
        name: name,
        type: _type,
        tareWeightGrams: tare,
        maxWeightGrams: max,
      );
    } else {
      await repo.updateBag(
        widget.existing!.id,
        name: name,
        type: _type,
        tareWeightGrams: tare,
        maxWeightGrams: max,
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SheetHeader(isEdit ? 'Modifica bagaglio' : 'Nuovo bagaglio'),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameCtrl,
              autofocus: !isEdit,
              decoration: const InputDecoration(labelText: 'Nome'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Campo obbligatorio' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<BagType>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Tipo'),
              items: [
                for (final t in BagType.values)
                  DropdownMenuItem(
                    value: t,
                    child: Row(
                      children: [
                        Icon(t.icon, size: 20),
                        const SizedBox(width: 8),
                        Text(t.label),
                      ],
                    ),
                  ),
              ],
              onChanged: (v) => setState(() => _type = v ?? _type),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _tareCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Tara (kg)'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _maxCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Limite (kg)'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (isEdit)
                  TextButton.icon(
                    onPressed: () async {
                      await ref
                          .read(packingRepositoryProvider)
                          .deleteBag(widget.existing!.id);
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
    );
  }
}
