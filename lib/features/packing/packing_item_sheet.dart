import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../data/database.dart';
import '../../ui/widgets.dart';
import 'packing_providers.dart';

/// Mostra il foglio di aggiunta/modifica di un oggetto della valigia.
Future<void> showPackingItemSheet(
  BuildContext context, {
  required String tripId,
  required List<PackingCategory> categories,
  required List<Bag> bags,
  PackingItem? existing,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: _PackingItemForm(
        tripId: tripId,
        categories: categories,
        bags: bags,
        existing: existing,
      ),
    ),
  );
}

class _PackingItemForm extends ConsumerStatefulWidget {
  const _PackingItemForm({
    required this.tripId,
    required this.categories,
    required this.bags,
    this.existing,
  });

  final String tripId;
  final List<PackingCategory> categories;
  final List<Bag> bags;
  final PackingItem? existing;

  @override
  ConsumerState<_PackingItemForm> createState() => _PackingItemFormState();
}

class _PackingItemFormState extends ConsumerState<_PackingItemForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _weightCtrl;
  late String _categoryId;
  String? _bagId;
  int _quantity = 1;
  bool _essential = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _weightCtrl = TextEditingController(
      text: e?.unitWeightGrams != null ? '${e!.unitWeightGrams}' : '',
    );
    _categoryId = e?.categoryId ?? widget.categories.first.id;
    _bagId = e?.bagId;
    _quantity = e?.quantity ?? 1;
    _essential = e?.isEssential ?? false;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final repo = ref.read(packingRepositoryProvider);
    final weight = _weightCtrl.text.trim().isEmpty
        ? null
        : Fmt.parseDecimal(_weightCtrl.text)?.round();
    final name = _nameCtrl.text.trim();

    if (widget.existing == null) {
      await repo.addItem(
        tripId: widget.tripId,
        categoryId: _categoryId,
        name: name,
        bagId: _bagId,
        quantity: _quantity,
        unitWeightGrams: weight,
        isEssential: _essential,
      );
    } else {
      await repo.updateItem(
        widget.existing!.id,
        categoryId: _categoryId,
        name: name,
        bagId: _bagId,
        quantity: _quantity,
        unitWeightGrams: weight,
        isEssential: _essential,
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
            SheetHeader(isEdit ? 'Modifica oggetto' : 'Nuovo oggetto'),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameCtrl,
              autofocus: !isEdit,
              decoration: const InputDecoration(labelText: 'Nome'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Campo obbligatorio' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _categoryId,
              decoration: const InputDecoration(labelText: 'Categoria'),
              items: [
                for (final c in widget.categories)
                  DropdownMenuItem(value: c.id, child: Text(c.name)),
              ],
              onChanged: (v) => setState(() => _categoryId = v ?? _categoryId),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              initialValue: _bagId,
              decoration: const InputDecoration(labelText: 'Bagaglio'),
              items: [
                const DropdownMenuItem(value: null, child: Text('Non assegnato')),
                for (final b in widget.bags)
                  DropdownMenuItem(value: b.id, child: Text(b.name)),
              ],
              onChanged: (v) => setState(() => _bagId = v),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _weightCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Peso unitario (g)'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Quantita'),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('$_quantity'),
                        Row(
                          children: [
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(Icons.remove),
                              onPressed: _quantity > 1
                                  ? () => setState(() => _quantity--)
                                  : null,
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(Icons.add),
                              onPressed: () => setState(() => _quantity++),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Essenziale'),
              subtitle: const Text('Evidenziato nel controllo finale'),
              value: _essential,
              onChanged: (v) => setState(() => _essential = v),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (isEdit)
                  TextButton.icon(
                    onPressed: () async {
                      await ref
                          .read(packingRepositoryProvider)
                          .deleteItem(widget.existing!.id);
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
