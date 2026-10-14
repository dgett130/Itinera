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
import 'package:itinera/features/explore/route_summary_screen.dart';
import 'package:itinera/features/explore/sightseeing_route_repository.dart';
import 'package:itinera/features/places/geocoding_service.dart';
import 'package:itinera/features/transport/routing_service.dart';
import 'package:itinera/features/settings/route_warnings_screen.dart';
import 'package:itinera/l10n/app_localizations.dart';
import 'package:itinera/providers.dart';

class _FakePoiService implements PoiDiscoveryService {
  _FakePoiService(this._pois, [this._known = const []]);
  final List<PoiSuggestion> _pois;

  /// Luoghi trovabili solo per id (es. dalla ricerca per nome).
  final List<PoiSuggestion> _known;
  @override
  Future<List<PoiSuggestion>> search({
    required double lat,
    required double lng,
    required double radiusMeters,
  }) async => _pois;

  @override
  Future<PoiSuggestion?> lookup(
    String osmType,
    int osmId, {
    required double lat,
    required double lng,
  }) async => [
    ..._pois,
    ..._known,
  ].where((p) => p.externalId == '$osmType/$osmId').firstOrNull;
}

/// Ricerca per nome finta: un solo risultato, con il suo id OpenStreetMap.
class _FakeGeocoding extends GeocodingService {
  @override
  Future<List<PlaceResult>> search(
    String query, {
    int limit = 6,
    double? lat,
    double? lon,
  }) async => const [
    PlaceResult(
      label: 'Galleria Borghese, Roma, Italia',
      latitude: 41.914,
      longitude: 12.492,
      country: 'Italia',
      osmType: 'way',
      osmId: 77,
    ),
  ];
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
    final legs = estimateLegs(
      waypoints: [...orderedPoints, if (returnToStart) orderedPoints.first],
      mode: mode,
    );
    return RouteResult(
      geometry: orderedPoints,
      distanceMeters: est.distanceMeters,
      durationSeconds: est.durationSeconds,
      source: DistanceSource.straightLine,
      effectiveMode: mode,
      legs: [
        for (final l in legs) RouteLeg(l.distanceMeters, l.durationSeconds),
      ],
    );
  }
}

/// Planner "sulle strade" finto: durata fissa ([flatSeconds]) qualunque sia
/// l'ordine, oppure la stima offline marcata come calcolata sulle strade.
class _OnlinePlanner implements RoutePlanner {
  _OnlinePlanner({this.flatSeconds});
  final double? flatSeconds;

