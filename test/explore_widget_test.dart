import 'package:drift/drift.dart' show OrderingTerm, Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:latlong2/latlong.dart';

import 'package:itinera/core/enums.dart';
import 'package:itinera/core/id.dart';
import 'package:itinera/data/database.dart';
import 'package:itinera/data/seed.dart';
import 'package:itinera/features/explore/explore_providers.dart';
import 'package:itinera/features/explore/places_home_screen.dart';
import 'package:itinera/features/explore/poi_discovery_service.dart';
import 'package:itinera/features/explore/poi_parser.dart';
import 'package:itinera/features/explore/route_flow_screen.dart';
import 'package:itinera/features/explore/route_math.dart';
import 'package:itinera/features/explore/route_planner.dart';
import 'package:itinera/features/explore/sightseeing_route_repository.dart';
import 'package:itinera/features/transport/routing_service.dart';
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

/// Planner senza rete: sempre la stima offline (niente chiamate HTTP nei test).
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

PoiSuggestion _poi(String id, String name, double lat, double lng) =>
    PoiSuggestion(
      provider: 'osm',
      externalId: id,
      name: name,
      lat: lat,
      lng: lng,
      category: PoiCategory.monument,
    );

Widget _app(AppDatabase db, List<PoiSuggestion> pois, Widget home) {
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => home),
      GoRoute(
        path: '/trip/:id/route/:routeId',
        builder: (_, s) => RouteFlowScreen(
          tripId: s.pathParameters['id']!,
          routeId: s.pathParameters['routeId']!,
          startNew: s.uri.queryParameters['new'] == '1',
        ),
      ),
    ],
  );
  return ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      poiDiscoveryServiceProvider.overrideWithValue(_FakePoiService(pois)),
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

Future<void> _settle(WidgetTester tester, [int frames = 10]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 60));
  }
}

/// Smonta l'albero (fa girare i dispose) PRIMA di chiudere il DB.
Future<void> _teardown(WidgetTester tester, AppDatabase db) async {
  await tester.pumpWidget(const SizedBox());
  await _settle(tester, 12);
  await db.close();
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

Future<String> _location(
  AppDatabase db,
  String tripId,
  String label,
  double lat, {
  LocationSource source = LocationSource.osm,
}) async {
  final id = newId();
  await db
      .into(db.locations)
      .insert(
        LocationsCompanion.insert(
          id: id,
          tripId: tripId,
          label: label,
          latitude: Value(lat),
          longitude: const Value(12.48),
          source: Value(source),
        ),
      );
  return id;
}

void _tallView(WidgetTester tester) {
  tester.view.physicalSize = const Size(1200, 4000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void main() {
  setUpAll(() async => initializeDateFormatting('it_IT', null));

  testWidgets('Pagina iniziale vuota: invito a creare il primo percorso', (
    tester,
  ) async {
    _tallView(tester);
    final db = AppDatabase.forExecutor(NativeDatabase.memory());
    await AppSeed.ensureSeeded(db);
    final tripId = await _trip(db);

    await tester.pumpWidget(
      _app(db, const [], PlacesHomeScreen(tripId: tripId)),
    );
    await _settle(tester);

    expect(find.text('Crea il tuo primo percorso'), findsOneWidget);
    expect(find.text('Nuovo percorso'), findsOneWidget);
    await _teardown(tester, db);
  });

  testWidgets('Pagina iniziale: i vecchi luoghi salvati diventano la bozza '
      '"Luoghi salvati"', (tester) async {
    _tallView(tester);
    final db = AppDatabase.forExecutor(NativeDatabase.memory());
    await AppSeed.ensureSeeded(db);
    final tripId = await _trip(db);
    await _location(db, tripId, 'Colosseo', 41.89);
    await _location(db, tripId, 'Pantheon', 41.898);

    await tester.pumpWidget(
      _app(db, const [], PlacesHomeScreen(tripId: tripId)),
    );
    await _settle(tester, 14);

    expect(find.text('Luoghi salvati'), findsOneWidget);
    expect(find.text('Bozza'), findsOneWidget);
    expect(find.textContaining('2 tappe'), findsOneWidget);
    await _teardown(tester, db);
  });

  testWidgets('Scegli: il [+] aggiunge il luogo al percorso', (tester) async {
    _tallView(tester);
    final db = AppDatabase.forExecutor(NativeDatabase.memory());
    await AppSeed.ensureSeeded(db);
    final tripId = await _trip(db);
    final routeId = await SightseeingRouteRepository(
      db,
    ).createRoute(tripId: tripId, name: 'Centro');

    await tester.pumpWidget(
      _app(db, [
        _poi('node/1', 'Colosseo', 41.8902, 12.4922),
        _poi('node/2', 'Pantheon', 41.8986, 12.4768),
      ], RouteFlowScreen(tripId: tripId, routeId: routeId, startNew: true)),
    );
    await _settle(tester, 14);

    expect(find.text('Scegli cosa vedere'), findsOneWidget);
    expect(find.text('Colosseo'), findsOneWidget);

    await tester.tap(find.byTooltip('Aggiungi al percorso').first);
    await _settle(tester, 12);

    final stops = await db.select(db.sightseeingRouteStops).get();
    expect(stops, hasLength(1));
    expect(find.text('1 luogo'), findsOneWidget);
    expect(find.textContaining('Aggiunto:'), findsOneWidget);
    await _teardown(tester, db);
  });

  testWidgets('Percorso esistente: si apre su "Ordina"; togliere una tappa '
      'si può annullare', (tester) async {
    _tallView(tester);
    final db = AppDatabase.forExecutor(NativeDatabase.memory());
    await AppSeed.ensureSeeded(db);
    final tripId = await _trip(db);
    final l1 = await _location(db, tripId, 'Colosseo', 41.89);
    final l2 = await _location(db, tripId, 'Pantheon', 41.898);
    final routeId = await SightseeingRouteRepository(
      db,
    ).createRoute(tripId: tripId, name: 'Centro', locationIds: [l1, l2]);

    await tester.pumpWidget(
      _app(db, const [], RouteFlowScreen(tripId: tripId, routeId: routeId)),
    );
    await _settle(tester, 14);

    expect(find.text('Metti in ordine'), findsOneWidget);
    expect(find.text('Colosseo'), findsOneWidget);
    expect(find.text('Pantheon'), findsOneWidget);

    await tester.tap(find.byTooltip('Togli dal percorso').last);
    await _settle(tester, 10);
    expect(find.text('Tolto: Pantheon'), findsOneWidget);
    expect(
      (await db.select(db.locations).get()).map((l) => l.label),
      ['Colosseo'],
      reason: 'il luogo tolto non era usato altrove: eliminato',
    );

    await tester.tap(find.text('Annulla'));
    await _settle(tester, 10);
    final stops = await (db.select(
      db.sightseeingRouteStops,
    )..orderBy([(s) => OrderingTerm(expression: s.sequenceIndex)])).get();
    expect(stops.map((s) => s.locationId), [l1, l2]);
    await _teardown(tester, db);
  });
}
