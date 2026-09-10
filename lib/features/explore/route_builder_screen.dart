import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../core/enums.dart';
import '../../core/format.dart';
import '../../data/database.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/itinera_theme.dart';
import '../../ui/widgets.dart';
import '../itinerary/itinerary_providers.dart';
import 'explore_providers.dart';
import 'explore_ui.dart';
import 'geo_codec.dart';
import 'route_math.dart';

/// Costruttore di un percorso di visita: riordino drag&drop, mezzo, partenza/
/// ritorno, ottimizzazione, polyline e "Aggiungi all'itinerario".
class RouteBuilderScreen extends ConsumerStatefulWidget {
  const RouteBuilderScreen({
    super.key,
    required this.tripId,
    required this.routeId,
  });
  final String tripId;
  final String routeId;

  @override
  ConsumerState<RouteBuilderScreen> createState() => _RouteBuilderScreenState();
}

class _RouteBuilderScreenState extends ConsumerState<RouteBuilderScreen> {
  final _map = MapController();
  bool _computing = false;

  Map<String, Location> _locMap(List<Location> saved) => {
    for (final l in saved) l.id: l,
  };

  Future<void> _recompute() async {
    final repo = ref.read(sightseeingRouteRepositoryProvider);
    final route = await repo.getRoute(widget.routeId);
    if (route == null) return;
    final stops = await repo.stopsFor(widget.routeId);
    final saved =
        ref.read(savedLocationsProvider(widget.tripId)).value ?? const [];
    final locById = _locMap(saved);
    final pts = <LatLng>[];
    for (final s in stops) {
      final l = locById[s.locationId];
      if (l != null && l.latitude != null && l.longitude != null) {
        pts.add(LatLng(l.latitude!, l.longitude!));
      }
    }
    if (pts.length < 2) {
      await repo.saveComputation(
        widget.routeId,
        distanceMeters: 0,
        durationSeconds: 0,
        geometryJson: encodeGeometry(pts),
        source: DistanceSource.straightLine,
      );
      return;
    }
    if (mounted) setState(() => _computing = true);
    final res = await ref
        .read(routePlannerProvider)
        .plan(pts, route.travelMode, returnToStart: route.returnToStart);
    await repo.saveComputation(
      widget.routeId,
      distanceMeters: res.distanceMeters.round(),
      durationSeconds: res.durationSeconds.round(),
      geometryJson: encodeGeometry(res.geometry),
      source: res.source,
    );
    if (mounted) setState(() => _computing = false);
  }

  Future<void> _optimize() async {
    final repo = ref.read(sightseeingRouteRepositoryProvider);
    final route = await repo.getRoute(widget.routeId);
    if (route == null) return;
    final stops = await repo.stopsFor(widget.routeId);
    final saved =
        ref.read(savedLocationsProvider(widget.tripId)).value ?? const [];
    final locById = _locMap(saved);
    final coordStops = <SightseeingRouteStop>[];
    final pts = <LatLng>[];
    for (final s in stops) {
      final l = locById[s.locationId];
      if (l != null && l.latitude != null && l.longitude != null) {
        coordStops.add(s);
        pts.add(LatLng(l.latitude!, l.longitude!));
      }
    }
    if (pts.length < 2) return;
    final opt = optimizeRouteOrder(
      points: pts,
      fixedStart: route.fixedStart,
      returnToStart: route.returnToStart,
    );
    final ordered = [for (final i in opt.order) coordStops[i].id];
    final noCoords = stops
        .where((s) {
          final l = locById[s.locationId];
          return !(l != null && l.latitude != null && l.longitude != null);
        })
        .map((s) => s.id);
    await repo.applyOptimizedOrder(widget.routeId, [...ordered, ...noCoords]);
    await _recompute();
  }

  Future<void> _restore() async {
    await ref
        .read(sightseeingRouteRepositoryProvider)
        .restoreManualOrder(widget.routeId);
    await _recompute();
  }

