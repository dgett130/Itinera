import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:itinera/core/enums.dart';
import 'package:itinera/core/id.dart';
import 'package:itinera/data/database.dart';
import 'package:itinera/data/seed.dart';
import 'package:itinera/features/explore/explore_providers.dart';
import 'package:itinera/features/explore/explore_screen.dart';
import 'package:itinera/features/explore/poi_discovery_service.dart';
import 'package:itinera/features/explore/poi_parser.dart';
import 'package:itinera/features/explore/route_builder_screen.dart';
import 'package:itinera/features/explore/sightseeing_route_repository.dart';
import 'package:itinera/l10n/app_localizations.dart';
import 'package:itinera/providers.dart';

class _FakePoiService implements PoiDiscoveryService {
  _FakePoiService(this._handler);
  final Future<List<PoiSuggestion>> Function() _handler;
  @override
  Future<List<PoiSuggestion>> search({
    required double lat,
    required double lng,
    required double radiusMeters,
  }) => _handler();
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

Widget _app(AppDatabase db, PoiDiscoveryService svc, Widget home) {
  final router = GoRouter(
    routes: [GoRoute(path: '/', builder: (_, _) => home)],
  );
  return ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      poiDiscoveryServiceProvider.overrideWithValue(svc),
    ],
    child: MaterialApp.router(
      routerConfig: router,
      locale: const Locale('it'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
}

Future<String> _tripWithCoords(AppDatabase db) async {
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

  testWidgets('Esplora: loading poi -> risultati', (tester) async {
    tester.view.physicalSize = const Size(1200, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final db = AppDatabase.forExecutor(NativeDatabase.memory());
    await AppSeed.ensureSeeded(db);
    final tripId = await _tripWithCoords(db);
    final completer = Completer<List<PoiSuggestion>>();
    final svc = _FakePoiService(() => completer.future);

    await tester.pumpWidget(_app(db, svc, ExploreScreen(tripId: tripId)));
    // Lascia caricare il trip e partire la ricerca automatica.
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.text('Cerco luoghi nei dintorni…'), findsOneWidget);

    completer.complete([_poi('node/1', 'Colosseo', 41.89, 12.49)]);
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.text('Colosseo'), findsWidgets);

    await db.close();
  });

  testWidgets('Esplora: errore di rete mostra lo stato d\'errore', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final db = AppDatabase.forExecutor(NativeDatabase.memory());
    await AppSeed.ensureSeeded(db);
    final tripId = await _tripWithCoords(db);
    final svc = _FakePoiService(
      () => Future.error(const PoiDiscoveryException('offline')),
    );

    await tester.pumpWidget(_app(db, svc, ExploreScreen(tripId: tripId)));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(
      find.text('Impossibile contattare il servizio dei luoghi'),
      findsOneWidget,
    );

    await db.close();
  });

  testWidgets('Costruttore percorso: mostra le tappe manuali in ordine', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final db = AppDatabase.forExecutor(NativeDatabase.memory());
    await AppSeed.ensureSeeded(db);
    final tripId = await _tripWithCoords(db);
    final l1 = newId();
    final l2 = newId();
    await db
        .into(db.locations)
        .insert(
          LocationsCompanion.insert(
            id: l1,
            tripId: tripId,
            label: 'Colosseo',
            latitude: const Value(41.89),
            longitude: const Value(12.49),
          ),
        );
    await db
        .into(db.locations)
        .insert(
          LocationsCompanion.insert(
            id: l2,
            tripId: tripId,
            label: 'Pantheon',
            latitude: const Value(41.898),
            longitude: const Value(12.476),
          ),
        );
    final routeId = await SightseeingRouteRepository(
      db,
    ).createRoute(tripId: tripId, name: 'Centro', locationIds: [l1, l2]);

    final svc = _FakePoiService(() async => const []);
    await tester.pumpWidget(
      _app(db, svc, RouteBuilderScreen(tripId: tripId, routeId: routeId)),
    );
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(find.text('Colosseo'), findsOneWidget);
    expect(find.text('Pantheon'), findsOneWidget);
    expect(find.text('Centro'), findsWidgets); // titolo appbar

    await db.close();
  });
}
