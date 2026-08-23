import 'package:flutter_test/flutter_test.dart';
import 'package:itinera/core/calc/distance.dart';

void main() {
  group('Distance', () {
    test('haversine Roma-Milano ~477 km in linea d\'aria', () {
      final km = Distance.haversineKm(41.9028, 12.4964, 45.4642, 9.1900);
      expect(km, closeTo(477, 15));
    });

    test('stessa posizione = 0 km', () {
      expect(Distance.haversineKm(45, 9, 45, 9), closeTo(0, 1e-6));
    });

    test('roadEstimate applica il fattore percorso', () {
      final straight = Distance.haversineKm(45.0, 9.0, 45.5, 9.5);
      final road = Distance.roadEstimateKm(45.0, 9.0, 45.5, 9.5,
          detourFactor: 1.3);
      expect(road, closeTo(straight * 1.3, 1e-6));
    });
  });
}