  Future<void> _rename(SightseeingRoute route) async {
    final l10n = AppLocalizations.of(context);
    final ctrl = TextEditingController(text: route.name);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.routeRename),
        content: TextField(controller: ctrl, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: Text(l10n.commonSave),
          ),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) {
      await ref
          .read(sightseeingRouteRepositoryProvider)
          .renameRoute(widget.routeId, name);
    }
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.routeDelete),
        content: Text(l10n.routeDeleteConfirm),
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
    if (ok == true) {
      await ref
          .read(sightseeingRouteRepositoryProvider)
          .deleteRoute(widget.routeId);
      if (mounted) context.pop();
    }
  }

  Future<void> _addStop(
    List<Location> saved,
    List<SightseeingRouteStop> stops,
  ) async {
    final l10n = AppLocalizations.of(context);
    final inRoute = stops.map((s) => s.locationId).toSet();
    final candidates = saved.where((l) => !inRoute.contains(l.id)).toList();
    if (candidates.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.routeNoPlaceLeft)));
      return;
    }
    final chosen = await showModalBottomSheet<Location>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                l10n.routePickPlace,
                style: context.texts.titleMedium,
              ),
            ),
            for (final l in candidates)
              ListTile(
                leading: Icon(
                  l.poiCategory != null
                      ? poiCategoryIcon(l.poiCategory!)
                      : Icons.place,
                  color: context.tokens.accent,
                ),
                title: Text(l.label),
                subtitle: l.address != null ? Text(l.address!) : null,
                onTap: () => Navigator.pop(context, l),
              ),
          ],
        ),
      ),
    );
    if (chosen != null) {
      await ref
          .read(sightseeingRouteRepositoryProvider)
          .addStop(widget.routeId, widget.tripId, chosen.id);
      await _recompute();
    }
  }

  Future<void> _addToItinerary() async {
    final l10n = AppLocalizations.of(context);
    final itineraryRepo = ref.read(itineraryRepositoryProvider);
    await itineraryRepo.ensureDays(widget.tripId);
    // Query diretta (non lo stream provider) per evitare letture stale del
    // bucket "Non programmato" appena creato da ensureDays.
    final days = await itineraryRepo.getDays(widget.tripId);
    if (!mounted) return;
    final day = await showModalBottomSheet<ItineraryDay>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(l10n.routePickDay, style: context.texts.titleMedium),
            ),
            for (final d in days)
              ListTile(
                leading: const Icon(Icons.event),
                title: Text(
                  d.title?.isNotEmpty == true
                      ? d.title!
                      : (d.date != null
                            ? Fmt.date(d.date!)
                            : l10n.routeDayUnplanned),
                ),
                onTap: () => Navigator.pop(context, d),
              ),
          ],
        ),
      ),
    );
    if (day == null) return;
    final count = await ref
        .read(sightseeingRouteRepositoryProvider)
        .addToItinerary(widget.routeId, day.id, widget.tripId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.routeAddedToItinerary(count))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final routeAsync = ref.watch(routeByIdProvider(widget.routeId));
    final stops =
        ref.watch(routeStopsProvider(widget.routeId)).value ?? const [];
    final saved =
        ref.watch(savedLocationsProvider(widget.tripId)).value ?? const [];
    final locById = _locMap(saved);

    return routeAsync.when(
      loading: () => const Scaffold(body: LoadingView()),
      error: (e, _) => Scaffold(body: ErrorView(e)),
      data: (route) {
        if (route == null) {
          return Scaffold(
            appBar: AppBar(),
            body: EmptyState(icon: Icons.search_off, title: l10n.commonEmpty),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(route.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: l10n.routeRename,
                onPressed: () => _rename(route),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: l10n.routeDelete,
                onPressed: _delete,
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
            children: [
              _mapCard(context, route, stops, locById),
              const SizedBox(height: 12),
              _stats(context, l10n, route),
              const SizedBox(height: 12),
              _modeSelector(context, l10n, route),
              const SizedBox(height: 4),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.routeFixedStart),
                value: route.fixedStart,
                onChanged: (v) async {
                  await ref
                      .read(sightseeingRouteRepositoryProvider)
                      .setFixedStart(widget.routeId, v);
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.routeReturnToStart),
                value: route.returnToStart,
                onChanged: (v) async {
                  await ref
                      .read(sightseeingRouteRepositoryProvider)
                      .setReturnToStart(widget.routeId, v);
                  await _recompute();
                },
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: stops.length >= 2 ? _optimize : null,
                    icon: const Icon(Icons.auto_fix_high, size: 18),
                    label: Text(l10n.routeOptimize),
                  ),
                  if (route.optimized && route.lastManualOrder != null)
                    OutlinedButton.icon(
                      onPressed: _restore,
                      icon: const Icon(Icons.undo, size: 18),
                      label: Text(l10n.routeRestoreManual),
                    ),
                  OutlinedButton.icon(
                    onPressed: () => _recompute(),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: Text(l10n.routeRecalculate),
                  ),
                ],
              ),
              if (route.optimized)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 16,
                        color: context.tokens.accent,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        l10n.routeOptimizedBadge,
                        style: context.texts.bodySmall?.copyWith(
                          color: context.tokens.accent,
                        ),
                      ),
                    ],
                  ),
                ),
              SectionHeader(l10n.routeStops),
              if (stops.length < 2)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    l10n.routeMinStops,
                    style: context.texts.bodySmall?.copyWith(
                      color: context.scheme.error,
                    ),
                  ),
                ),
              _stopsList(context, l10n, route, stops, locById),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => _addStop(saved, stops),
                icon: const Icon(Icons.add_location_alt_outlined),
                label: Text(l10n.routeAddStop),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: stops.isEmpty ? null : _addToItinerary,
                icon: const Icon(Icons.playlist_add),
                label: Text(l10n.routeAddToItinerary),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _mapCard(
    BuildContext context,
    SightseeingRoute route,
    List<SightseeingRouteStop> stops,
    Map<String, Location> locById,
  ) {
    final stopPts = <LatLng>[];
    for (final s in stops) {
      final l = locById[s.locationId];
      if (l != null && l.latitude != null && l.longitude != null) {
        stopPts.add(LatLng(l.latitude!, l.longitude!));
      }
    }
    final geometry = decodeGeometry(route.geometry);
    final line = geometry.length >= 2 ? geometry : stopPts;
    final center = stopPts.isNotEmpty
        ? stopPts.first
        : const LatLng(41.9028, 12.4964);
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 260,
        child: FlutterMap(
          mapController: _map,
          options: MapOptions(
            initialCenter: center,
            initialZoom: stopPts.isNotEmpty ? 13 : 5,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'org.itinera.app',
            ),
            if (line.length >= 2)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: line,
                    strokeWidth: 4,
                    color: context.tokens.accent,
                  ),
                ],
              ),
            MarkerLayer(
              markers: [
                for (var i = 0; i < stopPts.length; i++)
                  Marker(
                    point: stopPts[i],
                    width: 30,
                    height: 30,
                    child: CircleAvatar(
                      backgroundColor: context.tokens.accent,
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const RichAttributionWidget(
              attributions: [
                TextSourceAttribution('OpenStreetMap contributors'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stats(
    BuildContext context,
    AppLocalizations l10n,
    SightseeingRoute route,
  ) {
    final source = route.calcSource == DistanceSource.onlineRouting
        ? l10n.routeSourceOnline
        : l10n.routeSourceEstimate;
    return ItineraCard(
      child: Row(
        children: [
          Expanded(
            child: _statCol(
              context,
              l10n.routeDistance,
              route.distanceMeters != null
                  ? formatDistance(l10n, route.distanceMeters!)
                  : '—',
            ),
          ),
          Container(width: 1, height: 34, color: context.tokens.hairline),
          Expanded(
            child: _statCol(
              context,
              l10n.routeDuration,
              route.durationSeconds != null
                  ? formatDuration(l10n, route.durationSeconds!)
                  : '—',
            ),
          ),
          Container(width: 1, height: 34, color: context.tokens.hairline),
          Expanded(
            child: _statCol(
              context,
              '',
              _computing ? l10n.routeComputing : source,
              small: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCol(
    BuildContext context,
    String label,
    String value, {
    bool small = false,
  }) {
    return Column(
      children: [
        if (label.isNotEmpty)
          Text(
            label,
            style: context.texts.labelSmall?.copyWith(
              color: context.scheme.onSurfaceVariant,
            ),
          ),
        if (label.isNotEmpty) const SizedBox(height: 4),
        Text(
          value,
          textAlign: TextAlign.center,
          style: small ? context.texts.bodySmall : context.texts.titleMedium,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _modeSelector(
    BuildContext context,
    AppLocalizations l10n,
    SightseeingRoute route,
  ) {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<RouteTravelMode>(
        segments: [
          for (final m in RouteTravelMode.values)
            ButtonSegment(
              value: m,
              icon: Icon(routeModeIcon(m)),
              label: Text(routeModeLabel(l10n, m)),
            ),
        ],
        selected: {route.travelMode},
        showSelectedIcon: false,
        onSelectionChanged: (s) async {
          await ref
              .read(sightseeingRouteRepositoryProvider)
              .setMode(widget.routeId, s.first);
          await _recompute();
        },
      ),
    );
  }

  Widget _stopsList(
    BuildContext context,
    AppLocalizations l10n,
    SightseeingRoute route,
    List<SightseeingRouteStop> stops,
    Map<String, Location> locById,
  ) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stops.length,
      onReorder: (oldIndex, newIndex) async {
        if (newIndex > oldIndex) newIndex -= 1;
        final ids = stops.map((s) => s.id).toList();
        final moved = ids.removeAt(oldIndex);
        ids.insert(newIndex, moved);
        await ref
            .read(sightseeingRouteRepositoryProvider)
            .reorder(widget.routeId, ids);
        await _recompute();
      },
      itemBuilder: (context, i) {
        final s = stops[i];
        final l = locById[s.locationId];
        final title = l?.label ?? '—';
        final hasCoords = l?.latitude != null && l?.longitude != null;
        return Padding(
          key: ValueKey(s.id),
          padding: const EdgeInsets.only(bottom: 8),
          child: ItineraCard(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: context.tokens.accentSoft,
                child: Text(
                  '${i + 1}',
                  style: TextStyle(
                    color: context.tokens.accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: !hasCoords
                  ? Text(
                      l10n.exploreCatOther,
                      style: TextStyle(color: context.scheme.error),
                    )
                  : (l?.address != null
                        ? Text(
                            l!.address!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : null),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () async {
                      await ref
                          .read(sightseeingRouteRepositoryProvider)
                          .removeStop(s.id);
                      await _recompute();
                    },
                  ),
                  ReorderableDragStartListener(
                    index: i,
                    child: const Icon(Icons.drag_handle),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
