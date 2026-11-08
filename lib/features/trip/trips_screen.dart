import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/database.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/itinera_theme.dart';
import '../../ui/motion.dart';
import '../../ui/poster_sky.dart';
import '../../ui/posters.dart';
import '../../ui/widgets.dart';
import '../notifications/notifications_providers.dart';
import '../packing/packing_providers.dart';
import '../sync/sync_status_button.dart';
import '../weather/weather_providers.dart';
import 'trip_providers.dart';
import 'trip_status.dart';

/// Home: i viaggi in arrivo come grandi poster, i passati in piccolo.
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
          loading: () => const _HomeSkeleton(),
          error: (e, _) => ErrorView(e),
          data: (trips) {
            final upcoming = [
              for (final t in trips)
                if (!tripIsPast(t)) t,
            ];
            final past = [
              for (final t in trips)
                if (tripIsPast(t)) t,
            ];
            return CustomScrollView(
              slivers: [
                const _HomeHeader(),
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
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
                    sliver: SliverList.list(
                      children: [
                        for (final (i, t) in upcoming.indexed)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: StaggerIn(
                              index: i,
                              child: _BigPoster(trip: t, l10n: l10n),
                            ),
                          ),
                        if (past.isNotEmpty) ...[
                          SectionHeader(
                            l10n.tripsPast,
                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 12),
                          ),
                          for (var i = 0; i < past.length; i += 2)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _SmallPoster(
                                      trip: past[i],
                                      l10n: l10n,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: i + 1 < past.length
                                        ? _SmallPoster(
                                            trip: past[i + 1],
                                            l10n: l10n,
                                          )
                                        : const SizedBox.shrink(),
                                  ),
                                ],
                              ),
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

/// Segnaposto della home mentre arrivano i viaggi.
class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        const _HomeHeader(),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
          sliver: SliverList.list(
            children: const [
              AspectRatio(
                aspectRatio: 372 / 340,
                child: Skeleton(height: double.infinity, radius: 24),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: Skeleton(height: 216, radius: 20)),
                  SizedBox(width: 12),
                  Expanded(child: Skeleton(height: 216, radius: 20)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 8, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Itinera',
                    style: TextStyle(
                      fontFamily: tokens.displayFont,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: tokens.accent,
                    ),
                  ),
                ),
                const SyncStatusButton(),
                const _NotificationsBell(),
                IconButton(
                  icon: const Icon(Icons.people_outline),
                  tooltip: 'Amici',
                  onPressed: () => context.push('/friends'),
                ),
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  tooltip: AppLocalizations.of(context).settingsTitle,
                  onPressed: () => context.push('/settings'),
                ),
              ],
            ),
            Text(
              'I miei viaggi',
              style: context.texts.displaySmall?.copyWith(
                fontSize: 38,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Campanellino notifiche con badge del numero di non lette.
class _NotificationsBell extends ConsumerWidget {
  const _NotificationsBell();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadCountProvider);
    // Il badge avvolge l'icona (non l'IconButton) cosi' resta attaccato alla
    // campanella invece che nell'angolo dell'area di tocco da 48px.
    return IconButton(
      icon: unread == 0
          ? const Icon(Icons.notifications_none_outlined)
          : Badge.count(
              count: unread,
              child: const Icon(Icons.notifications_none_outlined),
            ),
      tooltip: AppLocalizations.of(context).notificationsTitle,
      onPressed: () => context.push('/notifications'),
    );
  }
}

/// Poster grande di un viaggio in arrivo o in corso.
class _BigPoster extends ConsumerWidget {
  const _BigPoster({required this.trip, required this.l10n});

