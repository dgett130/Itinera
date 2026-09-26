import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../app.dart';
import '../../core/enums.dart';
import '../../core/format.dart';
import '../../data/database.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/itinera_theme.dart';
import '../../ui/widgets.dart';
import '../itinerary/itinerary_providers.dart';
import '../places/geocoding_service.dart';
import '../trip/trip_providers.dart';
import 'explore_providers.dart';
import 'explore_repository.dart';
import 'explore_ui.dart';
import 'geo_codec.dart';
import 'place_sheet.dart';
import 'poi_parser.dart';
import 'route_math.dart';
import 'sightseeing_route_repository.dart';

/// Costruzione di un percorso a passi: ① Scegli → ② Ordina → ③ Pianifica.
///
/// Mappa a schermo pieno, indicatore dei passi in alto (tappabile: i passi
/// si possono saltare), vassoio trascinabile col contenuto del passo e bottone
/// principale sempre in basso. Il percorso è salvato a ogni modifica (bozza
/// finché non è nell'itinerario); uscendo senza tappe viene eliminato.
class RouteFlowScreen extends ConsumerStatefulWidget {
  const RouteFlowScreen({
    super.key,
    required this.tripId,
    required this.routeId,
    this.startNew = false,
  });

  final String tripId;
  final String routeId;

  /// Percorso appena creato: si parte dal passo ① "Scegli".
  final bool startNew;

  @override
  ConsumerState<RouteFlowScreen> createState() => _RouteFlowScreenState();
}

class _RouteFlowScreenState extends ConsumerState<RouteFlowScreen> {
  static const _fallbackCenter = LatLng(41.9028, 12.4964);
  static const _pageSize = 12;

  final _map = MapController();
  final _sheet = DraggableScrollableController();
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  late final SightseeingRouteRepository _routes;
  late final ExploreRepository _explore;

  int _step = 0;
  bool _stepInited = false;
  bool _mapReady = false;
  bool _centerInited = false;

  // Scoperta nell'area visibile.
  LatLng? _searchCenter;
  double _searchRadius = 1500;
  PoiSearchOutcome? _outcome;
  bool _loading = false;
  Object? _error;
  final Set<PoiCategory> _filters = {};
  int _visible = _pageSize;
  bool _showSearchHere = false;

  // Ricerca per nome.
  Timer? _nameDebounce;
  List<PlaceResult>? _nameResults;
  bool _searchingName = false;

  // Calcolo del percorso.
  Timer? _recomputeDebounce;
  bool _computing = false;

  // Pianifica.
  String? _pickedDayId;
  bool _daysEnsured = false;

