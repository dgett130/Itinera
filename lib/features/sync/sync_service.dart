import '../../data/backup_service.dart';
import '../../data/settings_repository.dart';
import 'remote_api.dart';

/// Esito di una sincronizzazione, per la UI.
class SyncOutcome {
  const SyncOutcome(this.message);
  final String message;
}

/// Orchestrazione della sincronizzazione con il server (versione remota).
///
/// Modello: **documento intero, last-write-wins**. Riusa il formato JSON del
/// backup locale ([BackupService]). L'app resta local-first: si lavora sul DB
/// locale e si sincronizza on demand.
class SyncService {
  SyncService({
    required BackupService backup,
    required SettingsRepository settings,
  })  : _backup = backup,
        _settings = settings;

  final BackupService _backup;
  final SettingsRepository _settings;

  /// Login + inizializzazione: se il server ha gia' dei dati li scarica
  /// (il server vince al primo collegamento), altrimenti carica quelli locali.
  Future<SyncOutcome> loginAndInit(
    String serverUrl,
    String username,
    String password,
  ) async {
    final api = RemoteApi(serverUrl);
    try {
      final token = await api.login(username, password);
      final remote = await api.getData(token);
      if (remote != null && remote.trim().isNotEmpty) {
        await _backup.importJson(remote);
      } else {
        await api.putData(token, await _backup.exportJson());
      }
      await _settings.saveRemoteSession(
        serverUrl: serverUrl,
        username: username,
        token: token,
      );
      await _settings.setLastSync(DateTime.now());
      return SyncOutcome(
        remote != null ? 'Dati scaricati dal server' : 'Dati caricati sul server',
      );
    } finally {
      api.dispose();
    }
  }

  /// Carica lo stato locale sul server (upload).
  Future<SyncOutcome> push() async {
    final (api, token) = await _session();
    try {
      await api.putData(token, await _backup.exportJson());
      await _settings.setLastSync(DateTime.now());
      return const SyncOutcome('Dati caricati sul server');
    } on RemoteException catch (e) {
      if (e.unauthorized) await _settings.clearRemoteSession();
      rethrow;
    } finally {
      api.dispose();
    }
  }

  /// Scarica lo stato dal server sovrascrivendo quello locale (download).
  Future<SyncOutcome> pull() async {
    final (api, token) = await _session();
    try {
      final remote = await api.getData(token);
      if (remote != null && remote.trim().isNotEmpty) {
        await _backup.importJson(remote);
      }
      await _settings.setLastSync(DateTime.now());
      return SyncOutcome(
        remote != null ? 'Dati scaricati dal server' : 'Nessun dato sul server',
      );
    } on RemoteException catch (e) {
      if (e.unauthorized) await _settings.clearRemoteSession();
      rethrow;
    } finally {
      api.dispose();
    }
  }

  Future<void> logout() => _settings.clearRemoteSession();

  Future<(RemoteApi, String)> _session() async {
    final s = await _settings.get();
    final url = s.serverUrl;
    final token = s.authToken;
    if (url == null || token == null) {
      throw RemoteException('Sessione assente: effettua di nuovo l\'accesso',
          unauthorized: true);
    }
    return (RemoteApi(url), token);
  }
}
