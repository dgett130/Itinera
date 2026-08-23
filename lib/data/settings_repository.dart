import 'package:drift/drift.dart';

import '../core/enums.dart';
import 'database.dart';

/// Accesso alle impostazioni globali (riga singola, id=1), inclusa la
/// modalita' locale/remota e la sessione col server.
class SettingsRepository {
  SettingsRepository(this._db);

  final AppDatabase _db;

  Stream<AppSetting> watch() {
    return (_db.select(_db.appSettings)..where((s) => s.id.equals(1)))
        .watchSingle();
  }

  Future<AppSetting> get() {
    return (_db.select(_db.appSettings)..where((s) => s.id.equals(1)))
        .getSingle();
  }

  Future<void> _write(AppSettingsCompanion companion) async {
    await (_db.update(_db.appSettings)..where((s) => s.id.equals(1)))
        .write(companion);
  }

  /// Sceglie la modalita' e segna l'onboarding come completato.
  Future<void> chooseMode(AppMode mode) async {
    await _write(AppSettingsCompanion(
      appMode: Value(mode),
      modeChosen: const Value(true),
    ));
  }

  Future<void> resetModeChoice() async {
    await _write(const AppSettingsCompanion(modeChosen: Value(false)));
  }

  /// Salva la sessione col server dopo un login riuscito.
  Future<void> saveRemoteSession({
    required String serverUrl,
    required String username,
    required String token,
  }) async {
    await _write(AppSettingsCompanion(
      appMode: const Value(AppMode.remote),
      modeChosen: const Value(true),
      serverUrl: Value(serverUrl),
      remoteUsername: Value(username),
      authToken: Value(token),
    ));
  }

  /// Logout: cancella il token (mantiene URL e username per comodita').
  Future<void> clearRemoteSession() async {
    await _write(const AppSettingsCompanion(authToken: Value(null)));
  }

  Future<void> setLastSync(DateTime when) async {
    await _write(AppSettingsCompanion(lastSyncAt: Value(when)));
  }

  Future<void> updateFuelDefaults({
    required double consumption,
    required int priceCents,
  }) async {
    await _write(AppSettingsCompanion(
      defaultFuelConsumption: Value(consumption),
      defaultFuelPriceCents: Value(priceCents),
    ));
  }
}
