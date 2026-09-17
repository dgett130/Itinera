import 'package:drift/drift.dart';

import '../../core/enums.dart';
import '../../core/id.dart';
import '../../data/database.dart';

/// Accesso ai dati dei viaggi (nucleo comune ai tre moduli).
class TripRepository {
  TripRepository(this._db);

  final AppDatabase _db;

  /// Stream reattivo di tutti i viaggi, dal piu' recente per data di partenza.
  Stream<List<Trip>> watchTrips() {
    final query = _db.select(_db.trips)
      ..orderBy([
        (t) => OrderingTerm(expression: t.startDate, mode: OrderingMode.desc),
        (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
      ]);
    return query.watch();
  }

  /// Stream reattivo di un singolo viaggio (null se eliminato).
  Stream<Trip?> watchTrip(String id) {
    return (_db.select(
      _db.trips,
    )..where((t) => t.id.equals(id))).watchSingleOrNull();
  }

  Future<Trip?> getTrip(String id) {
    return (_db.select(
      _db.trips,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Crea un viaggio e ritorna il suo id.
  Future<String> createTrip({
    required String name,
    String? destination,
    String? country,
    double? destinationLat,
    double? destinationLng,
    DateTime? startDate,
    DateTime? endDate,
    TripType tripType = TripType.generic,
    Climate climate = Climate.temperate,
    int travelerCount = 1,
    TripStyle? themeStyle,
    String? notes,
    String? driveUrl,
  }) async {
    final id = newId();
    await _db
        .into(_db.trips)
        .insert(
          TripsCompanion.insert(
            id: id,
            name: name,
            destination: Value(destination),
            country: Value(country),
            destinationLat: Value(destinationLat),
            destinationLng: Value(destinationLng),
            startDate: Value(startDate),
            endDate: Value(endDate),
            tripType: Value(tripType),
            climate: Value(climate),
            travelerCount: Value(travelerCount),
            themeStyle: Value(themeStyle),
            notes: Value(notes),
            driveUrl: Value(driveUrl),
          ),
        );
    // Il viaggiatore "io" di default, per la divisione spese.
    await _db
        .into(_db.travelers)
        .insert(
          TravelersCompanion.insert(
            id: newId(),
            tripId: id,
            name: 'Io',
            isSelfUser: const Value(true),
          ),
        );
    return id;
  }

  Future<void> updateTrip(
    String id, {
    required String name,
    String? destination,
    String? country,
    double? destinationLat,
    double? destinationLng,
    DateTime? startDate,
    DateTime? endDate,
    required TripType tripType,
    required Climate climate,
    required int travelerCount,
    TripStyle? themeStyle,
    String? notes,
    String? driveUrl,
  }) async {
    await (_db.update(_db.trips)..where((t) => t.id.equals(id))).write(
      TripsCompanion(
        name: Value(name),
        destination: Value(destination),
        country: Value(country),
        destinationLat: Value(destinationLat),
        destinationLng: Value(destinationLng),
        startDate: Value(startDate),
        endDate: Value(endDate),
        tripType: Value(tripType),
        climate: Value(climate),
        travelerCount: Value(travelerCount),
        themeStyle: Value(themeStyle),
        notes: Value(notes),
        driveUrl: Value(driveUrl),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Imposta solo il link Drive del viaggio (usato dalla creazione automatica
  /// della cartella Drive).
  Future<void> setDriveUrl(String id, String? driveUrl) async {
    await (_db.update(_db.trips)..where((t) => t.id.equals(id))).write(
      TripsCompanion(
        driveUrl: Value(driveUrl),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> deleteTrip(String id) async {
    await (_db.delete(_db.trips)..where((t) => t.id.equals(id))).go();
  }

  /// Imposta lo stile visivo del viaggio (null = automatico).
  Future<void> setThemeStyle(String id, TripStyle? style) async {
    await (_db.update(_db.trips)..where((t) => t.id.equals(id))).write(
      TripsCompanion(
        themeStyle: Value(style),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Duplica un viaggio come base per uno nuovo: copia struttura di valigia,
  /// tratte, itinerario e viaggiatori, azzerando spunte e stati; NON copia le
  /// spese reali sostenute.
  Future<String> duplicateTrip(String sourceId) async {
    final source = await getTrip(sourceId);
    if (source == null) return sourceId;

    return _db.transaction(() async {
      final newTripId = newId();
      await _db
          .into(_db.trips)
          .insert(
            TripsCompanion.insert(
              id: newTripId,
              name: '${source.name} (copia)',
              destination: Value(source.destination),
              country: Value(source.country),
              startDate: Value(source.startDate),
              endDate: Value(source.endDate),
              tripType: Value(source.tripType),
              climate: Value(source.climate),
              travelerCount: Value(source.travelerCount),
              themeStyle: Value(source.themeStyle),
              notes: Value(source.notes),
            ),
          );

      // Viaggiatori.
      final travelerIdMap = <String, String>{};
      final travelers = await (_db.select(
        _db.travelers,
      )..where((t) => t.tripId.equals(sourceId))).get();
      for (final tr in travelers) {
        final id = newId();
        travelerIdMap[tr.id] = id;
        await _db
            .into(_db.travelers)
            .insert(
              TravelersCompanion.insert(
                id: id,
                tripId: newTripId,
                name: tr.name,
                shareWeight: Value(tr.shareWeight),
                colorHex: Value(tr.colorHex),
                isSelfUser: Value(tr.isSelfUser),
                sortOrder: Value(tr.sortOrder),
              ),
            );
      }

      // Bagagli.
      final bagIdMap = <String, String>{};
      final bags = await (_db.select(
        _db.bags,
      )..where((b) => b.tripId.equals(sourceId))).get();
      for (final bag in bags) {
        final id = newId();
        bagIdMap[bag.id] = id;
        await _db
            .into(_db.bags)
            .insert(
              BagsCompanion.insert(
                id: id,
                tripId: newTripId,
                name: bag.name,
                type: Value(bag.type),
                tareWeightGrams: Value(bag.tareWeightGrams),
                maxWeightGrams: Value(bag.maxWeightGrams),
                colorHex: Value(bag.colorHex),
                sortOrder: Value(bag.sortOrder),
              ),
            );
      }

      // Oggetti valigia (spunte azzerate).
      final items = await (_db.select(
        _db.packingItems,
      )..where((i) => i.tripId.equals(sourceId))).get();
      for (final it in items) {
        await _db
            .into(_db.packingItems)
            .insert(
              PackingItemsCompanion.insert(
                id: newId(),
                tripId: newTripId,
                categoryId: it.categoryId,
                name: it.name,
                bagId: Value(it.bagId == null ? null : bagIdMap[it.bagId]),
                quantity: Value(it.quantity),
                packedCount: const Value(0),
                unitWeightGrams: Value(it.unitWeightGrams),
                isEssential: Value(it.isEssential),
                notes: Value(it.notes),
                sortOrder: Value(it.sortOrder),
              ),
            );
      }

      // Tratte (senza spese).
      final segments = await (_db.select(
        _db.transportSegments,
      )..where((s) => s.tripId.equals(sourceId))).get();
      for (final s in segments) {
        await _db
            .into(_db.transportSegments)
            .insert(
              TransportSegmentsCompanion.insert(
                id: newId(),
                tripId: newTripId,
                sequenceIndex: Value(s.sequenceIndex),
                mode: Value(s.mode),
                originLabel: Value(s.originLabel),
                originLat: Value(s.originLat),
                originLng: Value(s.originLng),
                destinationLabel: Value(s.destinationLabel),
                destinationLat: Value(s.destinationLat),
                destinationLng: Value(s.destinationLng),
                distanceKm: Value(s.distanceKm),
                distanceSource: Value(s.distanceSource),
                detourFactor: Value(s.detourFactor),
                isRoundTrip: Value(s.isRoundTrip),
                vehicleId: Value(s.vehicleId),
                consumptionSnapshot: Value(s.consumptionSnapshot),
                consumptionUnitSnapshot: Value(s.consumptionUnitSnapshot),
                fuelPriceCentsSnapshot: Value(s.fuelPriceCentsSnapshot),
                manualCostCents: Value(s.manualCostCents),
                provider: Value(s.provider),
                bookingRef: Value(s.bookingRef),
                seatInfo: Value(s.seatInfo),
                notes: Value(s.notes),
              ),
            );
      }

      // Luoghi.
      final locationIdMap = <String, String>{};
      final locations = await (_db.select(
        _db.locations,
      )..where((l) => l.tripId.equals(sourceId))).get();
      for (final loc in locations) {
        final id = newId();
        locationIdMap[loc.id] = id;
        await _db
            .into(_db.locations)
            .insert(
              LocationsCompanion.insert(
                id: id,
                tripId: newTripId,
                label: loc.label,
                address: Value(loc.address),
                latitude: Value(loc.latitude),
                longitude: Value(loc.longitude),
                placeType: Value(loc.placeType),
                notes: Value(loc.notes),
                source: Value(loc.source),
                externalProvider: Value(loc.externalProvider),
                externalId: Value(loc.externalId),
                poiCategory: Value(loc.poiCategory),
                description: Value(loc.description),
                website: Value(loc.website),
                openingHours: Value(loc.openingHours),
                wikidata: Value(loc.wikidata),
              ),
            );
      }

      // Giorni e attivita' (stato azzerato a "pianificata").
      final dayIdMap = <String, String>{};
      final days = await (_db.select(
        _db.itineraryDays,
      )..where((d) => d.tripId.equals(sourceId))).get();
      for (final day in days) {
        final dayId = newId();
        dayIdMap[day.id] = dayId;
        await _db
            .into(_db.itineraryDays)
            .insert(
              ItineraryDaysCompanion.insert(
                id: dayId,
                tripId: newTripId,
                date: Value(day.date),
                dayIndex: Value(day.dayIndex),
                title: Value(day.title),
                notes: Value(day.notes),
                sortIndex: Value(day.sortIndex),
              ),
            );
        final activities = await (_db.select(
          _db.activities,
        )..where((a) => a.dayId.equals(day.id))).get();
        for (final a in activities) {
          await _db
              .into(_db.activities)
              .insert(
                ActivitiesCompanion.insert(
                  id: newId(),
                  dayId: dayId,
                  tripId: newTripId,
                  title: a.title,
                  categoryId: Value(a.categoryId),
                  startMinutes: Value(a.startMinutes),
                  endMinutes: Value(a.endMinutes),
                  isAllDay: Value(a.isAllDay),
                  locationId: Value(
                    a.locationId == null ? null : locationIdMap[a.locationId],
                  ),
                  costCents: Value(a.costCents),
                  status: const Value(ActivityStatus.planned),
                  notes: Value(a.notes),
                  bookingRef: Value(a.bookingRef),
                  bookingUrl: Value(a.bookingUrl),
                  sortIndex: Value(a.sortIndex),
                ),
              );
        }
      }

      // Percorsi di visita + tappe (rimappando giorni e luoghi).
      final routes = await (_db.select(
        _db.sightseeingRoutes,
      )..where((r) => r.tripId.equals(sourceId))).get();
      for (final r in routes) {
        final newRouteId = newId();
        await _db
            .into(_db.sightseeingRoutes)
            .insert(
              SightseeingRoutesCompanion.insert(
                id: newRouteId,
                tripId: newTripId,
                name: r.name,
                dayId: Value(r.dayId == null ? null : dayIdMap[r.dayId]),
                travelMode: Value(r.travelMode),
                optimized: Value(r.optimized),
                fixedStart: Value(r.fixedStart),
                returnToStart: Value(r.returnToStart),
                distanceMeters: Value(r.distanceMeters),
                durationSeconds: Value(r.durationSeconds),
                geometry: Value(r.geometry),
                calcSource: Value(r.calcSource),
                // lastManualOrder referenzia id-tappa vecchi: azzerato nella copia.
              ),
            );
        final stops =
            await (_db.select(_db.sightseeingRouteStops)
                  ..where((s) => s.routeId.equals(r.id))
                  ..orderBy([(s) => OrderingTerm(expression: s.sequenceIndex)]))
                .get();
        for (final s in stops) {
          final newLoc = locationIdMap[s.locationId];
          if (newLoc == null) continue;
          await _db
              .into(_db.sightseeingRouteStops)
              .insert(
                SightseeingRouteStopsCompanion.insert(
                  id: newId(),
                  routeId: newRouteId,
                  tripId: newTripId,
                  locationId: newLoc,
                  sequenceIndex: Value(s.sequenceIndex),
                ),
              );
        }
      }

      return newTripId;
    });
  }
}
