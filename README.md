# Itinera — Organizzatore Viaggi

App mobile **offline-first** (Android + iOS) per organizzare una vacanza:
**valigia**, **viaggio/trasporto** (con calcolo carburante e spese) e
**itinerario** (tabella di marcia giorno per giorno).

Documento di analisi e requisiti: [`docs/01-analisi-e-requisiti.md`](docs/01-analisi-e-requisiti.md).

## Stack

- **Flutter 3.38.5 / Dart 3.10.4** — codebase unica Android + iOS
- **Drift (SQLite)** — database locale, offline-first, migrazioni versionate
- **Riverpod** — gestione dello stato (query reattive su Drift)
- **go_router** — navigazione
- **intl / flutter_localizations** — UI in italiano (predisposta EN)

> Nota versioni: i pacchetti sono pinnati a versioni compatibili con Dart 3.10.4
> (drift 2.28, build_runner 2.4.x, sqlite3_flutter_libs 0.5.x). Il file
> `android/build.gradle.kts` contiene un workaround che inietta il `namespace`
> mancante nei plugin datati. Aggiornando Flutter/Dart si potranno usare le
> versioni recenti e rimuovere il workaround.

## Struttura

```
lib/
  core/            # tema, enum, formattazione, calcoli puri (carburante, split, distanza)
  data/            # Drift: tabelle, database, seed, dati di esempio, backup
  features/
    trip/          # viaggi (home, form, dettaglio)
    packing/       # valigia
    transport/     # viaggio, carburante, spese, divisione
    itinerary/     # tabella di marcia
    settings/      # impostazioni + backup/restore
  l10n/            # stringhe ARB (it)
  main.dart · app.dart · router.dart · providers.dart
docs/              # analisi e requisiti
test/              # unit test (calcoli, DB, backup) + smoke test
```

## Sviluppo

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # genera Drift + l10n
flutter analyze
flutter test
flutter run                      # su emulatore/dispositivo Android
flutter build apk --debug        # APK installabile
```

Dopo aver modificato tabelle Drift o file `.arb`, rilanciare `build_runner`.

## Funzionalità (MVP)

- **Viaggi**: crea/modifica/duplica/elimina; home In arrivo/Passati; viaggio di esempio.
- **Valigia**: oggetti per categoria, spunta, essenziali, più bagagli con peso e
  avviso limite, template built-in + salva modello, ricerca.
- **Viaggio**: tratte multi-mezzo, calcolo carburante (distanza×consumo×prezzo),
  spese stima/reale, divisione tra viaggiatori e riepilogo "chi deve a chi".
- **Itinerario**: timeline giorno per giorno, attività con orari/luogo/costo,
  rilevamento sovrapposizioni, riordino, apri luogo in mappa esterna.
- **Backup**: export JSON completo via share; import (incolla JSON).
- **Offline totale**: tutto funziona senza rete; dati locali (Drift/SQLite).

## CI

`codemagic.yaml` — build Android (APK/AAB) + predisposizione iOS/TestFlight.

## Versioni locale e remota

Un'unica app, con **scelta all'avvio**:

- **Solo su questo dispositivo** (locale): dati salvati in locale, nessun login.
- **Con il mio server** (remota): login (`dgett130`/`password` di default) e
  sincronizzazione con un backend self-hosted, raggiungibile via **Tailscale**.

La modalita' si cambia in ogni momento da **Impostazioni → Modalita**.
La sincronizzazione usa lo stesso formato JSON del backup (documento intero,
last-write-wins): l'app resta local-first, il server e' solo il punto d'incontro.

Il backend e la guida di deploy su una VM Proxmox sono in **`server/`**
(vedi `server/README.md`). In sintesi:

```bash
cd server
docker compose up -d --build      # espone :8080
```
Poi nell'app scegli "Con il mio server" e inserisci
`http://<ip-tailscale-o-lan-della-VM>:8080`.

I test d'integrazione della sync (tag `integration`) richiedono il server
attivo; sono esclusi dal `flutter test` di CI con `--exclude-tags integration`.
