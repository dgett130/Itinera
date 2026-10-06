# Changelog

Tutte le modifiche rilevanti di **Itinera**. Formato ispirato a
[Keep a Changelog](https://keepachangelog.com/it/); versioni in stile
`X.Y.Z+build` (build = versionCode Android).

> Le voci sotto **Non rilasciato** confluiscono nella prossima versione: al
> rilascio si spostano sotto `## [X.Y.Z] - AAAA-MM-GG` e si bumpa `pubspec.yaml`
> + la stringa in `settings_screen.dart` + il tag git `vX.Y.Z`.

## [Non rilasciato]

## [1.4.0] - 2026-10-06

### Aggiunto
- **Scheda del luogo** in "Luoghi e percorsi": toccando un luogo (pin sulla
  mappa, elenco dei suggeriti, luoghi salvati, tappe del percorso) si apre un
  pannello trascinabile con **orari di apertura in italiano leggibile**,
  **durata di visita stimata**, indirizzo e "Apri in Mappe", descrizione, sito
  web e **note personali** (salvate in automatico). Il pin sulla mappa non
  salva più il luogo "alla cieca".
- **Luoghi e percorsi a passi**: nuova pagina iniziale con i percorsi
  raggruppati per giorno (le bozze in "Da programmare") e un grande "Nuovo
  percorso". La costruzione avviene su **mappa a schermo pieno** con un
  vassoio trascinabile e tre passi saltabili: **① Scegli → ② Ordina →
  ③ Pianifica**, bottone principale sempre sotto il pollice.
- **Scegli**: ricerca nell'**area visibile** della mappa ("Cerca qui" quando la
  sposti, niente più raggio in km), **ricerca per nome**, filtri, e **pin a
  mano** tenendo premuto sulla mappa. Il [+] aggiunge il luogo direttamente al
  percorso; togliere una tappa si può **annullare**.
- **Ordina**: **tempo e distanza tra una tappa e l'altra** (anche per il
  ritorno), calcolati sulle strade o stimati senza rete ("circa");
  **"Parti da"** una tappa a scelta, anche come **solo punto di partenza**
  (es. l'albergo), oppure dalla più comoda; **"Torno a … alla fine"**.
- **Suggerimento "Ordine più veloce: circa N min in meno"** con **Applica**,
  che si può annullare; compare solo quando il risparmio è concreto (con i
  tempi sulle strade viene prima verificato sulle strade).
- **Pianifica**: giorno, **ora di partenza** e **scaletta** con l'orario di
  arrivo a ogni tappa, il tempo tra una tappa e l'altra e la **durata di
  visita modificabile** (come suggerito per categoria, una durata a scelta,
  "solo passaggio"); in fondo **fine prevista** (o durata totale) con km,
  tempo in movimento e tempo di visita.
- Con l'ora di partenza l'evento del percorso nella tabella di marcia ha
  **inizio e fine** e resta allineato a ogni modifica (orario, durate, ordine,
  nome); senza orario resta "tutto il giorno".
- **Riepilogo del percorso** dalla tabella di marcia: toccando l'evento si
  vedono mappa e scaletta in sola lettura (schede dei luoghi comprese), con
  **"Modifica"** per rientrare nei passi. L'evento mostra il numero di tappe.
- La scheda del luogo mostra la **durata di visita scelta** nel percorso (non
  più sempre quella suggerita).
- **Avvisi nella scaletta** (Pianifica e riepilogo): luogo **chiuso quel
  giorno**, che **apre dopo il tuo arrivo**, **già chiuso** o che **chiude
  durante la visita** (dagli orari OpenStreetMap, quando sono interpretabili
  e il giorno ha una data); **giornata che finisce tardi**, **giornata
  lunga**, **tanta strada a piedi o in bici**.
- **Impostazioni → "Percorsi e avvisi"**: ogni avviso si può spegnere e le
  soglie si regolano con "Meno"/"Di più" (predefinite: fine dopo le 20:00,
  oltre 9 h, a piedi oltre 15 km, in bici oltre 40 km). Valgono solo su
  questo dispositivo.
- Scheda del luogo: **"Aperto ora · chiude alle …" / "Chiuso ora · apre alle
  …"** (o "Orari da verificare") e **ingresso** gratuito, a pagamento o a
  offerta libera, quando OpenStreetMap lo indica.

### Modificato
- **Niente più "luoghi salvati" separati**: i luoghi vivono dentro i percorsi.
  Quelli salvati in precedenza vengono raccolti in una bozza **"Luoghi
  salvati"** (una sola, anche tra più dispositivi e membri).
- Un nuovo percorso parte **vuoto** (prima conteneva tutti i luoghi salvati);
  una bozza lasciata senza tappe viene eliminata.
- Ordinamento più semplice: tempi e distanze si **ricalcolano da soli** (via
  "Ricalcola"); l'ordine automatico è un suggerimento con Annulla (via
  "Ripristina ordine manuale").
