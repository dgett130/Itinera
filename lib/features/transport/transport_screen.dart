import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/enum_labels.dart';
import '../../core/enums.dart';
import '../../core/format.dart';
import '../../data/database.dart';
import '../../ui/itinera_theme.dart';
import '../../ui/motion.dart';
import '../../ui/widgets.dart';
import 'expense_sheet.dart';
import 'reimbursement_sheet.dart';
import 'segment_sheet.dart';
import 'transport_domain.dart';
import 'transport_providers.dart';

// Numeri della testata, senza decimali ("642 km").
final _whole = NumberFormat('#,##0', Fmt.locale);
// Numeri delle righe, col decimale solo se serve ("268 km · 19,8 L").
final _compact = NumberFormat('#,##0.#', Fmt.locale);

// Titoli di sezione allineati alle card, come nelle maschere.
const _sectionPadding = EdgeInsets.fromLTRB(0, 18, 0, 10);

/// Modulo Viaggio: tratte con calcolo carburante + spese e divisione.
class TransportScreen extends ConsumerWidget {
  const TransportScreen({super.key, required this.tripId});
  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _TransportBody(tripId: tripId);
  }
}

enum _Tab { tratte, spese }

class _TransportBody extends ConsumerStatefulWidget {
  const _TransportBody({required this.tripId});
  final String tripId;

  @override
  ConsumerState<_TransportBody> createState() => _TransportBodyState();
}

class _TransportBodyState extends ConsumerState<_TransportBody> {
  var _tab = _Tab.tratte;

  void _select(_Tab tab) {
    if (tab != _tab) setState(() => _tab = tab);
  }

