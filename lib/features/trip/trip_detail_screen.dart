import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app.dart';
import '../../core/enum_labels.dart';
import '../../core/enums.dart';
import '../../core/format.dart';
import '../../data/database.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/itinera_theme.dart';
import '../../ui/signatures.dart';
import '../../ui/widgets.dart';
import '../itinerary/itinerary_providers.dart';
import '../packing/packing_providers.dart';
import '../transport/transport_providers.dart';
import 'trip_providers.dart';

/// Dettaglio di un viaggio: eroe + statistiche + accesso ai tre moduli.
///
/// Tutto il sottoalbero indossa il tema dello stile del viaggio.
class TripDetailScreen extends ConsumerWidget {
  const TripDetailScreen({super.key, required this.tripId});

  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripAsync = ref.watch(tripProvider(tripId));

    return tripAsync.when(
      loading: () => const Scaffold(body: LoadingView()),
      error: (e, _) => Scaffold(body: ErrorView(e)),
      data: (trip) {
        if (trip == null) {
          return const Scaffold(
            body: EmptyState(
              icon: Icons.search_off,
              title: 'Viaggio non trovato',
            ),
          );
        }
        return TripThemeScope(
          style: ItineraTheme.effectiveStyle(trip),
          child: _TripDetailBody(trip: trip),
        );
      },
    );
  }
}

class _TripDetailBody extends ConsumerWidget {
  const _TripDetailBody({required this.trip});
  final Trip trip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tripId = trip.id;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: Text(trip.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: l10n.commonEdit,
                onPressed: () => context.push('/trip/$tripId/edit'),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (v) async {
                  final repo = ref.read(tripRepositoryProvider);
                  switch (v) {
                    case 'duplicate':
                      final id = await repo.duplicateTrip(tripId);
                      if (context.mounted) context.pushReplacement('/trip/$id');
                    case 'delete':
                      final ok = await _confirmDelete(context, l10n);
                      if (ok && context.mounted) {
                        await repo.deleteTrip(tripId);
                        if (context.mounted) context.pop();
                      }
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'duplicate',
                    child: Text(l10n.commonDuplicate),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(l10n.commonDelete),
                  ),
                ],
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
            sliver: SliverList.list(
              children: [
                TripHero(
                  title: trip.name,
                  typeIcon: trip.tripType.icon,
                  kicker: _kicker(),
                  meta: _meta(l10n),
                ),
                const SizedBox(height: 16),
                _StatsRow(trip: trip, l10n: l10n),
                const SizedBox(height: 8),
                SectionHeader('Stile del viaggio'),
                _StyleSwitcher(trip: trip),
                SectionHeader('Sezioni'),
                _PackingModuleCard(tripId: tripId),
                const SizedBox(height: 12),
                _TransportModuleCard(tripId: tripId),
                const SizedBox(height: 12),
                _ItineraryModuleCard(tripId: tripId),
                if (trip.notes != null && trip.notes!.trim().isNotEmpty) ...[
                  SectionHeader(l10n.commonNotes),
                  ItineraCard(
                    child: Text(
                      trip.notes!,
                      style: context.texts.bodyMedium,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? _kicker() {
    if (trip.destination != null && trip.destination!.isNotEmpty) {
      final country = trip.country;
      if (country != null && country.isNotEmpty) {
        return '${trip.destination} · $country';
      }
      return trip.destination;
    }
    return trip.country?.isNotEmpty == true ? trip.country : trip.tripType.label;
  }

  String? _meta(AppLocalizations l10n) {
    final s = trip.startDate;
    final e = trip.endDate;
    if (s != null && e != null) {
      return '${Fmt.date(s)} → ${Fmt.date(e)}';
    }
    if (s != null) return Fmt.date(s);
    return null;
  }

  Future<bool> _confirmDelete(BuildContext context, AppLocalizations l10n) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.commonDelete),
        content: Text(l10n.tripDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.trip, required this.l10n});
  final Trip trip;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final tiles = <StatTile>[];
    final s = trip.startDate;
    final e = trip.endDate;
    if (s != null && e != null) {
      final days = e.difference(s).inDays + 1;
      tiles.add(StatTile(value: '$days', label: days == 1 ? 'giorno' : 'giorni'));
    }
    tiles.add(StatTile(
      value: '${trip.travelerCount}',
      label: trip.travelerCount == 1 ? 'viaggiatore' : 'viaggiatori',
    ));
    tiles.add(StatTile(
      value: trip.startDate != null ? Fmt.dayMonth(trip.startDate!) : '—',
      label: 'partenza',
      mono: true,
    ));
    return StatStrip(tiles: tiles);
  }
}

/// Selettore inline dello stile: tocco → ri-tematizza e persiste.
class _StyleSwitcher extends ConsumerWidget {
  const _StyleSwitcher({required this.trip});
  final Trip trip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ItineraTheme.effectiveStyle(trip);
    return Row(
      children: [
        for (final style in TripStyle.values) ...[
          Expanded(child: _StyleChip(
            style: style,
            selected: style == active,
            onTap: () =>
                ref.read(tripRepositoryProvider).setThemeStyle(trip.id, style),
          )),
          if (style != TripStyle.values.last) const SizedBox(width: 10),
        ],
      ],
    );
  }
}

class _StyleChip extends StatelessWidget {
  const _StyleChip({
    required this.style,
    required this.selected,
    required this.onTap,
  });
  final TripStyle style;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final meta = ItineraTheme.meta(style);
    final tokens = context.tokens;
    final scheme = context.scheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? tokens.accentSoft : scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? tokens.accent : tokens.hairline,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [meta.swatch.first, meta.swatch[1]],
                ),
              ),
              child: Icon(meta.icon, size: 17, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              meta.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.texts.labelMedium?.copyWith(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? tokens.accent : scheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card di modulo con statistica live.
class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.progress,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scheme = context.scheme;
    return ItineraCard(
      onTap: onTap,
      accentEdge: tokens.accent,
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: tokens.accentSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: tokens.accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.texts.titleMedium),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: context.texts.bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
                if (progress != null) ...[
                  const SizedBox(height: 10),
                  MeterBar(value: progress!),
                ],
              ],
            ),
          ),
          const SizedBox(width: 6),
          Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
        ],
      ),
    );
  }
}

