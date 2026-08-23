import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../data/database.dart';
import '../../ui/itinera_theme.dart';
import '../../ui/widgets.dart';
import 'transport_providers.dart';

/// Foglio dei rimborsi di una spesa: salda la quota di un viaggiatore o
/// l'intera spesa. Le quote saldate escono dal "chi deve a chi".
Future<void> showReimbursementSheet(
  BuildContext context, {
  required String tripId,
  required CostItem expense,
  required List<Traveler> travelers,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _ReimbursementSheet(
      tripId: tripId,
      expense: expense,
      travelers: travelers,
    ),
  );
}

class _ReimbursementSheet extends ConsumerStatefulWidget {
  const _ReimbursementSheet({
    required this.tripId,
    required this.expense,
    required this.travelers,
  });

  final String tripId;
  final CostItem expense;
  final List<Traveler> travelers;

  @override
  ConsumerState<_ReimbursementSheet> createState() =>
      _ReimbursementSheetState();
}

class _ReimbursementSheetState extends ConsumerState<_ReimbursementSheet> {
  List<CostSplit>? _splits;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final splits =
        await ref.read(transportRepositoryProvider).getSplits(widget.expense.id);
    if (!mounted) return;
    setState(() => _splits = splits);
  }

  Future<void> _toggle(CostSplit split, bool value) async {
    await ref.read(transportRepositoryProvider).setSplitSettled(split.id, value);
    ref.invalidate(settlementProvider(widget.tripId));
    await _load();
  }

  Future<void> _settleAll(bool value) async {
    await ref
        .read(transportRepositoryProvider)
        .setExpenseSettled(widget.expense.id, value);
    ref.invalidate(settlementProvider(widget.tripId));
    await _load();
  }

  String _name(String id) =>
      widget.travelers.where((t) => t.id == id).map((t) => t.name).firstOrNull ??
      '?';

  @override
  Widget build(BuildContext context) {
    final splits = _splits;
    final allSettled = splits != null &&
        splits.isNotEmpty &&
        splits.every((s) => s.settled);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SheetHeader('Rimborsi'),
          const SizedBox(height: 4),
          Text(
            widget.expense.description ?? 'Spesa',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.scheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 12),
          if (splits == null)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (splits.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Questa spesa non e\' stata divisa.'),
            )
          else ...[
            for (final s in splits)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: s.settled,
                onChanged: s.travelerId == widget.expense.paidByTravelerId
                    ? null // il pagante non rimborsa se stesso
                    : (v) => _toggle(s, v ?? false),
                title: Text(_name(s.travelerId)),
                subtitle: Text(
                  s.travelerId == widget.expense.paidByTravelerId
                      ? '${Fmt.currencyCents(s.shareAmountCents)} · ha pagato'
                      : Fmt.currencyCents(s.shareAmountCents),
                ),
                secondary: s.settled
                    ? Icon(Icons.check_circle, color: context.tokens.positive)
                    : const Icon(Icons.pending_outlined),
              ),
            const SizedBox(height: 8),
            FilledButton.tonalIcon(
              onPressed: () => _settleAll(!allSettled),
              icon: Icon(allSettled ? Icons.undo : Icons.done_all),
              label: Text(allSettled
                  ? 'Annulla tutti i rimborsi'
                  : 'Segna intera spesa come rimborsata'),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
