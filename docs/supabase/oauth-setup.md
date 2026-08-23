# Login social (Google + Apple) — configurazione

Il codice app è pronto (`AuthService.signInWithGoogle` / `signInWithApple`,
pulsanti nella schermata di accesso). Manca **solo la configurazione nelle
console**. Il deep link di ritorno è già registrato: `org.itinera://login-callback`.

URL di callback del progetto Supabase (serve nelle console):
```
https://jgnyuwfowaqpwggynllh.supabase.co/auth/v1/callback
```

## 0) Supabase — Redirect URL (una volta sola)
Dashboard → **Authentication → URL Configuration → Redirect URLs** → aggiungi:
```
org.itinera://login-callback
```

## 1) Google
1. **Google Cloud Console** → crea/seleziona un progetto.
2. **APIs & Services → OAuth consent screen**: tipo *External*, nome app
   "Itinera", email di supporto, salva (in *Testing* va bene per iniziare).
3. **APIs & Services → Credentials → Create credentials → OAuth client ID**:
   - *Application type*: **Web application**.
   - *Authorized redirect URIs*: `https://jgnyuwfowaqpwggynllh.supabase.co/auth/v1/callback`
   - Salva: annota **Client ID** e **Client secret**.
4. **Supabase → Authentication → Providers → Google**: abilita, incolla
   *Client ID* e *Client secret*, salva.

> Nota: il flusso su Android passa dal browser (client "Web"), quindi non serve
> per forza un client Android nativo. Se in futuro vuoi il one-tap nativo si
> aggiunge un client Android con lo SHA-1 della firma.

## 2) Apple (richiede Apple Developer, 99€/anno)
1. **Identifiers → App IDs**: crea/usa l'App ID di Itinera e abilita la
   capability **Sign in with Apple**.
2. **Identifiers → Services IDs**: crea un Service ID (es. `org.itinera.signin`),
   abilita **Sign in with Apple → Configure**:
   - *Primary App ID*: quello sopra.
   - *Domains*: `jgnyuwfowaqpwggynllh.supabase.co`
   - *Return URLs*: `https://jgnyuwfowaqpwggynllh.supabase.co/auth/v1/callback`
3. **Keys**: crea una chiave con *Sign in with Apple* → scarica il file `.p8`,
   annota **Key ID** e il tuo **Team ID**.
4. **Supabase → Authentication → Providers → Apple**: abilita e inserisci
   *Services ID* (come Client ID), *Team ID*, *Key ID* e il contenuto del `.p8`.
   Salva.

## Test
Dopo aver salvato i provider: apri l'app → **Accedi** → "Continua con Google" /
"Continua con Apple". Si apre il browser, autorizzi, torni all'app già loggato.
Se compare "provider is not enabled" il provider non è ancora attivo su Supabase;
se il browser non torna all'app, controlla il Redirect URL al punto 0.
