import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/supabase_config.dart';
import '../../features/auth/auth_providers.dart';
import '../../providers.dart';
import 'sync_engine.dart';

/// Motore di sync attivo quando c'e' un utente loggato; null in caso contrario.
///
/// Viene creato/avviato al login e smaltito al logout (o al cambio utente).
/// Va "osservato" da un widget in alto nell'albero (RootGate) perche' parta.
final syncEngineProvider = Provider<SyncEngine?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null || !supabaseReady) return null;

  final engine = SyncEngine(
    db: ref.watch(databaseProvider),
    client: Supabase.instance.client,
    userId: user.id,
  );
  // Avvio in background: bootstrap + primo sync + realtime.
  engine.start();
  ref.onDispose(engine.dispose);
  return engine;
});
