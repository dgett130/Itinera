import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:itinera/core/enums.dart';
import 'package:itinera/core/id.dart';
import 'package:itinera/core/visit_duration.dart';
import 'package:itinera/data/database.dart';
import 'package:itinera/data/seed.dart';
import 'package:itinera/features/explore/explore_providers.dart';
import 'package:itinera/features/explore/opening_hours.dart';
import 'package:itinera/features/explore/poi_discovery_service.dart';
import 'package:itinera/features/explore/poi_parser.dart';
import 'package:itinera/features/explore/route_flow_screen.dart';
import 'package:itinera/features/explore/route_math.dart';
import 'package:itinera/features/explore/route_planner.dart';
import 'package:itinera/features/transport/routing_service.dart';
import 'package:latlong2/latlong.dart';
import 'package:itinera/features/explore/sightseeing_route_repository.dart';
import 'package:itinera/l10n/app_localizations.dart';
import 'package:itinera/providers.dart';

class _FakePoiService implements PoiDiscoveryService {
  _FakePoiService(this._pois);
  final List<PoiSuggestion> _pois;
  @override
  Future<List<PoiSuggestion>> search({
    required double lat,
    required double lng,
    required double radiusMeters,
  }) async => _pois;
}

class _OfflinePlanner implements RoutePlanner {
  @override
  Future<RouteResult> plan(
    List<LatLng> orderedPoints,
    RouteTravelMode mode, {
    bool returnToStart = false,
  }) async {
    final est = estimateTravel(
      orderedPoints: orderedPoints,
      mode: mode,
      returnToStart: returnToStart,
    );
    return RouteResult(
      geometry: orderedPoints,
      distanceMeters: est.distanceMeters,
      durationSeconds: est.durationSeconds,
      source: DistanceSource.straightLine,
      effectiveMode: mode,
    );
  }
}

Widget _app(AppDatabase db, PoiDiscoveryService svc, Widget home) {
  final router = GoRouter(
    routes: [GoRoute(path: '/', builder: (_, _) => home)],
  );
  return ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      poiDiscoveryServiceProvider.overrideWithValue(svc),
      routePlannerProvider.overrideWithValue(_OfflinePlanner()),
    ],
    child: MaterialApp.router(
      routerConfig: router,
      locale: const Locale('it'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
}

Future<void> _settle(WidgetTester tester, [int frames = 8]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 60));
  }
}

Future<String> _trip(AppDatabase db) async {
  final id = newId();
  await db
      .into(db.trips)
      .insert(
        TripsCompanion.insert(
          id: id,
          name: 'Roma',
          destinationLat: const Value(41.9028),
          destinationLng: const Value(12.4964),
        ),
      );
  return id;
}

