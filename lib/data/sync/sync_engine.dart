import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database.dart';
import 'sync_mappers.dart';

enum SyncPhase { idle, syncing, offline, error }

@immutable
class SyncStatus {
  const SyncStatus({this.phase = SyncPhase.idle, this.lastSyncedAt, this.error});
  final SyncPhase phase;
  final DateTime? lastSyncedAt;
  final String? error;

  SyncStatus copyWith({SyncPhase? phase, DateTime? lastSyncedAt, String? error}) =>
      SyncStatus(
        phase: phase ?? this.phase,
        lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
        error: error,
      );
}

/// Motore di sincronizzazione locale <-> Supabase.
///
/// - **push**: legge la coda `_outbox` (riempita dai trigger su ogni scrittura)
///   e riversa upsert/soft-delete su Supabase.
/// - **pull**: scarica le righe con `updated_at` piu' recente del watermark e le
///   applica in locale, saltando quelle con modifiche locali pendenti (l'utente
///   locale vince finche' non ha spinto).
/// - **realtime**: si iscrive ai cambiamenti per tirare giu' subito.
class SyncEngine {
  SyncEngine({
    required this.db,
    required this.client,
    required this.userId,
  }) : _tables = {for (final t in buildSyncTables(db)) t.name: t};

  final AppDatabase db;
  final SupabaseClient client;
  final String userId;
  final Map<String, SyncTable> _tables;

  final status = ValueNotifier<SyncStatus>(const SyncStatus());

  StreamSubscription<dynamic>? _updatesSub;
  RealtimeChannel? _channel;
  Timer? _pushDebounce;
  Timer? _pullDebounce;
  bool _busy = false;
  bool _disposed = false;

  static String _nowIso() => DateTime.now().toUtc().toIso8601String();

  Future<void> start() async {
    await _ensureLocalOwner();
    await _ensureProfile();
    await _claimInvites();
    await _bootstrapOnce();
    await syncNow();

    // Push automatico dopo ogni scrittura locale (i trigger accodano su
    // _outbox; qui reagiamo al segnale nativo di modifica tabelle di Drift).
    _updatesSub = db
        .tableUpdates(const TableUpdateQuery.any())
        .listen((_) => _schedulePush());

    // Pull in tempo reale sui cambiamenti remoti.
    _subscribeRealtime();
  }

  void dispose() {
    _disposed = true;
    _pushDebounce?.cancel();
    _pullDebounce?.cancel();
    _updatesSub?.cancel();
    if (_channel != null) client.removeChannel(_channel!);
    status.dispose();
  }

  void _schedulePush() {
    _pushDebounce?.cancel();
    _pushDebounce = Timer(const Duration(milliseconds: 600), () {
      unawaited(_run(push: true, pull: false));
    });
  }

  void _schedulePull() {
    _pullDebounce?.cancel();
    _pullDebounce = Timer(const Duration(milliseconds: 400), () {
      unawaited(_run(push: false, pull: true));
    });
  }

  Future<void> syncNow() => _run(push: true, pull: true);

  Future<void> _run({required bool push, required bool pull}) async {
    if (_disposed || _busy) return;
    _busy = true;
    status.value = status.value.copyWith(phase: SyncPhase.syncing);
    try {
      if (push) await _pushOnce();
      if (pull) await _pullOnce();
      status.value = SyncStatus(
        phase: SyncPhase.idle,
        lastSyncedAt: DateTime.now(),
      );
    } on SocketException {
      status.value = status.value.copyWith(phase: SyncPhase.offline);
    } on AuthException {
      await _forceReauth();
    } on PostgrestException catch (e) {
      debugPrint('[sync] postgrest code=${e.code} msg=${e.message} '
          'details=${e.details} hint=${e.hint}');
      if (_isAuthError(e)) {
        await _forceReauth();
      } else {
        status.value =
            status.value.copyWith(phase: SyncPhase.error, error: e.message);
      }
    } catch (e) {
      debugPrint('[sync] error: $e');
      final s = e.toString().toLowerCase();
      if (s.contains('socket') ||
          s.contains('failed host') ||
          s.contains('connection')) {
        status.value = status.value.copyWith(phase: SyncPhase.offline);
      } else {
        status.value = status.value.copyWith(
          phase: SyncPhase.error,
          error: e.toString(),
        );
      }
    } finally {
      _busy = false;
    }
  }

