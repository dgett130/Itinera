import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../data/database.dart';
import '../../ui/itinera_theme.dart';
import '../../ui/motion.dart';
import '../../ui/widgets.dart';
import 'packing_providers.dart';

/// Mostra il foglio di aggiunta/modifica di un oggetto della valigia.
/// Con [fromFab] il foglio si apre dal bottone in basso.
Future<void> showPackingItemSheet(
  BuildContext context, {
  required String tripId,
  required List<PackingCategory> categories,
  required List<Bag> bags,
  PackingItem? existing,
  bool fromFab = false,
}) {
  return showCartolinaSheet<void>(
    context: context,
    fromFab: fromFab,
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

  /// Elimina senza conferma: l'avviso permette di annullare.
  Future<void> _delete() async {
    final repo = ref.read(packingRepositoryProvider);
    final deleted = await repo.deleteItem(widget.existing!.id);
    if (!mounted) return;
    if (deleted != null) {
      showUndoSnackBar(
        context,
        message: 'Oggetto eliminato',
        onUndo: () => repo.restoreItem(deleted),
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    final tokens = context.tokens;
    final texts = context.texts;
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SheetHeader(isEdit ? 'Modifica oggetto' : 'Nuovo oggetto'),
              const SizedBox(height: 14),
              TextFormField(
                controller: _nameCtrl,
                autofocus: !isEdit,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Campo obbligatorio'
                    : null,
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _categoryId,
                      isExpanded: true,
                      style: texts.bodyLarge,
                      decoration: const InputDecoration(labelText: 'Categoria'),
                      items: [
                        for (final c in widget.categories)
                          DropdownMenuItem(
                            value: c.id,
                            child: Text(
                              c.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: (v) =>
                          setState(() => _categoryId = v ?? _categoryId),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String?>(
                      initialValue: _bagId,
                      isExpanded: true,
                      style: texts.bodyLarge,
                      decoration: const InputDecoration(labelText: 'Bagaglio'),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text(
                            'Non assegnato',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        for (final b in widget.bags)
                          DropdownMenuItem(
                            value: b.id,
                            child: Text(
                              b.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: (v) => setState(() => _bagId = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _weightCtrl,
                decoration: const InputDecoration(
                  labelText: 'Peso unitario (g)',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 12),
              ItineraCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(child: Text('Quantità', style: texts.bodyLarge)),
                    _RoundStepper(
                      icon: Icons.remove,
                      tooltip: 'Togli uno',
                      onPressed: _quantity > 1
                          ? () => setState(() => _quantity--)
                          : null,
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 40),
                      child: Text(
                        '$_quantity',
                        textAlign: TextAlign.center,
                        style: texts.titleLarge?.copyWith(fontSize: 22),
                      ),
                    ),
                    _RoundStepper(
                      icon: Icons.add,
                      tooltip: 'Aggiungi uno',
                      filled: true,
                      onPressed: () => setState(() => _quantity++),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ItineraCard(
                padding: EdgeInsets.zero,
                child: SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  title: Text('Essenziale', style: texts.titleMedium),
                  subtitle: Text(
                    'Evidenziato nel controllo finale',
                    style: texts.bodySmall?.copyWith(
                      color: context.scheme.onSurfaceVariant,
                    ),
                  ),
                  value: _essential,
                  onChanged: (v) => setState(() => _essential = v),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  if (isEdit) ...[
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: tokens.warning,
                          textStyle: TextStyle(
                            fontFamily: tokens.displayFont,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                          side: BorderSide(color: tokens.warning, width: 1.5),
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
      ),
    );
  }
}

/// Bottone tondo del contatore: bordato o pieno come il bottone principale.
class _RoundStepper extends StatelessWidget {
  const _RoundStepper({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.filled = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final on = context.scheme.onSurface;
    final button = Theme.of(context).filledButtonTheme.style;
    final fill = button?.backgroundColor?.resolve(const {});
    final onFill = button?.foregroundColor?.resolve(const {});
    final enabled = onPressed != null;
    return SizedBox(
      width: 40,
      height: 40,
      child: IconButton(
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        iconSize: 20,
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: filled ? fill : Colors.transparent,
          foregroundColor: filled ? onFill : on,
          disabledForegroundColor: on.withValues(alpha: 0.35),
          shape: CircleBorder(
            side: filled
                ? BorderSide.none
                : BorderSide(
                    color: enabled ? on : on.withValues(alpha: 0.35),
                    width: 1.5,
                  ),
          ),
        ),
        icon: Icon(icon),
      ),
    );
  }
}
