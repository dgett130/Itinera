import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/enum_labels.dart';
import '../../core/format.dart';
import '../../data/database.dart';
import '../../ui/itinera_theme.dart';
import '../../ui/motion.dart';
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
  return showCartolinaSheet<void>(
    context: context,
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
    final splits = await ref
        .read(transportRepositoryProvider)
        .getSplits(widget.expense.id);
    if (!mounted) return;
    setState(() => _splits = splits);
  }

  Future<void> _toggle(CostSplit split, bool value) async {
    await ref
        .read(transportRepositoryProvider)
        .setSplitSettled(split.id, value);
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
      widget.travelers
          .where((t) => t.id == id)
          .map((t) => t.name)
          .firstOrNull ??
      '?';

  @override
  Widget build(BuildContext context) {
    final expense = widget.expense;
    final payerId = expense.paidByTravelerId;
    // Il pagante non rimborsa se stesso: resta solo nel sottotitolo.
    final due = _splits?.where((s) => s.travelerId != payerId).toList();
    final allSettled = due != null && due.every((s) => s.settled);
    final summary = [
      expense.description ?? expense.category.label,
      Fmt.currencyCents(expense.amountCents),
      if (payerId != null) 'ha pagato ${_name(payerId)}',
    ].join(' · ');

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SheetHeader('Rimborsi'),
            const SizedBox(height: 8),
            Text(
              summary,
              style: context.texts.bodyMedium?.copyWith(
                color: context.scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            if (due == null) ...const [
              Skeleton(height: 56, radius: 20),
              SizedBox(height: 10),
              Skeleton(height: 56, radius: 20),
            ] else if (due.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('Questa spesa non è stata divisa.'),
              )
            else ...[
              for (final s in due)
                Padding(
                  key: ValueKey(s.id),
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _SplitRow(
                    name: _name(s.travelerId),
                    cents: s.shareAmountCents,
                    settled: s.settled,
                    onTap: () => _toggle(s, !s.settled),
                  ),
                ),
              OutlinedButton(
                onPressed: () => _settleAll(!allSettled),
                child: Text(
                  allSettled
                      ? 'Annulla tutti i rimborsi'
                      : 'Segna intera spesa come rimborsata',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SplitRow extends StatelessWidget {
  const _SplitRow({
    required this.name,
    required this.cents,
    required this.settled,
    required this.onTap,
  });

  final String name;
  final int cents;
  final bool settled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: settled,
      child: ItineraCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        onTap: onTap,
        child: Row(
          children: [
            CheckDot(checked: settled),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.texts.titleSmall?.copyWith(fontSize: 15.5),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              Fmt.currencyCents(cents),
              style: TextStyle(
                fontFamily: context.tokens.displayFont,
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: context.scheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
