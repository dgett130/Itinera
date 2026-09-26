import 'dart:async';

import 'package:collection/collection.dart';
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
import '../places/geocoding_service.dart';
import '../places/place_autocomplete_field.dart';
import '../trip/trip_providers.dart';
import 'explore_providers.dart';
import 'explore_repository.dart';
import 'explore_ui.dart';
import 'place_sheet.dart';
import 'poi_discovery_service.dart';
import 'poi_parser.dart';

/// Schermata "Luoghi e percorsi": scopri POI reali vicino alla destinazione,
/// filtrali, salvali e passa alla costruzione di un percorso.
class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key, required this.tripId});
  final String tripId;

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final _map = MapController();
  final _destCtrl = TextEditingController();

  static const _radiusChoicesKm = [2.0, 5.0, 10.0, 25.0, 50.0];

  LatLng? _center;
  double _radiusKm = 5;
  final Set<PoiCategory> _filters = {};
  static const _pageSize = 12;
  int _visibleCount = _pageSize;
  bool _loading = false;
  Object? _error;
  PoiSearchOutcome? _outcome;
  bool _inited = false;

  @override
  void dispose() {
    _destCtrl.dispose();
    super.dispose();
  }

  void _maybeInit(Trip trip) {
    if (_inited) return;
    _inited = true;
    _destCtrl.text = trip.destination ?? '';
    final lat = trip.destinationLat;
    final lng = trip.destinationLng;
    if (lat != null && lng != null) {
      _center = LatLng(lat, lng);
      WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_search()));
    }
  }

  Future<void> _search({bool force = false}) async {
    final c = _center;
    if (c == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final outcome = await ref
          .read(exploreRepositoryProvider)
          .discover(
            lat: c.latitude,
            lng: c.longitude,
            radiusMeters: _radiusKm * 1000,
            forceRefresh: force,
          );
      if (!mounted) return;
      setState(() {
        _outcome = outcome;
        _loading = false;
        _visibleCount = _pageSize;
      });
    } on PoiDiscoveryException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  void _useMapCenter() {
    _center = _map.camera.center;
    unawaited(_search(force: true));
  }

  void _onDestinationSelected(PlaceResult place) {
    _center = LatLng(place.latitude, place.longitude);
    _map.move(_center!, 13);
    unawaited(_search(force: true));
  }

  Future<void> _toggle(PoiSuggestion p, List<Location> saved) async {
    final l10n = AppLocalizations.of(context);
    final repo = ref.read(exploreRepositoryProvider);
    final match = saved.firstWhereOrNull(
      (l) => l.externalProvider == p.provider && l.externalId == p.externalId,
    );
    if (match != null) {
      final ok = await repo.deleteSavedLocation(match.id);
      if (!ok && mounted) _snack(l10n.exploreInUse);
    } else {
      await repo.savePoi(widget.tripId, p);
    }
  }

  /// Distanza dal centro di ricerca, leggibile ("350 m dal centro").
  String? _distanceLabel(double? lat, double? lng) {
    final c = _center;
    if (c == null || lat == null || lng == null) return null;
    final l10n = AppLocalizations.of(context);
    final m = const Distance().as(LengthUnit.Meter, c, LatLng(lat, lng));
    return '${formatDistance(l10n, m)} ${l10n.exploreFromCenter}';
  }

  /// Scheda di un suggerimento: se è già salvato mostra il luogo salvato
  /// (con note), altrimenti propone di salvarlo.
  Future<void> _openSuggestion(PoiSuggestion p, List<Location> saved) async {
    final match = saved.firstWhereOrNull(
      (l) => l.externalProvider == p.provider && l.externalId == p.externalId,
    );
    if (match != null) return _openLocation(match);
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    await showPlaceSheet(
      context,
      place: PlaceInfo.fromSuggestion(p),
      distanceLabel: _distanceLabel(p.lat, p.lng),
      action: PlaceSheetAction(
        label: l10n.placeSave,
        icon: Icons.bookmark_add_outlined,
        onPressed: () async {
          await ref.read(exploreRepositoryProvider).savePoi(widget.tripId, p);
          messenger.showSnackBar(SnackBar(content: Text(l10n.placeSavedToast)));
        },
      ),
    );
  }

  /// Scheda di un luogo salvato (note modificabili, azione "Rimuovi").
  Future<void> _openLocation(Location l) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    await showPlaceSheet(
      context,
      place: PlaceInfo.fromLocation(l),
      distanceLabel: _distanceLabel(l.latitude, l.longitude),
      action: PlaceSheetAction(
        label: l10n.placeUnsave,
        icon: Icons.bookmark_remove_outlined,
        destructive: true,
        onPressed: () async {
          final ok = await ref
              .read(exploreRepositoryProvider)
              .deleteSavedLocation(l.id);
          messenger.showSnackBar(
            SnackBar(
              content: Text(ok ? l10n.placeRemovedToast : l10n.exploreInUse),
            ),
          );
        },
      ),
    );
  }

  Future<void> _newRoute() async {
    final l10n = AppLocalizations.of(context);
    final saved =
        ref.read(savedLocationsProvider(widget.tripId)).value ?? const [];
    final ids = saved
        .where((l) => l.latitude != null && l.longitude != null)
        .map((l) => l.id)
        .toList();
    final routeId = await ref
        .read(sightseeingRouteRepositoryProvider)
        .createRoute(
          tripId: widget.tripId,
          name: l10n.routeDefaultName,
          locationIds: ids,
        );
    if (mounted) {
      unawaited(context.push('/trip/${widget.tripId}/route/$routeId'));
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tripAsync = ref.watch(tripProvider(widget.tripId));
    return tripAsync.when(
      loading: () => const Scaffold(body: LoadingView()),
      error: (e, _) => Scaffold(body: ErrorView(e)),
      data: (trip) {
        if (trip == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.exploreTitle)),
            body: EmptyState(icon: Icons.search_off, title: l10n.commonEmpty),
          );
        }
        _maybeInit(trip);
        return _buildScaffold(context, l10n, trip);
      },
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    AppLocalizations l10n,
    Trip trip,
  ) {
    final saved =
        ref.watch(savedLocationsProvider(widget.tripId)).value ?? const [];
    final routes = ref.watch(routesProvider(widget.tripId)).value ?? const [];
    final savedWithCoords = saved
        .where((l) => l.latitude != null && l.longitude != null)
        .toList();
    final pois = (_outcome?.pois ?? const <PoiSuggestion>[])
        .where((p) => _filters.isEmpty || _filters.contains(p.category))
        .toList();
    final savedKeys = {
      for (final l in saved)
        if (l.externalId != null) '${l.externalProvider}/${l.externalId}',
    };

    return Scaffold(
      appBar: AppBar(title: Text(l10n.exploreTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          _searchControls(context, l10n),
          const SizedBox(height: 12),
          _mapCard(context, l10n, pois, savedWithCoords, savedKeys, saved),
          const SizedBox(height: 8),
          Text(
            l10n.exploreAttribution,
            style: context.texts.bodySmall?.copyWith(
              color: context.scheme.onSurfaceVariant,
            ),
          ),
          _filterChips(context, l10n),
          _results(context, l10n, pois, savedKeys, saved),
          SectionHeader(l10n.exploreSaved),
          _savedList(context, l10n, saved),
          SectionHeader(l10n.routesTitle),
          _routesList(context, l10n, routes),
        ],
      ),
    );
  }

  Widget _searchControls(BuildContext context, AppLocalizations l10n) {
    return ItineraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PlaceAutocompleteField(
            controller: _destCtrl,
            label: l10n.tripDestination,
            onSelected: _onDestinationSelected,
          ),
          const SizedBox(height: 14),
          Text(l10n.exploreRadius, style: context.texts.labelLarge),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: [
              for (final r in _radiusChoicesKm)
                ChoiceChip(
                  label: Text('${r.toInt()} ${l10n.unitKm}'),
                  selected: _radiusKm == r,
                  onSelected: (_) {
                    setState(() => _radiusKm = r);
                    unawaited(_search(force: true));
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _mapCard(
    BuildContext context,
    AppLocalizations l10n,
    List<PoiSuggestion> pois,
    List<Location> savedWithCoords,
    Set<String> savedKeys,
    List<Location> saved,
  ) {
    final center = _center ?? const LatLng(41.9028, 12.4964);
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 300,
        child: Stack(
          children: [
            FlutterMap(
              mapController: _map,
              options: MapOptions(
                initialCenter: center,
                initialZoom: _center != null ? 13 : 5,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'org.itinera.app',
                ),
                MarkerLayer(
                  markers: [
                    for (final l in savedWithCoords)
                      Marker(
                        point: LatLng(l.latitude!, l.longitude!),
                        width: 34,
                        height: 34,
                        alignment: Alignment.topCenter,
                        child: GestureDetector(
                          onTap: () => _openLocation(l),
                          child: Icon(
                            Icons.check_circle,
                            color: context.tokens.accent,
                            size: 30,
                          ),
                        ),
                      ),
                    for (final p in pois)
                      if (!savedKeys.contains('${p.provider}/${p.externalId}'))
                        Marker(
                          point: LatLng(p.lat, p.lng),
                          width: 30,
                          height: 30,
                          child: GestureDetector(
                            onTap: () => _openSuggestion(p, saved),
                            child: Icon(
                              Icons.circle,
                              color: poiCategoryColor(p.category),
                              size: 18,
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
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Center(
                child: FilledButton.icon(
                  onPressed: _useMapCenter,
                  icon: const Icon(Icons.my_location, size: 18),
                  label: Text(l10n.exploreSearchArea),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChips(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          FilterChip(
            label: Text(l10n.exploreCategoryAll),
            selected: _filters.isEmpty,
            onSelected: (_) => setState(() {
              _filters.clear();
              _visibleCount = _pageSize;
            }),
          ),
          for (final c in exploreFilterCategories)
            FilterChip(
              avatar: Icon(poiCategoryIcon(c), size: 18),
              label: Text(poiCategoryLabel(l10n, c)),
              selected: _filters.contains(c),
              onSelected: (on) => setState(() {
                if (on) {
                  _filters.add(c);
                } else {
                  _filters.remove(c);
                }
                _visibleCount = _pageSize;
              }),
            ),
        ],
      ),
    );
  }

  Widget _results(
    BuildContext context,
    AppLocalizations l10n,
    List<PoiSuggestion> pois,
    Set<String> savedKeys,
    List<Location> saved,
  ) {
    if (_center == null) {
      return Padding(
        padding: const EdgeInsets.only(top: 24),
        child: EmptyState(
          icon: Icons.travel_explore,
          title: l10n.exploreNoDestination,
        ),
      );
    }
    if (_loading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            const LoadingView(),
            const SizedBox(height: 12),
            Text(
              l10n.exploreLoading,
              style: context.texts.bodySmall?.copyWith(
                color: context.scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }
    if (_error != null && _outcome == null) {
      return Padding(
        padding: const EdgeInsets.only(top: 24),
        child: EmptyState(
          icon: Icons.wifi_off,
          title: l10n.exploreErrorNetwork,
          action: FilledButton(
            onPressed: () => _search(force: true),
            child: Text(l10n.exploreRetry),
          ),
        ),
      );
    }
    final outcome = _outcome;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (outcome != null && outcome.fromCache) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                outcome.stale ? Icons.wifi_off : Icons.history,
                size: 16,
                color: context.scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  outcome.stale
                      ? l10n.exploreOffline
                      : '${l10n.exploreUpdatedOn} ${outcome.fetchedAt != null ? Fmt.date(outcome.fetchedAt!) : ''}',
                  style: context.texts.bodySmall?.copyWith(
                    color: context.scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
        SectionHeader(l10n.exploreSuggested),
        if (pois.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: EmptyState(
              icon: Icons.location_off,
              title: l10n.exploreEmpty,
            ),
          )
        else ...[
          ...pois
              .take(_visibleCount)
              .map((p) => _poiTile(context, l10n, p, savedKeys, saved)),
          if (pois.length > _visibleCount)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: OutlinedButton.icon(
                onPressed: () => setState(() => _visibleCount += _pageSize),
                icon: const Icon(Icons.expand_more),
                label: Text(
                  '${l10n.exploreShowMore} (${pois.length - _visibleCount})',
                ),
              ),
            ),
        ],
      ],
    );
  }

  Widget _poiTile(
    BuildContext context,
    AppLocalizations l10n,
    PoiSuggestion p,
    Set<String> savedKeys,
    List<Location> saved,
  ) {
    final isSaved = savedKeys.contains('${p.provider}/${p.externalId}');
    final dist = _center == null
        ? null
        : const Distance().as(LengthUnit.Meter, _center!, LatLng(p.lat, p.lng));
    return ItineraCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        onTap: () => _openSuggestion(p, saved),
        leading: CircleAvatar(
          backgroundColor: poiCategoryColor(p.category).withValues(alpha: 0.15),
          child: Icon(
            poiCategoryIcon(p.category),
            color: poiCategoryColor(p.category),
          ),
        ),
        title: Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          [
            poiCategoryLabel(l10n, p.category),
            if (dist != null)
              '${formatDistance(l10n, dist)} ${l10n.exploreFromCenter}',
          ].join(' · '),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          icon: Icon(
            isSaved ? Icons.bookmark : Icons.bookmark_add_outlined,
            color: isSaved ? context.tokens.accent : null,
          ),
          tooltip: isSaved ? l10n.exploreSaved : l10n.commonAdd,
          onPressed: () => _toggle(p, saved),
        ),
      ),
    );
  }

  Widget _savedList(
    BuildContext context,
    AppLocalizations l10n,
    List<Location> saved,
  ) {
    if (saved.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          l10n.exploreSavedEmpty,
          style: context.texts.bodyMedium?.copyWith(
            color: context.scheme.onSurfaceVariant,
          ),
        ),
      );
    }
    return Column(
      children: [
        for (final l in saved)
          ItineraCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              onTap: () => _openLocation(l),
              leading: Icon(
                l.poiCategory != null
                    ? poiCategoryIcon(l.poiCategory!)
                    : Icons.place,
                color: context.tokens.accent,
              ),
              title: Text(
                l.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: l.address != null
                  ? Text(
                      l.address!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  : null,
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  final ok = await ref
                      .read(exploreRepositoryProvider)
                      .deleteSavedLocation(l.id);
                  if (!ok && context.mounted) _snack(l10n.exploreInUse);
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _routesList(
    BuildContext context,
    AppLocalizations l10n,
    List<SightseeingRoute> routes,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (routes.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              l10n.routesEmpty,
              style: context.texts.bodyMedium?.copyWith(
                color: context.scheme.onSurfaceVariant,
              ),
            ),
          )
        else
          for (final r in routes)
            ItineraCard(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  routeModeIcon(r.travelMode),
                  color: context.tokens.accent,
                ),
                title: Text(
                  r.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: r.distanceMeters != null
                    ? Text(
                        '${formatDistance(l10n, r.distanceMeters!)} · ${formatDuration(l10n, r.durationSeconds ?? 0)}',
                      )
                    : null,
                trailing: const Icon(Icons.chevron_right),
                onTap: () =>
                    context.push('/trip/${widget.tripId}/route/${r.id}'),
              ),
            ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: _newRoute,
          icon: const Icon(Icons.add_road),
          label: Text(l10n.routeNew),
        ),
      ],
    );
  }
}