- Durate senza "0 min" superflui (es. "1 h" invece di "1 h 0 min").
- Tappa senza posizione sulla mappa: messaggio chiaro invece di "Altro" in rosso.
- Pannello **"Novità"** aggiornato con le novità di "Luoghi e percorsi".

### Corretto
- La scheda del luogo e i pannelli/dialoghi di "Luoghi e percorsi" usano lo
  **stile del viaggio** (prima comparivano con i colori generali dell'app).
- Aggiungere all'itinerario un percorso già presente in un altro giorno ora lo
  **sposta** invece di duplicare l'evento.

### Note tecniche
- Redesign a passi di "Luoghi e percorsi" descritto in
  **`docs/03-luoghi-e-percorsi-redesign.md`**.
- **Schema locale v8** (colonne nullable): `sightseeing_routes.start_minutes`
  e `legs` (tratti JSON `[{m,s}]`), `sightseeing_route_stops.visit_minutes`,
  `locations.fee`. Mapper di sync aggiornati; in pull le colonne nuove si
  applicano solo se il server le restituisce.
- **Supabase**: **`docs/supabase/explore-v2.sql`** (già eseguito) va
  eseguito nel SQL Editor **prima** di distribuire questa versione (RLS
  invariate); i client 1.3.0 continuano a sincronizzare.

## [1.3.0] - 2026-09-17

### Aggiunto
- **Luoghi e percorsi** (4ª sezione del viaggio): scoperta di POI reali vicino
  alla destinazione (OpenStreetMap via Overpass), filtri per categoria e per
  raggio (2/5/10/25/50 km), mappa ed elenco sincronizzati, salvataggio dei
  luoghi (consultabili offline), suggeriti **paginati** ("Mostra altri").
- **Percorsi di visita**: costruzione con riordino **drag&drop**, scelta del
  mezzo (a piedi/bici/auto), partenza fissa e ritorno alla partenza,
  **ottimizzazione automatica** dell'ordine delle tappe (offline, deterministica),
  distanza/durata e origine del calcolo, salva/rinomina.
- **Routing stradale reale** per **piedi, bici e auto** (istanze OSRM FOSSGIS);
  offline o servizio non disponibile → **stima etichettata** (linea d'aria).
- **Aggiungi all'itinerario**: il percorso diventa un **evento unico** del
  giorno; toccandolo si riapre il percorso (mappa + tappe).
- Coordinate della destinazione salvate dall'autocomplete (invalidate se il
  testo è modificato a mano).
- **Bacheca del viaggio**: carica e condividi file e documenti (biglietti,
  programmi…) tra i partecipanti. I byte stanno su Supabase Storage (bucket
  privato); l'elenco è consultabile offline. **Anteprima in-app** di foto (con
  zoom) e **PDF**, **download** sul dispositivo o condivisione (niente browser).
  Limite 25 MB per file, eliminazione con conferma.
- **Link Drive per il viaggio**: campo nel form di creazione/modifica per una
  cartella Drive di condivisione foto; nel dettaglio diventa una scorciatoia
  "Foto del viaggio" che apre la cartella.