  @override
  void initState() {
    super.initState();
    _routes = ref.read(sightseeingRouteRepositoryProvider);
    _explore = ref.read(exploreRepositoryProvider);
    _searchFocus.addListener(() {
      if (_searchFocus.hasFocus && _sheet.isAttached) {
        _sheet.animateTo(
          0.92,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _nameDebounce?.cancel();
    _recomputeDebounce?.cancel();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    _sheet.dispose();
    // Bozza abbandonata senza tappe: non lasciare percorsi vuoti in giro.
    unawaited(_routes.deleteIfEmpty(widget.routeId));
    super.dispose();
  }

  // --- Dati di comodo -------------------------------------------------------

  Map<String, Location> _locById() => {
    for (final l
        in ref.read(savedLocationsProvider(widget.tripId)).value ??
            const <Location>[])
      l.id: l,
  };

  List<(SightseeingRouteStop, Location)> _stopRefs(
    List<SightseeingRouteStop> stops,
    Map<String, Location> locById,
  ) => [
    for (final s in stops)
      if (locById[s.locationId] != null) (s, locById[s.locationId]!),
  ];

  // --- Mappa e scoperta -----------------------------------------------------

  double _visibleRadius() {
    final cam = _map.camera;
    final d = const Distance().as(
      LengthUnit.Meter,
      cam.center,
      cam.visibleBounds.northEast,
    );
    return d.clamp(400, 15000).toDouble();
  }

  Future<void> _tryInitCenter(Trip trip, List<Location> stopLocs) async {
    if (_centerInited || !_mapReady) return;
    _centerInited = true;
    final pts = [
      for (final l in stopLocs)
        if (l.latitude != null && l.longitude != null)
          LatLng(l.latitude!, l.longitude!),
    ];
    final bottom = MediaQuery.sizeOf(context).height * 0.45;
    if (pts.length >= 2) {
      _map.fitCamera(
        CameraFit.coordinates(
          coordinates: pts,
          padding: EdgeInsets.fromLTRB(48, 140, 48, bottom),
        ),
      );
    } else if (pts.length == 1) {
      _map.move(pts.first, 15);
    } else if (trip.destinationLat != null && trip.destinationLng != null) {
      _map.move(LatLng(trip.destinationLat!, trip.destinationLng!), 14);
    } else if (trip.destination?.trim().isNotEmpty == true) {
      final r = await ref
          .read(geocodingServiceProvider)
          .search(trip.destination!, limit: 1);
      if (!mounted || r.isEmpty) return;
      _map.move(LatLng(r.first.latitude, r.first.longitude), 14);
    } else {
      return; // nessun punto di partenza: il vassoio chiede "Dove?".
    }
    await Future<void>.delayed(Duration.zero);
    if (mounted) unawaited(_discover());
  }

  void _onMapMoved(MapCamera camera, bool hasGesture) {
    if (!hasGesture) return;
    final c = _searchCenter;
    bool show;
    if (c == null) {
      show = true;
    } else {
      final moved = const Distance().as(LengthUnit.Meter, c, camera.center);
      final r = _visibleRadius();
      show = moved > _searchRadius * 0.35 || r > _searchRadius * 1.8;
    }
    if (show != _showSearchHere) setState(() => _showSearchHere = show);
  }

  Future<void> _discover({bool force = false, bool isRetry = false}) async {
    if (!_mapReady) return;
    final center = _map.camera.center;
    final radius = _visibleRadius();
    setState(() {
      _searchCenter = center;
      _searchRadius = radius;
      _loading = true;
      _error = null;
      _showSearchHere = false;
      _visible = _pageSize;
    });
    try {
      final outcome = await _explore.discover(
        lat: center.latitude,
        lng: center.longitude,
        radiusMeters: radius,
        forceRefresh: force,
      );
      if (!mounted) return;
      setState(() {
        _outcome = outcome;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      if (!isRetry) {
        // Un secondo tentativo silenzioso prima di mostrare l'errore.
        await Future<void>.delayed(const Duration(seconds: 2));
        if (mounted) return _discover(force: force, isRetry: true);
        return;
      }
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  String? _distanceLabel(double? lat, double? lng) {
    final c = _searchCenter;
    if (c == null || lat == null || lng == null) return null;
    final l10n = AppLocalizations.of(context);
    final m = const Distance().as(LengthUnit.Meter, c, LatLng(lat, lng));
    return formatDistance(l10n, m);
  }

  // --- Ricerca per nome -----------------------------------------------------

  void _onQueryChanged(String q) {
    _nameDebounce?.cancel();
    if (q.trim().length < 3) {
      setState(() {
        _nameResults = q.trim().isEmpty ? null : const [];
        _searchingName = false;
      });
      return;
    }
    setState(() => _searchingName = true);
    _nameDebounce = Timer(const Duration(milliseconds: 450), () async {
      final c = _mapReady ? _map.camera.center : null;
      final res = await ref
          .read(geocodingServiceProvider)
          .search(q, limit: 8, lat: c?.latitude, lon: c?.longitude);
      if (!mounted || _searchCtrl.text != q) return;
      setState(() {
        _nameResults = res;
        _searchingName = false;
      });
    });
  }

  void _clearQuery() {
    _searchCtrl.clear();
    _nameDebounce?.cancel();
    setState(() {
      _nameResults = null;
      _searchingName = false;
    });
  }

  Future<void> _openNameResult(PlaceResult r) async {
    final l10n = AppLocalizations.of(context);
    FocusScope.of(context).unfocus();
    final point = LatLng(r.latitude, r.longitude);
    if (_mapReady) {
      _map.move(point, 16);
      setState(() => _showSearchHere = true);
    }
    await showPlaceSheet(
      context,
      place: PlaceInfo(
        name: r.label,
        lat: r.latitude,
        lng: r.longitude,
        address: r.country,
      ),
      action: PlaceSheetAction(
        label: l10n.placeAddToRoute,
        icon: Icons.add_location_alt_outlined,
        onPressed: () => _addManual(r.label, point),
      ),
    );
  }

  // --- Aggiunta/rimozione tappe --------------------------------------------

  void _snack(String msg, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(msg),
          action: action,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _addPoi(PoiSuggestion p) async {
    final l10n = AppLocalizations.of(context);
    final locId = await _explore.savePoi(widget.tripId, p);
    await _routes.addStop(widget.routeId, widget.tripId, locId);
    _scheduleRecompute();
    if (mounted) _snack(l10n.flowAdded(p.name));
  }

  Future<void> _addManual(String label, LatLng point) async {
    final l10n = AppLocalizations.of(context);
    final id = await _explore.saveManualLocation(
      widget.tripId,
      label: label,
      latitude: point.latitude,
      longitude: point.longitude,
    );
    await _routes.addStop(widget.routeId, widget.tripId, id);
    _scheduleRecompute();
    if (mounted) _snack(l10n.flowAdded(label));
  }

  Future<void> _removeStop(SightseeingRouteStop stop, String name) async {
    final l10n = AppLocalizations.of(context);
    final removed = await _routes.removeStop(stop.id);
    _scheduleRecompute();
    if (removed == null || !mounted) return;
    _snack(
      l10n.flowRemoved(name),
      action: SnackBarAction(
        label: l10n.flowUndo,
        onPressed: () async {
          await _routes.restoreStop(removed);
          _scheduleRecompute();
        },
      ),
    );
  }

  Future<void> _addPinAt(LatLng point) async {
    final l10n = AppLocalizations.of(context);
    final ctrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.flowPinTitle),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(hintText: l10n.flowPinNameHint),
          onSubmitted: (v) => Navigator.pop(context, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, ctrl.text),
            child: Text(l10n.commonAdd),
          ),
        ],
      ),
    );
    if (name == null) return;
    final label = name.trim().isEmpty ? l10n.flowPinDefaultName : name.trim();
    await _addManual(label, point);
  }

  // --- Schede luogo ---------------------------------------------------------

  Future<void> _openPoi(
    PoiSuggestion p,
    SightseeingRouteStop? stop,
    Location? loc,
  ) async {
    final l10n = AppLocalizations.of(context);
    if (stop != null && loc != null) return _openStop(stop, loc);
    await showPlaceSheet(
      context,
      place: PlaceInfo.fromSuggestion(p),
      distanceLabel: _distanceLabel(p.lat, p.lng),
      action: PlaceSheetAction(
        label: l10n.placeAddToRoute,
        icon: Icons.add_location_alt_outlined,
        onPressed: () => _addPoi(p),
      ),
    );
  }

  Future<void> _openStop(SightseeingRouteStop stop, Location loc) async {
    final l10n = AppLocalizations.of(context);
    await showPlaceSheet(
      context,
      place: PlaceInfo.fromLocation(loc),
      distanceLabel: _distanceLabel(loc.latitude, loc.longitude),
      action: PlaceSheetAction(
        label: l10n.placeRemoveFromRoute,
        icon: Icons.remove_circle_outline,
        destructive: true,
        onPressed: () => _removeStop(stop, loc.label),
      ),
    );
  }

  // --- Calcolo percorso -----------------------------------------------------

  void _scheduleRecompute() {
    _recomputeDebounce?.cancel();
    _recomputeDebounce = Timer(
      const Duration(milliseconds: 350),
      () => unawaited(_recompute()),
    );
  }

  Future<void> _recompute() async {
    final route = await _routes.getRoute(widget.routeId);
    if (route == null) return;
    final stops = await _routes.stopsFor(widget.routeId);
    final locById = _locById();
    final pts = <LatLng>[];
    for (final s in stops) {
      final l = locById[s.locationId];
      if (l != null && l.latitude != null && l.longitude != null) {
        pts.add(LatLng(l.latitude!, l.longitude!));
      }
    }
    if (pts.length < 2) {
      await _routes.saveComputation(
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
    await _routes.saveComputation(
      widget.routeId,
      distanceMeters: res.distanceMeters.round(),
      durationSeconds: res.durationSeconds.round(),
      geometryJson: encodeGeometry(res.geometry),
      source: res.source,
    );
    if (mounted) setState(() => _computing = false);
  }

  Future<void> _optimize(SightseeingRoute route) async {
    final stops = await _routes.stopsFor(widget.routeId);
    final locById = _locById();
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
    final rest = stops.where((s) => !ordered.contains(s.id)).map((s) => s.id);
    await _routes.applyOptimizedOrder(widget.routeId, [...ordered, ...rest]);
    await _recompute();
  }

  // --- Navigazione tra passi e azioni ---------------------------------------

  void _goStep(int step) {
    FocusScope.of(context).unfocus();
    setState(() => _step = step);
    if (step >= 1) _fitStops();
    if (step == 2) unawaited(_ensureDays());
  }

  /// Inquadra tutte le tappe, lasciando libera la parte coperta dal vassoio.
  void _fitStops() {
    if (!_mapReady) return;
    final stops =
        ref.read(routeStopsProvider(widget.routeId)).value ?? const [];
    final locById = _locById();
    final pts = [
      for (final s in stops)
        if (locById[s.locationId]?.latitude != null &&
            locById[s.locationId]?.longitude != null)
          LatLng(
            locById[s.locationId]!.latitude!,
            locById[s.locationId]!.longitude!,
          ),
    ];
    if (pts.isEmpty) return;
    if (pts.length == 1) {
      _map.move(pts.first, 15);
      return;
    }
    final size = MediaQuery.sizeOf(context);
    final sheet = _sheet.isAttached ? _sheet.size : 0.45;
    _map.fitCamera(
      CameraFit.coordinates(
        coordinates: pts,
        padding: EdgeInsets.fromLTRB(48, 140, 48, size.height * sheet + 24),
        maxZoom: 17,
      ),
    );
  }

  Future<void> _ensureDays() async {
    if (_daysEnsured) return;
    _daysEnsured = true;
    await ref.read(itineraryRepositoryProvider).ensureDays(widget.tripId);
  }

  Future<void> _addToItinerary(String dayId) async {
    final l10n = AppLocalizations.of(context);
    final result = await _routes.addToItinerary(
      widget.routeId,
      dayId,
      widget.tripId,
    );
    if (!mounted) return;
    final msg = switch (result) {
      1 => l10n.flowAddedToDay,
      2 => l10n.flowMovedToDay,
      _ => l10n.flowAlreadyInDay,
    };
    _snack(
      msg,
      action: SnackBarAction(
        label: l10n.flowView,
        onPressed: () => context.push('/trip/${widget.tripId}/itinerary'),
      ),
    );
  }

  Future<void> _rename(SightseeingRoute route) async {
    final l10n = AppLocalizations.of(context);
    final ctrl = TextEditingController(text: route.name);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.routeRename),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
        ),
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
      await _routes.renameRoute(widget.routeId, name);
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
      await _routes.deleteRoute(widget.routeId);
      if (mounted) context.pop();
    }
  }

  // --- Build ----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final trip = ref.watch(tripProvider(widget.tripId)).value;
    final routeAsync = ref.watch(routeByIdProvider(widget.routeId));
    final stopsAsync = ref.watch(routeStopsProvider(widget.routeId));
    final locsAsync = ref.watch(savedLocationsProvider(widget.tripId));
    final route = routeAsync.value;

    if (trip == null || (route == null && routeAsync.isLoading)) {
      return const Scaffold(body: LoadingView());
    }
    if (route == null) {
      return Scaffold(
        appBar: AppBar(),
        body: EmptyState(icon: Icons.search_off, title: l10n.commonEmpty),
      );
    }

    final stops = stopsAsync.value ?? const <SightseeingRouteStop>[];
    final locById = {
      for (final l in locsAsync.value ?? const <Location>[]) l.id: l,
    };
    final refs = _stopRefs(stops, locById);

    if (!_stepInited && stopsAsync.hasValue) {
      _stepInited = true;
      _step = widget.startNew || stops.length < 2 ? 0 : 1;
    }
    if (!_centerInited &&
        _mapReady &&
        stopsAsync.hasValue &&
        locsAsync.hasValue) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _tryInitCenter(trip, [for (final r in refs) r.$2]),
      );
    }

    return TripThemeScope(
      style: ItineraTheme.effectiveStyle(trip),
      child: Builder(
        builder: (context) => Scaffold(
          bottomNavigationBar: _primaryBar(context, l10n, route, stops),
          body: Stack(
            children: [
              Positioned.fill(child: _mapView(context, trip, route, refs)),
              _statusScrim(context),
              _topBar(context, l10n, route),
              if (_step == 0 && _showSearchHere) _searchHereButton(l10n),
              _tray(context, l10n, route, stops, refs, locById),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mapView(
    BuildContext context,
    Trip trip,
    SightseeingRoute route,
    List<(SightseeingRouteStop, Location)> refs,
  ) {
    final tokens = context.tokens;
    final stopPts = [
      for (final r in refs)
        if (r.$2.latitude != null && r.$2.longitude != null)
          (r, LatLng(r.$2.latitude!, r.$2.longitude!)),
    ];
    final geometry = decodeGeometry(route.geometry);
    final line = geometry.length >= 2
        ? geometry
        : [for (final p in stopPts) p.$2];
    final stopKeys = {
      for (final r in refs)
        if (r.$2.externalId != null)
          '${r.$2.externalProvider}/${r.$2.externalId}',
    };
    final pois = _step == 0
        ? (_outcome?.pois ?? const <PoiSuggestion>[])
              .where((p) => _filters.isEmpty || _filters.contains(p.category))
              .where((p) => !stopKeys.contains('${p.provider}/${p.externalId}'))
              .toList()
        : const <PoiSuggestion>[];
    final hasDest = trip.destinationLat != null && trip.destinationLng != null;

    return FlutterMap(
      mapController: _map,
      options: MapOptions(
        initialCenter: hasDest
            ? LatLng(trip.destinationLat!, trip.destinationLng!)
            : _fallbackCenter,
        initialZoom: hasDest ? 14 : 5,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
        onMapReady: () => setState(() => _mapReady = true),
        onPositionChanged: _onMapMoved,
        onLongPress: (_, p) => _addPinAt(p),
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
                strokeWidth: 5,
                color: tokens.accent.withValues(alpha: 0.85),
              ),
            ],
          ),
        MarkerLayer(
          markers: [
            for (final p in pois)
              Marker(
                point: LatLng(p.lat, p.lng),
                width: 36,
                height: 36,
                child: GestureDetector(
                  onTap: () => _openPoi(p, null, null),
                  child: Center(
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: poiCategoryColor(p.category),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ),
              ),
            for (var i = 0; i < stopPts.length; i++)
              Marker(
                point: stopPts[i].$2,
                width: 40,
                height: 40,
                child: GestureDetector(
                  onTap: () => _openStop(stopPts[i].$1.$1, stopPts[i].$1.$2),
                  child: Container(
                    decoration: BoxDecoration(
                      color: tokens.accent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                      boxShadow: const [
                        BoxShadow(color: Color(0x40000000), blurRadius: 4),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${refs.indexOf(stopPts[i].$1) + 1}',
                      style: TextStyle(
                        color: tokens.onAccent,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
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

  Widget _statusScrim(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final c = context.scheme.surface;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: top + 28,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [c.withValues(alpha: 0.9), c.withValues(alpha: 0)],
            ),
          ),
        ),
      ),
    );
  }

  Widget _topBar(
    BuildContext context,
    AppLocalizations l10n,
    SightseeingRoute route,
  ) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: Row(
            children: [
              _RoundIconButton(
                icon: Icons.arrow_back,
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StepIndicator(
                  step: _step,
                  labels: [
                    l10n.flowStepChoose,
                    l10n.flowStepOrder,
                    l10n.flowStepPlan,
                  ],
                  onTap: _goStep,
                ),
              ),
              const SizedBox(width: 8),
              _RoundMenuButton(
                items: [
                  (Icons.edit_outlined, l10n.routeRename, () => _rename(route)),
                  (Icons.delete_outline, l10n.routeDelete, _delete),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _searchHereButton(AppLocalizations l10n) {
    return Positioned(
      top: MediaQuery.paddingOf(context).top + 70,
      left: 0,
      right: 0,
      child: Center(
        child: FilledButton.icon(
          onPressed: () => _discover(force: true),
          icon: const Icon(Icons.search, size: 18),
          label: Text(l10n.flowSearchHere),
        ),
      ),
    );
  }

  Widget _primaryBar(
    BuildContext context,
    AppLocalizations l10n,
    SightseeingRoute route,
    List<SightseeingRouteStop> stops,
  ) {
    final (label, icon, onPressed) = switch (_step) {
      0 => (
        l10n.flowNextOrder,
        Icons.arrow_forward,
        stops.isEmpty ? null : () => _goStep(1),
      ),
      1 => (
        l10n.flowNextPlan,
        Icons.arrow_forward,
        stops.isEmpty ? null : () => _goStep(2),
      ),
      _ => (
        l10n.routeAddToItinerary,
        Icons.playlist_add,
        stops.isEmpty
            ? null
            : () {
                final day = _pickedDayId ?? route.dayId;
                if (day == null) {
                  _snack(l10n.flowPickDayFirst);
                } else {
                  unawaited(_addToItinerary(day));
                }
              },
      ),
    };
    return Material(
      color: context.scheme.surface,
      child: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: SizedBox(
          height: 56,
          child: FilledButton.icon(
            onPressed: onPressed,
            icon: Icon(icon),
            label: Text(label),
          ),
        ),
      ),
    );
  }

  Widget _tray(
    BuildContext context,
    AppLocalizations l10n,
    SightseeingRoute route,
    List<SightseeingRouteStop> stops,
    List<(SightseeingRouteStop, Location)> refs,
    Map<String, Location> locById,
  ) {
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return DraggableScrollableSheet(
      controller: _sheet,
      initialChildSize: 0.45,
      minChildSize: 0.14,
      maxChildSize: 0.92,
      snap: true,
      snapSizes: const [0.14, 0.45],
      builder: (context, scroll) => Material(
        color: context.scheme.surface,
        elevation: 8,
        shadowColor: Colors.black54,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        clipBehavior: Clip.antiAlias,
        child: ListView(
          controller: scroll,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: context.tokens.hairline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            AnimatedSwitcher(
              duration: reduceMotion
                  ? Duration.zero
                  : const Duration(milliseconds: 220),
              child: KeyedSubtree(
                key: ValueKey(_step),
                child: switch (_step) {
                  0 => _chooseStep(context, l10n, refs, locById),
                  1 => _orderStep(context, l10n, route, stops, refs),
                  _ => _planStep(context, l10n, route, refs),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- ① Scegli -------------------------------------------------------------

  Widget _chooseStep(
    BuildContext context,
    AppLocalizations l10n,
    List<(SightseeingRouteStop, Location)> refs,
    Map<String, Location> locById,
  ) {
    final scheme = context.scheme;
    final stopByKey = {
      for (final r in refs)
        if (r.$2.externalId != null)
          '${r.$2.externalProvider}/${r.$2.externalId}': r,
    };
    final pois = (_outcome?.pois ?? const <PoiSuggestion>[])
        .where((p) => _filters.isEmpty || _filters.contains(p.category))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.flowChooseTitle,
                style: context.texts.titleLarge,
              ),
            ),
            Text(
              l10n.flowInRoute(refs.length),
              style: context.texts.labelLarge?.copyWith(
                color: context.tokens.accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _searchCtrl,
          focusNode: _searchFocus,
          onChanged: _onQueryChanged,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: l10n.flowSearchHint,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchCtrl.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _clearQuery,
                  ),
          ),
        ),
        const SizedBox(height: 8),
        if (_nameResults != null)
          ..._nameResultsList(context, l10n)
        else ...[
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(l10n.exploreCategoryAll),
                    selected: _filters.isEmpty,
                    onSelected: (_) => setState(() {
                      _filters.clear();
                      _visible = _pageSize;
                    }),
                  ),
                ),
                for (final c in exploreFilterCategories)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      avatar: Icon(poiCategoryIcon(c), size: 18),
                      label: Text(poiCategoryLabel(l10n, c)),
                      selected: _filters.contains(c),
                      onSelected: (on) => setState(() {
                        on ? _filters.add(c) : _filters.remove(c);
                        _visible = _pageSize;
                      }),
                    ),
                  ),
              ],
            ),
          ),
          ..._discoveryStatus(context, l10n),
          for (final p in pois.take(_visible))
            _poiRow(
              context,
              l10n,
              p,
              stopByKey['${p.provider}/${p.externalId}'],
            ),
          if (pois.length > _visible)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: OutlinedButton.icon(
                onPressed: () => setState(() => _visible += _pageSize),
                icon: const Icon(Icons.expand_more),
                label: Text(
                  '${l10n.exploreShowMore} (${pois.length - _visible})',
                ),
              ),
            ),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(
              Icons.touch_app_outlined,
              size: 18,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.flowPinHint,
                style: context.texts.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _discoveryStatus(BuildContext context, AppLocalizations l10n) {
    final muted = context.texts.bodySmall?.copyWith(
      color: context.scheme.onSurfaceVariant,
    );
    if (_searchCenter == null && !_loading) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(
                Icons.travel_explore,
                size: 40,
                color: context.tokens.accent,
              ),
              const SizedBox(height: 8),
              Text(l10n.flowWhereTitle, style: context.texts.titleMedium),
              const SizedBox(height: 4),
              Text(
                l10n.flowWhereMessage,
                textAlign: TextAlign.center,
                style: muted,
              ),
            ],
          ),
        ),
      ];
    }
    if (_loading) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: context.tokens.accent,
                ),
              ),
              const SizedBox(width: 12),
              Text(l10n.exploreLoading, style: muted),
            ],
          ),
        ),
      ];
    }
    final outcome = _outcome;
    if (_error != null && outcome == null) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Text(l10n.exploreErrorNetwork, style: context.texts.titleSmall),
              const SizedBox(height: 4),
              Text(
                l10n.flowOfflineHint,
                textAlign: TextAlign.center,
                style: muted,
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => _discover(force: true),
                child: Text(l10n.exploreRetry),
              ),
            ],
          ),
        ),
      ];
    }
    return [
      if (outcome != null && outcome.fromCache)
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 4),
          child: Row(
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
                  style: muted,
                ),
              ),
            ],
          ),
        ),
      if (outcome != null && outcome.pois.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(l10n.exploreEmpty, style: muted),
        ),
    ];
  }

  List<Widget> _nameResultsList(BuildContext context, AppLocalizations l10n) {
    if (_searchingName) {
      return [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: CircularProgressIndicator(color: context.tokens.accent),
          ),
        ),
      ];
    }
    final results = _nameResults ?? const <PlaceResult>[];
    if (results.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            l10n.flowNoResults,
            style: context.texts.bodyMedium?.copyWith(
              color: context.scheme.onSurfaceVariant,
            ),
          ),
        ),
      ];
    }
    return [
      for (final r in results)
        ListTile(
          contentPadding: EdgeInsets.zero,
          minTileHeight: 56,
          leading: Icon(Icons.place_outlined, color: context.tokens.accent),
          title: Text(r.label, maxLines: 2, overflow: TextOverflow.ellipsis),
          subtitle: r.country != null ? Text(r.country!) : null,
          onTap: () => _openNameResult(r),
        ),
    ];
  }

  Widget _poiRow(
    BuildContext context,
    AppLocalizations l10n,
    PoiSuggestion p,
    (SightseeingRouteStop, Location)? inRoute,
  ) {
    final dist = _distanceLabel(p.lat, p.lng);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      minTileHeight: 60,
      onTap: () => _openPoi(p, inRoute?.$1, inRoute?.$2),
      leading: CircleAvatar(
        backgroundColor: poiCategoryColor(p.category).withValues(alpha: 0.15),
        child: Icon(
          poiCategoryIcon(p.category),
          color: poiCategoryColor(p.category),
        ),
      ),
      title: Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        [poiCategoryLabel(l10n, p.category), ?dist].join(' · '),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        iconSize: 30,
        tooltip: inRoute != null
            ? l10n.placeRemoveFromRoute
            : l10n.placeAddToRoute,
        icon: Icon(
          inRoute != null ? Icons.check_circle : Icons.add_circle_outline,
          color: context.tokens.accent,
        ),
        onPressed: () => inRoute != null
            ? _removeStop(inRoute.$1, inRoute.$2.label)
            : _addPoi(p),
      ),
    );
  }

  // --- ② Ordina -------------------------------------------------------------

  Widget _orderStep(
    BuildContext context,
    AppLocalizations l10n,
    SightseeingRoute route,
    List<SightseeingRouteStop> stops,
    List<(SightseeingRouteStop, Location)> refs,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.flowOrderTitle, style: context.texts.titleLarge),
        const SizedBox(height: 12),
        if (refs.length < 2) ...[
          Text(
            l10n.flowOrderNeedTwo,
            style: context.texts.bodyMedium?.copyWith(
              color: context.scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _goStep(0),
            icon: const Icon(Icons.add_location_alt_outlined),
            label: Text(l10n.flowAddPlaces),
          ),
          const SizedBox(height: 12),
        ] else
          _stats(context, l10n, route),
        const SizedBox(height: 12),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          itemCount: refs.length,
          onReorder: (oldIndex, newIndex) async {
            if (newIndex > oldIndex) newIndex -= 1;
            final ids = refs.map((r) => r.$1.id).toList();
            ids.insert(newIndex, ids.removeAt(oldIndex));
            await _routes.reorder(widget.routeId, ids);
            _scheduleRecompute();
          },
          itemBuilder: (context, i) {
            final (stop, loc) = refs[i];
            final hasCoords = loc.latitude != null && loc.longitude != null;
            return Padding(
              key: ValueKey(stop.id),
              padding: const EdgeInsets.only(bottom: 8),
              child: ItineraCard(
                onTap: () => _openStop(stop, loc),
                padding: const EdgeInsets.fromLTRB(10, 4, 4, 4),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: context.tokens.accentSoft,
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          color: context.tokens.accent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.texts.titleSmall,
                          ),
                          if (!hasCoords)
                            Text(
                              l10n.placeNoCoords,
                              style: context.texts.bodySmall?.copyWith(
                                color: context.scheme.error,
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.placeRemoveFromRoute,
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () => _removeStop(stop, loc.label),
                    ),
                    ReorderableDragStartListener(
                      index: i,
                      child: const SizedBox(
                        width: 48,
                        height: 48,
                        child: Icon(Icons.drag_handle),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        SizedBox(
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
              await _routes.setMode(widget.routeId, s.first);
              _scheduleRecompute();
            },
          ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.routeFixedStart),
          subtitle: Text(l10n.routeFixedStartHint),
          value: route.fixedStart,
          onChanged: (v) => _routes.setFixedStart(widget.routeId, v),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.routeReturnToStart),
          value: route.returnToStart,
          onChanged: (v) async {
            await _routes.setReturnToStart(widget.routeId, v);
            _scheduleRecompute();
          },
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: refs.length >= 2 ? () => _optimize(route) : null,
              icon: const Icon(Icons.auto_fix_high, size: 18),
              label: Text(l10n.routeOptimize),
            ),
            if (route.optimized && route.lastManualOrder != null)
              TextButton.icon(
                onPressed: () async {
                  await _routes.restoreManualOrder(widget.routeId);
                  await _recompute();
                },
                icon: const Icon(Icons.undo, size: 18),
                label: Text(l10n.routeRestoreManual),
              ),
          ],
        ),
      ],
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
    final muted = context.texts.bodySmall?.copyWith(
      color: context.scheme.onSurfaceVariant,
    );
    return ItineraCard(
      child: Row(
        children: [
          Icon(routeModeIcon(route.travelMode), color: context.tokens.accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  [
                    if (route.distanceMeters != null)
                      formatDistance(l10n, route.distanceMeters!),
                    if (route.durationSeconds != null)
                      formatDuration(l10n, route.durationSeconds!),
                  ].join(' · '),
                  style: context.texts.titleMedium,
                ),
                Text(_computing ? l10n.routeComputing : source, style: muted),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- ③ Pianifica ----------------------------------------------------------

  Widget _planStep(
    BuildContext context,
    AppLocalizations l10n,
    SightseeingRoute route,
    List<(SightseeingRouteStop, Location)> refs,
  ) {
    final days = sortDaysForPicker(
      ref.watch(itineraryDaysProvider(widget.tripId)).value ??
          const <ItineraryDay>[],
    );
    final selected = _pickedDayId ?? route.dayId;
    final currentDay = days.firstWhereOrNull((d) => d.id == route.dayId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.flowPlanTitle, style: context.texts.titleLarge),
        const SizedBox(height: 12),
        ItineraCard(
          onTap: () => _rename(route),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.flowRouteName,
                      style: context.texts.labelMedium?.copyWith(
                        color: context.scheme.onSurfaceVariant,
                      ),
                    ),
                    Text(route.name, style: context.texts.titleMedium),
                  ],
                ),
              ),
              const Icon(Icons.edit_outlined),
            ],
          ),
        ),
        if (refs.length >= 2) ...[
          const SizedBox(height: 10),
          _stats(context, l10n, route),
        ],
        const SizedBox(height: 16),
        Text(l10n.flowWhichDay, style: context.texts.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final d in days)
              ChoiceChip(
                label: Text(_dayLabel(l10n, d)),
                selected: selected == d.id,
                onSelected: (_) => setState(() => _pickedDayId = d.id),
              ),
          ],
        ),
        if (currentDay != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.event_available,
                size: 18,
                color: context.tokens.accent,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l10n.flowInItinerary(_dayLabel(l10n, currentDay)),
                  style: context.texts.bodyMedium,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        Text(
          l10n.flowPlanInfo,
          style: context.texts.bodySmall?.copyWith(
            color: context.scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  String _dayLabel(AppLocalizations l10n, ItineraryDay d) {
    if (d.title?.trim().isNotEmpty == true) return d.title!;
    if (d.date != null) return Fmt.dateShort(d.date!);
    return l10n.routeDayUnplanned;
  }
}

/// Bottone tondo sopra la mappa (indietro, menu).
class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.scheme.surface,
      shape: const CircleBorder(),
      elevation: 3,
      child: IconButton(
        icon: Icon(icon),
        tooltip: tooltip,
        onPressed: onPressed,
      ),
    );
  }
}

