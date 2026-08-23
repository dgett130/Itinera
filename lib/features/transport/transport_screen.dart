import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app.dart';
import '../../core/enum_labels.dart';
import '../../core/enums.dart';
import '../../core/format.dart';
import '../../data/database.dart';
import '../../ui/itinera_theme.dart';
import '../../ui/widgets.dart';
import '../trip/trip_providers.dart';
import 'expense_sheet.dart';
import 'reimbursement_sheet.dart';
import 'segment_sheet.dart';
import 'transport_domain.dart';
import 'transport_providers.dart';

/// Modulo Viaggio: tratte con calcolo carburante + spese e divisione.
class TransportScreen extends ConsumerWidget {
  const TransportScreen({super.key, required this.tripId});
  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trip = ref.watch(tripProvider(tripId)).value;
    final style =
        trip == null ? TripStyle.atlante : ItineraTheme.effectiveStyle(trip);
    return TripThemeScope(style: style, child: _TransportBody(tripId: tripId));
  }
}

class _TransportBody extends ConsumerStatefulWidget {
  const _TransportBody({required this.tripId});
  final String tripId;

  @override
  ConsumerState<_TransportBody> createState() => _TransportBodyState();
}

class _TransportBodyState extends ConsumerState<_TransportBody>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this)
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final segments = ref.watch(segmentsProvider(widget.tripId)).value;
    final expenses = ref.watch(expensesProvider(widget.tripId)).value;
    final travelers = ref.watch(travelersProvider(widget.tripId)).value;

    if (segments == null || expenses == null || travelers == null) {
      return const Scaffold(body: LoadingView());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Viaggio e costi'),
        bottom: TabBar(
          controller: _tab,
          labelColor: tokens.accent,
          unselectedLabelColor: context.scheme.onSurfaceVariant,
          indicatorColor: tokens.accent,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700),
          tabs: const [Tab(text: 'Tratte'), Tab(text: 'Spese')],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_tab.index == 0) {
            showSegmentSheet(context, tripId: widget.tripId);
          } else {
            showExpenseSheet(context,
                tripId: widget.tripId, travelers: travelers);
          }
        },
        icon: const Icon(Icons.add),
        label: Text(_tab.index == 0 ? 'Tratta' : 'Spesa'),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _SegmentsTab(tripId: widget.tripId, segments: segments),
          _ExpensesTab(
            tripId: widget.tripId,
            expenses: expenses,
            travelers: travelers,
            segments: segments,
          ),
        ],
      ),
    );
  }
}

// --- TAB TRATTE ---

class _SegmentsTab extends StatelessWidget {
  const _SegmentsTab({required this.tripId, required this.segments});
  final String tripId;
  final List<TransportSegment> segments;

