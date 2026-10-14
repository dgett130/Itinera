import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../providers.dart';
import '../places/geocoding_service.dart';
import '../transport/routing_service.dart';
import 'explore_repository.dart';
import 'place_photo_service.dart';
import 'poi_discovery_service.dart';
import 'route_planner.dart';
import 'sightseeing_route_repository.dart';

final routingServiceProvider = Provider<RoutingService>((ref) {
  final s = RoutingService();
  ref.onDispose(s.dispose);
  return s;
});

final poiDiscoveryServiceProvider = Provider<PoiDiscoveryService>((ref) {
  final s = OverpassPoiService();
  ref.onDispose(s.dispose);
  return s;
});

final geocodingServiceProvider = Provider<GeocodingService>(
  (ref) => GeocodingService(),
);

final placePhotoServiceProvider = Provider<PlacePhotoService>(
  (ref) => PlacePhotoService(),
);

/// Foto del luogo per codice Wikidata. Non autoDispose: resta in memoria per
/// la sessione, così riaprendo una scheda non si rifà la richiesta.
final placePhotoProvider = FutureProvider.family<PlacePhoto?, String>(
  (ref, wikidata) => ref.watch(placePhotoServiceProvider).forWikidata(wikidata),
);

/// Da URL a immagine (rete con lo User-Agent richiesto da Wikimedia).
/// Sostituibile nei test, dove la rete non c'è.
final placePhotoImageProvider = Provider<ImageProvider Function(String url)>(
  (ref) =>
      (url) => NetworkImage(url, headers: PlacePhotoService.headers),
);

final routePlannerProvider = Provider<RoutePlanner>((ref) {
  return RoutePlanner(ref.watch(routingServiceProvider));
});

final exploreRepositoryProvider = Provider<ExploreRepository>((ref) {
  return ExploreRepository(
    ref.watch(databaseProvider),
    ref.watch(poiDiscoveryServiceProvider),
  );
});

final sightseeingRouteRepositoryProvider = Provider<SightseeingRouteRepository>(
  (ref) {
    return SightseeingRouteRepository(ref.watch(databaseProvider));
  },
);

final routesProvider = StreamProvider.family<List<SightseeingRoute>, String>((
  ref,
  tripId,
) {
  return ref.watch(sightseeingRouteRepositoryProvider).watchRoutes(tripId);
});

final routeStopsProvider =
    StreamProvider.family<List<SightseeingRouteStop>, String>((ref, routeId) {
      return ref.watch(sightseeingRouteRepositoryProvider).watchStops(routeId);
    });

final routeByIdProvider = StreamProvider.family<SightseeingRoute?, String>((
  ref,
  routeId,
) {
  return ref.watch(sightseeingRouteRepositoryProvider).watchRoute(routeId);
});

final savedLocationsProvider = StreamProvider.family<List<Location>, String>((
  ref,
  tripId,
) {
  return ref.watch(exploreRepositoryProvider).watchSavedLocations(tripId);
});

/// Tutte le tappe del viaggio (conteggi nella pagina iniziale).
final tripStopsProvider =
    StreamProvider.family<List<SightseeingRouteStop>, String>((ref, tripId) {
      return ref
          .watch(sightseeingRouteRepositoryProvider)
          .watchTripStops(tripId);
    });