void main() {
  setUpAll(() async => initializeDateFormatting('it_IT', null));

  group('Durata di visita predefinita', () {
    test('per categoria', () {
      expect(defaultVisitMinutes(PoiCategory.museum), 90);
      expect(defaultVisitMinutes(PoiCategory.monument), 45);
      expect(defaultVisitMinutes(PoiCategory.viewpoint), 20);
    });
    test('categoria sconosciuta = 30 minuti', () {
      expect(defaultVisitMinutes(null), 30);
      expect(defaultVisitMinutes(PoiCategory.other), 30);
    });
  });

  group('Orari di apertura leggibili', () {
    test('regole multiple con giorno di chiusura', () {
      expect(
        humanizeOpeningHours('Mo-Fr 09:00-18:00; Sa 10:00-13:00; Su off'),
        ['Lun–Ven 09:00–18:00', 'Sab 10:00–13:00', 'Dom chiuso'],
      );
    });
    test('sempre aperto', () {
      expect(humanizeOpeningHours('24/7'), ['Sempre aperto']);
    });
    test('liste di giorni e più fasce orarie', () {
      expect(humanizeOpeningHours('Mo,We,Fr 10:00-12:00,15:00-17:00'), [
        'Lun, Mer, Ven 10:00–12:00, 15:00–17:00',
      ]);
    });
    test('mesi e festivi', () {
      expect(humanizeOpeningHours('Apr-Oct Mo-Su 09:00-19:00; PH off'), [
        'Apr–ott Lun–Dom 09:00–19:00',
        'Festivi chiuso',
      ]);
    });
    test('vuoto', () {
      expect(humanizeOpeningHours('  '), isEmpty);
    });
  });

  testWidgets('Scegli: tocco su un suggerimento apre la scheda; "Aggiungi al '
      'percorso" lo aggiunge', (tester) async {
    tester.view.physicalSize = const Size(1200, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final db = AppDatabase.forExecutor(NativeDatabase.memory());
    await AppSeed.ensureSeeded(db);
    final tripId = await _trip(db);
    final routeId = await SightseeingRouteRepository(
      db,
    ).createRoute(tripId: tripId, name: 'Centro');
    final svc = _FakePoiService([
      const PoiSuggestion(
        provider: 'osm',
        externalId: 'node/1',
        name: 'Colosseo',
        lat: 41.8902,
        lng: 12.4922,
        category: PoiCategory.monument,
        openingHours: 'Mo-Su 09:00-19:00',
        description: 'Anfiteatro romano',
      ),
    ]);

    await tester.pumpWidget(
      _app(
        db,
        svc,
        RouteFlowScreen(tripId: tripId, routeId: routeId, startNew: true),
      ),
    );
    await _settle(tester, 14);

    await tester.tap(find.text('Colosseo'));
    await _settle(tester);

    // Scheda: orari leggibili, durata stimata, azione principale.
    expect(find.text('Lun–Dom 09:00–19:00'), findsOneWidget);
    expect(find.text('Visita di circa 45 min'), findsOneWidget);
    expect(find.text('Aggiungi al percorso'), findsOneWidget);

    await tester.tap(find.text('Aggiungi al percorso'));
    await _settle(tester, 12);

    final saved = await db.select(db.locations).get();
    expect(saved.map((l) => l.label), ['Colosseo']);
    expect(saved.single.openingHours, 'Mo-Su 09:00-19:00');
    expect(await db.select(db.sightseeingRouteStops).get(), hasLength(1));

    await tester.pumpWidget(const SizedBox());
    await _settle(tester, 12);
    await db.close();
  });

  testWidgets('Ordina: tocco su una tappa apre la scheda con note e '
      '"Togli dal percorso"', (tester) async {
    tester.view.physicalSize = const Size(1200, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final db = AppDatabase.forExecutor(NativeDatabase.memory());
    await AppSeed.ensureSeeded(db);
    final tripId = await _trip(db);
    final l1 = newId();
    final l2 = newId();
    for (final (id, name, lat) in [
      (l1, 'Colosseo', 41.89),
      (l2, 'Pantheon', 41.898),
    ]) {
      await db
          .into(db.locations)
          .insert(
            LocationsCompanion.insert(
              id: id,
              tripId: tripId,
              label: name,
              latitude: Value(lat),
              longitude: const Value(12.48),
              notes: const Value('Prenotare'),
            ),
          );
    }
    final routeId = await SightseeingRouteRepository(
      db,
    ).createRoute(tripId: tripId, name: 'Centro', locationIds: [l1, l2]);

    await tester.pumpWidget(
      _app(
        db,
        _FakePoiService(const []),
        RouteFlowScreen(tripId: tripId, routeId: routeId),
      ),
    );
    await _settle(tester, 14);

    await tester.tap(find.text('Pantheon'));
    await _settle(tester);

    expect(find.text('Togli dal percorso'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Prenotare'), findsOneWidget);

    await tester.tap(find.text('Togli dal percorso'));
    await _settle(tester, 12);

    final stops = await db.select(db.sightseeingRouteStops).get();
    expect(stops.map((s) => s.locationId), [l1]);

    await tester.pumpWidget(const SizedBox());
    await _settle(tester, 12);
    await db.close();
  });
}
