import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import 'package:itinera/core/enums.dart';
import 'package:itinera/features/explore/route_math.dart';

/// Punti su una linea (lat fissa) a longitudini crescenti: cosi' l'ordine
/// ottimo e' quello monotono e le lunghezze sono facili da verificare.
LatLng _p(double lng) => LatLng(0, lng);

void main() {
  group('haversine', () {
    test('Roma-Milano ~ 477 km', () {
      final rome = LatLng(41.9028, 12.4964);
      final milan = LatLng(45.4642, 9.1900);
      final km = haversineMeters(rome, milan) / 1000;
      expect(km, closeTo(477, 15));
    });
  });

  group('optimizeRouteOrder', () {
    test('riordina uno zig-zag e non peggiora mai l\'ordine iniziale', () {
      // Indici dati in ordine zig-zag lungo la linea: 0,2,4,1,3.
      final pts = [_p(0), _p(2), _p(4), _p(1), _p(3)];
      final d = distanceMatrixMeters(pts);
      final initialLen = pathLengthMeters([0, 1, 2, 3, 4], d);
      final res = optimizeRouteOrder(points: pts);
      // Permutazione valida.
      expect(res.order.toSet(), {0, 1, 2, 3, 4});
      // Non peggiore dell'ordine iniziale.
      expect(res.lengthMeters, lessThanOrEqualTo(initialLen + 1e-6));
      // In pratica trova l'ordine monotono (0,3,1,4,2 = lng 0,1,2,3,4).
      final lngs = res.order.map((i) => pts[i].longitude).toList();
      final sorted = [...lngs]..sort();
      expect(lngs, sorted);
    });

    test('deterministico: due esecuzioni danno lo stesso ordine', () {
      final pts = [_p(0), _p(3), _p(1), _p(4), _p(2)];
      final a = optimizeRouteOrder(points: pts);
      final b = optimizeRouteOrder(points: pts);
      expect(a.order, b.order);
    });

    test('rispetta la partenza fissa (indice 0)', () {
      final pts = [_p(4), _p(0), _p(1), _p(2), _p(3)];
      final res = optimizeRouteOrder(points: pts, fixedStart: true);
      expect(res.order.first, 0);
    });

    test('rispetta l\'arrivo fisso (ultimo indice)', () {
      final pts = [_p(0), _p(3), _p(1), _p(2), _p(4)];
      final res = optimizeRouteOrder(points: pts, fixedEnd: true);
      expect(res.order.last, pts.length - 1);
    });

    test('ritorno alla partenza: la lunghezza include l\'anello', () {
      final pts = [_p(0), _p(1), _p(2), _p(3)];
      final d = distanceMatrixMeters(pts);
      final res = optimizeRouteOrder(points: pts, returnToStart: true);
      final open = pathLengthMeters(res.order, d);
      final loop = pathLengthMeters(res.order, d, returnToStart: true);
      expect(loop, greaterThan(open));
    });

    test('meno di 2 tappe: ordine invariato, lunghezza 0', () {
      expect(optimizeRouteOrder(points: [_p(0)]).order, [0]);
      expect(optimizeRouteOrder(points: <LatLng>[]).order, isEmpty);
      expect(optimizeRouteOrder(points: [_p(0)]).lengthMeters, 0);
    });

    test('coordinate duplicate: nessun crash, permutazione valida', () {
      final pts = [_p(0), _p(1), _p(1), _p(2)];
      final res = optimizeRouteOrder(points: pts);
      expect(res.order.toSet(), {0, 1, 2, 3});
    });

    test('oltre maxStops l\'ordine resta invariato', () {
      final pts = List.generate(30, (i) => _p((30 - i).toDouble()));
      final res = optimizeRouteOrder(points: pts, maxStops: 25);
      expect(res.order, List.generate(30, (i) => i));
    });
  });

  group('estimateTravel', () {
    test(
      'distanza = linea d\'aria x fattore; durata coerente con la velocita\'',
      () {
        final pts = [_p(0), _p(0.1)];
        final straight = haversineMeters(pts[0], pts[1]);
        final est = estimateTravel(
          orderedPoints: pts,
          mode: RouteTravelMode.walk,
        );
        final profile = travelModeProfiles[RouteTravelMode.walk]!;
        expect(
          est.distanceMeters,
          closeTo(straight * profile.detourFactor, 1e-3),
        );
        final speedMs = profile.speedKmh * 1000 / 3600;
        expect(
          est.durationSeconds,
          closeTo(est.distanceMeters / speedMs, 1e-3),
        );
      },
    );

    test('il ritorno alla partenza aumenta la distanza', () {
      final pts = [_p(0), _p(1), _p(2)];
      final open = estimateTravel(
        orderedPoints: pts,
        mode: RouteTravelMode.car,
      );
      final loop = estimateTravel(
        orderedPoints: pts,
        mode: RouteTravelMode.car,
        returnToStart: true,
      );
      expect(loop.distanceMeters, greaterThan(open.distanceMeters));
    });
  });
}
