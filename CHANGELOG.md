# Changelog

Tutte le modifiche rilevanti di **Itinera**. Formato ispirato a
[Keep a Changelog](https://keepachangelog.com/it/); versioni in stile
`X.Y.Z+build` (build = versionCode Android).

> Le voci sotto **Non rilasciato** confluiscono nella prossima versione: al
> rilascio si spostano sotto `## [X.Y.Z] - AAAA-MM-GG` e si bumpa `pubspec.yaml`
> + la stringa in `settings_screen.dart` + il tag git `vX.Y.Z`.

## [Non rilasciato]

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
  privato, apertura via link firmato); l'elenco è consultabile offline. Limite
  25 MB per file, eliminazione con conferma.
- **Link Drive per il viaggio**: campo nel form di creazione/modifica per una
  cartella Drive di condivisione foto; nel dettaglio diventa una scorciatoia
  "Foto del viaggio" che apre la cartella.
- **Crea cartella Drive dall'app**: se l'account Google è collegato, un tocco
  crea la cartella "Itinera – <viaggio>" (condivisa con chi ha il link) e ne
  inserisce il link nel campo.

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
  con le policy) e **`docs/supabase/drive.sql`** (colonna `trips.drive_url`)
  prima di distribuire le feature ai collaboratori.
- Creazione cartella Drive: richiede Google Drive API abilitata e lo scope
  `drive.file` sulla schermata di consenso OAuth — vedi
  **`docs/google-drive-setup.md`**.
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