  bool _isAuthError(PostgrestException e) {
    final c = e.code ?? '';
    return c == 'PGRST301' ||
        c == '401' ||
        e.message.toLowerCase().contains('jwt');
  }

  /// Sessione non piu' valida (token scaduto/revocato): esce, cosi' il
  /// RootGate riporta alla schermata di accesso.
  Future<void> _forceReauth() async {
    status.value = status.value.copyWith(phase: SyncPhase.error, error: 'auth');
    try {
      await client.auth.signOut();
    } catch (_) {}
  }

  /// Reclama gli inviti in sospeso per l'email dell'utente (al login).
  Future<void> _claimInvites() async {
    try {
      await client.rpc('claim_invites');
    } catch (_) {}
  }

  /// Crea la riga `profiles` se manca (self-heal, indipendente dal trigger DB).
  Future<void> _ensureProfile() async {
    try {
      final u = client.auth.currentUser;
      if (u == null) return;
      final name = (u.userMetadata?['display_name'] as String?) ??
          u.email?.split('@').first;
      await client.from('profiles').upsert(
        {'id': u.id, 'display_name': name},
        onConflict: 'id',
        ignoreDuplicates: true,
      );
    } catch (_) {
      // profiles assente o offline: non bloccante.
    }
  }

  // --- Isolamento per-utente: cambio account => svuota la cache locale -------

  /// Se la cache locale appartiene a un altro utente (login con account diverso
  /// sullo stesso dispositivo), la azzera prima di sincronizzare, cosi' non si
  /// vedono i viaggi del profilo precedente. Con lo STESSO utente non tocca
  /// nulla (le eventuali modifiche offline restano).
  Future<void> _ensureLocalOwner() async {
    final prev = await _getState('local_owner');
    if (prev != null && prev != userId) {
      await _wipeLocalData();
    }
    await _setState('local_owner', userId);
  }

  /// Cancella tutte le tabelle sincronizzate + la coda e lo stato di sync.
  /// L'ordine inverso rispetta le foreign key; `_outbox` viene svuotata per
  /// ULTIMA nella stessa transazione, cosi' le delete accodate dai trigger
  /// durante la pulizia non vengono mai spinte sul server.
  Future<void> _wipeLocalData() async {
    await db.transaction(() async {
      for (final name in AppDatabase.syncedTables.reversed) {
        await db.customStatement('DELETE FROM $name');
      }
      await db.customStatement('DELETE FROM _sync_state');
      await db.customStatement('DELETE FROM _outbox');
    });
  }

  // --- Bootstrap: accoda i dati locali gia' presenti (primo login) ----------

  Future<void> _bootstrapOnce() async {
    final key = 'bootstrapped_$userId';
    if (await _getState(key) != null) return;
    for (final name in AppDatabase.syncedTables) {
      await db.customStatement(
        'INSERT OR REPLACE INTO _outbox(tbl,row_id,op,at) '
        "SELECT ?, id, 'upsert', strftime('%s','now') FROM $name",
        [name],
      );
    }
    await _setState(key, '1');
  }

  // --- PUSH -----------------------------------------------------------------

