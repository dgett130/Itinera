import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/supabase_config.dart';
import 'profile.dart';

/// Servizio di autenticazione e profilo su Supabase.
///
/// Incapsula l'accesso a `Supabase.instance.client`: se il client non e'
/// disponibile (chiavi assenti o init fallito) i metodi lanciano un errore
/// leggibile, cosi' la modalita' locale dell'app continua a funzionare.
class AuthService {
  AuthService(this._client);

  final SupabaseClient? _client;

  bool get isReady => _client != null;

  SupabaseClient get _c {
    final c = _client;
    if (c == null) {
      throw const AuthException('Account non disponibile: Supabase non attivo.');
    }
    return c;
  }

  User? get currentUser => _client?.auth.currentUser;
  Session? get currentSession => _client?.auth.currentSession;

  /// Registrazione. Il `display_name` finisce nei metadata utente; un trigger
  /// sul database crea la riga `profiles`. Se il progetto richiede la conferma
  /// via email, `res.session` sara' null finche' l'utente non conferma.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String displayName,
  }) {
    return _c.auth.signUp(
      email: email.trim(),
      password: password,
      data: {'display_name': displayName.trim()},
      emailRedirectTo: SupabaseConfig.authRedirect,
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return _c.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> signOut() => _c.auth.signOut();

  Future<void> sendPasswordReset(String email) => _c.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: SupabaseConfig.authRedirect,
      );

  Future<Profile?> fetchProfile(String userId) async {
    final data =
        await _c.from('profiles').select().eq('id', userId).maybeSingle();
    return data == null ? null : Profile.fromMap(data);
  }

  /// Aggiorna (o crea, come fallback al trigger) il nome visualizzato.
  Future<void> updateDisplayName(String displayName) async {
    final uid = currentUser?.id;
    if (uid == null) return;
    await _c.from('profiles').upsert({
      'id': uid,
      'display_name': displayName.trim(),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
  }
}
