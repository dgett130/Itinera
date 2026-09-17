# Creare la cartella Drive dall'app (scope `drive.file`)

La funzione "Crea cartella Drive" nel form del viaggio crea una cartella su
Google Drive dell'utente e ne inserisce il link condivisibile nel campo *Link
cartella Drive*. Usa lo stesso login Google del resto dell'app: **non servono
nuovi client OAuth**, ma va abilitata l'API Drive e aggiunto lo scope.

Prerequisito: login Google già configurato (vedi `docs/supabase/oauth-setup.md`).

## 1) Abilita la Google Drive API
Google Cloud → **APIs & Services → Library** → cerca **Google Drive API** →
**Enable** (sullo stesso progetto dei client OAuth di Itinera).

## 2) Aggiungi lo scope alla schermata di consenso
**APIs & Services → OAuth consent screen → Data access → Add or remove scopes**:
aggiungi **`.../auth/drive.file`**
(«See, edit, create, and delete only the specific Google Drive files you use
with this app»). È il minimo indispensabile: l'app vede **solo** i file/cartelle
che crea lei, non tutto il Drive.

## 3) Utenti (finché l'app è in *Testing*)
Se lo stato di pubblicazione è **Testing**, ogni persona che usa la funzione
deve essere tra i **Test users** (APIs & Services → OAuth consent screen →
Test users). Per il gruppo di amici basta aggiungerne gli indirizzi Google.

> `drive.file` è uno scope *sensibile*: per l'uso pubblico (utenti esterni fuori
> dalla lista test) Google chiede la verifica dell'app. Per una cerchia ristretta
> resta più semplice tenere lo stato *Testing* e aggiungere i test users.

## Comportamento nell'app
- Il pulsante **Crea cartella Drive** compare nel form del viaggio solo se
  l'utente ha effettuato l'accesso con Google.
- Alla prima creazione Google chiede il consenso allo scope Drive.
- La cartella viene creata come **"Itinera – <nome viaggio>"** e impostata come
  *chiunque abbia il link può visualizzare*, così il gruppo vede le foto.
- Se l'API/scope non sono configurati, l'app mostra un errore leggibile e non
  compromette nient'altro (il link resta comunque inseribile a mano).
