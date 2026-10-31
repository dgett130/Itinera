import 'dart:async';
import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../core/enums.dart';
import '../../core/format.dart';
import '../../core/visit_duration.dart';
import '../../data/database.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/itinera_theme.dart';
import '../../ui/motion.dart';
import '../../ui/widgets.dart';
import '../itinerary/itinerary_providers.dart';
import '../places/geocoding_service.dart';
import '../places/place_autocomplete_field.dart';
import '../transport/routing_service.dart';
import '../trip/trip_providers.dart';
import 'explore_providers.dart';
import 'explore_repository.dart';
import 'explore_ui.dart';
import 'geo_codec.dart';
import 'place_sheet.dart';
import 'poi_parser.dart';
import 'route_math.dart';
import 'route_schedule.dart';
import 'route_schedule_view.dart';
import 'route_warnings.dart';
import 'sightseeing_route_repository.dart';
import 'warning_settings_provider.dart';

/// Costruzione di un percorso a passi: ① Scegli → ② Ordina → ③ Pianifica.
///
/// Mappa a schermo pieno, pillola dei passi in alto (tappabile: i passi si
/// possono saltare), vassoio trascinabile col contenuto del passo e bottone
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

  /// Altezza del vassoio in ogni passo e punti in cui si ferma trascinandolo.
  static const _trayHeights = [0.60, 0.69, 0.76];
  static const _traySnaps = [
    [0.14, 0.60],
    [0.14, 0.69],
    [0.14, 0.76],
  ];
  static const _trayFull = 0.92;

  final _map = MapController();
  final _line = GlobalKey<RouteLineState>();

  /// Spilli già caduti e righe di "Ordina" già entrate.
  final _seenPins = <String>{};
  final _seenRows = <String>{};

  /// Contesto dentro lo stile del viaggio: pannelli e dialoghi aperti da qui
  /// ne ereditano colori e font.
  final _themeKey = GlobalKey();
  BuildContext get _themed => _themeKey.currentContext ?? context;
  final _sheet = DraggableScrollableController();
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  late final SightseeingRouteRepository _routes;
  late final ExploreRepository _explore;

  int _step = 0;
  double _trayInitial = _trayHeights[0];
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
  bool _legsChecked = false;
  String? _suggestKey;
  String? _verifyKey;
  double? _verifiedSaved;
  ({List<String> ids, double saved})? _suggestion;

  // Pianifica.
  String? _pickedDayId;
  bool _daysEnsured = false;

  @override
  void initState() {
    super.initState();
    _routes = ref.read(sightseeingRouteRepositoryProvider);
    _explore = ref.read(exploreRepositoryProvider);
    _searchFocus.addListener(() {
      if (_searchFocus.hasFocus) _trayTo(_trayFull);
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
    if (pts.length >= 2) {
      _map.fitCamera(
        CameraFit.coordinates(
          coordinates: pts,
          padding: _fitPadding(_trayHeights[_step]),
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
    // Photon dà solo nome e indirizzo: con l'id OSM chiedo i dati completi
    // (categoria, orari, ingresso, foto), come per i luoghi sulla mappa.
    final type = r.osmType;
    final id = r.osmId;
    if (type != null && id != null) {
      setState(() => _searchingName = true);
      final poi = await ref
          .read(poiDiscoveryServiceProvider)
          .lookup(type, id, lat: r.latitude, lng: r.longitude);
      if (!mounted) return;
      setState(() => _searchingName = false);
      if (poi != null) {
        final stops = ref.read(routeStopsProvider(widget.routeId)).value ?? [];
        final inRoute = _stopRefs(stops, _locById())
            .where(
              (x) =>
                  x.$2.externalProvider == poi.provider &&
                  x.$2.externalId == poi.externalId,
            )
            .firstOrNull;
        return _openPoi(poi, inRoute?.$1, inRoute?.$2);
      }
    }
    if (!mounted) return;
    await showPlaceSheet(
      _themed,
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

  /// Avviso con "Annulla" e barra del tempo.
  void _undoSnack(String msg, Future<void> Function() onUndo) {
    showUndoSnackBar(context, message: msg, onUndo: () => unawaited(onUndo()));
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
    _undoSnack(l10n.flowRemoved(name), () async {
      await _routes.restoreStop(removed);
      _scheduleRecompute();
    });
  }

  Future<void> _addPinAt(LatLng point) async {
    final l10n = AppLocalizations.of(context);
    final ctrl = TextEditingController();
    final name = await showDialog<String>(
      context: _themed,
      builder: (context) => AlertDialog(
        title: Text(l10n.flowPinTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lo trovi nel percorso con il nome che scegli.',
              style: context.texts.bodyMedium?.copyWith(
                color: context.scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: ctrl,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Nome',
                hintText: l10n.flowPinNameHint,
              ),
              onSubmitted: (v) => Navigator.pop(context, v),
            ),
          ],
        ),
        actions: [
          _DialogCancel(l10n.commonCancel),
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
      _themed,
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
    final stops = ref.read(routeStopsProvider(widget.routeId)).value ?? [];
    final isFirst = stops.isEmpty || stops.first.id == stop.id;
    await showPlaceSheet(
      _themed,
      place: PlaceInfo.fromLocation(loc, visitMinutes: stop.visitMinutes),
      distanceLabel: _distanceLabel(loc.latitude, loc.longitude),
      secondaryAction: PlaceSheetAction(
        label: l10n.placeMoveShort,
        icon: Icons.drive_file_move_outline,
        destructive: true,
        onPressed: () => _moveStop(stop, loc),
      ),
      action: PlaceSheetAction(
        label: l10n.placeRemoveShort,
        icon: Icons.remove_circle_outline,
        destructive: true,
        onPressed: () => _removeStop(stop, loc.label),
      ),
      // Dalla prima tappa "dividere" vorrebbe dire spostare tutto.
      extraAction: isFirst
          ? null
          : PlaceSheetAction(
              label: l10n.placeSplitHere,
              icon: Icons.call_split,
              onPressed: () => _splitFrom(stop.id),
            ),
    );
  }

  /// Divide il percorso: da [fromStopId] in poi le tappe vanno in un
  /// percorso nuovo tra le bozze, con Annulla.
  Future<void> _splitFrom(String fromStopId) async {
    final l10n = AppLocalizations.of(context);
    final route = ref.read(routeByIdProvider(widget.routeId)).value;
    if (route == null) return;
    final name = l10n.splitName(route.name);
    _scheduleRecompute();
    final split = await _routes.splitRoute(widget.routeId, fromStopId, name);
    if (split == null || !mounted) return;
    _undoSnack(l10n.splitDone(name), () async {
      _scheduleRecompute();
      await _routes.undoSplit(widget.routeId, split);
    });
  }

  /// "Dividi in 2 giorni": taglia dove le due parti durano più o meno uguali.
  Future<void> _splitBalanced(
    RouteSchedule schedule,
    List<(SightseeingRouteStop, Location)> refs,
  ) async {
    final k = balancedSplitIndex(schedule);
    if (k == null || k >= refs.length) return;
    await _splitFrom(refs[k].$1.id);
  }

  /// "Sposta": sceglie un altro percorso del viaggio (o ne crea uno nuovo) e
  /// ci porta la tappa, con Annulla.
  Future<void> _moveStop(SightseeingRouteStop stop, Location loc) async {
    final l10n = AppLocalizations.of(context);
    // Elenchi tenuti vivi dal build (vedi "Sposta"): disponibili subito.
    final all = ref.read(routesProvider(widget.tripId)).value ?? const [];
    final tripStops =
        ref.read(tripStopsProvider(widget.tripId)).value ?? const [];
    final dayList =
        ref.read(itineraryDaysProvider(widget.tripId)).value ?? const [];
    final others = [
      for (final r in all)
        if (r.id != widget.routeId) r,
    ];
    final stopCount = <String, int>{};
    for (final s in tripStops) {
      stopCount[s.routeId] = (stopCount[s.routeId] ?? 0) + 1;
    }
    final days = {for (final d in dayList) d.id: d};
    final fromName = ref.read(routeByIdProvider(widget.routeId)).value?.name;
    // Valore restituito: id del percorso, oppure '' per "Nuovo percorso".
    final picked = await _showTraySheet<String>(
      title: l10n.moveTitle,
      subtitle: fromName == null ? loc.label : '${loc.label} lascia $fromName.',
      builder: (context) => [
        for (final (i, r) in others.indexed)
          StaggerIn(
            index: i,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ItineraCard(
                onTap: () => Navigator.pop(context, r.id),
                padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
                child: Row(
                  children: [
                    RouteModeTile(r.travelMode),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.texts.titleMedium,
                          ),
                          Text(
                            [
                              if (days[r.dayId] case final d?)
                                _dayLabel(l10n, d)
                              else
                                l10n.moveDraft,
                              l10n.routeStopsCount(stopCount[r.id] ?? 0),
                            ].join(' · '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.texts.bodySmall?.copyWith(
                              color: context.scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: context.scheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(height: 2),
        SizedBox(
          height: 52,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pop(context, ''),
            icon: const Icon(Icons.add),
            label: Text(l10n.moveNewRoute),
          ),
        ),
      ],
    );
    if (picked == null || !mounted) return;

    var targetId = picked;
    var targetName = others.firstWhereOrNull((r) => r.id == picked)?.name;
    if (picked.isEmpty) {
      targetName = l10n.routeNewName(all.length + 1);
      targetId = await _routes.createRoute(
        tripId: widget.tripId,
        name: targetName,
      );
    }
    _scheduleRecompute();
    final moved = await _routes.moveStop(stop.id, targetId);
    if (moved == null || !mounted) return;
    _undoSnack(
      moved.merged
          ? l10n.movedMerged(targetName ?? '')
          : l10n.movedTo(targetName ?? ''),
      () async {
        _scheduleRecompute();
        await _routes.undoMove(moved, targetId);
        // Il percorso nuovo creato solo per lo spostamento torna via.
        if (picked.isEmpty) await _routes.deleteIfEmpty(targetId);
      },
    );
  }

  // --- Calcolo percorso -----------------------------------------------------

  /// Ricalcolo automatico (a ogni modifica, con un breve ritardo). Fino alla
  /// fine del calcolo i tempi tra le tappe non vengono mostrati: sarebbero
  /// quelli dell'ordine precedente.
  void _scheduleRecompute() {
    if (!mounted) return;
    _recomputeDebounce?.cancel();
    if (!_computing) setState(() => _computing = true);
    _recomputeDebounce = Timer(
      const Duration(milliseconds: 350),
      () => unawaited(_recompute()),
    );
  }

  Future<void> _recompute() async {
    try {
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
          legsJson: encodeLegs(const []),
        );
        return;
      }
      final res = await ref
          .read(routePlannerProvider)
          .plan(pts, route.travelMode, returnToStart: route.returnToStart);
      await _routes.saveComputation(
        widget.routeId,
        distanceMeters: res.distanceMeters.round(),
        durationSeconds: res.durationSeconds.round(),
        geometryJson: encodeGeometry(res.geometry),
        source: res.source,
        legsJson: encodeLegs(res.legs),
      );
    } finally {
      if (mounted && !(_recomputeDebounce?.isActive ?? false)) {
        setState(() => _computing = false);
      }
    }
  }

  /// Tratti salvati, solo se corrispondono alle tappe attuali (altrimenti il
  /// ricalcolo è in corso o va rifatto).
  List<RouteLeg>? _currentLegs(SightseeingRoute route, int coordStops) {
    if (_computing || coordStops < 2) return null;
    final legs = decodeLegs(route.legs);
    final expected = coordStops - 1 + (route.returnToStart ? 1 : 0);
    return legs.length == expected ? legs : null;
  }

  /// Ordine più veloce (id delle tappe) e risparmio stimato, ricalcolato solo
  /// quando cambiano tappe, mezzo o opzioni.
  ({List<String> ids, double saved})? _fasterOrder(
    SightseeingRoute route,
    List<(SightseeingRouteStop, Location)> refs,
  ) {
    final coord = [
      for (final r in refs)
        if (r.$2.latitude != null && r.$2.longitude != null) r,
    ];
    final key = [
      route.travelMode.name,
      route.fixedStart,
      route.returnToStart,
      for (final r in refs) '${r.$1.id}@${r.$2.latitude},${r.$2.longitude}',
    ].join('|');
    if (key == _suggestKey) return _suggestion;
    _suggestKey = key;
    final s = suggestFasterOrder(
      points: [for (final r in coord) LatLng(r.$2.latitude!, r.$2.longitude!)],
      mode: route.travelMode,
      fixedStart: route.fixedStart,
      returnToStart: route.returnToStart,
    );
    final coordIds = {for (final r in coord) r.$1.id};
    _suggestion = s == null
        ? null
        : (
            ids: [
              for (final i in s.order) coord[i].$1.id,
              for (final r in refs)
                if (!coordIds.contains(r.$1.id)) r.$1.id,
            ],
            saved: s.savedSeconds,
          );
    return _suggestion;
  }

  /// Con i tempi calcolati sulle strade, il suggerimento (stimato in linea
  /// d'aria) si mostra solo dopo averlo verificato sulle strade: niente
  /// risparmi promessi che poi non ci sono.
  ({List<String> ids, double saved})? _checkedOnRoads(
    SightseeingRoute route,
    List<(SightseeingRouteStop, Location)> refs,
    ({List<String> ids, double saved}) candidate,
  ) {
    if (route.calcSource != DistanceSource.onlineRouting) return candidate;
    final current = route.durationSeconds;
    if (_computing || current == null) return null;
    final key = '$_suggestKey|$current';
    if (key != _verifyKey) {
      _verifyKey = key;
      _verifiedSaved = null;
      unawaited(_verifyOnRoads(key, route, refs, candidate, current));
      return null;
    }
    final saved = _verifiedSaved;
    return saved == null ? null : (ids: candidate.ids, saved: saved);
  }

  Future<void> _verifyOnRoads(
    String key,
    SightseeingRoute route,
    List<(SightseeingRouteStop, Location)> refs,
    ({List<String> ids, double saved}) candidate,
    int currentSeconds,
  ) async {
    final locByStop = {for (final r in refs) r.$1.id: r.$2};
    final pts = [
      for (final id in candidate.ids)
        if (locByStop[id]?.latitude != null && locByStop[id]?.longitude != null)
          LatLng(locByStop[id]!.latitude!, locByStop[id]!.longitude!),
    ];
    final res = await ref
        .read(routePlannerProvider)
        .plan(pts, route.travelMode, returnToStart: route.returnToStart);
    if (!mounted || key != _verifyKey) return;
    final saved = res.source == DistanceSource.onlineRouting
        ? currentSeconds - res.durationSeconds
        : candidate.saved;
    setState(() => _verifiedSaved = saved >= 120 ? saved : null);
  }

  Future<void> _applyFasterOrder(
    List<String> ids,
    List<String> previous,
  ) async {
    final l10n = AppLocalizations.of(context);
    _scheduleRecompute();
    await _routes.applyOptimizedOrder(widget.routeId, ids);
    if (!mounted) return;
    _undoSnack(l10n.flowOrderChanged, () async {
      _scheduleRecompute();
      await _routes.reorder(widget.routeId, previous);
    });
  }

  /// "Parti da": una tappa (bloccata in testa) oppure la più comoda.
  Future<void> _pickStart() async {
    await _showTraySheet<void>(
      title: AppLocalizations.of(context).flowStartPickTitle,
      builder: (_) => [
        Consumer(
          builder: (context, ref, _) {
            final l10n = AppLocalizations.of(context);
            final route = ref.watch(routeByIdProvider(widget.routeId)).value;
            final stops =
                ref.watch(routeStopsProvider(widget.routeId)).value ??
                const <SightseeingRouteStop>[];
            final locById = {
              for (final l
                  in ref.watch(savedLocationsProvider(widget.tripId)).value ??
                      const <Location>[])
                l.id: l,
            };
            final refs = _stopRefs(stops, locById);
            if (route == null || refs.isEmpty) return const SizedBox.shrink();
            final fixed = route.fixedStart;
            Widget option({
              required bool selected,
              required String title,
              String? subtitle,
              required Future<void> Function() onTap,
            }) => _RadioRow(
              selected: selected,
              title: title,
              subtitle: subtitle,
              onTap: () async {
                final nav = Navigator.of(context);
                _scheduleRecompute();
                await onTap();
                nav.pop();
              },
            );
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                option(
                  selected: !fixed,
                  title: l10n.flowStartAny,
                  subtitle: l10n.flowStartAnyHint,
                  onTap: () => _routes.clearStart(widget.routeId),
                ),
                for (final (i, r) in refs.indexed)
                  option(
                    selected: fixed && i == 0,
                    title: r.$2.label,
                    onTap: () => _routes.setStart(widget.routeId, r.$1.id),
                  ),
                if (fixed) ...[
                  const Divider(),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.flowStartOnly),
                    subtitle: Text(l10n.flowStartOnlyHint),
                    value: refs.first.$1.visitMinutes == 0,
                    onChanged: (v) =>
                        _routes.setVisitMinutes(refs.first.$1.id, v ? 0 : null),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  /// Foglio del flusso: titolo, sottotitolo facoltativo e righe.
  Future<T?> _showTraySheet<T>({
    required String title,
    String? subtitle,
    required List<Widget> Function(BuildContext context) builder,
  }) {
    final theme = Theme.of(_themed);
    return showCartolinaSheet<T>(
      context: _themed,
      builder: (_) => Theme(
        data: theme,
        child: Builder(
          builder: (context) => ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            children: [
              SheetHeader(title),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: context.texts.bodyMedium?.copyWith(
                    color: context.scheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              ...builder(context),
            ],
          ),
        ),
      ),
    );
  }

  // --- Navigazione tra passi e azioni ---------------------------------------

  void _goStep(int step) {
    FocusScope.of(context).unfocus();
    _seenRows.clear();
    setState(() => _step = step);
    if (step >= 1) _fitStops();
    if (step == 2) unawaited(_ensureDays());
    unawaited(_trayToStep(step));
  }

  /// Il vassoio prende l'altezza del passo. Si parte a fine frame: cambiando
  /// passo cambiano anche i punti di aggancio, e l'aggancio deve venire prima.
  Future<void> _trayToStep(int step) async {
    await WidgetsBinding.instance.endOfFrame;
    if (mounted && step == _step) _trayTo(_trayHeights[step]);
  }

  void _trayTo(double size) {
    if (!_sheet.isAttached) return;
    if (Motion.off(context)) {
      _sheet.jumpTo(size);
    } else {
      unawaited(
        _sheet.animateTo(size, duration: Motion.emphasis, curve: Motion.spring),
      );
    }
  }

  /// Margini per inquadrare le tappe nella parte di mappa libera dal vassoio
  /// (alto [tray], in frazione): su schermi bassi la mappa non resta mai a zero.
  EdgeInsets _fitPadding(double tray) {
    final h = _map.camera.nonRotatedSize.height;
    final top = math.min(MediaQuery.paddingOf(context).top + 72, h * 0.3);
    final bottom = math.min(h * tray + 24, math.max(24.0, h - top - 72));
    return EdgeInsets.fromLTRB(48, top, 48, bottom);
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
    _map.fitCamera(
      CameraFit.coordinates(
        coordinates: pts,
        padding: _fitPadding(_trayHeights[_step]),
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
      context: _themed,
      builder: (context) => AlertDialog(
        title: Text(l10n.routeRename),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(labelText: l10n.flowRouteName),
        ),
        actions: [
          _DialogCancel(l10n.commonCancel),
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
      context: _themed,
      builder: (context) {
        final warning = context.tokens.warning;
        return AlertDialog(
          title: Text(l10n.routeDelete),
          content: Text(
            l10n.routeDeleteConfirm,
            style: context.texts.bodyMedium?.copyWith(
              color: context.scheme.onSurfaceVariant,
            ),
          ),
          actions: [
            _DialogCancel(l10n.commonCancel, result: false),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: warning,
                foregroundColor: warning.computeLuminance() > 0.4
                    ? Cartolina.inchiostro
                    : Colors.white,
              ),
              child: Text(l10n.commonDelete),
            ),
          ],
        );
      },
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
    // Tenuti vivi per "Sposta" (elenco degli altri percorsi con tappe e
    // giorno): senza ascoltatori in Riverpod 3 resterebbero in pausa.
    ref.watch(routesProvider(widget.tripId));
    ref.watch(tripStopsProvider(widget.tripId));
    ref.watch(itineraryDaysProvider(widget.tripId));

    if (trip == null || (route == null && routeAsync.isLoading)) {
      return const RouteLoadingView();
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
      _trayInitial = _trayHeights[_step];
    }
    // Percorso calcolato prima dei tratti (o cambiato altrove): ricalcolo.
    if (!_legsChecked && stopsAsync.hasValue && locsAsync.hasValue) {
      _legsChecked = true;
      final coords = refs
          .where((r) => r.$2.latitude != null && r.$2.longitude != null)
          .length;
      final expected = coords < 2
          ? 0
          : coords - 1 + (route.returnToStart ? 1 : 0);
      if (route.legs == null || decodeLegs(route.legs).length != expected) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _scheduleRecompute(),
        );
      }
    }
    if (!_centerInited &&
        _mapReady &&
        stopsAsync.hasValue &&
        locsAsync.hasValue) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _tryInitCenter(trip, [for (final r in refs) r.$2]),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyleOn(context.scheme.surface),
      child: Builder(
        key: _themeKey,
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
    // Un punto sparito e poi tornato (annulla, filtri) ricade.
    _seenPins.retainAll({
      for (final p in stopPts) p.$1.$1.id,
      for (final p in pois) '${p.provider}/${p.externalId}',
    });

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
          RouteLine(key: _line, points: line, color: tokens.accent),
        MarkerLayer(
          markers: [
            for (final (i, p) in pois.indexed)
              Marker(
                point: LatLng(p.lat, p.lng),
                width: 36,
                height: 36,
                child: PinDrop(
                  key: ValueKey('${p.provider}/${p.externalId}'),
                  id: '${p.provider}/${p.externalId}',
                  seen: _seenPins,
                  index: i,
                  child: GestureDetector(
                    onTap: () => _openPoi(p, null, null),
                    child: Center(
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: Cartolina.corallo,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 14,
                          color: Cartolina.inchiostro,
                        ),
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
                child: PinDrop(
                  key: ValueKey(stopPts[i].$1.$1.id),
                  id: stopPts[i].$1.$1.id,
                  seen: _seenPins,
                  index: i,
                  child: RouteStopMarker(
                    number: refs.indexOf(stopPts[i].$1) + 1,
                    onTap: () => _openStop(stopPts[i].$1.$1, stopPts[i].$1.$2),
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
                child: Material(
                  color: context.scheme.surfaceContainerLow,
                  elevation: 2,
                  shape: const StadiumBorder(),
                  child: PillSelector<int>(
                    items: {
                      0: l10n.flowStepChoose,
                      1: l10n.flowStepOrder,
                      2: l10n.flowStepPlan,
                    },
                    selected: _step,
                    onChanged: _goStep,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _RoundMenuButton(
                items: [
                  (Icons.edit, 'Rinomina', false, () => _rename(route)),
                  (Icons.delete, l10n.commonDelete, true, _delete),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// "Cerca qui" sta appena sopra il vassoio e lo segue quando si muove; se
  /// sopra non c'è posto (vassoio tirato su) sparisce.
  Widget _searchHereButton(AppLocalizations l10n) {
    final top = MediaQuery.paddingOf(context).top + 64;
    final button = FilledButton.icon(
      onPressed: () => _discover(force: true),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        minimumSize: const Size(0, 40),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
      icon: const Icon(Icons.search, size: 18),
      label: Text(l10n.flowSearchHere),
    );
    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, box) => AnimatedBuilder(
          animation: _sheet,
          child: button,
          builder: (context, child) {
            final size = _sheet.isAttached ? _sheet.size : _trayInitial;
            final above = box.maxHeight * size + 12;
            if (box.maxHeight - above < top + 40) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: EdgeInsets.only(bottom: above),
              child: Align(alignment: Alignment.bottomCenter, child: child),
            );
          },
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
    final (label, onPressed) = switch (_step) {
      0 => (l10n.flowNextOrder, stops.isEmpty ? null : () => _goStep(1)),
      1 => (l10n.flowNextPlan, stops.isEmpty ? null : () => _goStep(2)),
      _ => (
        l10n.routeAddToItinerary,
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
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: SizedBox(
          height: 56,
          child: FilledButton(onPressed: onPressed, child: Text(label)),
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
    return DraggableScrollableSheet(
      controller: _sheet,
      initialChildSize: _trayInitial,
      minChildSize: 0.14,
      maxChildSize: _trayFull,
      snap: true,
      snapSizes: _traySnaps[_step],
      builder: (context, scroll) => Material(
        color: context.scheme.surface,
        elevation: 8,
        shadowColor: Colors.black54,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        clipBehavior: Clip.antiAlias,
        child: ListView(
          controller: scroll,
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: context.tokens.hairline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            AnimatedSwitcher(
              duration: Motion.of(context, Motion.standard),
              // In alto: i passi hanno altezze diverse e non devono ballare.
              layoutBuilder: (current, previous) => Stack(
                alignment: Alignment.topCenter,
                children: [...previous, ?current],
              ),
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
    OutlineInputBorder pill(Color color, {double width = 1}) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(26),
          borderSide: BorderSide(color: color, width: width),
        );
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
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: Cartolina.cobalto,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                l10n.flowInRoute(refs.length),
                style: context.texts.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
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
            border: pill(context.tokens.hairline),
            enabledBorder: pill(context.tokens.hairline),
            focusedBorder: pill(context.tokens.accent, width: 2),
            suffixIcon: _searchCtrl.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _clearQuery,
                  ),
          ),
        ),
        const SizedBox(height: 10),
        if (_nameResults != null)
          ..._nameResultsList(context, l10n)
        else ...[
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _FilterPill(
                label: l10n.exploreCategoryAll,
                selected: _filters.isEmpty,
                onSelected: (_) => setState(() {
                  _filters.clear();
                  _visible = _pageSize;
                }),
              ),
              for (final c in exploreFilterCategories)
                _FilterPill(
                  label: poiCategoryLabel(l10n, c),
                  selected: _filters.contains(c),
                  onSelected: (on) => setState(() {
                    on ? _filters.add(c) : _filters.remove(c);
                    _visible = _pageSize;
                  }),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ..._discoveryStatus(context, l10n),
          for (final (i, p) in pois.take(_visible).indexed)
            StaggerIn(
              key: ValueKey('${p.provider}/${p.externalId}'),
              index: i,
              child: _poiRow(
                context,
                l10n,
                p,
                stopByKey['${p.provider}/${p.externalId}'],
              ),
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
              const IconTile(
                Icons.travel_explore,
                color: Cartolina.corallo,
                round: true,
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
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(l10n.exploreLoading, style: muted),
        ),
        const _PoiSkeleton(),
        const _PoiSkeleton(),
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
      return const [_PoiSkeleton(), _PoiSkeleton()];
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
      ItineraCard(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (i, r) in results.indexed)
              StaggerIn(
                key: ValueKey('${r.label}/${r.latitude}/${r.longitude}'),
                index: i,
                offset: 12,
                child: PlaceResultRow(
                  place: r,
                  onTap: () => _openNameResult(r),
                ),
              ),
          ],
        ),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ItineraCard(
        onTap: () => _openPoi(p, inRoute?.$1, inRoute?.$2),
        padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
        child: Row(
          children: [
            PoiTile(p.category),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.texts.titleMedium,
                  ),
                  Text(
                    [poiCategoryLabel(l10n, p.category), ?dist].join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.texts.bodySmall?.copyWith(
                      color: context.scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: inRoute != null
                  ? l10n.placeRemoveFromRoute
                  : l10n.placeAddToRoute,
              icon: _PickDot(picked: inRoute != null),
              onPressed: () => inRoute != null
                  ? _removeStop(inRoute.$1, inRoute.$2.label)
                  : _addPoi(p),
            ),
          ],
        ),
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
    final muted = context.texts.bodySmall?.copyWith(
      color: context.scheme.onSurfaceVariant,
    );
    final coordIds = [
      for (final r in refs)
        if (r.$2.latitude != null && r.$2.longitude != null) r.$1.id,
    ];
    final legs = _currentLegs(route, coordIds.length);
    // Tratto che parte da ciascuna tappa (verso la tappa con coordinate dopo).
    final legFrom = <String, RouteLeg>{
      if (legs != null)
        for (var c = 1; c < coordIds.length; c++) coordIds[c - 1]: legs[c - 1],
    };
    final candidate = refs.length >= 3 ? _fasterOrder(route, refs) : null;
    final suggestion = candidate == null
        ? null
        : _checkedOnRoads(route, refs, candidate);
    final first = refs.isEmpty ? null : refs.first;

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
        ] else
          _stats(context, l10n, route),
        if (suggestion != null) ...[
          const SizedBox(height: 10),
          ItineraCard(
            color: Cartolina.sole,
            borderColor: Colors.transparent,
            padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.flowSuggestion(formatDuration(l10n, suggestion.saved)),
                    style: context.texts.bodyMedium?.copyWith(
                      color: Cartolina.inchiostro,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => _applyFasterOrder(suggestion.ids, [
                    for (final r in refs) r.$1.id,
                  ]),
                  style: FilledButton.styleFrom(
                    backgroundColor: Cartolina.inchiostro,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    minimumSize: const Size(0, 40),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: Text(l10n.flowApply),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          // La riga trascinata resta una card, senza ombra quadrata attorno.
          proxyDecorator: (child, _, _) =>
              Material(type: MaterialType.transparency, child: child),
          itemCount: refs.length,
          onReorder: (oldIndex, newIndex) async {
            if (newIndex > oldIndex) newIndex -= 1;
            final ids = refs.map((r) => r.$1.id).toList();
            ids.insert(newIndex, ids.removeAt(oldIndex));
            _scheduleRecompute();
            await _routes.reorder(widget.routeId, ids);
          },
          itemBuilder: (context, i) {
            final (stop, loc) = refs[i];
            final hasCoords = loc.latitude != null && loc.longitude != null;
            final leg = legFrom[stop.id];
            return _RowIn(
              key: ValueKey(stop.id),
              id: stop.id,
              seen: _seenRows,
              index: i,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ItineraCard(
                  onTap: () => _openStop(stop, loc),
                  padding: const EdgeInsets.fromLTRB(12, 6, 2, 6),
                  child: Row(
                    children: [
                      StopNumber(i + 1),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.texts.titleMedium,
                            ),
                            if (!hasCoords)
                              Text(
                                l10n.placeNoCoords,
                                style: context.texts.bodySmall?.copyWith(
                                  color: context.scheme.error,
                                ),
                              )
                            else if (stop.visitMinutes == 0)
                              Text(
                                i == 0 ? l10n.flowStartOnly : l10n.planPassOnly,
                                style: muted,
                              ),
                            if (leg != null)
                              Text(
                                _legText(l10n, route, leg),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: muted,
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: l10n.placeRemoveFromRoute,
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => _removeStop(stop, loc.label),
                      ),
                      ReorderableDragStartListener(
                        index: i,
                        child: const SizedBox(
                          width: 40,
                          height: 48,
                          child: Icon(Icons.drag_handle, size: 22),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        if (legs != null && route.returnToStart && first != null)
          RouteLegRow(
            leg: legs.last,
            mode: route.travelMode,
            estimate: route.calcSource != DistanceSource.onlineRouting,
            label: l10n.flowLegBack(first.$2.label),
          ),
        if (first != null) ...[
          const SizedBox(height: 2),
          ItineraCard(
            onTap: _pickStart,
            padding: const EdgeInsets.fromLTRB(14, 8, 10, 8),
            child: Row(
              children: [
                Icon(Icons.flag, color: context.scheme.onSurfaceVariant),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.flowStartFrom, style: muted),
                      Text(
                        route.fixedStart ? first.$2.label : l10n.flowStartAny,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.texts.titleSmall,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.expand_more),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        Text(l10n.flowHowTitle, style: context.texts.titleMedium),
        const SizedBox(height: 8),
        PillSelector<RouteTravelMode>(
          items: {
            for (final m in RouteTravelMode.values) m: routeModeLabel(l10n, m),
          },
          selected: route.travelMode,
          onChanged: (m) async {
            _scheduleRecompute();
            await _routes.setMode(widget.routeId, m);
          },
        ),
        if (first != null && refs.length >= 2)
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              l10n.flowReturnTo(first.$2.label),
              style: context.texts.bodyMedium,
            ),
            value: route.returnToStart,
            onChanged: (v) async {
              _scheduleRecompute();
              await _routes.setReturnToStart(widget.routeId, v);
            },
          ),
      ],
    );
  }

  /// "8 min a piedi · 650 m" (con "circa" se i tempi sono stimati).
  String _legText(AppLocalizations l10n, SightseeingRoute route, RouteLeg leg) {
    final seconds = leg.durationSeconds < 60 ? 60 : leg.durationSeconds;
    final value =
        '${formatDuration(l10n, seconds)} '
        '${routeModePhrase(route.travelMode)} · '
        '${formatDistance(l10n, leg.distanceMeters)}';
    return route.calcSource == DistanceSource.onlineRouting
        ? value
        : l10n.flowAbout(value);
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
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
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
            style: context.texts.titleLarge?.copyWith(fontSize: 20),
          ),
          Text(_computing ? l10n.routeComputing : source, style: muted),
        ],
      ),
    );
  }

  // --- ③ Pianifica ----------------------------------------------------------

  Future<void> _pickStartTime(SightseeingRoute route) async {
    final current = route.startMinutes ?? 9 * 60;
    final picked = await showTimePicker(
      context: _themed,
      initialTime: TimeOfDay(hour: current ~/ 60, minute: current % 60),
    );
    if (picked == null) return;
    await _routes.setStartMinutes(
      widget.routeId,
      picked.hour * 60 + picked.minute,
    );
  }

  /// Quanto ti fermi: predefinita per categoria, solo partenza/passaggio o
  /// una durata a scelta.
  Future<void> _editVisit(
    SightseeingRouteStop stop,
    Location loc,
    bool first,
  ) async {
    final l10n = AppLocalizations.of(context);
    const options = <int?>[null, 0, 15, 30, 45, 60, 90, 120, 180];
    final picked = await _showTraySheet<({int? minutes})>(
      title: l10n.planVisitTitle,
      subtitle: loc.label,
      builder: (context) => [
        for (final m in options)
          _RadioRow(
            selected: m == stop.visitMinutes,
            title: m == null
                ? l10n.planVisitDefault(
                    formatDuration(
                      l10n,
                      defaultVisitMinutes(loc.poiCategory) * 60,
                    ),
                  )
                : visitLabel(l10n, m, first: first),
            onTap: () => Navigator.pop(context, (minutes: m)),
          ),
      ],
    );
    if (picked == null) return;
    await _routes.setVisitMinutes(stop.id, picked.minutes);
  }

  /// "In quale giorno?": elenco dei giorni (con data prima, poi gli altri).
  Future<void> _pickDay(List<ItineraryDay> days, String? selected) async {
    final l10n = AppLocalizations.of(context);
    final picked = await _showTraySheet<String>(
      title: l10n.flowWhichDay,
      builder: (context) => [
        for (final d in days)
          _RadioRow(
            selected: d.id == selected,
            title: _dayLabel(l10n, d),
            onTap: () => Navigator.pop(context, d.id),
          ),
      ],
    );
    if (picked != null && mounted) setState(() => _pickedDayId = picked);
  }

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
    final selectedDay = days.firstWhereOrNull((d) => d.id == selected);
    final currentDay = days.firstWhereOrNull((d) => d.id == route.dayId);
    final muted = context.texts.bodySmall?.copyWith(
      color: context.scheme.onSurfaceVariant,
    );
    final start = route.startMinutes;
    final schedule = _computing ? null : scheduleForRefs(route, refs);
    final warnings = schedule == null
        ? const <RouteWarning>[]
        : warningsForRefs(
            route,
            refs,
            schedule,
            ref.watch(warningSettingsProvider),
            selectedDay?.date?.weekday,
          );
    final dayWarnings = [
      for (final w in warnings)
        if (w.stopIndex == null) w,
    ];

    // Riquadro compatto "etichetta / valore" per giorno e partenza.
    Widget field({
      required IconData icon,
      required String label,
      required String value,
      required VoidCallback onTap,
      Widget? clear,
    }) => ItineraCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(14, 8, 12, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: muted),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.texts.bodyLarge,
                ),
              ],
            ),
          ),
          ?clear,
          // Alto come un IconButton: i due riquadri restano allineati.
          SizedBox(height: 40, child: Icon(icon, size: 22)),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.flowPlanTitle, style: context.texts.titleLarge),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: field(
                icon: Icons.calendar_today,
                label: l10n.planDay,
                value: selectedDay == null
                    ? l10n.planDayPick
                    : _dayLabel(l10n, selectedDay),
                onTap: () => _pickDay(days, selected),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: field(
                icon: Icons.schedule,
                label: l10n.planStart,
                value: start == null
                    ? l10n.planStartNone
                    : Fmt.timeOfDayMinutes(start),
                onTap: () => _pickStartTime(route),
                clear: start == null
                    ? null
                    : IconButton(
                        tooltip: l10n.planStartClear,
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () =>
                            _routes.setStartMinutes(widget.routeId, null),
                      ),
              ),
            ),
          ],
        ),
        if (currentDay != null) ...[
          const SizedBox(height: 8),
          Text(l10n.flowInItinerary(_dayLabel(l10n, currentDay)), style: muted),
        ],
        if (refs.isNotEmpty) ...[
          SectionHeader(
            l10n.planScheduleTitle,
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 10),
          ),
          if (schedule == null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.planCalculating, style: muted),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: Motion.off(context) ? 0.5 : null,
                      minHeight: 4,
                      color: Cartolina.corallo,
                      backgroundColor: context.tokens.hairline,
                    ),
                  ),
                ],
              ),
            ),
          RouteScheduleList(
            route: route,
            refs: refs,
            schedule: schedule,
            onTapStop: _openStop,
            onEditVisit: _editVisit,
            warnings: warnings,
          ),
          if (dayWarnings.isNotEmpty) ...[
            const SizedBox(height: 2),
            RouteWarningsCard(
              warnings: dayWarnings,
              onSplit: schedule == null
                  ? null
                  : () => _splitBalanced(schedule, refs),
            ),
            const SizedBox(height: 8),
          ],
          if (schedule != null) ...[
            const SizedBox(height: 6),
            RouteScheduleFooter(route: route, schedule: schedule),
            if (start == null) ...[
              const SizedBox(height: 8),
              Text(l10n.planNoTimeHint, style: muted),
            ],
          ],
        ],
        const SizedBox(height: 14),
        ItineraCard(
          onTap: () => _rename(route),
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.flowRouteName, style: muted),
              Text(route.name, style: context.texts.bodyLarge),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(l10n.flowPlanInfo, style: muted),
      ],
    );
  }

  String _dayLabel(AppLocalizations l10n, ItineraryDay d) {
    if (d.title?.trim().isNotEmpty == true) return d.title!;
    if (d.date != null) return routeDayShort(d.date!);
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
      color: context.scheme.surfaceContainerLow,
      shape: const CircleBorder(),
      elevation: 2,
      child: IconButton(
        icon: Icon(icon, color: context.scheme.onSurface),
        tooltip: tooltip,
        onPressed: onPressed,
      ),
    );
  }
}

class _RoundMenuButton extends StatelessWidget {
  const _RoundMenuButton({required this.items});

  /// Icona, etichetta, se è un'azione distruttiva, azione.
  final List<(IconData, String, bool, VoidCallback)> items;

  @override
  Widget build(BuildContext context) {
    final warning = context.tokens.warning;
    return Material(
      color: context.scheme.surfaceContainerLow,
      shape: const CircleBorder(),
      elevation: 2,
      child: PopupMenuButton<int>(
        icon: Icon(Icons.more_vert, color: context.scheme.onSurface),
        onSelected: (i) => items[i].$4(),
        itemBuilder: (_) => [
          for (var i = 0; i < items.length; i++)
            PopupMenuItem(
              value: i,
              child: Row(
                children: [
                  Icon(
                    items[i].$1,
                    size: 20,
                    color: items[i].$3 ? warning : null,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    items[i].$2,
                    style: items[i].$3 ? TextStyle(color: warning) : null,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// "Annulla" dei dialoghi: nel colore del testo, non dell'accento.
class _DialogCancel extends StatelessWidget {
  const _DialogCancel(this.label, {this.result});

  final String label;
  final Object? result;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.pop(context, result),
      style: TextButton.styleFrom(foregroundColor: context.scheme.onSurface),
      child: Text(label),
    );
  }
}

/// Riga con pallino di scelta, nei fogli del flusso.
class _RadioRow extends StatelessWidget {
  const _RadioRow({
    required this.selected,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final bool selected;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: selected ? context.tokens.accent : null,
      ),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      onTap: onTap,
    );
  }
}

/// Filtro per categoria: corallo quando è scelto.
class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      showCheckmark: false,
      selectedColor: Cartolina.corallo,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      side: BorderSide(
        color: selected ? Cartolina.corallo : context.tokens.hairline,
      ),
      labelStyle: context.texts.labelLarge?.copyWith(
        color: selected ? Cartolina.inchiostro : context.scheme.onSurface,
      ),
    );
  }
}

/// Cerchio del luogo nell'elenco: "+" da aggiungere, spunta se è nel percorso.
class _PickDot extends StatelessWidget {
  const _PickDot({required this.picked});

  final bool picked;

  @override
  Widget build(BuildContext context) {
    final on = context.scheme.onSurface;
    return AnimatedScale(
      scale: picked ? 1 : 0.94,
      duration: Motion.of(context, Motion.standard),
      curve: Motion.pop,
      child: AnimatedContainer(
        duration: Motion.of(context, Motion.fast),
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: picked ? Cartolina.cobalto : Colors.transparent,
          border: picked ? null : Border.all(color: on, width: 1.5),
        ),
        child: Icon(
          picked ? Icons.check : Icons.add,
          size: 20,
          color: picked ? Colors.white : on,
        ),
      ),
    );
  }
}

/// Segnaposto di una riga dell'elenco mentre si cerca.
class _PoiSkeleton extends StatelessWidget {
  const _PoiSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Skeleton(height: 66, radius: 20),
    );
  }
}

/// Ingresso in cascata che scatta una volta sola per [id]: trascinando una
/// riga la lista ne crea una copia, e la copia non deve rifare l'ingresso.
class _RowIn extends StatefulWidget {
  const _RowIn({
    super.key,
    required this.id,
    required this.seen,
    required this.index,
    required this.child,
  });

  final String id;
  final Set<String> seen;
  final int index;
  final Widget child;

  @override
  State<_RowIn> createState() => _RowInState();
}

class _RowInState extends State<_RowIn> {
  late final bool _enter = widget.seen.add(widget.id);

  @override
  Widget build(BuildContext context) {
    return _enter
        ? StaggerIn(index: widget.index, child: widget.child)
        : widget.child;
  }
}
