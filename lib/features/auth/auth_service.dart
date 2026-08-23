import 'dart:typed_data';

import 'package:google_sign_in/google_sign_in.dart';
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

  /// Cancella definitivamente l'account e tutti i dati sul server (RPC
  /// `delete_account`, security definer), poi termina la sessione locale.
  Future<void> deleteAccount() async {
    await _c.rpc('delete_account');
    try {
      await _c.auth.signOut();
    } catch (_) {
      // l'utente non esiste piu': la sessione e' comunque da ripulire.
    }
  }

  static bool _googleReady = false;

  /// Accesso con Google **NATIVO**: mostra il popup di scelta account (niente
  /// browser) tramite `google_sign_in`, poi scambia l'ID token con Supabase
  /// (`signInWithIdToken`). Richiede su Google Cloud un client **Android**
  /// (package + SHA-1, fa apparire il popup) e un client **Web** il cui ID va
  /// in [SupabaseConfig.googleServerClientId] + nel provider Google di Supabase.
  Future<void> signInWithGoogle() async {
    final serverId = SupabaseConfig.googleServerClientId;
    if (serverId.isEmpty) {
      throw const AuthException(
          'Google non ancora configurato (manca il Web client ID).');
    }
    final gsi = GoogleSignIn.instance;
    if (!_googleReady) {
      await gsi.initialize(serverClientId: serverId);
      _googleReady = true;
    }
    final account = await gsi.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw const AuthException('Google non ha restituito un ID token.');
    }
    // Access token (facoltativo) per gli scope base, se gia' autorizzati.
    String? accessToken;
    try {
      final authz = await account.authorizationClient
          .authorizationForScopes(const ['email', 'profile']);
      accessToken = authz?.accessToken;
    } catch (_) {}
    await _c.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  }

  /// Accesso con Apple (browser + deep link). Richiede il provider Apple
  /// configurato in Supabase. Attualmente non esposto in UI (manca Apple Dev).
  Future<bool> signInWithApple() => _c.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: SupabaseConfig.authRedirect,
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

  Future<void> sendPasswordReset(String email) => _c.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: SupabaseConfig.authRedirect,
      );

  /// Imposta una nuova password (usato dopo il link di recupero).
  Future<void> updatePassword(String newPassword) =>
      _c.auth.updateUser(UserAttributes(password: newPassword));

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

  /// Carica un'immagine di profilo su Supabase Storage (bucket `avatars`) e
  /// salva l'URL pubblico su `profiles.avatar_url`. Ritorna l'URL (con
  /// cache-busting, cosi' l'app mostra subito la nuova immagine).
  Future<String> uploadAvatar(Uint8List bytes, {String ext = 'jpg'}) async {
    final uid = currentUser!.id;
    final path = '$uid/avatar.$ext';
    await _c.storage.from('avatars').uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(upsert: true, contentType: 'image/$ext'),
        );
    final base = _c.storage.from('avatars').getPublicUrl(path);
    final url = '$base?t=${DateTime.now().millisecondsSinceEpoch}';
    await _c.from('profiles').upsert({
      'id': uid,
      'avatar_url': url,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
    return url;
  }
}
