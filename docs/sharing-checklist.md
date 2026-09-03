# Condividere Itinera con gli amici (beta) — checklist

## 1) Login Google per TUTTI (pubblicare il consent screen)
Ora la schermata di consenso è in *Testing*: solo i Test users possono accedere.
- Google Cloud → **APIs & Services → OAuth consent screen** → **PUBLISH APP** → Confirm.
- Con gli scope base (`email`, `profile`, `openid`) **non serve la verifica** di
  Google: dopo la pubblicazione chiunque può accedere con Google.
- (Alternativa senza pubblicare: aggiungere le email Google degli amici tra i
  *Test users*, max 100.)

## 2) Reset password via SMTP — ✅ CONFIGURATO con Gmail SMTP
L'app-side è già pronto (Password dimenticata → email → deep link → nuova password).
Serve un SMTP su Supabase. **Soluzione che funziona senza dominio: Gmail SMTP.**

### Gmail SMTP (in uso, invia a chiunque, ~500 email/giorno)
1. Account Google (`dgettatelli@gmail.com`) → **myaccount.google.com/security** →
   attiva la **Verifica in due passaggi**.
2. **myaccount.google.com/apppasswords** → crea una password per app ("Itinera")
   → 16 caratteri.
3. Supabase → **Authentication → SMTP Settings → Enable custom SMTP**:
   - Sender email: `dgettatelli@gmail.com` · Sender name: `Itinera`
   - Host: `smtp.gmail.com` · Port: `465`
   - Username: `dgettatelli@gmail.com` · Password: la **password per app** (senza spazi)
   - Save.

**Note importanti (verificate sul campo):**
- Il link di reset è **usa-e-getta**: va cliccato **una sola volta**. Un secondo
  click (o un pre-scan del client email) dà "link scaduto/otp_expired" → basta
  richiederne uno nuovo.
- Il reset vale per gli account **email/password**. Gli account **solo-Google**
  non ricevono il recupero (ma accedono con Google, quindi non serve).

### Resend — perché NON l'abbiamo usato
Resend via SMTP **rifiuta** il mittente di prova `onboarding@resend.dev` (l'invio
non parte nemmeno, nessun log). Richiede un **dominio verificato**. Se un domani
avrai un dominio, Resend va benissimo: `smtp.resend.com:465`, user `resend`,
password = API key, sender `no-reply@tuodominio`.

## 3) Firebase App Distribution (installazione + auto-update per i tester)
1. **console.firebase.google.com** → crea/usa un progetto.
2. **Add app → Android**, package name `org.itinera.itinera` (nickname *Itinera*).
   Per la sola App Distribution NON serve `google-services.json`.
3. Sul PC: `npm i -g firebase-tools` poi `firebase login`.
4. In Firebase → **App Distribution → Testers & Groups** → crea il gruppo
   `amici` e aggiungi le email.
5. Carica la build (l'APK firmato è già pronto):
   ```bash
   firebase appdistribution:distribute \
     build/app/outputs/flutter-apk/app-release.apk \
     --app <FIREBASE_APP_ID> \
     --groups amici \
     --release-notes "Prima beta di Itinera 1.2.0"
   ```
   `<FIREBASE_APP_ID>` = Firebase → Project settings → Le tue app → **App ID**
   (formato `1:1234567890:android:abcdef...`).
6. I tester ricevono un'email con il link per installare l'app e le build future.
   *(Nota: al primo avvio devono consentire l'installazione da origini sconosciute.)*

> Per pochi amici va bene anche mandare direttamente l'APK
> (`build/app/outputs/flutter-apk/app-release.apk`): semplice, ma senza
> auto-update e con l'avviso di Play Protect all'installazione.

## 4) Elimina account — FATTO
- Esegui `docs/supabase/delete-account.sql` (funzione `delete_account`).
- In-app: **Profilo → Zona pericolosa → Elimina account** (cancella account +
  tutti i dati, poi logout). Irreversibile.

---
### Da tenere a mente (non bloccanti)
- **Privacy**: raccogli email, nome, avatar Google e dati viaggi su Supabase
  (region EU). Per gli amici basta essere trasparente; per il Play Store servirà
  una privacy policy.
- **Crash/errori**: nessun reporting (Sentry/Crashlytics) — utile per capire
  dove si bloccano i tester, da valutare.
- **Test multi-dispositivo**: finora provato solo su Pixel.