class _PackingModuleCard extends ConsumerWidget {
  const _PackingModuleCard({required this.tripId});
  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final items = ref.watch(packingItemsProvider(tripId)).value ?? const [];
    final total = items.length;
    final packed =
        items.where((i) => i.packedCount >= i.quantity && i.quantity > 0).length;
    final subtitle = total == 0
        ? 'Prepara e spunta il bagaglio'
        : '$packed di $total oggetti in valigia';
    return _ModuleCard(
      icon: Icons.luggage_outlined,
      title: l10n.sectionPacking,
      subtitle: subtitle,
      progress: total == 0 ? null : packed / total,
      onTap: () => context.push('/trip/$tripId/packing'),
    );
  }
}

class _TransportModuleCard extends ConsumerWidget {
  const _TransportModuleCard({required this.tripId});
  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final segments = ref.watch(segmentsProvider(tripId)).value ?? const [];
    final expenses = ref.watch(expensesProvider(tripId)).value ?? const [];
    final spent = expenses
        .where((e) => e.status == CostStatus.actual)
        .fold<int>(0, (a, e) => a + e.amountCents);
    final parts = <String>[];
    if (segments.isNotEmpty) {
      parts.add(segments.length == 1 ? '1 tratta' : '${segments.length} tratte');
    }
    if (spent > 0) parts.add('${Fmt.currencyCents(spent)} spesi');
    final subtitle = parts.isEmpty ? 'Tratte, carburante e spese' : parts.join(' · ');
    return _ModuleCard(
      icon: Icons.route_outlined,
      title: l10n.sectionTransport,
      subtitle: subtitle,
      onTap: () => context.push('/trip/$tripId/transport'),
    );
  }
}

class _ItineraryModuleCard extends ConsumerWidget {
  const _ItineraryModuleCard({required this.tripId});
  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final activities = ref.watch(activitiesProvider(tripId)).value ?? const [];
    final days = ref.watch(itineraryDaysProvider(tripId)).value ?? const [];
    final dayCount = days.where((d) => d.date != null).length;
    final parts = <String>[];
    if (activities.isNotEmpty) {
      parts.add(activities.length == 1
          ? '1 attività'
          : '${activities.length} attività');
    }
    if (dayCount > 0) parts.add(dayCount == 1 ? '1 giorno' : '$dayCount giorni');
    final subtitle =
        parts.isEmpty ? 'Programma giorno per giorno' : parts.join(' · ');
    return _ModuleCard(
      icon: Icons.map_outlined,
      title: l10n.sectionItinerary,
      subtitle: subtitle,
      onTap: () => context.push('/trip/$tripId/itinerary'),
    );
  }
}
