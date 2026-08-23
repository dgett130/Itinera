import 'package:drift/drift.dart';

import '../../core/enums.dart';
import '../../core/id.dart';
import '../../data/database.dart';

/// Accesso ai dati del modulo Itinerario.
class ItineraryRepository {
  ItineraryRepository(this._db);

  final AppDatabase _db;

  Stream<List<ItineraryDay>> watchDays(String tripId) {
    return (_db.select(_db.itineraryDays)
          ..where((d) => d.tripId.equals(tripId))
          ..orderBy([
            // I giorni con data prima (ordinati), il bucket "Non programmato"
            // (data null) in fondo.
            (d) => OrderingTerm(expression: d.date),
            (d) => OrderingTerm(expression: d.sortIndex),
          ]))
        .watch();
  }

  Stream<List<Activity>> watchActivities(String tripId) {
    return (_db.select(_db.activities)
          ..where((a) => a.tripId.equals(tripId)))
        .watch();
  }

  Stream<List<ActivityCategory>> watchCategories() {
    return (_db.select(_db.activityCategories)
          ..orderBy([(c) => OrderingTerm(expression: c.sortIndex)]))
        .watch();
  }

  Stream<List<Location>> watchLocations(String tripId) {
    return (_db.select(_db.locations)..where((l) => l.tripId.equals(tripId)))
        .watch();
  }

  /// Crea o aggiorna un luogo (etichetta + coordinate opzionali) e ne ritorna
  /// l'id. Ritorna null se l'etichetta e' vuota (nessun luogo associato).
  Future<String?> upsertLocationLabel(
    String tripId,
    String? existingLocationId,
    String label, {
    double? latitude,
    double? longitude,
  }) async {
    final trimmed = label.trim();
    if (trimmed.isEmpty) return null;
    if (existingLocationId != null) {
      await (_db.update(_db.locations)
            ..where((l) => l.id.equals(existingLocationId)))
          .write(LocationsCompanion(
        label: Value(trimmed),
        latitude: Value(latitude),
        longitude: Value(longitude),
      ));
      return existingLocationId;
    }
    final id = newId();
    await _db.into(_db.locations).insert(
          LocationsCompanion.insert(
            id: id,
            tripId: tripId,
            label: trimmed,
            latitude: Value(latitude),
            longitude: Value(longitude),
          ),
        );
    return id;
  }

  /// Crea i giorni mancanti per l'intervallo di date del viaggio e garantisce
  /// il bucket "Non programmato". Idempotente.
  Future<void> ensureDays(String tripId) async {
    final trip = await (_db.select(_db.trips)..where((t) => t.id.equals(tripId)))
        .getSingleOrNull();
    if (trip == null) return;

    final existing = await (_db.select(_db.itineraryDays)
          ..where((d) => d.tripId.equals(tripId)))
        .get();
    final existingDates = <String>{
      for (final d in existing)
        if (d.date != null) _dateKey(d.date!),
    };
    final hasBucket = existing.any((d) => d.date == null);

    final toInsert = <ItineraryDaysCompanion>[];

    final start = trip.startDate;
    final end = trip.endDate;
    if (start != null && end != null && !end.isBefore(start)) {
      final startDay = DateTime(start.year, start.month, start.day);
      final endDay = DateTime(end.year, end.month, end.day);
      var current = startDay;
      var index = 0;
      while (!current.isAfter(endDay)) {
        if (!existingDates.contains(_dateKey(current))) {
          toInsert.add(ItineraryDaysCompanion.insert(
            id: newId(),
            tripId: tripId,
            date: Value(current),
            dayIndex: Value(index),
          ));
        }
        current = current.add(const Duration(days: 1));
        index++;
      }
    }

    if (!hasBucket) {
      toInsert.add(ItineraryDaysCompanion.insert(
        id: newId(),
        tripId: tripId,
        date: const Value(null),
        dayIndex: const Value(9999),
        sortIndex: const Value(9999),
      ));
    }

    if (toInsert.isNotEmpty) {
      await _db.batch((b) => b.insertAll(_db.itineraryDays, toInsert));
    }
  }

  Future<int> _nextSortIndex(String dayId) async {
    final acts = await (_db.select(_db.activities)
          ..where((a) => a.dayId.equals(dayId)))
        .get();
    if (acts.isEmpty) return 0;
    return acts.map((a) => a.sortIndex).reduce((a, b) => a > b ? a : b) + 1;
  }

  Future<void> addActivity({
    required String tripId,
    required String dayId,
    required String title,
    String? categoryId,
    int? startMinutes,
    int? endMinutes,
    int? costCents,
    String? locationId,
    String? notes,
  }) async {
    await _db.into(_db.activities).insert(
          ActivitiesCompanion.insert(
            id: newId(),
            dayId: dayId,
            tripId: tripId,
            title: title,
            categoryId: Value(categoryId),
            startMinutes: Value(startMinutes),
            endMinutes: Value(endMinutes),
            costCents: Value(costCents),
            locationId: Value(locationId),
            notes: Value(notes),
            sortIndex: Value(await _nextSortIndex(dayId)),
          ),
        );
  }

  Future<void> updateActivity(
    String id, {
    required String dayId,
    required String title,
    String? categoryId,
    int? startMinutes,
    int? endMinutes,
    int? costCents,
    String? locationId,
    String? notes,
  }) async {
    await (_db.update(_db.activities)..where((a) => a.id.equals(id))).write(
      ActivitiesCompanion(
        dayId: Value(dayId),
        title: Value(title),
        categoryId: Value(categoryId),
        startMinutes: Value(startMinutes),
        endMinutes: Value(endMinutes),
        costCents: Value(costCents),
        locationId: Value(locationId),
        notes: Value(notes),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> setStatus(String id, ActivityStatus status) async {
    await (_db.update(_db.activities)..where((a) => a.id.equals(id)))
        .write(ActivitiesCompanion(status: Value(status)));
  }

  Future<void> deleteActivity(String id) async {
    await (_db.delete(_db.activities)..where((a) => a.id.equals(id))).go();
  }

  /// Riscrive il sortIndex secondo il nuovo ordine visuale del giorno.
  Future<void> reorderDay(List<String> orderedActivityIds) async {
    await _db.transaction(() async {
      for (var i = 0; i < orderedActivityIds.length; i++) {
        await (_db.update(_db.activities)
              ..where((a) => a.id.equals(orderedActivityIds[i])))
            .write(ActivitiesCompanion(sortIndex: Value(i)));
      }
    });
  }

  static String _dateKey(DateTime d) => '${d.year}-${d.month}-${d.day}';
}
