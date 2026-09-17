import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/supabase_config.dart';
import 'auth_service.dart';
import 'profile.dart';

/// Client Supabase, o null se non inizializzato (modalita' locale).
SupabaseClient? get _clientOrNull =>
    supabaseReady ? Supabase.instance.client : null;

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(_clientOrNull);
});

/// Stream degli eventi di autenticazione (login/logout/refresh token).
final authChangesProvider = StreamProvider<AuthState?>((ref) {
  final client = _clientOrNull;
  if (client == null) return const Stream.empty();
  return client.auth.onAuthStateChange;
});

/// Utente corrente (null se non loggato o modalita' locale). Reattivo agli
/// eventi di [authChangesProvider].
final currentUserProvider = Provider<User?>((ref) {
  ref.watch(authChangesProvider);
  return _clientOrNull?.auth.currentUser;
});

/// True se l'utente corrente ha l'account Google collegato (login via Google):
/// abilita azioni come la creazione della cartella Drive dall'app.
final googleLinkedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return false;
  final providers = user.appMetadata['providers'];
  if (providers is List && providers.contains('google')) return true;
  if (user.appMetadata['provider'] == 'google') return true;
  return (user.identities ?? const []).any((i) => i.provider == 'google');
});

/// Profilo dell'utente corrente (null se non loggato).
final profileProvider = FutureProvider<Profile?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return ref.watch(authServiceProvider).fetchProfile(user.id);
});
