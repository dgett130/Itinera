import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

import '../core/enums.dart';
import 'tables.dart';

part 'database.g.dart';

/// Database locale unico dell'app (SQLite via Drift).
///
/// Offline-first: e' l'unica fonte di verita'. Le foreign key sono attive
/// (ON DELETE CASCADE / SET NULL) per garantire l'integrita' referenziale.
@DriftDatabase(
  tables: [
    AppSettings,
    Trips,
    Travelers,
    PackingCategories,
    Bags,
    PackingItems,
    PackingTemplates,
    PackingTemplateItems,
    Vehicles,
    TransportSegments,
    CostItems,
    CostSplits,
    ItineraryDays,
    ActivityCategories,
    Locations,
    Activities,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Costruttore per i test: passare `NativeDatabase.memory()`.
  AppDatabase.forExecutor(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // v2: campi per la modalita' locale/remota.
            await m.addColumn(appSettings, appSettings.modeChosen);
            await m.addColumn(appSettings, appSettings.appMode);
            await m.addColumn(appSettings, appSettings.serverUrl);
            await m.addColumn(appSettings, appSettings.remoteUsername);
            await m.addColumn(appSettings, appSettings.authToken);
            await m.addColumn(appSettings, appSettings.lastSyncAt);
          }
          if (from < 3) {
            // v3: stile visivo per-viaggio (nullable = automatico).
            await m.addColumn(trips, trips.themeStyle);
          }
        },
        beforeOpen: (details) async {
          // Necessario perche' CASCADE/SET NULL vengano applicate da SQLite.
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'itinera.sqlite'));

    // Workaround per vecchie versioni di SQLite su Android datati.
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }
    // Directory temporanea per SQLite (necessaria su iOS/Android).
    final cacheBase = (await getTemporaryDirectory()).path;
    sqlite3.tempDirectory = cacheBase;

    return NativeDatabase.createInBackground(file);
  });
}