  Future<void> _pushOnce() async {
    final rows = await db
        .customSelect('SELECT tbl, row_id, op FROM _outbox ORDER BY at ASC')
        .get();
    for (final r in rows) {
      final tbl = r.read<String>('tbl');
      final id = r.read<String>('row_id');
      final op = r.read<String>('op');
      final spec = _tables[tbl];
      if (spec == null) {
        await _dropOutbox(tbl, id);
        continue;
      }
      if (op == 'delete') {
        await client.from(tbl).update({
          'deleted_at': _nowIso(),
          'updated_at': _nowIso(),
        }).eq('id', id);
      } else {
        final map = await spec.toRemote(db, id);
        if (map != null) {
          // owner_id esplicito (il default auth.uid() non e' affidabile per la
          // WITH CHECK). Per i viaggi condivisi, un trigger DB impedisce che
          // owner_id di `trips` cambi in update (la proprieta' resta all'autore).
          map['owner_id'] = userId;
          map['updated_at'] = _nowIso();
          map['deleted_at'] = null;
          await client.from(tbl).upsert(map);
          // La membership 'owner' e' creata dal trigger DB add_owner_membership
          // all'INSERT del viaggio: nessuna auto-iscrizione lato client (che
          // altrimenti farebbe auto-iscrivere owner anche chi non lo e').
        }
      }
      await _dropOutbox(tbl, id);
    }
  }

  // --- PULL -----------------------------------------------------------------

  Future<void> _pullOnce() async {
    // Ordine delle tabelle = ordine di dipendenza (le FK locali sono attive).
    for (final name in AppDatabase.syncedTables) {
      final spec = _tables[name]!;
      final wm = await _getState('pull_wm_$name') ?? '1970-01-01T00:00:00.000Z';
      final remote = await client
          .from(name)
          .select()
          .gt('updated_at', wm)
          .order('updated_at', ascending: true);
      if (remote.isEmpty) continue;

      final pending = <String>{
        for (final p in await db
            .customSelect('SELECT row_id FROM _outbox WHERE tbl = ?',
                variables: [Variable<String>(name)])
            .get())
          p.read<String>('row_id'),
      };

      final appliedIds = <String>[];
      String maxWm = wm;
      await db.transaction(() async {
        for (final row in remote) {
          final map = Map<String, dynamic>.from(row as Map);
          final id = map['id'] as String;
          final upd = map['updated_at'] as String?;
          if (upd != null && upd.compareTo(maxWm) > 0) maxWm = upd;
          if (pending.contains(id)) continue; // modifica locale in attesa: vince
          if (map['deleted_at'] != null) {
            await spec.deleteLocal(db, id);
          } else {
            await spec.applyRemote(db, map);
          }
          appliedIds.add(id);
        }
        // Soppressione dell'eco: le applyRemote/deleteLocal hanno riacceso i
        // trigger e riempito _outbox; rimuovo quelle voci appena create.
        for (final id in appliedIds) {
          await db.customStatement(
            'DELETE FROM _outbox WHERE tbl = ? AND row_id = ?',
            [name, id],
          );
        }
      });

      if (maxWm != wm) await _setState('pull_wm_$name', maxWm);
    }
  }

  // --- Realtime -------------------------------------------------------------

  void _subscribeRealtime() {
    try {
      final channel = client.channel('itinera_sync');
      for (final name in AppDatabase.syncedTables) {
        channel.onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: name,
          callback: (_) => _schedulePull(),
        );
      }
      channel.subscribe();
      _channel = channel;
    } catch (_) {
      // Realtime non disponibile: si resta su push/pull espliciti.
    }
  }

  // --- _sync_state helpers ---------------------------------------------------

  Future<String?> _getState(String key) async {
    final row = await db
        .customSelect('SELECT value FROM _sync_state WHERE key = ?',
            variables: [Variable<String>(key)])
        .getSingleOrNull();
    return row?.read<String?>('value');
  }

  Future<void> _setState(String key, String value) => db.customStatement(
        'INSERT OR REPLACE INTO _sync_state(key,value) VALUES(?,?)',
        [key, value],
      );

  Future<void> _dropOutbox(String tbl, String id) => db.customStatement(
        'DELETE FROM _outbox WHERE tbl = ? AND row_id = ?',
        [tbl, id],
      );
}
