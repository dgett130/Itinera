import 'dart:convert';

import 'package:drift/drift.dart';

import 'database.dart';

/// Esporta e importa l'intero database in un file JSON versionato.
///
/// Mitiga il rischio "telefono perso = viaggio perso" (dati solo-locali):
/// l'utente puo' salvare un backup con un tap e ripristinarlo su un altro
/// dispositivo. Formato leggibile e con `schemaVersion` per la portabilita'.
class BackupService {
  BackupService(this._db);

  final AppDatabase _db;

  static const int backupVersion = 1;

  Future<String> exportJson() async {
    final tables = <String, dynamic>{
      'appSettings': await _dump(_db.select(_db.appSettings)),
      'packingCategories': await _dump(_db.select(_db.packingCategories)),
      'activityCategories': await _dump(_db.select(_db.activityCategories)),
      'vehicles': await _dump(_db.select(_db.vehicles)),
      'packingTemplates': await _dump(_db.select(_db.packingTemplates)),
      'packingTemplateItems': await _dump(_db.select(_db.packingTemplateItems)),
      'trips': await _dump(_db.select(_db.trips)),
      'travelers': await _dump(_db.select(_db.travelers)),
      'bags': await _dump(_db.select(_db.bags)),
      'locations': await _dump(_db.select(_db.locations)),
      'itineraryDays': await _dump(_db.select(_db.itineraryDays)),
      'transportSegments': await _dump(_db.select(_db.transportSegments)),
      'packingItems': await _dump(_db.select(_db.packingItems)),
      'costItems': await _dump(_db.select(_db.costItems)),
      'costSplits': await _dump(_db.select(_db.costSplits)),
      'activities': await _dump(_db.select(_db.activities)),
    };
    final root = <String, dynamic>{
      'app': 'itinera',
      'backupVersion': backupVersion,
      'schemaVersion': _db.schemaVersion,
      'tables': tables,
    };
    return const JsonEncoder.withIndent('  ').convert(root);
  }

  Future<List<Map<String, dynamic>>> _dump(
      Selectable<DataClass> query) async {
    final rows = await query.get();
    return rows.map((r) => r.toJson()).toList();
  }

  /// Ripristina completamente i dati dal JSON (sostituisce tutto).
  ///
  /// Le tabelle vengono svuotate e reinserite in ordine di dipendenza,
  /// dentro un'unica transazione: o va a buon fine tutto, o niente.
  Future<void> importJson(String jsonStr) async {
    final root = jsonDecode(jsonStr) as Map<String, dynamic>;
    if (root['app'] != 'itinera') {
      throw const FormatException('File di backup non riconosciuto');
    }
    final tables = (root['tables'] as Map).cast<String, dynamic>();

    List<Map<String, dynamic>> rows(String key) {
      final list = tables[key] as List? ?? const [];
      return list.map((e) => (e as Map).cast<String, dynamic>()).toList();
    }

    await _db.transaction(() async {
      // Cancella dai figli verso i genitori.
      await _db.delete(_db.activities).go();
      await _db.delete(_db.costSplits).go();
      await _db.delete(_db.costItems).go();
      await _db.delete(_db.packingItems).go();
      await _db.delete(_db.transportSegments).go();
      await _db.delete(_db.itineraryDays).go();
      await _db.delete(_db.locations).go();
      await _db.delete(_db.bags).go();
      await _db.delete(_db.travelers).go();
      await _db.delete(_db.trips).go();
      await _db.delete(_db.packingTemplateItems).go();
      await _db.delete(_db.packingTemplates).go();
      await _db.delete(_db.vehicles).go();
      await _db.delete(_db.activityCategories).go();
      await _db.delete(_db.packingCategories).go();
      await _db.delete(_db.appSettings).go();

      // Reinserisci dai genitori verso i figli.
      for (final j in rows('appSettings')) {
        await _db.into(_db.appSettings).insert(AppSetting.fromJson(j));
      }
      for (final j in rows('packingCategories')) {
        await _db.into(_db.packingCategories).insert(PackingCategory.fromJson(j));
      }
      for (final j in rows('activityCategories')) {
        await _db
            .into(_db.activityCategories)
            .insert(ActivityCategory.fromJson(j));
      }
      for (final j in rows('vehicles')) {
        await _db.into(_db.vehicles).insert(Vehicle.fromJson(j));
      }
      for (final j in rows('packingTemplates')) {
        await _db.into(_db.packingTemplates).insert(PackingTemplate.fromJson(j));
      }
      for (final j in rows('packingTemplateItems')) {
        await _db
            .into(_db.packingTemplateItems)
            .insert(PackingTemplateItem.fromJson(j));
      }
      for (final j in rows('trips')) {
        await _db.into(_db.trips).insert(Trip.fromJson(j));
      }
      for (final j in rows('travelers')) {
        await _db.into(_db.travelers).insert(Traveler.fromJson(j));
      }
      for (final j in rows('bags')) {
        await _db.into(_db.bags).insert(Bag.fromJson(j));
      }
      for (final j in rows('locations')) {
        await _db.into(_db.locations).insert(Location.fromJson(j));
      }
      for (final j in rows('itineraryDays')) {
        await _db.into(_db.itineraryDays).insert(ItineraryDay.fromJson(j));
      }
      for (final j in rows('transportSegments')) {
        await _db
            .into(_db.transportSegments)
            .insert(TransportSegment.fromJson(j));
      }
      for (final j in rows('packingItems')) {
        await _db.into(_db.packingItems).insert(PackingItem.fromJson(j));
      }
      for (final j in rows('costItems')) {
        await _db.into(_db.costItems).insert(CostItem.fromJson(j));
      }
      for (final j in rows('costSplits')) {
        await _db.into(_db.costSplits).insert(CostSplit.fromJson(j));
      }
      for (final j in rows('activities')) {
        await _db.into(_db.activities).insert(Activity.fromJson(j));
      }
    });
  }
}
