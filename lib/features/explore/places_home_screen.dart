import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app.dart';
import '../../core/enums.dart';
import '../../core/format.dart';
import '../../data/database.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';
import '../../ui/itinera_theme.dart';
import '../../ui/widgets.dart';
import '../itinerary/itinerary_providers.dart';
import '../trip/trip_providers.dart';
import 'explore_providers.dart';
import 'explore_ui.dart';

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
    final trip = ref.watch(tripProvider(widget.tripId)).value;
    final style = trip == null
        ? TripStyle.atlante
        : ItineraTheme.effectiveStyle(trip);
    return TripThemeScope(style: style, child: _body(context));
  }

  Widget _body(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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

    return Scaffold(
      appBar: AppBar(title: Text(l10n.exploreTitle)),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: SizedBox(
          height: 56,
          child: FilledButton.icon(
            onPressed: routes == null || _creating
                ? null
                : () => _newRoute(routes.length),
            icon: const Icon(Icons.add_road),
            label: Text(l10n.routeNew),
          ),
        ),
      ),
      body: routes == null
          ? const LoadingView()
          : routes.isEmpty
          ? EmptyState(
              icon: Icons.route_outlined,
              title: l10n.placesHomeEmptyTitle,
              message: l10n.placesHomeEmptyMessage,
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              children: [
                for (final d in orderedDays) ...[
                  SectionHeader(_dayLabel(l10n, d)),
                  for (final r in byDay[d]!)
                    _RouteCard(
                      route: r,
                      stops: stopCount[r.id] ?? 0,
                      onTap: () => _open(r),
                    ),
                ],
                if (drafts.isNotEmpty) ...[
                  SectionHeader(l10n.placesHomeDrafts),
                  for (final r in drafts)
                    _RouteCard(
                      route: r,
                      stops: stopCount[r.id] ?? 0,
                      draft: true,
                      onTap: () => _open(r),
                    ),
                ],
              ],
            ),
    );
  }

  void _open(SightseeingRoute r) {
    context.push('/trip/${widget.tripId}/route/${r.id}');
  }

  String _dayLabel(AppLocalizations l10n, ItineraryDay d) {
    if (d.title?.trim().isNotEmpty == true) return d.title!;
    if (d.date != null) return Fmt.dateShort(d.date!);
    return l10n.routeDayUnplanned;
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
    final tokens = context.tokens;
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
        padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: tokens.accentSoft,
              child: Icon(
                routeModeIcon(route.travelMode),
                color: tokens.accent,
              ),
            ),
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
                    style: context.texts.bodySmall?.copyWith(
                      color: context.scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (draft) ...[
              const SizedBox(width: 8),
              InfoPill(Icons.edit_outlined, l10n.placesDraftBadge),
            ],
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: context.scheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
