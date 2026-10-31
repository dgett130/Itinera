import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../core/format.dart';
import '../../data/database.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/itinera_theme.dart';
import '../../ui/widgets.dart';
import '../itinerary/itinerary_providers.dart';
import '../trip/trip_providers.dart';
import 'explore_providers.dart';
import 'explore_ui.dart';
import 'geo_codec.dart';
import 'place_sheet.dart';
import 'route_schedule_view.dart';
import 'route_warnings.dart';
import 'warning_settings_provider.dart';

/// Riepilogo in sola lettura di un percorso, aperto dall'evento nella
/// tabella di marcia: mappa, scaletta e schede dei luoghi. "Modifica" rientra
/// nel flusso a passi.
class RouteSummaryScreen extends ConsumerWidget {
  const RouteSummaryScreen({
    super.key,
    required this.tripId,
    required this.routeId,
  });

  final String tripId;
  final String routeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final trip = ref.watch(tripProvider(tripId)).value;
    final routeAsync = ref.watch(routeByIdProvider(routeId));
    final route = routeAsync.value;
    if (trip == null || (route == null && routeAsync.isLoading)) {
      return const RouteLoadingView();
    }
    if (route == null) {
      return Scaffold(
        appBar: AppBar(),
        body: EmptyState(icon: Icons.search_off, title: l10n.commonEmpty),
      );
    }
    final stops = ref.watch(routeStopsProvider(routeId)).value ?? const [];
    final locById = {
      for (final l
          in ref.watch(savedLocationsProvider(tripId)).value ??
              const <Location>[])
        l.id: l,
    };
    final refs = [
      for (final s in stops)
        if (locById[s.locationId] case final l?) (s, l),
    ];
    final days = ref.watch(itineraryDaysProvider(tripId)).value ?? const [];
    final day = days.where((d) => d.id == route.dayId).firstOrNull;
    final schedule = scheduleForRefs(route, refs);
    final warnings = schedule == null
        ? const <RouteWarning>[]
        : warningsForRefs(
            route,
            refs,
            schedule,
            ref.watch(warningSettingsProvider),
            day?.date?.weekday,
          );
    final dayWarnings = [
      for (final w in warnings)
        if (w.stopIndex == null) w,
    ];

    void openPlace(SightseeingRouteStop s, Location loc) => showPlaceSheet(
      context,
      place: PlaceInfo.fromLocation(loc, visitMinutes: s.visitMinutes),
    );
    final when = [
      if (day != null)
        day.title?.trim().isNotEmpty == true
            ? day.title!
            : day.date != null
            ? routeDayLong(day.date!)
            : l10n.routeDayUnplanned,
      if (route.startMinutes != null) Fmt.timeOfDayMinutes(route.startMinutes),
      l10n.routeStopsCount(refs.length),
      routeModeLabel(l10n, route.travelMode).toLowerCase(),
    ].join(' · ');
    return Scaffold(
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: SizedBox(
          height: 56,
          child: FilledButton(
            onPressed: () => context.push('/trip/$tripId/route/$routeId'),
            child: Text(l10n.commonEdit),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PlainHeader(title: route.name, note: when, size: 30),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                SizedBox(
                  height: 260,
                  child: _SummaryMap(
                    trip: trip,
                    route: route,
                    refs: refs,
                    onTapStop: openPlace,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SectionHeader(
                        l10n.planScheduleTitle,
                        padding: const EdgeInsets.fromLTRB(0, 18, 0, 10),
                      ),
                      RouteScheduleList(
                        route: route,
                        refs: refs,
                        schedule: schedule,
                        onTapStop: openPlace,
                        warnings: warnings,
                      ),
                      if (dayWarnings.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        RouteWarningsCard(warnings: dayWarnings),
                        const SizedBox(height: 8),
                      ],
                      if (schedule != null) ...[
                        const SizedBox(height: 6),
                        RouteScheduleFooter(route: route, schedule: schedule),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryMap extends StatefulWidget {
  const _SummaryMap({
    required this.trip,
    required this.route,
    required this.refs,
    required this.onTapStop,
  });

  final Trip trip;
  final SightseeingRoute route;
  final List<(SightseeingRouteStop, Location)> refs;
  final void Function(SightseeingRouteStop stop, Location loc) onTapStop;

  @override
  State<_SummaryMap> createState() => _SummaryMapState();
}

class _SummaryMapState extends State<_SummaryMap> {
  final _line = GlobalKey<RouteLineState>();
  final _seenPins = <String>{};

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;
    final pts = [
      for (final (i, r) in widget.refs.indexed)
        if (r.$2.latitude != null && r.$2.longitude != null)
          (i, r, LatLng(r.$2.latitude!, r.$2.longitude!)),
    ];
    final geometry = decodeGeometry(widget.route.geometry);
    final line = geometry.length >= 2 ? geometry : [for (final p in pts) p.$3];
    final center = pts.isNotEmpty
        ? pts.first.$3
        : trip.destinationLat != null && trip.destinationLng != null
        ? LatLng(trip.destinationLat!, trip.destinationLng!)
        : const LatLng(41.9028, 12.4964);
    return FlutterMap(
      // Le tappe arrivano dopo il percorso: l'inquadratura iniziale va rifatta.
      key: ValueKey(pts.length),
      options: MapOptions(
        initialCenter: center,
        initialZoom: pts.isEmpty ? 12 : 15,
        initialCameraFit: pts.length >= 2
            ? CameraFit.coordinates(
                coordinates: [for (final p in pts) p.$3],
                padding: const EdgeInsets.all(40),
                maxZoom: 17,
              )
            : null,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
        onPointerDown: (_, _) => _line.currentState?.finish(),
      ),
      children: [
        TileLayer(
          tileBuilder: Theme.of(context).brightness == Brightness.dark
              ? darkModeTileBuilder
              : null,
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'org.itinera.app',
        ),
        if (line.length >= 2)
          RouteLine(key: _line, points: line, color: context.tokens.accent),
        MarkerLayer(
          markers: [
            for (final (i, r, p) in pts)
              Marker(
                point: p,
                width: 40,
                height: 40,
                child: PinDrop(
                  key: ValueKey(r.$1.id),
                  id: r.$1.id,
                  seen: _seenPins,
                  index: i,
                  child: RouteStopMarker(
                    number: i + 1,
                    onTap: () => widget.onTapStop(r.$1, r.$2),
                  ),
                ),
              ),
          ],
        ),
        const RichAttributionWidget(
          alignment: AttributionAlignment.bottomLeft,
          attributions: [TextSourceAttribution('OpenStreetMap contributors')],
        ),
      ],
    );
  }
}
