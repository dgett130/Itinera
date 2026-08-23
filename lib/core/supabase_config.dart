/// Configurazione del backend Supabase (account, profilo, sync futura).
///
/// La `anonKey` e' **pubblica per definizione** (viaggia in ogni copia dell'app):
/// la protezione dei dati e' data dalle Row Level Security policy sul database,
/// non dalla segretezza della chiave. I valori qui sono i default del progetto
/// gestito; si possono sovrascrivere a build-time con
/// `--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`
/// (utile per puntare a un'istanza self-hostata in futuro).
class SupabaseConfig {
  SupabaseConfig._();

  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://jgnyuwfowaqpwggynllh.supabase.co',
  );

  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Impnbnl1d2Zvd2FxcHdnZ3lubGxoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODc0ODk4MDYsImV4cCI6MjEwMzA2NTgwNn0.uF3im4721pRr3cUl7qLYZVswXVEhvBEwbj0etI-2-Js',
  );

  /// Deep link a cui Supabase reindirizza dalle email (conferma account,
  /// reset password, futuri inviti). Deve essere presente anche nell'elenco
  /// **Redirect URLs** del progetto Supabase (Authentication → URL Configuration).
  static const String authRedirect = 'org.itinera://login-callback';

  /// ID del client OAuth **Web** di Google Cloud (…apps.googleusercontent.com).
  /// Serve al Google Sign-In NATIVO come `serverClientId`: fa sì che l'ID token
  /// restituito abbia l'audience che Supabase si aspetta. Il client **Android**
  /// (package `org.itinera.itinera` + SHA-1) va comunque creato su Google Cloud
  /// per far apparire il popup nativo. Impostabile a build-time con
  /// `--dart-define=GOOGLE_SERVER_CLIENT_ID=...`.
  static const String googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue: '',
  );

  /// Sono presenti delle credenziali (URL + chiave)?
  static bool get hasCredentials => url.isNotEmpty && anonKey.isNotEmpty;
}

/// Diventa `true` solo dopo un `Supabase.initialize` andato a buon fine
/// (impostato in `main()`); i provider auth lo usano per non toccare
/// `Supabase.instance` quando l'inizializzazione e' fallita o assente.
bool supabaseReady = false;
