import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../core/enums.dart';

/// Un paese (per l'autocomplete del campo Paese).
class Country {
  const Country({required this.name, required this.code});
  final String name;
  final String code;
}

/// Una specifica auto dal database offline (consumo indicativo).
class CarSpec {
  const CarSpec({
    required this.make,
    required this.model,
    required this.fuel,
    required this.consumption,
  });

  final String make;
  final String model;
  final FuelType fuel;

  /// L/100km (o kWh/100km se elettrico).
  final double consumption;

  String get label => '$make $model';

  ConsumptionUnit get unit => fuel == FuelType.electric
      ? ConsumptionUnit.kwhPer100km
      : ConsumptionUnit.lPer100km;
}

/// Dati di riferimento caricati dagli asset (paesi, auto). Cache in memoria.
class ReferenceData {
  ReferenceData._();

  static List<Country>? _countries;
  static List<CarSpec>? _cars;

  static Future<List<Country>> countries() async {
    if (_countries != null) return _countries!;
    final raw = await rootBundle.loadString('assets/countries.json');
    final list = jsonDecode(raw) as List;
    _countries = list
        .map((e) => Country(
              name: e['name'] as String,
              code: e['code'] as String,
            ))
        .toList();
    return _countries!;
  }

  static Future<List<CarSpec>> cars() async {
    if (_cars != null) return _cars!;
    final raw = await rootBundle.loadString('assets/cars.json');
    final list = jsonDecode(raw) as List;
    _cars = list.map((e) {
      final fuelName = e['fuel'] as String;
      final fuel = FuelType.values.firstWhere(
        (f) => f.name == fuelName,
        orElse: () => FuelType.petrol,
      );
      return CarSpec(
        make: e['make'] as String,
        model: e['model'] as String,
        fuel: fuel,
        consumption: (e['consumption'] as num).toDouble(),
      );
    }).toList();
    return _cars!;
  }

  /// Filtra i paesi per prefisso/contenuto (case-insensitive).
  static List<Country> filterCountries(List<Country> all, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return all.take(8).toList();
    final starts = <Country>[];
    final contains = <Country>[];
    for (final c in all) {
      final n = c.name.toLowerCase();
      if (n.startsWith(q)) {
        starts.add(c);
      } else if (n.contains(q)) {
        contains.add(c);
      }
    }
    return [...starts, ...contains].take(8).toList();
  }

  /// Filtra le auto per marca/modello.
  static List<CarSpec> filterCars(List<CarSpec> all, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return all
        .where((c) => c.label.toLowerCase().contains(q))
        .take(10)
        .toList();
  }
}