  final Trip trip;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sky = ref.watch(posterSkyProvider(trip.id));
    final c = sky?.colorsFor(trip.tripType) ?? trip.tripType.posterColors;
    final items = ref.watch(packingItemsProvider(trip.id)).value ?? const [];
    final packed = items
        .where((i) => i.packedCount >= i.quantity && i.quantity > 0)
        .length;
    final place = tripPlaceLine(trip);
    final titleStyle = context.texts.displaySmall?.copyWith(
      color: c.foreground,
      height: 1.02,
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Material(
        color: c.background,
        child: InkWell(
          onTap: () => context.push('/trip/${trip.id}'),
          child: AspectRatio(
            aspectRatio: 372 / 340,
            child: LayoutBuilder(
              builder: (context, box) => Stack(
                children: [
                  Positioned.fill(
                    child: PosterHero(
                      tripId: trip.id,
                      child: PosterArt(
                        type: trip.tripType,
                        alive: true,
                        sky: sky,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 22,
                    top: 18,
                    right: 44,
                    child: Text(
                      trip.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: titleStyle?.copyWith(
                        fontSize: box.maxWidth * 0.12,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 2,
                    child: _TripMenu(
                      trip: trip,
                      l10n: l10n,
                      color: c.foreground,
                    ),
                  ),
                  Positioned(
                    left: 22,
                    right: 22,
                    bottom: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (place.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              place,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.texts.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: c.lowerForeground,
                              ),
                            ),
                          ),
                        Row(
                          children: [
                            PosterPill(tripStatusLabel(trip), color: c.pill),
                            const SizedBox(width: 12),
                            Expanded(
                              child: items.isEmpty
                                  ? const SizedBox.shrink()
                                  : Text(
                                      'valigia $packed/${items.length}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: context.texts.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: c.lowerForeground,
                                      ),
                                    ),
                            ),
                            if (sky?.weather != null &&
                                sky?.temperature != null)
                              _WeatherChip(sky: sky!, color: c.lowerForeground),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Poster piccolo di un viaggio passato.
class _SmallPoster extends StatelessWidget {
  const _SmallPoster({required this.trip, required this.l10n});

  final Trip trip;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final c = trip.tripType.posterColors;
    final place = trip.destination?.isNotEmpty == true
        ? trip.destination!
        : (trip.country ?? '');
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Material(
        color: c.background,
        child: InkWell(
          onTap: () => context.push('/trip/${trip.id}'),
          child: AspectRatio(
            aspectRatio: 180 / 216,
            child: Stack(
              children: [
                Positioned.fill(
                  child: PosterHero(
                    tripId: trip.id,
                    child: PosterArt(type: trip.tripType),
                  ),
                ),
                Positioned(
                  left: 14,
                  top: 12,
                  right: 30,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.name,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: context.texts.titleLarge?.copyWith(
                          fontSize: 21,
                          height: 1.08,
                          color: c.foreground,
                        ),
                      ),
                      if (place.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            place,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.texts.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: c.foreground,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Positioned(
                  top: 2,
                  right: -6,
                  child: _TripMenu(trip: trip, l10n: l10n, color: c.foreground),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TripMenu extends ConsumerWidget {
  const _TripMenu({required this.trip, required this.l10n, this.color});
  final Trip trip;
  final AppLocalizations l10n;
  final Color? color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: color),
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
    children: [Icon(icon, size: 20), const SizedBox(width: 12), Text(label)],
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

/// Il meteo sul poster: icona e temperatura su un velo chiaro o scuro.
class _WeatherChip extends StatelessWidget {
  const _WeatherChip({required this.sky, required this.color});

  final PosterSky sky;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final light = color.computeLuminance() > 0.5;
    return TweenAnimationBuilder<double>(
      // Compare con lo scatto delle spunte quando arriva il meteo.
      tween: Tween(begin: 0, end: 1),
      duration: Motion.of(context, Motion.standard),
      curve: Motion.pop,
      builder: (context, t, child) => Transform.scale(scale: t, child: child),
      child: Container(
        padding: const EdgeInsets.fromLTRB(9, 6, 12, 6),
        decoration: ShapeDecoration(
          color: (light ? Colors.white : Cartolina.inchiostro).withValues(
            alpha: light ? 0.18 : 0.12,
          ),
          shape: const StadiumBorder(),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(sky.icon, size: 18, color: color),
            const SizedBox(width: 5),
            Text(
              '${sky.temperature}°',
              style: TextStyle(
                fontFamily: context.tokens.displayFont,
                fontWeight: FontWeight.w700,
                fontSize: 15,
                height: 1.2,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
