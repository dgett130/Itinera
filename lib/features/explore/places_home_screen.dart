import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/database.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';
import '../../ui/itinera_theme.dart';
import '../../ui/motion.dart';
import '../../ui/widgets.dart';
import '../itinerary/itinerary_providers.dart';
import '../trip/trip_providers.dart';
import 'explore_providers.dart';
import 'explore_ui.dart';
import 'route_schedule_view.dart';

/// Pagina iniziale di "Luoghi e percorsi": i percorsi del viaggio raggruppati
/// per giorno (le bozze in "Da programmare") e un grande "Nuovo percorso"
/// sotto il pollice. Da qui si entra nel flusso a passi.
class PlacesHomeScreen extends ConsumerStatefulWidget {
  const PlacesHomeScreen({super.key, required this.tripId});
  final String tripId;

  @override
  ConsumerState<PlacesHomeScreen> createState() => _PlacesHomeScreenState();
}

class _PlacesHomeScreenState extends ConsumerState<PlacesHomeScreen> {
  bool _creating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _migrateOnce());
  }

  /// I vecchi "luoghi salvati" diventano la bozza "Luoghi salvati" (una volta
  /// per viaggio su questo dispositivo; gli id deterministici evitano doppioni
  /// tra dispositivi).
  Future<void> _migrateOnce() async {
    final db = ref.read(databaseProvider);
    final key = 'places_migrated_${widget.tripId}';
    if (await db.getPref(key) != null) return;
    if (!mounted) return;
    final name = AppLocalizations.of(context).routeSavedPlacesName;
    await ref
        .read(sightseeingRouteRepositoryProvider)
        .ensureSavedPlacesRoute(widget.tripId, name);
    await db.setPref(key, '1');
  }

  Future<void> _newRoute(int existing) async {
    if (_creating) return;
    setState(() => _creating = true);
    final l10n = AppLocalizations.of(context);
    final id = await ref
        .read(sightseeingRouteRepositoryProvider)
        .createRoute(
          tripId: widget.tripId,
          name: l10n.routeNewName(existing + 1),
        );
    if (!mounted) return;
    setState(() => _creating = false);
    unawaited(context.push('/trip/${widget.tripId}/route/$id?new=1'));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final trip = ref.watch(tripProvider(widget.tripId)).value;
    final routes = ref.watch(routesProvider(widget.tripId)).value;
    final stops = ref.watch(tripStopsProvider(widget.tripId)).value ?? const [];
    final days =
        ref.watch(itineraryDaysProvider(widget.tripId)).value ?? const [];

    final stopCount = <String, int>{};
    for (final s in stops) {
      stopCount[s.routeId] = (stopCount[s.routeId] ?? 0) + 1;
    }
    final dayById = {for (final d in days) d.id: d};

    // Raggruppa: prima i giorni (in ordine), poi le bozze.
    final byDay = <ItineraryDay, List<SightseeingRoute>>{};
    final drafts = <SightseeingRoute>[];
    for (final r in routes ?? const <SightseeingRoute>[]) {
      final day = r.dayId != null ? dayById[r.dayId] : null;
      if (day == null) {
        drafts.add(r);
      } else {
        byDay.putIfAbsent(day, () => []).add(r);
      }
    }
    final orderedDays = sortDaysForPicker(byDay.keys.toList());
    final hasRoutes = routes != null && routes.isNotEmpty;
    final note = hasRoutes
        ? [
            routes.length == 1 ? '1 percorso' : '${routes.length} percorsi',
            ?trip?.name,
          ].join(' · ')
        : null;

    var row = 0;
    Widget card(SightseeingRoute r, {bool draft = false}) => StaggerIn(
      key: ValueKey(r.id),
      index: row++,
      child: _RouteCard(
        route: r,
        stops: stopCount[r.id] ?? 0,
        draft: draft,
        onTap: () => _open(r),
      ),
    );

    return Scaffold(
      bottomNavigationBar: !hasRoutes
          ? null
          : SafeArea(
              minimum: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: SizedBox(
                height: 56,
                child: FilledButton(
                  onPressed: _creating ? null : () => _newRoute(routes.length),
                  child: Text(l10n.routeNew),
                ),
              ),
            ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ModuleHeader(
            style: ModuleStyle.luoghi,
            title: l10n.exploreTitle,
            note: note,
          ),
          Expanded(
            child: routes == null
                ? const _HomeSkeleton()
                : routes.isEmpty
                ? EmptyState(
                    icon: Icons.route,
                    color: Cartolina.corallo,
                    iconColor: Cartolina.inchiostro,
                    title: l10n.placesHomeEmptyTitle,
                    message: l10n.placesHomeEmptyMessage,
                    action: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        onPressed: _creating
                            ? null
                            : () => _newRoute(routes.length),
                        child: Text(l10n.routeNew),
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    children: [
                      for (final d in orderedDays) ...[
                        SectionHeader(
                          _dayLabel(l10n, d),
                          padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                        ),
                        for (final r in byDay[d]!) card(r),
                      ],
                      if (drafts.isNotEmpty) ...[
                        SectionHeader(
                          l10n.placesHomeDrafts,
                          padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                        ),
                        for (final r in drafts) card(r, draft: true),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  void _open(SightseeingRoute r) {
    context.push('/trip/${widget.tripId}/route/${r.id}');
  }

  String _dayLabel(AppLocalizations l10n, ItineraryDay d) {
    if (d.title?.trim().isNotEmpty == true) return d.title!;
    if (d.date != null) return routeDayLong(d.date!);
    return l10n.routeDayUnplanned;
  }
}

/// Segnaposto che respirano mentre arrivano i percorsi.
class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      children: const [
        Skeleton(width: 180, height: 20),
        SizedBox(height: 14),
        Skeleton(height: 72, radius: 20),
        SizedBox(height: 10),
        Skeleton(height: 72, radius: 20),
        SizedBox(height: 26),
        Skeleton(width: 140, height: 20),
        SizedBox(height: 14),
        Skeleton(height: 72, radius: 20),
      ],
    );
  }
}

class _RouteCard extends StatelessWidget {
  const _RouteCard({
    required this.route,
    required this.stops,
    required this.onTap,
    this.draft = false,
  });

  final SightseeingRoute route;
  final int stops;
  final VoidCallback onTap;
  final bool draft;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final details = [
      l10n.routeStopsCount(stops),
      if (stops >= 2 &&
          route.distanceMeters != null &&
          route.distanceMeters! > 0)
        formatDistance(l10n, route.distanceMeters!),
      if (stops >= 2 &&
          route.durationSeconds != null &&
          route.durationSeconds! > 0)
        formatDuration(l10n, route.durationSeconds!),
    ].join(' · ');
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ItineraCard(
        onTap: onTap,
        padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
        child: Row(
          children: [
            RouteModeTile(route.travelMode),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    route.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.texts.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    details,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.texts.bodySmall?.copyWith(
                      color: context.scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (draft) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: Cartolina.sole,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  l10n.placesDraftBadge,
                  style: context.texts.labelSmall?.copyWith(
                    color: Cartolina.inchiostro,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: context.scheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
