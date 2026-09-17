# Notifiche push (FCM) — setup

Le notifiche usano **Firebase Cloud Messaging** (push anche ad app chiusa) +
un **centro notifiche in-app** e **preferenze per categoria**. Questa guida
elenca i passi lato Firebase/Supabase (il codice app è già pronto).

## 1) Firebase — `google-services.json` dell'app Android (già registrata)
L'app Android `org.itinera.itinera` è **già nel progetto** (è quella usata per
App Distribution): NON va aggiunta di nuovo. Serve solo scaricarne la config.

Console Firebase → **Impostazioni progetto** (⚙️) → scheda **Generali** → sezione
**Le tue app** → seleziona l'app Android `org.itinera.itinera` →
**Scarica `google-services.json`** → mettilo in **`android/app/google-services.json`**.

- Senza questo file la build Android **non compila** (il plugin google-services
  lo richiede).
- Per **FCM la SHA-1 non è necessaria** (serviva per il login Google, già
  configurato): non devi aggiungere nulla lato firme.

## 2) Firebase — Cloud Messaging
- Assicurati che **Cloud Messaging API (V1)** sia abilitata
  (Impostazioni progetto → Cloud Messaging).
- (iOS, opzionale) aggiungi l'app iOS, scarica `GoogleService-Info.plist` in
  `ios/Runner/`, e carica la APNs key in Firebase.

## 3) Supabase — schema
Esegui nel SQL Editor **`docs/supabase/notifications.sql`** (tabelle
`device_tokens`, `notification_prefs`, `notifications`, colonna
`profiles.is_admin`, RLS, realtime e i trigger sugli eventi).

## 4) Supabase — Edge Function `send-push`
È il "mittente" dei push: quando nasce una notifica, la function usa la chiave
di servizio Firebase per inviare il push FCM ai dispositivi del destinatario.

### 4.1 Chiave di servizio Firebase
Console Firebase → **Impostazioni progetto** → **Account di servizio** →
**Genera nuova chiave privata** → scarica il file JSON (es. `service-account.json`).
NON committarlo: è una credenziale segreta.

### 4.2 Supabase CLI (una volta)
Installa la CLI e collega il progetto:
```powershell
# Windows: installa la CLI (scegli uno)
scoop install supabase          # se usi Scoop
# oppure scarica l'exe da https://github.com/supabase/cli/releases

supabase login                  # apre il browser, autorizza
supabase link --project-ref jgnyuwfowaqpwggynllh
```

### 4.3 Imposta il secret (Windows, metodo base64 a prova di errore)
La function accetta la chiave anche in **base64** (evita problemi di
virgolette/newline su Windows). In PowerShell, dalla cartella dove hai il JSON:
```powershell
$b64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes("service-account.json"))
supabase secrets set FCM_SERVICE_ACCOUNT="$b64"
```
(Su Mac/Linux, in alternativa: `supabase secrets set FCM_SERVICE_ACCOUNT="$(cat service-account.json)"`.)

`SUPABASE_URL` e `SUPABASE_SERVICE_ROLE_KEY` sono forniti in automatico alla
function: non devi impostarli.

### 4.4 Deploy della function
```powershell
supabase functions deploy send-push
```
Il deploy avviene nel cloud Supabase (non serve Docker locale).

## 5) Supabase — Database Webhook
Database → **Webhooks** → *Create*:
- Tabella: **`public.notifications`**, evento **INSERT**
- Tipo: **Supabase Edge Functions** → function **`send-push`** (metodo POST)

Così ogni notifica inserita dai trigger fa partire il push, **rispettando le
preferenze** dell'utente (`notification_prefs`).

## 6) Admin (messaggi di sistema)
Per poter inviare messaggi di sistema, imposta il tuo profilo come admin:
```sql
update public.profiles set is_admin = true where id = '<il-tuo-user-id>';
```
Poi in **Impostazioni → Notifiche → Invia messaggio di sistema** (voce visibile
solo agli admin) puoi scrivere titolo+testo e inviare a tutti o a un utente. Il
push parte via lo stesso webhook.

## Come funziona nell'app
- Al login: richiesta permesso notifiche (Android 13+), registrazione del
  **token FCM** in `device_tokens`.
- **Campanellino** in home con badge dei non letti → centro notifiche (lista
  realtime, tap apre la sezione giusta, swipe per eliminare).
- **Preferenze** (icona regola nel centro notifiche): master + toggle per
  categoria; valgono anche ad app chiusa perché l'Edge Function le controlla
  prima di inviare.
- Eventi che generano notifica: richiesta di amicizia, richiesta accettata,
  viaggio condiviso con te, nuovo documento in bacheca, messaggi di sistema.
