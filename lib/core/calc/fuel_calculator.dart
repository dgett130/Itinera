import '../enums.dart';

/// Risultato del calcolo carburante di una tratta.
class FuelResult {
  const FuelResult({required this.units, required this.costCents});

  /// Quantita' di carburante consumata: litri (combustione) o kWh (elettrico).
  final double units;

  /// Costo totale in centesimi (valuta della tratta).
  final int costCents;
}

/// Calcolo del carburante consumato e del suo costo per una tratta.
///
/// Formula: `unita = (distanzaKm / 100) x consumo_per_100km x (a/r ? 2 : 1)`,
/// `costo = unita x prezzo_per_unita`.
/// Tutto in Dart puro e deterministico: e' la logica su cui poggia il budget,
/// quindi e' isolata e coperta da test.
class FuelCalculator {
  const FuelCalculator._();

  /// Converte un valore di consumo nella forma canonica "per 100 km".
  ///
  /// - [ConsumptionUnit.lPer100km] / [ConsumptionUnit.kwhPer100km]: gia' canonici.
  /// - [ConsumptionUnit.kmPerL]: invertito (100 / km-per-litro).
  static double toPer100km(double value, ConsumptionUnit unit) {
    if (value <= 0) return 0;
    return switch (unit) {
      ConsumptionUnit.lPer100km => value,
      ConsumptionUnit.kwhPer100km => value,
      ConsumptionUnit.kmPerL => 100.0 / value,
    };
  }

  /// Calcola unita' consumate e costo.
  ///
  /// [pricePerUnitCents] e' il prezzo per litro (o per kWh) in centesimi.
  /// Ritorna zero se i dati non sono validi (distanza/consumo/prezzo <= 0):
  /// una tratta incompleta non deve mai produrre un costo fasullo.
  static FuelResult compute({
    required double distanceKm,
    required double consumptionValue,
    required ConsumptionUnit consumptionUnit,
    required int pricePerUnitCents,
    bool roundTrip = false,
  }) {
    if (distanceKm <= 0 ||
        consumptionValue <= 0 ||
        pricePerUnitCents <= 0 ||
        !distanceKm.isFinite ||
        !consumptionValue.isFinite) {
      return const FuelResult(units: 0, costCents: 0);
    }
    final per100 = toPer100km(consumptionValue, consumptionUnit);
    final multiplier = roundTrip ? 2 : 1;
    final units = (distanceKm / 100.0) * per100 * multiplier;
    final costCents = (units * pricePerUnitCents).round();
    return FuelResult(units: units, costCents: costCents);
  }
}
