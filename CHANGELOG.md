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
- Migrazione database **v3 → v5** (non distruttiva); **backup v2**
  retrocompatibile; `duplicateTrip` copia luoghi, percorsi e tappe.
- Nuovo schema Supabase: eseguire **`docs/supabase/explore.sql`** (tabelle + RLS
  + realtime) prima di distribuire la feature ai collaboratori.

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
