# Login con Google — NATIVO (popup di scelta account, senza browser)

L'app usa `google_sign_in` (popup nativo) + `supabase.auth.signInWithIdToken`.
Servono **due** client OAuth su Google Cloud: uno **Android** (fa apparire il
popup) e uno **Web** (il cui ID va nell'app e in Supabase).

## 1) OAuth consent screen (una volta)
Google Cloud → **APIs & Services → OAuth consent screen**: tipo *External*,
nome "Itinera", email di supporto. In *Testing* va bene per iniziare (aggiungi
il tuo indirizzo tra i *Test users*).

## 2) Client OAuth **Android** (abilita il popup nativo)
Credentials → Create credentials → OAuth client ID → **Android**:
- **Package name**: `org.itinera.itinera`
- **SHA-1**: `FE:37:ED:8A:05:E4:AE:32:F4:99:01:09:0C:F3:E8:DC:C3:49:80:EE`
  (keystore di firma release `itinera-upload.jks`; per il debug la SHA-1 è diversa)

Non ha client secret e non chiede redirect URI: è normale.

## 3) Client OAuth **Web** (per l'ID token + Supabase)
Credentials → Create credentials → OAuth client ID → **Web application**:
- Il redirect URI non serve al flusso nativo; se il form lo richiede puoi
  mettere `https://jgnyuwfowaqpwggynllh.supabase.co/auth/v1/callback`.
- Copia il **Client ID** (…apps.googleusercontent.com) e il **Client secret**.

➡️ **Mandami il Web Client ID**: lo metto nell'app come `serverClientId`
(oppure lo passi tu a build-time con `--dart-define=GOOGLE_SERVER_CLIENT_ID=...`).
Senza, il pulsante mostra "Google non ancora configurato".

## 4) Supabase → Authentication → Providers → Google
- **Enable**.
- **Client ID** e **Client secret** = quelli del client **Web** (punto 3).
- In **Authorized Client IDs** aggiungi il **Web Client ID** (è l'audience
  dell'ID token che l'app invia). Salva.
- Se il login fallisse con errore *nonce*, attiva "Skip nonce check".

## 5) Test
Rilancio l'app col Web Client ID impostato → **Accedi → Continua con Google** →
appare il **popup di scelta account** → login automatico, niente browser.

---
*Apple*: rimandato (serve Apple Developer 99€/anno). Il metodo
`AuthService.signInWithApple` resta pronto per riattivare il pulsante.