class _RoundMenuButton extends StatelessWidget {
  const _RoundMenuButton({required this.items});
  final List<(IconData, String, VoidCallback)> items;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.scheme.surface,
      shape: const CircleBorder(),
      elevation: 3,
      child: PopupMenuButton<int>(
        icon: const Icon(Icons.more_vert),
        onSelected: (i) => items[i].$3(),
        itemBuilder: (_) => [
          for (var i = 0; i < items.length; i++)
            PopupMenuItem(
              value: i,
              child: Row(
                children: [
                  Icon(items[i].$1, size: 20),
                  const SizedBox(width: 12),
                  Text(items[i].$2),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Indicatore dei tre passi (tappabile: i passi si possono saltare).
class _StepIndicator extends StatelessWidget {
  const _StepIndicator({
    required this.step,
    required this.labels,
    required this.onTap,
  });
  final int step;
  final List<String> labels;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scheme = context.scheme;
    return Material(
      color: scheme.surface,
      elevation: 3,
      borderRadius: BorderRadius.circular(28),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 48,
        child: Row(
          children: [
            for (var i = 0; i < labels.length; i++)
              Expanded(
                child: Semantics(
                  button: true,
                  selected: i == step,
                  label: '${i + 1}. ${labels[i]}',
                  excludeSemantics: true,
                  child: InkWell(
                    onTap: () => onTap(i),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 11,
                          backgroundColor: i <= step
                              ? tokens.accent
                              : scheme.surfaceContainerHighest,
                          child: i < step
                              ? Icon(
                                  Icons.check,
                                  size: 14,
                                  color: tokens.onAccent,
                                )
                              : Text(
                                  '${i + 1}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: i == step
                                        ? tokens.onAccent
                                        : scheme.onSurfaceVariant,
                                  ),
                                ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            labels[i],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.texts.labelLarge?.copyWith(
                              fontWeight: i == step
                                  ? FontWeight.w800
                                  : FontWeight.w500,
                              color: i == step
                                  ? scheme.onSurface
                                  : scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
