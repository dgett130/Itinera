import 'package:flutter_test/flutter_test.dart';
import 'package:itinera/core/calc/fuel_calculator.dart';
import 'package:itinera/core/enums.dart';

void main() {
  group('FuelCalculator.compute', () {
    test('calcolo base benzina: 100 km, 6 L/100km, 1,80 EUR/L', () {
      final r = FuelCalculator.compute(
        distanceKm: 100,
        consumptionValue: 6,
        consumptionUnit: ConsumptionUnit.lPer100km,
        pricePerUnitCents: 180,
      );
      expect(r.units, closeTo(6.0, 1e-9));
      expect(r.costCents, 1080); // 6 L * 1,80 EUR = 10,80 EUR
    });

    test('andata/ritorno raddoppia consumo e costo', () {
      final r = FuelCalculator.compute(
        distanceKm: 100,
        consumptionValue: 6,
        consumptionUnit: ConsumptionUnit.lPer100km,
        pricePerUnitCents: 180,
        roundTrip: true,
      );
      expect(r.units, closeTo(12.0, 1e-9));
      expect(r.costCents, 2160);
    });

    test('conversione km/L in L/100km', () {
      // 20 km/L => 5 L/100km => su 200 km = 10 L
      final r = FuelCalculator.compute(
        distanceKm: 200,
        consumptionValue: 20,
        consumptionUnit: ConsumptionUnit.kmPerL,
        pricePerUnitCents: 200,
      );
      expect(r.units, closeTo(10.0, 1e-9));
      expect(r.costCents, 2000);
    });

    test('elettrico in kWh/100km', () {
      final r = FuelCalculator.compute(
        distanceKm: 250,
        consumptionValue: 18,
        consumptionUnit: ConsumptionUnit.kwhPer100km,
        pricePerUnitCents: 40, // 0,40 EUR/kWh
      );
      expect(r.units, closeTo(45.0, 1e-9)); // 2,5 * 18
      expect(r.costCents, 1800); // 45 * 0,40
    });

    test('input non validi producono zero, mai un costo fasullo', () {
      for (final bad in [
        FuelCalculator.compute(
          distanceKm: 0,
          consumptionValue: 6,
          consumptionUnit: ConsumptionUnit.lPer100km,
          pricePerUnitCents: 180,
        ),
        FuelCalculator.compute(
          distanceKm: 100,
          consumptionValue: -1,
          consumptionUnit: ConsumptionUnit.lPer100km,
          pricePerUnitCents: 180,
        ),
        FuelCalculator.compute(
          distanceKm: 100,
          consumptionValue: 6,
          consumptionUnit: ConsumptionUnit.lPer100km,
          pricePerUnitCents: 0,
        ),
      ]) {
        expect(bad.units, 0);
        expect(bad.costCents, 0);
      }
    });

    test('toPer100km inverte correttamente km/L', () {
      expect(FuelCalculator.toPer100km(20, ConsumptionUnit.kmPerL),
          closeTo(5.0, 1e-9));
      expect(FuelCalculator.toPer100km(6, ConsumptionUnit.lPer100km), 6.0);
    });
  });
}