  @override
  Widget build(BuildContext context) {
    if (segments.isEmpty) {
      return const EmptyState(
        icon: Icons.route_outlined,
        title: 'Nessuna tratta',
        message: 'Aggiungi la prima tappa del viaggio.',
      );
    }
    final totalKm = segments
        .map(segmentEffectiveKm)
        .whereType<double>()
        .fold<double>(0, (a, b) => a + b);
    final totalFuel = segments
        .where((s) => s.mode.burnsFuel)
        .fold<int>(0, (a, s) => a + segmentEstimatedCents(s));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        StatStrip(tiles: [
          StatTile(
            value: Fmt.distanceKm(totalKm),
            label: 'distanza totale',
            icon: Icons.straighten,
            mono: true,
          ),
          StatTile(
            value: Fmt.currencyCents(totalFuel),
            label: 'carburante stimato',
            icon: Icons.local_gas_station,
          ),
        ]),
        const SizedBox(height: 8),
        SectionHeader('Tappe'),
        for (final s in segments) ...[
          _SegmentTile(tripId: tripId, segment: s),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _SegmentTile extends StatelessWidget {
  const _SegmentTile({required this.tripId, required this.segment});
  final String tripId;
  final TransportSegment segment;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scheme = context.scheme;
    final cost = segmentEstimatedCents(segment);
    final units = segmentFuelUnits(segment);
    final km = segmentEffectiveKm(segment);
    final route = [segment.originLabel, segment.destinationLabel]
        .where((s) => s.isNotEmpty)
        .join('  →  ');

    final tags = <Widget>[];
    if (km != null) tags.add(MonoTag(Fmt.distanceKm(km)));
    if (segment.isRoundTrip) tags.add(MonoTag('A/R', icon: Icons.sync_alt));
    if (units != null) tags.add(MonoTag(Fmt.liters(units)));
    if (segment.provider != null && segment.provider!.isNotEmpty) {
      tags.add(MonoTag(segment.provider!));
    }

    return ItineraCard(
      onTap: () => showSegmentSheet(context, tripId: tripId, existing: segment),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: tokens.accentSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(segment.mode.icon, color: tokens.accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  route.isEmpty ? segment.mode.label : route,
                  style: context.texts.titleSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (tags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(spacing: 6, runSpacing: 6, children: tags),
                ],
              ],
            ),
          ),
          if (cost > 0) ...[
            const SizedBox(width: 10),
            Text(
              Fmt.currencyCents(cost),
              style: TextStyle(
                fontFamily: tokens.displayFont,
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: scheme.onSurface,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// --- TAB SPESE ---

class _ExpensesTab extends ConsumerWidget {
  const _ExpensesTab({
    required this.tripId,
    required this.expenses,
    required this.travelers,
    required this.segments,
  });
  final String tripId;
  final List<CostItem> expenses;
  final List<Traveler> travelers;
  final List<TransportSegment> segments;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fuelEstimate = segments
        .where((s) => s.mode.burnsFuel)
        .fold<int>(0, (a, s) => a + segmentEstimatedCents(s));
    final estimateExpenses = expenses
        .where((e) => e.status == CostStatus.estimate)
        .fold<int>(0, (a, e) => a + e.amountCents);
    final actual = expenses
        .where((e) => e.status == CostStatus.actual)
        .fold<int>(0, (a, e) => a + e.amountCents);
    final estimatedTotal = fuelEstimate + estimateExpenses;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        StatStrip(tiles: [
          StatTile(
            value: Fmt.currencyCents(estimatedTotal),
            label: 'stima totale',
            icon: Icons.calculate_outlined,
          ),
          StatTile(
            value: Fmt.currencyCents(actual),
            label: 'speso davvero',
            icon: Icons.payments_outlined,
            accent: context.tokens.accent,
          ),
        ]),
        const SizedBox(height: 12),
        _TravelersRow(tripId: tripId, travelers: travelers),
        if (travelers.length >= 2)
          _SettlementCard(tripId: tripId, travelers: travelers),
        SectionHeader('Spese'),
        if (expenses.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              'Nessuna spesa registrata.',
              textAlign: TextAlign.center,
              style: context.texts.bodyMedium
                  ?.copyWith(color: context.scheme.onSurfaceVariant),
            ),
          )
        else
          for (final e in expenses) ...[
            _ExpenseTile(tripId: tripId, expense: e, travelers: travelers),
            const SizedBox(height: 8),
          ],
      ],
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  const _ExpenseTile({
    required this.tripId,
    required this.expense,
    required this.travelers,
  });
  final String tripId;
  final CostItem expense;
  final List<Traveler> travelers;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scheme = context.scheme;
    final estimate = expense.status == CostStatus.estimate;
    final payer =
        travelers.where((t) => t.id == expense.paidByTravelerId).firstOrNull;

    return ItineraCard(
      onTap: () => showExpenseSheet(
        context,
        tripId: tripId,
        travelers: travelers,
        existing: expense,
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(expense.category.icon, size: 20, color: scheme.onSurface),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.description ?? expense.category.label,
                  style: context.texts.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (payer != null) ...[
                      Icon(Icons.person_outline,
                          size: 13, color: scheme.onSurfaceVariant),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          payer.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.texts.bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ),
                    ],
                    if (estimate) ...[
                      const SizedBox(width: 6),
                      MonoTag('STIMA'),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Fmt.currencyCents(expense.amountCents),
                style: TextStyle(
                  fontFamily: tokens.displayFont,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: estimate ? scheme.onSurfaceVariant : scheme.onSurface,
                ),
              ),
              if (expense.splitMethod != SplitMethod.none)
                SizedBox(
                  height: 28,
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      visualDensity: VisualDensity.compact,
                    ),
                    icon: const Icon(Icons.price_check, size: 16),
                    label: const Text('Rimborsi'),
                    onPressed: () => showReimbursementSheet(
                      context,
                      tripId: tripId,
                      expense: expense,
                      travelers: travelers,
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

class _TravelersRow extends ConsumerWidget {
  const _TravelersRow({required this.tripId, required this.travelers});
  final String tripId;
  final List<Traveler> travelers;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final t in travelers)
          Chip(
            label: Text(t.name),
            avatar: t.isSelfUser
                ? Icon(Icons.person, size: 16, color: context.tokens.accent)
                : null,
          ),
        ActionChip(
          avatar: const Icon(Icons.group_add, size: 18),
          label: const Text('Viaggiatori'),
          onPressed: () => _manageTravelers(context, ref, tripId, travelers),
        ),
      ],
    );
  }
}

class _SettlementCard extends ConsumerWidget {
  const _SettlementCard({required this.tripId, required this.travelers});
  final String tripId;
  final List<Traveler> travelers;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settlementAsync = ref.watch(settlementProvider(tripId));
    final result = settlementAsync.value;
    if (result == null || result.settlements.isEmpty) {
      return const SizedBox.shrink();
    }
    final tokens = context.tokens;
    final nameById = {for (final t in travelers) t.id: t.name};
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: ItineraCard(
        accentEdge: tokens.accent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.swap_horiz, color: tokens.accent),
                const SizedBox(width: 8),
                Text('Chi deve a chi', style: context.texts.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            for (final s in result.settlements)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${nameById[s.fromTravelerId] ?? '?'} → '
                        '${nameById[s.toTravelerId] ?? '?'}',
                        style: context.texts.bodyMedium,
                      ),
                    ),
                    Text(
                      Fmt.currencyCents(s.cents),
                      style: TextStyle(
                        fontFamily: tokens.monoFont,
                        fontWeight: FontWeight.w700,
                        color: tokens.accent,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

Future<void> _manageTravelers(
  BuildContext context,
  WidgetRef ref,
  String tripId,
  List<Traveler> travelers,
) {
  final repo = ref.read(transportRepositoryProvider);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      final controller = TextEditingController();
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
            const SheetHeader('Viaggiatori'),
            const SizedBox(height: 8),
            for (final t in travelers)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: t.isSelfUser
                    ? Icon(Icons.person, color: context.tokens.accent)
                    : const Icon(Icons.person_outline),
                title: Text(t.name),
                trailing: t.isSelfUser
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => repo.deleteTraveler(t.id),
                      ),
              ),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: 'Aggiungi viaggiatore',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () async {
                    final name = controller.text.trim();
                    if (name.isEmpty) return;
                    await repo.addTraveler(tripId, name);
                    controller.clear();
                  },
                  child: const Text('Aggiungi'),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    },
  );
}
