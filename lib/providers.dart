import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/backup_service.dart';
import 'data/database.dart';
import 'data/settings_repository.dart';
import 'features/sync/sync_service.dart';

/// Provider globale del database.
///
/// Viene sovrascritto in `main()` con l'istanza reale (gia' aperta e con i
/// dati di default caricati), cosi' l'app non deve gestire uno stato di
/// caricamento del DB nella UI.
final databaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('databaseProvider va sovrascritto in main()');
});

final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService(ref.watch(databaseProvider));
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(databaseProvider));
});

/// Impostazioni globali dell'app (riga singola, sempre presente dopo il seed).
final settingsProvider = StreamProvider<AppSetting>((ref) {
  return ref.watch(settingsRepositoryProvider).watch();
});

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    backup: ref.watch(backupServiceProvider),
    settings: ref.watch(settingsRepositoryProvider),
  );
});
