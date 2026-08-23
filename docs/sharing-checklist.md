# Condividere Itinera con gli amici (beta) — checklist

## 1) Login Google per TUTTI (pubblicare il consent screen)
Ora la schermata di consenso è in *Testing*: solo i Test users possono accedere.
- Google Cloud → **APIs & Services → OAuth consent screen** → **PUBLISH APP** → Confirm.
- Con gli scope base (`email`, `profile`, `openid`) **non serve la verifica** di
  Google: dopo la pubblicazione chiunque può accedere con Google.
- (Alternativa senza pubblicare: aggiungere le email Google degli amici tra i
  *Test users*, max 100.)

## 2) Reset password via Resend (SMTP)
L'app-side è già pronto (Password dimenticata → email → deep link → nuova password).
Manca solo l'SMTP su Supabase.
1. Crea un account su **resend.com**.
2. **Domains → Add domain**: aggiungi un tuo dominio e inserisci i record DNS
   (SPF/DKIM) che Resend mostra, poi *Verify*.
   ⚠️ Serve un dominio tuo. Senza, Resend permette solo `onboarding@resend.dev`
   che invia **solo al tuo indirizzo** → inutile per gli amici.
3. **API Keys → Create** → copia la key.
4. Supabase → **Authentication → SMTP Settings → Enable custom SMTP**:
   - Sender email: `no-reply@iltuodominio` · Sender name: `Itinera`
   - Host: `smtp.resend.com` · Port: `465` · Username: `resend` · Password: *(la API key)*
   - Save.
5. (Opz.) Authentication → **Email Templates** → personalizza "Reset password".

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