  // Le schede stanno una accanto all'altra: Tratte a sinistra, Spese a destra.
  // Ognuna entra e esce dal suo lato, in qualunque verso si cambi.
  static Widget _slide(Widget child, Animation<double> animation) {
    final side = child.key == const ValueKey(_Tab.spese) ? 1.0 : -1.0;
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: animation.drive(
          Tween(
            begin: Offset(side * 0.12, 0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOutCubic)),
        ),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final segments = ref.watch(segmentsProvider(widget.tripId)).value;
    final expenses = ref.watch(expensesProvider(widget.tripId)).value;
    final travelers = ref.watch(travelersProvider(widget.tripId)).value;

    if (segments == null || expenses == null || travelers == null) {
      return const Scaffold(
        body: Column(
          children: [
            ModuleHeader(style: ModuleStyle.costi, title: 'Viaggio e costi'),
            Expanded(child: _LoadingRows()),
          ],
        ),
      );
    }

    final isSegments = _tab == _Tab.tratte;
    final standard = Motion.of(context, Motion.standard);

    return Scaffold(
      // Senza tratte l'azione è il bottone al centro dello stato vuoto.
      floatingActionButton: isSegments && segments.isEmpty
          ? null
          : CartolinaFab(
              label: isSegments ? 'Tratta' : 'Spesa',
              tint: Cartolina.laguna,
              onPressed: () {
                if (isSegments) {
                  showSegmentSheet(
                    context,
                    tripId: widget.tripId,
                    fromFab: true,
                  );
                } else {
                  showExpenseSheet(
                    context,
                    tripId: widget.tripId,
                    travelers: travelers,
                    fromFab: true,
                  );
                }
              },
            ),
      body: Column(
        children: [
          ModuleHeader(
            style: ModuleStyle.costi,
            title: 'Viaggio e costi',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AnimatedSize(
                  duration: standard,
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.topCenter,
                  child: AnimatedSwitcher(
                    duration: standard,
                    child: _HeaderStats(
                      key: ValueKey(_tab),
                      tab: _tab,
                      segments: segments,
                      expenses: expenses,
                    ),
                  ),
                ),
                _TabSelector(selected: _tab, onChanged: _select),
              ],
            ),
          ),
          Expanded(
            child: GestureDetector(
              // Come prima con le schede: si cambia anche scorrendo di lato.
              behavior: HitTestBehavior.translucent,
              onHorizontalDragEnd: (details) {
                final v = details.primaryVelocity ?? 0;
                if (v < -300) _select(_Tab.spese);
                if (v > 300) _select(_Tab.tratte);
              },
              child: AnimatedSwitcher(
                duration: standard,
                transitionBuilder: _slide,
                layoutBuilder: (current, previous) => Stack(
                  fit: StackFit.expand,
                  children: [...previous, ?current],
                ),
                child: isSegments
                    ? _SegmentsTab(
                        key: const ValueKey(_Tab.tratte),
                        tripId: widget.tripId,
                        segments: segments,
                      )
                    : _ExpensesTab(
                        key: const ValueKey(_Tab.spese),
                        tripId: widget.tripId,
                        expenses: expenses,
                        travelers: travelers,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- TESTATA ---

class _TabSelector extends StatelessWidget {
  const _TabSelector({required this.selected, required this.onChanged});
  final _Tab selected;
  final ValueChanged<_Tab> onChanged;

  @override
  Widget build(BuildContext context) {
    final selector = PillSelector<_Tab>(
      items: const {_Tab.tratte: 'Tratte', _Tab.spese: 'Spese'},
      selected: selected,
      onChanged: onChanged,
      track: const Color(0xFF0A8F96),
      pill: Cartolina.inchiostro,
      onPill: Colors.white,
      foreground: Cartolina.inchiostro,
    );
    if (Theme.of(context).brightness != Brightness.dark) return selector;
    // In scuro il selettore ha un filo d'inchiostro attorno.
    return DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Cartolina.inchiostro),
      ),
      child: selector,
    );
  }
}

class _HeaderStats extends StatelessWidget {
  const _HeaderStats({
    super.key,
    required this.tab,
    required this.segments,
    required this.expenses,
  });
  final _Tab tab;
  final List<TransportSegment> segments;
  final List<CostItem> expenses;

  static String _money(num cents) => Fmt.currencyCents(cents.round());

  @override
  Widget build(BuildContext context) {
    // Vuoto / Tratte: testata senza numeri.
    if (tab == _Tab.tratte && segments.isEmpty) {
      return const SizedBox(width: double.infinity);
    }
    final List<Widget> stats;
    if (tab == _Tab.tratte) {
      final km = segments
          .map(segmentEffectiveKm)
          .whereType<double>()
          .fold<double>(0, (a, b) => a + b);
      // I kWh delle tratte elettriche non si sommano ai litri.
      final liters = segments
          .where(
            (s) => s.consumptionUnitSnapshot != ConsumptionUnit.kwhPer100km,
          )
          .map(segmentFuelUnits)
          .whereType<double>()
          .fold<double>(0, (a, b) => a + b);
      stats = [
        _HeaderStat(
          value: km,
          format: (v) => '${_whole.format(v)} km',
          label: 'distanza totale',
        ),
        _HeaderStat(
          value: liters,
          format: (v) => '${_whole.format(v)} L',
          label: 'carburante stimato',
        ),
      ];
    } else {
      final fuelEstimate = segments
          .where((s) => s.mode.burnsFuel)
          .fold<int>(0, (a, s) => a + segmentEstimatedCents(s));
      final estimateExpenses = expenses
          .where((e) => e.status == CostStatus.estimate)
          .fold<int>(0, (a, e) => a + e.amountCents);
      final actual = expenses
          .where((e) => e.status == CostStatus.actual)
          .fold<int>(0, (a, e) => a + e.amountCents);
      stats = [
        _HeaderStat(value: actual, format: _money, label: 'speso davvero'),
        _HeaderStat(
          value: fuelEstimate + estimateExpenses,
          format: _money,
          label: 'stima totale',
        ),
      ];
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(child: stats[0]),
          const SizedBox(width: 26),
          Flexible(child: stats[1]),
        ],
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  const _HeaderStat({
    required this.value,
    required this.format,
    required this.label,
  });
  final num value;
  final String Function(num) format;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: CountUpText(
            value: value,
            format: format,
            maxLines: 1,
            style: context.texts.displaySmall?.copyWith(
              fontSize: 32,
              height: 1.1,
              color: ModuleStyle.costi.foreground,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.texts.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: ModuleStyle.costi.foreground,
          ),
        ),
      ],
    );
  }
}

/// Segnaposto mentre arrivano i dati.
class _LoadingRows extends StatelessWidget {
  const _LoadingRows();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        children: [
          Skeleton(height: 72, radius: 20),
          SizedBox(height: 10),
          Skeleton(height: 72, radius: 20),
          SizedBox(height: 10),
          Skeleton(height: 72, radius: 20),
        ],
      ),
    );
  }
}

