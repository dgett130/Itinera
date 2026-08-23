import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/enum_labels.dart';
import '../../core/format.dart';
import '../../data/database.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/itinera_theme.dart';
import '../../ui/widgets.dart';
import '../sync/sync_status_button.dart';
import 'trip_providers.dart';

/// Home: elenco dei viaggi, raggruppati in "In arrivo" e "Passati".
class TripsScreen extends ConsumerWidget {
  const TripsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tripsAsync = ref.watch(tripsProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/trip/new'),
        icon: const Icon(Icons.add),
        label: Text(l10n.tripNew),
      ),
      body: SafeArea(
        child: tripsAsync.when(
          loading: () => const LoadingView(),
          error: (e, _) => ErrorView(e),
          data: (trips) {
            final today = DateTime.now();
            final todayDate = DateTime(today.year, today.month, today.day);
            final upcoming = <Trip>[];
            final past = <Trip>[];
            for (final t in trips) {
              final end = t.endDate;
              if (end != null && end.isBefore(todayDate)) {
                past.add(t);
              } else {
                upcoming.add(t);
              }
            }
            return CustomScrollView(
              slivers: [
                _HomeHeader(count: trips.length),
                if (trips.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      icon: Icons.luggage_outlined,
                      title: 'Nessun viaggio, per ora',
                      message: l10n.tripsEmpty,
                      action: FilledButton.icon(
                        onPressed: () => context.push('/trip/new'),
                        icon: const Icon(Icons.add),
                        label: Text(l10n.tripNew),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                    sliver: SliverList.list(
                      children: [
                        if (upcoming.isNotEmpty) ...[
                          SectionHeader(l10n.tripsUpcoming),
                          for (final t in upcoming)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _TripCard(trip: t, l10n: l10n),
                            ),
                        ],
                        if (past.isNotEmpty) ...[
                          SectionHeader(l10n.tripsPast),
                          for (final t in past)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _TripCard(trip: t, l10n: l10n, faded: true),
                            ),
                        ],
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scheme = context.scheme;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ITINERA',
                    style: TextStyle(
                      fontFamily: tokens.monoFont,
                      fontSize: 12,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w700,
                      color: tokens.accent,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'I miei viaggi',
                    style: context.texts.displaySmall?.copyWith(fontSize: 32),
                  ),
                  if (count > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        count == 1 ? '1 viaggio' : '$count viaggi',
                        style: context.texts.bodyMedium
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ),
                ],
              ),
            ),
            const SyncStatusButton(),
            IconButton(
              icon: const Icon(Icons.people_outline),
              tooltip: 'Amici',
              onPressed: () => context.push('/friends'),
            ),
            IconButton.filledTonal(
              icon: const Icon(Icons.settings_outlined),
              tooltip: AppLocalizations.of(context).settingsTitle,
              onPressed: () => context.push('/settings'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TripCard extends ConsumerWidget {
  const _TripCard({required this.trip, required this.l10n, this.faded = false});

  final Trip trip;
  final AppLocalizations l10n;
  final bool faded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final style = ItineraTheme.effectiveStyle(trip);
    final swatch = ItineraTheme.meta(style).swatch;
    final scheme = context.scheme;

    return Opacity(
      opacity: faded ? 0.72 : 1,
      child: ItineraCard(
        padding: EdgeInsets.zero,
        onTap: () => context.push('/trip/${trip.id}'),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  _CoverTile(icon: trip.tripType.icon, colors: swatch),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trip.name,
                          style: context.texts.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _subtitle(),
                          style: context.texts.bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  _TripMenu(trip: trip, l10n: l10n),
                ],
              ),
            ),
            Divider(height: 1, color: context.tokens.hairline),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Row(
                children: [
                  _StatusChip(trip: trip),
                  const Spacer(),
                  MonoTag(
                    ItineraTheme.meta(style).name.toUpperCase(),
                    icon: ItineraTheme.meta(style).icon,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _subtitle() {
    final parts = <String>[];
    if (trip.destination != null && trip.destination!.isNotEmpty) {
      parts.add(trip.destination!);
    } else if (trip.country != null && trip.country!.isNotEmpty) {
      parts.add(trip.country!);
    }
    final s = trip.startDate;
    final e = trip.endDate;
    if (s != null && e != null) {
      parts.add('${Fmt.dayMonth(s)} – ${Fmt.dayMonth(e)}');
    } else if (s != null) {
      parts.add(Fmt.date(s));
    }
    return parts.isEmpty ? trip.tripType.label : parts.join('  ·  ');
  }
}

class _CoverTile extends StatelessWidget {
  const _CoverTile({required this.icon, required this.colors});
  final IconData icon;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.first, colors.length > 1 ? colors[1] : colors.first],
        ),
      ),
      child: Icon(icon, color: Colors.white, size: 26),
    );
  }
}

/// Chip di stato con conto alla rovescia.
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.trip});
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final (label, color) = _status(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          Text(
            label,
            style: TextStyle(
              fontFamily: tokens.monoFont,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  (String, Color) _status(BuildContext context) {
    final tokens = context.tokens;
    final scheme = context.scheme;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final s = trip.startDate;
    final e = trip.endDate;
    if (s == null) return ('DA PIANIFICARE', scheme.onSurfaceVariant);
    final start = DateTime(s.year, s.month, s.day);
    final end = e == null ? start : DateTime(e.year, e.month, e.day);
    if (today.isBefore(start)) {
      final days = start.difference(today).inDays;
      if (days == 0) return ('DOMANI', tokens.accent);
      return ('TRA $days GG', tokens.accent);
    }
    if (!today.isAfter(end)) return ('IN CORSO', tokens.positive);
    return ('CONCLUSO', scheme.onSurfaceVariant);
  }
}

class _TripMenu extends ConsumerWidget {
  const _TripMenu({required this.trip, required this.l10n});
  final Trip trip;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) async {
        final repo = ref.read(tripRepositoryProvider);
        switch (value) {
          case 'edit':
            if (context.mounted) {
              unawaited(context.push('/trip/${trip.id}/edit'));
            }
          case 'duplicate':
            await repo.duplicateTrip(trip.id);
          case 'delete':
            final ok = await _confirmDelete(context);
            if (ok) await repo.deleteTrip(trip.id);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: _menuRow(Icons.edit_outlined, l10n.commonEdit),
        ),
        PopupMenuItem(
          value: 'duplicate',
          child: _menuRow(Icons.copy_all_outlined, l10n.commonDuplicate),
        ),
        PopupMenuItem(
          value: 'delete',
          child: _menuRow(Icons.delete_outline, l10n.commonDelete),
        ),
      ],
    );
  }

  Widget _menuRow(IconData icon, String label) => Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Text(label),
        ],
      );

  Future<bool> _confirmDelete(BuildContext context) async {
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