  @override
  Future<RouteResult> plan(
    List<LatLng> orderedPoints,
    RouteTravelMode mode, {
    bool returnToStart = false,
  }) async {
    final r = await _OfflinePlanner().plan(
      orderedPoints,
      mode,
      returnToStart: returnToStart,
    );
    return RouteResult(
      geometry: r.geometry,
      distanceMeters: r.distanceMeters,
      durationSeconds: flatSeconds ?? r.durationSeconds,
      source: DistanceSource.onlineRouting,
      effectiveMode: mode,
      legs: r.legs,
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

Widget _app(
  AppDatabase db,
  List<PoiSuggestion> pois,
  Widget home, {
  RoutePlanner? planner,
  GeocodingService? geocoding,
  List<PoiSuggestion> known = const [],
}) {
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
      poiDiscoveryServiceProvider.overrideWithValue(
        _FakePoiService(pois, known),
      ),
      routePlannerProvider.overrideWithValue(planner ?? _OfflinePlanner()),
      // Niente rete nei test: nessuna foto.
      placePhotoProvider.overrideWith((ref, qid) async => null),
      if (geocoding != null)
        geocodingServiceProvider.overrideWithValue(geocoding),
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

  testWidgets('Ordina: tempi tra le tappe, "Applica" l\'ordine più veloce '
      'si annulla, "Parti da" blocca la partenza', (tester) async {
    _tallView(tester);
    final db = AppDatabase.forExecutor(NativeDatabase.memory());
    await AppSeed.ensureSeeded(db);
    final tripId = await _trip(db);
    // Zig-zag nord-sud: l'ordine più veloce è evidente.
    final a = await _location(db, tripId, 'Alfa', 41.89);
    final b = await _location(db, tripId, 'Beta', 41.95);
    final c = await _location(db, tripId, 'Gamma', 41.90);
    final d = await _location(db, tripId, 'Delta', 41.96);
    final repo = SightseeingRouteRepository(db);
    final routeId = await repo.createRoute(
      tripId: tripId,
      name: 'Centro',
      locationIds: [a, b, c, d],
    );
    Future<List<String>> order() async =>
        (await repo.stopsFor(routeId)).map((s) => s.locationId).toList();

    await tester.pumpWidget(
      _app(db, const [], RouteFlowScreen(tripId: tripId, routeId: routeId)),
    );
    await _settle(tester, 16);

    expect(find.text('Metti in ordine'), findsOneWidget);
    expect(find.text('Parti da'), findsOneWidget);
    expect(find.text('Dalla tappa più comoda'), findsOneWidget);
    // Ricalcolo automatico all'apertura: 3 tratti, stimati (niente rete).
    expect(find.textContaining(RegExp(r'^circa .* km$')), findsNWidgets(3));
    expect(find.textContaining('Ordine più veloce: circa'), findsOneWidget);

    await tester.tap(find.text('Applica'));
    await _settle(tester, 12);
    expect(await order(), isNot([a, b, c, d]));
    expect(find.text('Ordine cambiato'), findsOneWidget);
    expect(find.textContaining('Ordine più veloce: circa'), findsNothing);

    await tester.tap(find.text('Annulla'));
    await _settle(tester, 12);
    expect(await order(), [a, b, c, d]);

    // "Parti da" → Gamma: in testa e bloccata.
    await tester.tap(find.text('Dalla tappa più comoda'));
    await _settle(tester, 10);
    expect(find.text('Da dove parti?'), findsOneWidget);
    await tester.tap(find.text('Gamma').last);
    await _settle(tester, 12);
    expect((await order()).first, c);
    expect((await repo.getRoute(routeId))!.fixedStart, isTrue);
    expect(find.text('Torno a Gamma alla fine'), findsOneWidget);
    await _teardown(tester, db);
  });

  testWidgets('Ordina con tempi sulle strade: il suggerimento compare solo se '
      'il risparmio è reale', (tester) async {
    _tallView(tester);
    for (final flat in [true, false]) {
      final db = AppDatabase.forExecutor(NativeDatabase.memory());
      await AppSeed.ensureSeeded(db);
      final tripId = await _trip(db);
      final ids = [
        for (final (n, lat) in [
          ('Alfa', 41.89),
          ('Beta', 41.95),
          ('Gamma', 41.90),
          ('Delta', 41.96),
        ])
          await _location(db, tripId, n, lat),
      ];
      final routeId = await SightseeingRouteRepository(
        db,
      ).createRoute(tripId: tripId, name: 'Centro', locationIds: ids);

      await tester.pumpWidget(
        _app(
          db,
          const [],
          RouteFlowScreen(tripId: tripId, routeId: routeId),
          planner: _OnlinePlanner(flatSeconds: flat ? 3000 : null),
        ),
      );
      await _settle(tester, 20);

      expect(find.text('Tempi calcolati sulle strade'), findsOneWidget);
      expect(
        find.textContaining('Ordine più veloce'),
        flat ? findsNothing : findsOneWidget,
        reason: flat
            ? 'sulle strade ogni ordine dura uguale: niente promesse'
            : 'risparmio confermato sulle strade',
      );
      await _teardown(tester, db);
    }
  });

  testWidgets('Pianifica: partenza, scaletta con orari, durata di visita '
      'modificabile', (tester) async {
    _tallView(tester);
    final db = AppDatabase.forExecutor(NativeDatabase.memory());
    await AppSeed.ensureSeeded(db);
    final tripId = await _trip(db);
    final a = await _location(db, tripId, 'Alfa', 41.89);
    final b = await _location(db, tripId, 'Beta', 41.90);
    final repo = SightseeingRouteRepository(db);
    final routeId = await repo.createRoute(
      tripId: tripId,
      name: 'Centro',
      locationIds: [a, b],
    );
    await repo.setStartMinutes(routeId, 9 * 60);

    await tester.pumpWidget(
      _app(db, const [], RouteFlowScreen(tripId: tripId, routeId: routeId)),
    );
    await _settle(tester, 16);
    await tester.tap(find.text('Pianifica'));
    await _settle(tester, 10);

    expect(find.text('Scaletta'), findsOneWidget);
    expect(find.text('09:00'), findsWidgets);
    expect(find.textContaining('Fine prevista alle'), findsOneWidget);

    await tester.tap(find.text('30 min').first);
    await _settle(tester, 8);
    expect(find.text('Quanto ti fermi?'), findsOneWidget);
    await tester.tap(find.text('1 h'));
    await _settle(tester, 8);
    expect((await repo.stopsFor(routeId)).first.visitMinutes, 60);
    expect(find.text('1 h'), findsOneWidget);
    await _teardown(tester, db);
  });

  testWidgets("Riepilogo dall'itinerario: scaletta in sola lettura e "
      '"Modifica"', (tester) async {
    _tallView(tester);
    final db = AppDatabase.forExecutor(NativeDatabase.memory());
    await AppSeed.ensureSeeded(db);
    final tripId = await _trip(db);
    final a = await _location(db, tripId, 'Alfa', 41.89);
    final b = await _location(db, tripId, 'Beta', 41.90);
    final repo = SightseeingRouteRepository(db);
    final routeId = await repo.createRoute(
      tripId: tripId,
      name: 'Centro',
      locationIds: [a, b],
    );
    await repo.setStartMinutes(routeId, 10 * 60);
    await repo.saveComputation(
      routeId,
      distanceMeters: 1200,
      durationSeconds: 900,
      geometryJson: '[]',
      source: DistanceSource.onlineRouting,
      legsJson: '[{"m":1200,"s":900}]',
    );

    await tester.pumpWidget(
      _app(db, const [], RouteSummaryScreen(tripId: tripId, routeId: routeId)),
    );
    await _settle(tester, 12);

    expect(find.text('Centro'), findsOneWidget);
    expect(find.text('Scaletta'), findsOneWidget);
    expect(find.text('10:00'), findsOneWidget);
    // 30' ad Alfa + 15' di cammino.
    expect(find.text('10:45'), findsOneWidget);
    expect(find.textContaining('Fine prevista alle 11:15'), findsOneWidget);
    expect(
      find.byIcon(Icons.expand_more),
      findsNothing,
      reason: 'sola lettura',
    );
    expect(find.text('Modifica'), findsOneWidget);
    await _teardown(tester, db);
  });

  testWidgets("Pianifica: avviso se un luogo apre dopo l'arrivo", (
    tester,
  ) async {
    _tallView(tester);
    final db = AppDatabase.forExecutor(NativeDatabase.memory());
    await AppSeed.ensureSeeded(db);
    final tripId = await _trip(db);
    final a = await _location(db, tripId, 'Museo', 41.89);
    final b = await _location(db, tripId, 'Chiesa', 41.90);
    await (db.update(db.locations)..where((l) => l.id.equals(a))).write(
      const LocationsCompanion(openingHours: Value('Mo-Su 10:00-18:00')),
    );
    final dayId = newId();
    await db
        .into(db.itineraryDays)
        .insert(
          ItineraryDaysCompanion.insert(
            id: dayId,
            tripId: tripId,
            date: Value(DateTime(2026, 9, 21)), // lunedì
          ),
        );
    final repo = SightseeingRouteRepository(db);
    final routeId = await repo.createRoute(
      tripId: tripId,
      name: 'Centro',
      locationIds: [a, b],
    );
    await repo.addToItinerary(routeId, dayId, tripId);
    await repo.setStartMinutes(routeId, 9 * 60);

    await tester.pumpWidget(
      _app(db, const [], RouteFlowScreen(tripId: tripId, routeId: routeId)),
    );
    await _settle(tester, 16);
    await tester.tap(find.text('Pianifica'));
    await _settle(tester, 10);

    expect(find.text('Apre alle 10:00, arrivi alle 09:00'), findsOneWidget);
    await _teardown(tester, db);
  });

  testWidgets('Impostazioni "Percorsi e avvisi": le scelte restano sul '
      'dispositivo', (tester) async {
    _tallView(tester);
    final db = AppDatabase.forExecutor(NativeDatabase.memory());
    await AppSeed.ensureSeeded(db);

    await tester.pumpWidget(_app(db, const [], const RouteWarningsScreen()));
    await _settle(tester, 6);
    expect(find.text('Oltre 15 km'), findsOneWidget);

    await tester.tap(find.text('Tanta strada a piedi'));
    await _settle(tester, 6);
    expect(await db.getPref('route_warnings'), contains('"walk":false'));

    await tester.tap(find.text('Di più').first);
    await _settle(tester, 6);
    expect(find.text('Dopo le 20:30'), findsOneWidget);
    await _teardown(tester, db);
  });

  testWidgets('Sposta: una tappa va in un nuovo percorso e si può annullare', (
    tester,
  ) async {
    _tallView(tester);
    final db = AppDatabase.forExecutor(NativeDatabase.memory());
    await AppSeed.ensureSeeded(db);
    final tripId = await _trip(db);
    final a = await _location(db, tripId, 'Colosseo', 41.89);
    final b = await _location(db, tripId, 'Pantheon', 41.898);
    final repo = SightseeingRouteRepository(db);
    final routeId = await repo.createRoute(
      tripId: tripId,
      name: 'Percorso 1',
      locationIds: [a, b],
    );
    final other = await repo.createRoute(
      tripId: tripId,
      name: 'Trastevere',
      locationIds: [a],
    );

    await tester.pumpWidget(
      _app(db, const [], RouteFlowScreen(tripId: tripId, routeId: routeId)),
    );
    await _settle(tester, 16);

    // Tocco sulla tappa → scheda con "Sposta" e "Togli".
    await tester.tap(find.text('Pantheon'));
    await _settle(tester, 8);
    await tester.tap(find.text('Sposta'));
    await _settle(tester, 8);
    expect(find.text('Sposta in un altro percorso'), findsOneWidget);
    expect(find.text('Trastevere'), findsOneWidget);

    await tester.tap(find.text('Nuovo percorso'));
    await _settle(tester, 10);
    expect(find.text('Spostato in «Percorso 3»'), findsOneWidget);
    final routes = await db.select(db.sightseeingRoutes).get();
    final created = routes.singleWhere((r) => r.name == 'Percorso 3');
    expect((await repo.stopsFor(created.id)).single.locationId, b);
    expect((await repo.stopsFor(routeId)).single.locationId, a);

    await tester.tap(find.text('Annulla'));
    await _settle(tester, 10);
    expect((await repo.stopsFor(routeId)).map((s) => s.locationId), [a, b]);
    expect(
      (await db.select(db.sightseeingRoutes).get()).map((r) => r.id),
      unorderedEquals([routeId, other]),
      reason: 'il percorso creato solo per lo spostamento viene tolto',
    );
    await _teardown(tester, db);
  });

  testWidgets('Dividi da qui: dalla terza tappa in poi va in una bozza; la '
      'prima tappa non lo propone', (tester) async {
    _tallView(tester);
    final db = AppDatabase.forExecutor(NativeDatabase.memory());
    await AppSeed.ensureSeeded(db);
    final tripId = await _trip(db);
    final ids = [
      for (final (n, lat) in [
        ('Alfa', 41.89),
        ('Beta', 41.90),
        ('Gamma', 41.91),
        ('Delta', 41.92),
      ])
        await _location(db, tripId, n, lat),
    ];
    final repo = SightseeingRouteRepository(db);
    final routeId = await repo.createRoute(
      tripId: tripId,
      name: 'Centro',
      locationIds: ids,
    );

    await tester.pumpWidget(
      _app(db, const [], RouteFlowScreen(tripId: tripId, routeId: routeId)),
    );
    await _settle(tester, 16);

    await tester.tap(find.text('Alfa'));
    await _settle(tester, 8);
    expect(find.text('Dividi da qui'), findsNothing);
    await tester.tapAt(const Offset(600, 40)); // chiude la scheda
    await _settle(tester, 8);

    await tester.tap(find.text('Gamma'));
    await _settle(tester, 8);
    await tester.tap(find.text('Dividi da qui'));
    await _settle(tester, 12);

    expect(find.text('Diviso: «Centro (2)» è tra le bozze'), findsOneWidget);
    expect((await repo.stopsFor(routeId)).map((s) => s.locationId), [
      ids[0],
      ids[1],
    ]);
    final created = (await db.select(db.sightseeingRoutes).get()).singleWhere(
      (r) => r.name == 'Centro (2)',
    );
    expect((await repo.stopsFor(created.id)).map((s) => s.locationId), [
      ids[2],
      ids[3],
    ]);
    await _teardown(tester, db);
  });

  testWidgets('Giornata lunga: "Dividi in 2 giorni" taglia a metà', (
    tester,
  ) async {
    _tallView(tester);
    final db = AppDatabase.forExecutor(NativeDatabase.memory());
    await AppSeed.ensureSeeded(db);
    final tripId = await _trip(db);
    final ids = [
      for (final (n, lat) in [
        ('Alfa', 41.89),
        ('Beta', 41.892),
        ('Gamma', 41.894),
        ('Delta', 41.896),
      ])
        await _location(db, tripId, n, lat),
    ];
    final repo = SightseeingRouteRepository(db);
    final routeId = await repo.createRoute(
      tripId: tripId,
      name: 'Centro',
      locationIds: ids,
    );
    // 4 visite da 3 h: 12 h, oltre le 9 h predefinite.
    for (final s in await repo.stopsFor(routeId)) {
      await repo.setVisitMinutes(s.id, 180);
    }

    await tester.pumpWidget(
      _app(db, const [], RouteFlowScreen(tripId: tripId, routeId: routeId)),
    );
    await _settle(tester, 16);
    await tester.tap(find.text('Pianifica'));
    await _settle(tester, 10);

    expect(find.textContaining('Giornata lunga'), findsOneWidget);
    await tester.tap(find.text('Dividi in 2 giorni'));
    await _settle(tester, 12);

    expect((await repo.stopsFor(routeId)).map((s) => s.locationId), [
      ids[0],
      ids[1],
    ]);
    expect(find.text('Diviso: «Centro (2)» è tra le bozze'), findsOneWidget);
    await _teardown(tester, db);
  });

  testWidgets('Ricerca per nome: il risultato apre la scheda completa (orari, '
      'categoria) e si aggiunge con i suoi dati', (tester) async {
    _tallView(tester);
    final db = AppDatabase.forExecutor(NativeDatabase.memory());
    await AppSeed.ensureSeeded(db);
    final tripId = await _trip(db);
    final routeId = await SightseeingRouteRepository(
      db,
    ).createRoute(tripId: tripId, name: 'Centro');
    const borghese = PoiSuggestion(
      provider: 'osm',
      externalId: 'way/77',
      name: 'Galleria Borghese',
      lat: 41.914,
      lng: 12.492,
      category: PoiCategory.museum,
      openingHours: 'Tu-Su 09:00-19:00',
      fee: 'yes',
      wikidata: 'Q1284',
    );

    await tester.pumpWidget(
      _app(
        db,
        // La scoperta nell'area non lo trova: arriva solo dalla ricerca.
        const [],
        RouteFlowScreen(tripId: tripId, routeId: routeId, startNew: true),
        geocoding: _FakeGeocoding(),
        known: const [borghese],
      ),
    );
    await _settle(tester, 14);
    await tester.enterText(find.byType(TextField), 'Borghese');
    await _settle(tester, 12);
    await tester.tap(find.text('Galleria Borghese, Roma, Italia'));
    await _settle(tester, 10);

    // Scheda "vera": nome OSM, categoria, orari leggibili, ingresso.
    expect(find.text('Galleria Borghese'), findsWidgets);
    expect(find.textContaining('Musei e cultura'), findsOneWidget);
    expect(find.text('Mar–Dom 09:00–19:00'), findsOneWidget);
    expect(find.text('A pagamento'), findsOneWidget);

    await tester.tap(find.text('Aggiungi al percorso').last);
    await _settle(tester, 10);
    final loc = await db.select(db.locations).getSingle();
    expect(loc.externalId, 'way/77');
    expect(loc.openingHours, 'Tu-Su 09:00-19:00');
    expect(loc.wikidata, 'Q1284');
    await _teardown(tester, db);
  });
}