/// Riga di lista: entra in cascata, ma solo le prime (le altre arrivano
/// scorrendo e non devono animarsi a ogni comparsa).
class _ListRow extends StatelessWidget {
  const _ListRow({super.key, required this.index, required this.child});
  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: child,
    );
    return index < Motion.staggerMax
        ? StaggerIn(index: index, child: row)
        : row;
  }
}

// --- TAB TRATTE ---

class _SegmentsTab extends StatelessWidget {
  const _SegmentsTab({super.key, required this.tripId, required this.segments});
  final String tripId;
  final List<TransportSegment> segments;

  @override
  Widget build(BuildContext context) {
    if (segments.isEmpty) {
      return EmptyState(
        icon: Icons.directions_car,
        color: Cartolina.laguna,
        iconColor: Cartolina.inchiostro,
        title: 'Nessuna tratta',
        message: 'Aggiungi la prima tappa del viaggio.',
        action: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => showSegmentSheet(context, tripId: tripId),
            child: const Text('Aggiungi tratta'),
          ),
        ),
      );
    }

    return ListView(
      key: const PageStorageKey('tratte'),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
      children: [
        const SectionHeader('Tappe', padding: _sectionPadding),
        for (final (i, s) in segments.indexed)
          _ListRow(
            key: ValueKey(s.id),
            index: i,
            child: _SegmentTile(tripId: tripId, segment: s),
          ),
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
    final route = [
      segment.originLabel,
      segment.destinationLabel,
    ].where((s) => s.isNotEmpty).join(' → ');
    final electric =
        segment.consumptionUnitSnapshot == ConsumptionUnit.kwhPer100km;
    final provider = segment.provider;

    final details = [
      segment.mode.label,
      if (provider != null && provider.isNotEmpty) provider,
      if (km != null) '${_compact.format(km)} km',
      if (units != null) '${_compact.format(units)} ${electric ? 'kWh' : 'L'}',
      if (segment.isRoundTrip) 'A/R',
    ].join(' · ');

    return ItineraCard(
      onTap: () => showSegmentSheet(context, tripId: tripId, existing: segment),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          IconTile(
            segment.mode.icon,
            color: Cartolina.laguna,
            size: 44,
            round: true,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  route.isEmpty ? segment.mode.label : route,
                  style: context.texts.titleSmall?.copyWith(fontSize: 15.5),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  details,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.texts.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
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

class _ExpensesTab extends StatelessWidget {
  const _ExpensesTab({
    super.key,
    required this.tripId,
    required this.expenses,
    required this.travelers,
  });
  final String tripId;
  final List<CostItem> expenses;
  final List<Traveler> travelers;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const PageStorageKey('spese'),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 100),
      children: [
        _TravelersRow(tripId: tripId, travelers: travelers),
        if (travelers.length >= 2)
          _SettlementCard(tripId: tripId, travelers: travelers),
        const SectionHeader('Spese', padding: _sectionPadding),
        if (expenses.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              'Nessuna spesa registrata.',
              textAlign: TextAlign.center,
              style: context.texts.bodyMedium?.copyWith(
                color: context.scheme.onSurfaceVariant,
              ),
            ),
          )
        else
          for (final (i, e) in expenses.indexed)
            _ListRow(
              key: ValueKey(e.id),
              index: i,
              child: _ExpenseTile(
                tripId: tripId,
                expense: e,
                travelers: travelers,
              ),
            ),
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
    final payer = travelers
        .where((t) => t.id == expense.paidByTravelerId)
        .firstOrNull;
    final description = expense.description;

    final details = [
      // Senza descrizione la categoria è già il titolo.
      if (description != null) expense.category.label,
      if (payer != null) 'ha pagato ${payer.name}',
      if (estimate) 'stima',
    ].join(' · ');

    return ItineraCard(
      onTap: () => showExpenseSheet(
        context,
        tripId: tripId,
        travelers: travelers,
        existing: expense,
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description ?? expense.category.label,
                  style: context.texts.titleSmall?.copyWith(fontSize: 15.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (details.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    details,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.texts.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
                if (expense.splitMethod != SplitMethod.none)
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: tokens.accent,
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 28),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      textStyle: context.texts.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () => showReimbursementSheet(
                      context,
                      tripId: tripId,
                      expense: expense,
                      travelers: travelers,
                    ),
                    child: const Text('Rimborsi'),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            Fmt.currencyCents(expense.amountCents),
            style: TextStyle(
              fontFamily: tokens.displayFont,
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: estimate ? scheme.onSurfaceVariant : scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _TravelersRow extends StatelessWidget {
  const _TravelersRow({required this.tripId, required this.travelers});
  final String tripId;
  final List<Traveler> travelers;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final t in travelers)
          Chip(
            label: Text(t.name),
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ActionChip(
          avatar: Icon(Icons.add, size: 16, color: context.scheme.onSurface),
          label: const Text('Viaggiatori'),
          side: BorderSide(color: context.scheme.onSurface, width: 1.5),
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onPressed: () => _manageTravelers(context, tripId),
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
      padding: const EdgeInsets.only(top: 14),
      child: ItineraCard(
        color: Cartolina.sole,
        borderColor: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chi deve a chi',
              style: context.texts.titleMedium?.copyWith(
                color: Cartolina.inchiostro,
              ),
            ),
            const SizedBox(height: 8),
            for (final s in result.settlements)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${nameById[s.fromTravelerId] ?? '?'} → '
                        '${nameById[s.toTravelerId] ?? '?'}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.texts.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Cartolina.inchiostro,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      Fmt.currencyCents(s.cents),
                      style: TextStyle(
                        fontFamily: tokens.displayFont,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        color: Cartolina.inchiostro,
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

// --- FOGLIO VIAGGIATORI ---

Future<void> _manageTravelers(BuildContext context, String tripId) {
  return showCartolinaSheet<void>(
    context: context,
    builder: (context) => _TravelersSheet(tripId: tripId),
  );
}

class _TravelersSheet extends ConsumerStatefulWidget {
  const _TravelersSheet({required this.tripId});
  final String tripId;

  @override
  ConsumerState<_TravelersSheet> createState() => _TravelersSheetState();
}

class _TravelersSheetState extends ConsumerState<_TravelersSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    await ref
        .read(transportRepositoryProvider)
        .addTraveler(widget.tripId, name);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final travelers =
        ref.watch(travelersProvider(widget.tripId)).value ?? const <Traveler>[];
    final repo = ref.read(transportRepositoryProvider);
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
            const SheetHeader('Viaggiatori'),
            const SizedBox(height: 8),
            Text(
              'Servono per dividere le spese. Non hanno bisogno di un account.',
              style: context.texts.bodyMedium?.copyWith(
                color: context.scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            for (final t in travelers)
              Padding(
                key: ValueKey(t.id),
                padding: const EdgeInsets.only(bottom: 10),
                child: ItineraCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      InitialAvatar(
                        t.name,
                        size: 40,
                        color: t.isSelfUser ? Cartolina.cobalto : null,
                        foreground: t.isSelfUser ? Colors.white : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          t.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.texts.titleSmall?.copyWith(
                            fontSize: 15.5,
                          ),
                        ),
                      ),
                      // Il sé resta sempre: lo spazio tiene allineate le righe.
                      if (t.isSelfUser)
                        const SizedBox(height: 48)
                      else
                        IconButton(
                          tooltip: 'Rimuovi ${t.name}',
                          icon: const Icon(Icons.close),
                          onPressed: () async {
                            // Quote e rimborsi non si possono recuperare.
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Rimuovi ${t.name}'),
                                content: const Text(
                                  'Spariscono anche le sue quote e i suoi '
                                  'rimborsi. Non si può annullare.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Annulla'),
                                  ),
                                  FilledButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Rimuovi'),
                                  ),
                                ],
                              ),
                            );
                            if (ok == true) await repo.deleteTraveler(t.id);
                          },
                        ),
                    ],
                  ),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Nome',
                      hintText: 'Aggiungi un viaggiatore',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(onPressed: _add, child: const Text('Aggiungi')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
