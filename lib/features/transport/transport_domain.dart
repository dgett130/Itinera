import '../../core/calc/fuel_calculator.dart';
import '../../core/enums.dart';
import '../../data/database.dart';

/// Logica di dominio del modulo Trasporto (pura, testabile).

/// Litri/kWh consumati da una tratta a motore, o null se non calcolabile.
double? segmentFuelUnits(TransportSegment s) {
  if (!s.mode.burnsFuel) return null;
  final dist = s.distanceKm;
  final cons = s.consumptionSnapshot;
  final unit = s.consumptionUnitSnapshot;
  if (dist == null || cons == null || unit == null) return null;
  return FuelCalculator.compute(
    distanceKm: dist,
    consumptionValue: cons,
    consumptionUnit: unit,
    pricePerUnitCents: s.fuelPriceCentsSnapshot ?? 1,
    roundTrip: s.isRoundTrip,
  ).units;
}

/// Costo stimato di una tratta in centesimi.
///
/// Per i mezzi a motore = carburante (distanza x consumo x prezzo). Per gli
/// altri = costo inserito manualmente (biglietto). Ritorna 0 se non calcolabile.
int segmentEstimatedCents(TransportSegment s) {
  if (s.mode.burnsFuel) {
    final dist = s.distanceKm;
    final cons = s.consumptionSnapshot;
    final unit = s.consumptionUnitSnapshot;
    final price = s.fuelPriceCentsSnapshot;
    if (dist != null && cons != null && unit != null && price != null) {
      return FuelCalculator.compute(
        distanceKm: dist,
        consumptionValue: cons,
        consumptionUnit: unit,
        pricePerUnitCents: price,
        roundTrip: s.isRoundTrip,
      ).costCents;
    }
    return s.manualCostCents ?? 0;
  }
  return s.manualCostCents ?? 0;
}

/// Distanza effettiva considerando l'andata/ritorno.
double? segmentEffectiveKm(TransportSegment s) {
  final d = s.distanceKm;
  if (d == null) return null;
  return s.isRoundTrip ? d * 2 : d;
}
