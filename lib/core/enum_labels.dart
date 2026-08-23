import 'package:flutter/material.dart';

import 'enums.dart';

/// Etichette e icone in italiano per gli enum di dominio.
///
/// NOTA i18n: per la v1 (solo IT) le etichette sono qui, centralizzate.
/// Quando si aggiungera' l'inglese, queste mappe potranno essere sostituite
/// da lookup su AppLocalizations senza toccare il resto del codice.

extension TripTypeLabel on TripType {
  String get label => switch (this) {
        TripType.sea => 'Mare',
        TripType.mountain => 'Montagna',
        TripType.city => 'Citta',
        TripType.business => 'Lavoro',
        TripType.roadTrip => 'Road trip',
        TripType.backpacking => 'Zaino in spalla',
        TripType.generic => 'Generico',
      };

  IconData get icon => switch (this) {
        TripType.sea => Icons.beach_access,
        TripType.mountain => Icons.terrain,
        TripType.city => Icons.location_city,
        TripType.business => Icons.work,
        TripType.roadTrip => Icons.route,
        TripType.backpacking => Icons.hiking,
        TripType.generic => Icons.luggage,
      };
}

extension ClimateLabel on Climate {
  String get label => switch (this) {
        Climate.hot => 'Caldo',
        Climate.temperate => 'Temperato',
        Climate.cold => 'Freddo',
        Climate.tropical => 'Tropicale',
        Climate.variable => 'Variabile',
      };
}

extension BagTypeLabel on BagType {
  String get label => switch (this) {
        BagType.cabin => 'Bagaglio a mano',
        BagType.hold => 'Stiva',
        BagType.personal => 'Oggetto personale',
        BagType.backpack => 'Zaino',
        BagType.duffel => 'Borsone',
      };

  IconData get icon => switch (this) {
        BagType.cabin => Icons.work_outline,
        BagType.hold => Icons.luggage,
        BagType.personal => Icons.backpack_outlined,
        BagType.backpack => Icons.backpack,
        BagType.duffel => Icons.shopping_bag,
      };
}

extension TransportModeLabel on TransportMode {
  String get label => switch (this) {
        TransportMode.car => 'Auto',
        TransportMode.motorcycle => 'Moto',
        TransportMode.camper => 'Camper',
        TransportMode.plane => 'Aereo',
        TransportMode.train => 'Treno',
        TransportMode.ferry => 'Traghetto',
        TransportMode.bus => 'Autobus',
        TransportMode.taxi => 'Taxi',
        TransportMode.bicycle => 'Bicicletta',
        TransportMode.walk => 'A piedi',
        TransportMode.other => 'Altro',
      };

  IconData get icon => switch (this) {
        TransportMode.car => Icons.directions_car,
        TransportMode.motorcycle => Icons.two_wheeler,
        TransportMode.camper => Icons.airport_shuttle,
        TransportMode.plane => Icons.flight,
        TransportMode.train => Icons.train,
        TransportMode.ferry => Icons.directions_boat,
        TransportMode.bus => Icons.directions_bus,
        TransportMode.taxi => Icons.local_taxi,
        TransportMode.bicycle => Icons.directions_bike,
        TransportMode.walk => Icons.directions_walk,
        TransportMode.other => Icons.more_horiz,
      };
}

extension FuelTypeLabel on FuelType {
  String get label => switch (this) {
        FuelType.petrol => 'Benzina',
        FuelType.diesel => 'Diesel',
        FuelType.lpg => 'GPL',
        FuelType.cng => 'Metano',
        FuelType.electric => 'Elettrico',
        FuelType.hybrid => 'Ibrido',
      };

  /// L'elettrico ragiona in kWh, gli altri in litri.
  ConsumptionUnit get defaultConsumptionUnit => this == FuelType.electric
      ? ConsumptionUnit.kwhPer100km
      : ConsumptionUnit.lPer100km;
}

extension ConsumptionUnitLabel on ConsumptionUnit {
  String get label => switch (this) {
        ConsumptionUnit.lPer100km => 'L/100 km',
        ConsumptionUnit.kwhPer100km => 'kWh/100 km',
        ConsumptionUnit.kmPerL => 'km/L',
      };
}

extension DistanceSourceLabel on DistanceSource {
  String get label => switch (this) {
        DistanceSource.manual => 'Inserita a mano',
        DistanceSource.onlineRouting => 'Percorso online',
        DistanceSource.cached => 'Da cache',
        DistanceSource.straightLine => 'Stima (linea d\'aria)',
      };

  bool get isApproximate => this == DistanceSource.straightLine;
}

extension CostCategoryLabel on CostCategory {
  String get label => switch (this) {
        CostCategory.fuel => 'Carburante',
        CostCategory.ticket => 'Biglietto',
        CostCategory.toll => 'Pedaggio',
        CostCategory.parking => 'Parcheggio',
        CostCategory.rental => 'Noleggio',
        CostCategory.baggage => 'Bagaglio',
        CostCategory.insurance => 'Assicurazione',
        CostCategory.taxi => 'Taxi',
        CostCategory.accommodation => 'Alloggio',
        CostCategory.food => 'Cibo',
        CostCategory.activity => 'Attivita',
        CostCategory.other => 'Altro',
      };

  IconData get icon => switch (this) {
        CostCategory.fuel => Icons.local_gas_station,
        CostCategory.ticket => Icons.confirmation_number,
        CostCategory.toll => Icons.toll,
        CostCategory.parking => Icons.local_parking,
        CostCategory.rental => Icons.car_rental,
        CostCategory.baggage => Icons.luggage,
        CostCategory.insurance => Icons.shield,
        CostCategory.taxi => Icons.local_taxi,
        CostCategory.accommodation => Icons.hotel,
        CostCategory.food => Icons.restaurant,
        CostCategory.activity => Icons.local_activity,
        CostCategory.other => Icons.receipt_long,
      };
}

extension SplitMethodLabel on SplitMethod {
  String get label => switch (this) {
        SplitMethod.equal => 'In parti uguali',
        SplitMethod.weighted => 'Per quota',
        SplitMethod.custom => 'Personalizzata',
        SplitMethod.none => 'Non divisa',
      };
}

extension ActivityStatusLabel on ActivityStatus {
  String get label => switch (this) {
        ActivityStatus.planned => 'Pianificata',
        ActivityStatus.done => 'Fatta',
        ActivityStatus.skipped => 'Saltata',
        ActivityStatus.cancelled => 'Annullata',
      };
}