- **Crea cartella Drive dall'app**: se l'account Google è collegato, un tocco
  crea la cartella "Itinera – <viaggio>" (condivisa con chi ha il link) e ne
  inserisce il link nel campo.
- **Notifiche**: push **FCM** (anche ad app chiusa) + **centro notifiche**
  in-app (campanellino con badge, lista in tempo reale) su eventi (richiesta di
  amicizia, richiesta accettata, viaggio condiviso, nuovo documento in bacheca),
  **preferenze per categoria** (l'utente sceglie se e cosa ricevere), promemoria
  **scadenze locali** (valigia/partenza) e **messaggi di sistema** inviabili
  dall'admin (a tutti o a un utente).
- **Novità del rilascio**: al primo avvio dopo un aggiornamento appare (una
  volta) un pannello con un **viaggiatore animato** (Lottie) e l'elenco delle
  nuove funzioni.

### Modificato
- **Animazioni UI**: apertura del viaggio con Hero (la card della lista si
  espande nel dettaglio), sfondo **"aurora" animato** nell'hero del viaggio (nei
  colori dello stile, rispetta "Riduci animazioni"), transizione dei valori del
  percorso (distanza/durata/fonte) al ricalcolo/ottimizzazione/cambio mezzo.

### Corretto
- **Sync più robusta**: le eliminazioni propagano il soft-delete dei figli
  (`recursive_triggers`), l'ordine di applicazione rispetta la nuova FK
  `activities.route_id`, e il pull **salta** eventuali righe orfane senza
  bloccare l'intera sincronizzazione.

### Note tecniche
- Migrazione database **v3 → v7** (non distruttiva); **backup v3**
  retrocompatibile; `duplicateTrip` copia luoghi, percorsi e tappe.
- Nuovo schema Supabase: eseguire **`docs/supabase/explore.sql`**,
  **`docs/supabase/bacheca.sql`** (crea anche il bucket Storage `trip-files`
  con le policy), **`docs/supabase/drive.sql`** (colonna `trips.drive_url`) e
  **`docs/supabase/notifications.sql`** (tabelle notifiche + trigger + realtime)
  prima di distribuire le feature ai collaboratori.
- Anteprima documenti bacheca: aggiunge `flutter_pdfview` (PDF) e
  `flutter_file_dialog` (salvataggio sul dispositivo).
- Creazione cartella Drive: richiede Google Drive API abilitata e lo scope
  `drive.file` sulla schermata di consenso OAuth — vedi
  **`docs/google-drive-setup.md`**.
- Notifiche push: aggiunge Firebase (FCM) + `flutter_local_notifications` +
  `timezone`. Setup in **`docs/notifications-setup.md`**: `google-services.json`
  in `android/app/`, schema **`docs/supabase/notifications.sql`**, Edge Function
  **`supabase/functions/send-push`** e un Database Webhook su `notifications`.
- Pannello Novità: aggiunge `lottie` + asset `assets/lottie/hiker.json` (licenza
  Lottie Simple). Fallback disegnato a mano se l'asset manca. La costante
  `kWhatsNewVersion` va allineata alla versione a ogni rilascio.
- Sync più tollerante: se una tabella non esiste ancora su Supabase (client
  aggiornato prima dello schema SQL) il motore la salta invece di andare in
  errore.

## [1.2.2] - 2026-09-10

### Modificato
- Nuova **icona app (v2)**: adaptive Android (sfondo/foreground/monochrome, con
  il simbolo nella safe zone) e varianti iOS (default/dark/tinted).

## [1.2.1] - 2026-09-10

### Corretto
- Al **logout** si torna subito alla schermata di accesso (idem per
  l'eliminazione dell'account), invece di restare nelle impostazioni.

## [1.2.0] - 2026-08-23

### Aggiunto
- **Elimina account** dall'app.
- Predisposizione **condivisione (beta)**: accesso Google per tutti, SMTP Gmail
  per il recupero password, distribuzione via Firebase App Distribution.
