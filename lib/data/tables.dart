import 'package:drift/drift.dart';

import '../core/enums.dart';

/// Definizione delle tabelle Drift (schema locale SQLite).
///
/// Convenzioni:
/// - chiavi primarie TEXT (UUID v4), generate lato client;
/// - enum salvati come *nome* (`textEnum`), robusti al riordino;
/// - denaro in centesimi interi, pesi in grammi interi;
/// - foreign key con ON DELETE CASCADE verso il viaggio (eliminare un viaggio
///   ne rimuove tutti i dati) e SET NULL dove l'entita' figlia deve
///   sopravvivere (es. un oggetto resta se la sua borsa viene eliminata).

/// Impostazioni globali dell'app (riga singola, id fisso = 1).
class AppSettings extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get languageCode => text().withDefault(const Constant('it'))();
  TextColumn get currencyCode => text().withDefault(const Constant('EUR'))();
  TextColumn get unitSystem =>
      textEnum<UnitSystem>().withDefault(Constant(UnitSystem.metric.name))();
  RealColumn get defaultFuelConsumption =>
      real().withDefault(const Constant(6.5))();
  IntColumn get defaultFuelPriceCents =>
      integer().withDefault(const Constant(185))();
  TextColumn get defaultFuelType =>
      textEnum<FuelType>().withDefault(Constant(FuelType.petrol.name))();

  // --- Modalita' locale/remota (schema v2) ---
  /// L'utente ha gia' scelto la modalita' all'avvio?
  BoolColumn get modeChosen => boolean().withDefault(const Constant(false))();
  TextColumn get appMode =>
      textEnum<AppMode>().withDefault(Constant(AppMode.local.name))();
  TextColumn get serverUrl => text().nullable()();
  TextColumn get remoteUsername => text().nullable()();
  TextColumn get authToken => text().nullable()();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Un viaggio: radice condivisa dai tre moduli.
class Trips extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get destination => text().nullable()();
  TextColumn get country => text().nullable()();
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get endDate => dateTime().nullable()();
  TextColumn get tripType =>
      textEnum<TripType>().withDefault(Constant(TripType.generic.name))();
  TextColumn get climate =>
      textEnum<Climate>().withDefault(Constant(Climate.temperate.name))();
  IntColumn get travelerCount => integer().withDefault(const Constant(1))();
  TextColumn get homeCurrency => text().withDefault(const Constant('EUR'))();
  TextColumn get coverImagePath => text().nullable()();
  /// Stile visivo del viaggio; null = automatico (dedotto dal tipo). Nullable
  /// per retrocompatibilita' con i backup/sync precedenti alla v3.
  TextColumn get themeStyle => textEnum<TripStyle>().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().clientDefault(DateTime.now)();
  DateTimeColumn get updatedAt => dateTime().clientDefault(DateTime.now)();

  @override
  Set<Column> get primaryKey => {id};
}

