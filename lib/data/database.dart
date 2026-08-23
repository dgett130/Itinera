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
          await ensureSyncInfrastructure();
        },
      );

  /// Tabelle i cui dati vengono sincronizzati con Supabase.
  static const List<String> syncedTables = [
    'trips',
    'travelers',
    'bags',
    'packing_items',
    'transport_segments',
    'cost_items',
    'cost_splits',
    'itinerary_days',
    'locations',
    'activities',
  ];

  /// Crea (idempotente) la coda `_outbox`, lo stato `_sync_state` e i trigger
  /// che accodano ogni scrittura sulle tabelle sincronizzate. Cosi' repository
  /// e UI non devono sapere nulla della sincronizzazione.
  Future<void> ensureSyncInfrastructure() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS _outbox(
        tbl TEXT NOT NULL,
        row_id TEXT NOT NULL,
        op TEXT NOT NULL,
        at INTEGER NOT NULL,
        PRIMARY KEY(tbl, row_id)
      );''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS _sync_state(
        key TEXT PRIMARY KEY,
        value TEXT
      );''');
    // NB: upsert esplicito con ON CONFLICT DO UPDATE. `INSERT OR REPLACE`
    // dentro un trigger puo' ereditare la conflict-policy dell'operazione
    // esterna (es. FK SET NULL) e fallire con UNIQUE constraint.
    for (final t in syncedTables) {
      await customStatement('''
        CREATE TRIGGER IF NOT EXISTS _sync_${t}_ai AFTER INSERT ON $t BEGIN
          INSERT INTO _outbox(tbl,row_id,op,at)
          VALUES('$t', NEW.id, 'upsert', strftime('%s','now'))
          ON CONFLICT(tbl,row_id) DO UPDATE SET op=excluded.op, at=excluded.at;
        END;''');
      await customStatement('''
        CREATE TRIGGER IF NOT EXISTS _sync_${t}_au AFTER UPDATE ON $t BEGIN
          INSERT INTO _outbox(tbl,row_id,op,at)
          VALUES('$t', NEW.id, 'upsert', strftime('%s','now'))
          ON CONFLICT(tbl,row_id) DO UPDATE SET op=excluded.op, at=excluded.at;
        END;''');
      await customStatement('''
        CREATE TRIGGER IF NOT EXISTS _sync_${t}_ad AFTER DELETE ON $t BEGIN
          INSERT INTO _outbox(tbl,row_id,op,at)
          VALUES('$t', OLD.id, 'delete', strftime('%s','now'))
          ON CONFLICT(tbl,row_id) DO UPDATE SET op=excluded.op, at=excluded.at;
        END;''');
    }
  }
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
