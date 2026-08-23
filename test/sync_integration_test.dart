@Tags(['integration'])
library;

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itinera/data/backup_service.dart';
import 'package:itinera/data/database.dart';
import 'package:itinera/data/sample_data.dart';
import 'package:itinera/data/seed.dart';
import 'package:itinera/data/settings_repository.dart';
import 'package:itinera/features/sync/remote_api.dart';
import 'package:itinera/features/sync/sync_service.dart';

/// Test d'integrazione: richiede il server in ascolto su questo URL.
/// Avviare prima: `cd server && PORT=8899 dart run bin/server.dart`.
/// Se il server non risponde, il test viene saltato.
const _serverUrl = 'http://127.0.0.1:8899';

void main() {
  test('sync end-to-end: device A carica, device B scarica', () async {
    final probe = RemoteApi(_serverUrl);
    final up = await probe.health();
    probe.dispose();
    if (!up) {
      markTestSkipped('Server non in ascolto su $_serverUrl');
      return;
    }

    // Device A: dati locali (seed + viaggio di esempio) -> login -> push.
    final dbA = AppDatabase.forExecutor(NativeDatabase.memory());
    await AppSeed.ensureSeeded(dbA);
    await SampleData.createIfEmpty(dbA);
    final tripsA = (await dbA.select(dbA.trips).get()).length;
    final activitiesA = (await dbA.select(dbA.activities).get()).length;
    final syncA = SyncService(
      backup: BackupService(dbA),
      settings: SettingsRepository(dbA),
    );
    await syncA.loginAndInit(_serverUrl, 'dgett130', 'password');

    // Device B: DB nuovo -> login -> pull (deve ricevere i dati di A).
    final dbB = AppDatabase.forExecutor(NativeDatabase.memory());
    await AppSeed.ensureSeeded(dbB);
    final syncB = SyncService(
      backup: BackupService(dbB),
      settings: SettingsRepository(dbB),
    );
    await syncB.loginAndInit(_serverUrl, 'dgett130', 'password');

    final tripsB = (await dbB.select(dbB.trips).get()).length;
    final activitiesB = (await dbB.select(dbB.activities).get()).length;
    expect(tripsA, greaterThan(0));
    expect(tripsB, tripsA);
    expect(activitiesB, activitiesA);

    // La sessione remota risulta salvata sul device B.
    final settingsB = await SettingsRepository(dbB).get();
    expect(settingsB.authToken, isNotNull);
    expect(settingsB.serverUrl, _serverUrl);

    await dbA.close();
    await dbB.close();
  });
}