/// I compagni di viaggio (per la divisione delle spese).
class Travelers extends Table {
  TextColumn get id => text()();
  TextColumn get tripId =>
      text().references(Trips, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  RealColumn get shareWeight => real().withDefault(const Constant(1.0))();
  TextColumn get colorHex => text().nullable()();
  BoolColumn get isSelfUser => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// VALIGIA
// ---------------------------------------------------------------------------

/// Categorie della valigia (globali, condivise tra i viaggi).
class PackingCategories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get iconKey => text().withDefault(const Constant('category'))();
  TextColumn get colorHex => text().nullable()();
  BoolColumn get isSystem => boolean().withDefault(const Constant(false))();
  BoolColumn get isHidden => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Una borsa/bagaglio di un viaggio.
class Bags extends Table {
  TextColumn get id => text()();
  TextColumn get tripId =>
      text().references(Trips, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  TextColumn get type =>
      textEnum<BagType>().withDefault(Constant(BagType.hold.name))();
  IntColumn get tareWeightGrams => integer().withDefault(const Constant(0))();
  IntColumn get maxWeightGrams => integer().nullable()();
  TextColumn get colorHex => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Un oggetto da mettere in valigia.
class PackingItems extends Table {
  TextColumn get id => text()();
  TextColumn get tripId =>
      text().references(Trips, #id, onDelete: KeyAction.cascade)();
  TextColumn get categoryId => text().references(PackingCategories, #id)();
  TextColumn get bagId =>
      text().nullable().references(Bags, #id, onDelete: KeyAction.setNull)();
  TextColumn get name => text()();
  IntColumn get quantity => integer().withDefault(const Constant(1))();
  IntColumn get packedCount => integer().withDefault(const Constant(0))();
  IntColumn get unitWeightGrams => integer().nullable()();
  BoolColumn get isEssential => boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().clientDefault(DateTime.now)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Modello di lista valigia riutilizzabile (built-in o creato dall'utente).
class PackingTemplates extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get tripType => textEnum<TripType>().nullable()();
  BoolColumn get isBuiltIn => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().clientDefault(DateTime.now)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Voce di un modello di valigia.
class PackingTemplateItems extends Table {
  TextColumn get id => text()();
  TextColumn get templateId =>
      text().references(PackingTemplates, #id, onDelete: KeyAction.cascade)();
  TextColumn get categoryName => text()();
  TextColumn get name => text()();
  IntColumn get baseQuantity => integer().withDefault(const Constant(1))();
  IntColumn get unitWeightGrams => integer().nullable()();
  BoolColumn get isEssential => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// TRASPORTO
// ---------------------------------------------------------------------------

/// Un veicolo salvato (globale, riusabile tra i viaggi).
class Vehicles extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get fuelType =>
      textEnum<FuelType>().withDefault(Constant(FuelType.petrol.name))();
  RealColumn get consumptionValue =>
      real().withDefault(const Constant(6.5))();
  TextColumn get consumptionUnit => textEnum<ConsumptionUnit>()
      .withDefault(Constant(ConsumptionUnit.lPer100km.name))();
  RealColumn get tankCapacity => real().nullable()();
  TextColumn get plate => text().nullable()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().clientDefault(DateTime.now)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Una tratta del viaggio. I valori del veicolo sono "congelati" (snapshot)
/// al momento del calcolo, cosi' modificare/archiviare un veicolo non altera
/// i costi gia' calcolati.
class TransportSegments extends Table {
  TextColumn get id => text()();
  TextColumn get tripId =>
      text().references(Trips, #id, onDelete: KeyAction.cascade)();
  IntColumn get sequenceIndex => integer().withDefault(const Constant(0))();
  TextColumn get mode =>
      textEnum<TransportMode>().withDefault(Constant(TransportMode.car.name))();
  TextColumn get originLabel => text().withDefault(const Constant(''))();
  RealColumn get originLat => real().nullable()();
  RealColumn get originLng => real().nullable()();
  TextColumn get destinationLabel => text().withDefault(const Constant(''))();
  RealColumn get destinationLat => real().nullable()();
  RealColumn get destinationLng => real().nullable()();
  RealColumn get distanceKm => real().nullable()();
  TextColumn get distanceSource => textEnum<DistanceSource>()
      .withDefault(Constant(DistanceSource.manual.name))();
  RealColumn get detourFactor => real().withDefault(const Constant(1.3))();
  BoolColumn get isRoundTrip => boolean().withDefault(const Constant(false))();
  DateTimeColumn get departureAt => dateTime().nullable()();
  DateTimeColumn get arrivalAt => dateTime().nullable()();
  TextColumn get vehicleId =>
      text().nullable().references(Vehicles, #id, onDelete: KeyAction.setNull)();
  RealColumn get consumptionSnapshot => real().nullable()();
  TextColumn get consumptionUnitSnapshot =>
      textEnum<ConsumptionUnit>().nullable()();
  IntColumn get fuelPriceCentsSnapshot => integer().nullable()();
  IntColumn get manualCostCents => integer().nullable()();
  TextColumn get provider => text().nullable()();
  TextColumn get bookingRef => text().nullable()();
  TextColumn get seatInfo => text().nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Una voce di spesa (stima o reale), opzionalmente legata a una tratta.
class CostItems extends Table {
  TextColumn get id => text()();
  TextColumn get tripId =>
      text().references(Trips, #id, onDelete: KeyAction.cascade)();
  TextColumn get segmentId => text()
      .nullable()
      .references(TransportSegments, #id, onDelete: KeyAction.setNull)();
  TextColumn get category => textEnum<CostCategory>()
      .withDefault(Constant(CostCategory.other.name))();
  TextColumn get description => text().nullable()();
  IntColumn get amountCents => integer().withDefault(const Constant(0))();
  TextColumn get currency => text().withDefault(const Constant('EUR'))();
  DateTimeColumn get date => dateTime().nullable()();
  TextColumn get status =>
      textEnum<CostStatus>().withDefault(Constant(CostStatus.actual.name))();
  TextColumn get paidByTravelerId => text()
      .nullable()
      .references(Travelers, #id, onDelete: KeyAction.setNull)();
  TextColumn get splitMethod =>
      textEnum<SplitMethod>().withDefault(Constant(SplitMethod.equal.name))();
  TextColumn get receiptPhotoPath => text().nullable()();
  DateTimeColumn get createdAt => dateTime().clientDefault(DateTime.now)();

  @override
  Set<Column> get primaryKey => {id};
}

/// La quota dovuta da un viaggiatore su una spesa.
class CostSplits extends Table {
  TextColumn get id => text()();
  TextColumn get costItemId =>
      text().references(CostItems, #id, onDelete: KeyAction.cascade)();
  TextColumn get travelerId =>
      text().references(Travelers, #id, onDelete: KeyAction.cascade)();
  RealColumn get shareWeight => real().withDefault(const Constant(1.0))();
  IntColumn get shareAmountCents => integer().withDefault(const Constant(0))();
  BoolColumn get settled => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// ITINERARIO
// ---------------------------------------------------------------------------

/// Un giorno dell'itinerario. `date == null` = bucket "Non programmato".
class ItineraryDays extends Table {
  TextColumn get id => text()();
  TextColumn get tripId =>
      text().references(Trips, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get date => dateTime().nullable()();
  IntColumn get dayIndex => integer().withDefault(const Constant(0))();
  TextColumn get title => text().nullable()();
  TextColumn get notes => text().nullable()();
  IntColumn get sortIndex => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Categorie delle attivita' (globali).
class ActivityCategories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get iconKey => text().withDefault(const Constant('place'))();
  TextColumn get colorHex => text().nullable()();
  BoolColumn get isSystem => boolean().withDefault(const Constant(false))();
  IntColumn get sortIndex => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Un luogo salvato, riferibile dalle attivita'.
class Locations extends Table {
  TextColumn get id => text()();
  TextColumn get tripId =>
      text().references(Trips, #id, onDelete: KeyAction.cascade)();
  TextColumn get label => text()();
  TextColumn get address => text().nullable()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  TextColumn get placeType => textEnum<PlaceType>().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get source => textEnum<LocationSource>()
      .withDefault(Constant(LocationSource.manual.name))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Un'attivita' dell'itinerario. Gli orari sono minuti-da-mezzanotte
/// (wall-clock locale del giorno), per evitare slittamenti di fuso.
class Activities extends Table {
  TextColumn get id => text()();
  TextColumn get dayId =>
      text().references(ItineraryDays, #id, onDelete: KeyAction.cascade)();
  TextColumn get tripId =>
      text().references(Trips, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text()();
  TextColumn get categoryId =>
      text().nullable().references(ActivityCategories, #id)();
  IntColumn get startMinutes => integer().nullable()();
  IntColumn get endMinutes => integer().nullable()();
  BoolColumn get isAllDay => boolean().withDefault(const Constant(false))();
  TextColumn get locationId =>
      text().nullable().references(Locations, #id, onDelete: KeyAction.setNull)();
  IntColumn get costCents => integer().nullable()();
  TextColumn get currency => text().withDefault(const Constant('EUR'))();
  TextColumn get status => textEnum<ActivityStatus>()
      .withDefault(Constant(ActivityStatus.planned.name))();
  BoolColumn get ignoreConflict =>
      boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();
  TextColumn get bookingRef => text().nullable()();
  TextColumn get bookingUrl => text().nullable()();
  IntColumn get sortIndex => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().clientDefault(DateTime.now)();
  DateTimeColumn get updatedAt => dateTime().clientDefault(DateTime.now)();

  @override
  Set<Column> get primaryKey => {id};
}
