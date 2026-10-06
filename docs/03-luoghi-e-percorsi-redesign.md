# 03 — Luoghi e percorsi: redesign a passi

Stato: **bozza da approvare** · Base: v1.3.0, schema Drift v7 · Data: 2026-09-25

## 1. Obiettivi e decisioni

Obiettivi: costruzione del percorso **a passi**, **dettagli dei luoghi sempre a
portata**, tutto **user friendly** (una mano, italiano semplice, poche scelte
per schermata, nessun vicolo cieco).

| # | Decisione |
|---|-----------|
| D1 | Mappa sempre visibile + **vassoio** in basso; 3 passi saltabili **① Scegli → ② Ordina → ③ Pianifica**; bozza automatica |
| D2 | **Scheda luogo** = pannello trascinabile a 3 altezze, lo stesso componente ovunque |
| D3 | **Niente "luoghi salvati"**: toccare "Aggiungi" mette il luogo nel percorso in lavorazione |
| D4 | Nell'itinerario resta **un evento unico**, ma con **orario di partenza e scaletta** (durata di visita per tappa) |
| D5 | Vassoio del passo ①: **ricerca per nome + filtri + elenco**; si cerca nell'**area visibile**; pressione lunga = **pin a mano** |
| D6 | Ingresso: **home corta** con i percorsi raggruppati per giorno (bozze incluse) + "＋ Nuovo percorso" |
| D7 | I luoghi salvati orfani esistenti migrano in una **bozza "Luoghi salvati"** per viaggio |
| D8 | Ordine: **quello di inserimento + suggerimento** "Ordine più veloce: −12 min [Applica]" (annullabile) |
| D9 | Avvisi non bloccanti: **chiuso a quell'ora**, **giornata lunga** (fine dopo 20:00 o > 9 h), **tanto cammino** (> 15 km piedi / > 40 km bici); **soglie configurabili** in una sezione dedicata |
| D10 | **Un percorso = un giorno**; "Sposta da qui in un nuovo percorso" per dividere |

## 2. Flusso e schermate

### 2.1 Home della sezione
```
┌──────────────────────────────┐
│ ← Luoghi e percorsi          │
│ ▸ Mar 12 ago                 │
│   🚶 Centro storico · 5 tappe │  → apre il riepilogo del percorso
│      9:00–16:30 · 6,2 km     │
│ ▸ Da programmare             │
│   ✏️ Bozza · 3 tappe          │  → riprende da dove eri
│   ✏️ Luoghi salvati · 7 tappe │  (migrazione D7)
│                              │
│      [ ＋ Nuovo percorso ]    │  ← grande, in basso (pollice)
└──────────────────────────────┘
```
Vuoto: illustrazione + "Crea il tuo primo percorso: scegli cosa vedere, noi lo
mettiamo in ordine." + bottone.

### 2.2 Costruzione: mappa a schermo pieno + vassoio
La mappa occupa tutto lo schermo (niente conflitto tra scroll e pan). Il vassoio
è un pannello trascinabile con il contenuto del passo corrente. In alto
l'indicatore dei passi (tappabile: i passi si possono saltare). In basso,
sempre sotto il pollice, il bottone principale del passo.

**① Scegli**
```
│ ①Scegli ─ ②Ordina ─ ③Pianifica │
│░░░ MAPPA · pin per categoria ░░│   pressione lunga = "Aggiungi un punto qui"
│░░ [Cerca qui] (se sposti) ░░░░░│
├────────────────────────────────┤
│ 🔍 Cerca un luogo…              │   ricerca per nome (Photon, riuso)
│ [Tutti][⛪][🏛][🌳][👁]…  ▸      │   filtri (scorrono di lato)
│ ⛪ S. Marco      350 m      [+] │   tocca la riga = apre la scheda
│ 🏛 Ducale        400 m      [✓] │   [+]/[✓] = aggiungi/togli dal percorso
│ ── 3 luoghi nel percorso ──     │
│ [ Avanti: ordina ▸ ]            │
```
- Pin già nel percorso: numerati con il colore d'accento; gli altri colorati per categoria.
- Tocco su un pin = apre la **scheda** (mai aggiunta alla cieca).
- Senza destinazione impostata: la mappa parte dalla posizione del viaggio o
  chiede "Dove vuoi esplorare?" (campo di ricerca), non resta vuota.

**② Ordina**
```
├────────────────────────────────┤
│ Parti da: ① S. Marco ▾          │   una tappa; può essere "solo partenza"
│ 🚶 A piedi ▾   Torno qui alla fine ○│
│ 💡 Ordine più veloce: 12 min in meno [Applica]│
│ ≡ 1 S. Marco                    │   trascina per riordinare
│      ↓ 🚶 8 min · 600 m          │   tempo tra le tappe
│ ≡ 2 Palazzo Ducale              │
│ [ Avanti: pianifica ▸ ]         │
```
- Il ricalcolo è **automatico** (niente "Ricalcola"). Senza rete: tempi con
  etichetta **"stima"**.
- "Applica" mostra un avviso "Ordine cambiato · Annulla" (sostituisce
  "Ripristina ordine manuale").

**③ Pianifica**
```
├────────────────────────────────┤
│ Giorno: Mar 12 ago ▾   Partenza: 9:00 ▾│
│ 9:00  ⛪ S. Marco        1 h ▾   │   durata visita modificabile
│ 10:08 🏛 Palazzo Ducale  1 h 30 ▾│
│ ⚠️ Chiude alle 18:00, arrivi alle 18:20 │
│ Fine prevista 16:30 · 6,2 km a piedi │
│ [ Aggiungi all'itinerario ]     │   → apre la tabella di marcia su quel giorno
```

### 2.3 Scheda luogo (componente unico)
Pannello trascinabile, 3 altezze, aperto da: pin, riga dell'elenco, tappa,
evento nell'itinerario.
- **Bassa**: nome, categoria, distanza, stato "Aperto ora / Chiuso / Orari da
  verificare", azione **[+ Aggiungi al percorso]** o **[Togli]**.
- **Media**: orari di apertura leggibili, durata di visita stimata, ingresso
  (gratis/a pagamento se noto), indirizzo, "Apri in Mappe".
- **Alta**: descrizione, sito web, **note personali** (modificabili), fonte
  "© OpenStreetMap".
- Foto: fuori da questo lavoro (vedi §6).

### 2.4 Dall'itinerario
L'evento del percorso mostra orario e numero di tappe. Toccandolo si apre il
**riepilogo in sola lettura** (mappa + scaletta, schede consultabili) con un
bottone **"Modifica"** che rientra nel flusso a passi.

### 2.5 Impostazioni → "Percorsi e avvisi"
Nuova sezione (accanto a "Notifiche"): fine giornata oltre le **20:00**, durata
oltre **9 h**, a piedi oltre **15 km**, in bici oltre **40 km**, e un
interruttore per ogni avviso.

## 3. Comportamenti trasversali
- **Bozza**: il percorso è salvato a ogni modifica; "bozza" = non ancora
  nell'itinerario. Uscire non perde mai niente, quindi niente conferme di uscita.
- **Annulla**: aggiungi, togli, riordina e "applica ordine" mostrano un avviso
  con **Annulla**. Conferma solo per **eliminare un percorso**.
- **Togliere una tappa** elimina il luogo dal viaggio se non è usato altrove
  (attività o altri percorsi); altrimenti toglie solo la tappa.
- **Offline**: home, percorsi, schede e scaletta funzionano sempre. Ricerca di
  luoghi nuovi: risultati in cache con "aggiornati il…"; senza cache c'è un
  messaggio chiaro più "Aggiungi un punto a mano". Tempi e distanze senza
  routing = "stima".
- **Testi**: niente gergo. "Partenza fissa" → "Parti da"; "Ritorno alla partenza"
  → "Torno qui alla fine"; "Stima (linea d'aria)" → "tempi stimati"; il
  raggio in km sparisce.
- **Accessibilità e aspetto**: colori dello stile del viaggio (`lib/ui/`),
  bersagli di tocco ≥ 48 dp, animazioni del vassoio e dei passi che rispettano
  "Riduci animazioni".

## 4. Modello dati

**Riuso**: `Locations` (luoghi, con i metadati OSM già presenti),
`SightseeingRoutes` (mezzo, `fixedStart` = "Parti da", `returnToStart` =
"Torno qui", `optimized`, geometria, `dayId`), `SightseeingRouteStops`
(ordine), `Activities.routeId` (evento unico), `PoiCacheEntries`,
`GeocodingService` (Photon), `optimizeRouteOrder`.

**Aggiunte (schema v8, tutte nullable)**

| Tabella | Colonna | Uso |
|---|---|---|
| `sightseeing_routes` | `start_minutes` int | Ora di partenza (minuti da mezzanotte); null = senza orario |
| `sightseeing_routes` | `legs` text (JSON) | `[{m,s}]` per tratto: tempi tra le tappe, offline |
| `sightseeing_route_stops` | `visit_minutes` int | Durata visita; null = default per categoria; 0 = solo punto di partenza |
| `locations` | `fee` text | Tag OSM `fee` (ingresso gratis/a pagamento) |

**Nessuna tabella nuova.** Durate predefinite per categoria (costanti in
`core/`): monumento 45′, museo 90′, natura 60′, panorama 20′, luogo di culto
30′, attrazione 60′, altro 30′.

**Evento nell'itinerario**: con `start_minutes` impostato, l'`Activity` riceve
`startMinutes`/`endMinutes` calcolati e `isAllDay = false`; senza orario resta
"tutto il giorno" come oggi. Il repository tiene allineati percorso ed evento.

**Soglie degli avvisi**: preferenze locali del dispositivo (`_app_prefs`, non
sincronizzate).

**Cosa cambia di significato**: "luoghi salvati" non esiste più. Nella
sezione compaiono solo le `Locations` che sono tappe di un percorso. Quelle
usate da attività e tratte (`source = transportLeg`, luoghi delle attività)
non vengono toccate né mostrate.

## 5. Sync, RLS, migrazione
- **Drift v7→v8**: `addColumn` delle 4 colonne (nullable, retrocompatibili con
  backup e sync). Codegen mirato su `lib/data/database.g.dart`.
- **`sync_mappers`**: aggiungere i nuovi campi ai mapper di routes, stops e
  locations. Trigger outbox invariati (stesse tabelle). Ordine delle tabelle in
  `syncedTables` invariato.
- **Supabase**: `docs/supabase/explore-v2.sql` con
  `alter table … add column if not exists …` sulle 3 tabelle. **RLS
  invariate**: le policy di membership coprono già le nuove colonne, e l'owner
  resta accettato in modo diretto (niente regressione su INSERT…RETURNING).
- **Client vecchi (1.3.0 degli amici)**: ignorano le colonne nuove. L'upsert
  aggiorna solo le colonne inviate, quindi non azzera i valori nuovi.
- **Backup**: i campi entrano da soli in `toJson`; i backup vecchi si importano
  (colonne null). Nessun cambio di `backupVersion` necessario.
- **Migrazione D7 ("Luoghi salvati")**: **non** nella migration Drift. È un
  passaggio **pigro e idempotente per viaggio**, all'apertura della sezione
  dopo il sync. Criterio: `Locations` del viaggio non usate da tappe né da
  attività, con `source` in {osm, mapPick} e non `transportLeg`. **Id
  deterministici** (UUID v5 da `tripId` per il percorso, da
  `routeId+locationId` per le tappe), così più dispositivi o membri generano la
  stessa bozza invece di duplicarla.

## 6. Logica pura nuova (in `core/` o `features/explore/`, con test)
- **Orari di apertura OSM**: parser del sottoinsieme comune (giorni, intervalli,
  `24/7`, `off`, più fasce). Tutto il resto dà "orari da verificare", senza
  inventare.
- **Scaletta**: da partenza + tratti + durate a orari di arrivo/uscita, fine
  giornata, totali.
- **Avvisi**: chiuso all'arrivo, giornata lunga, tanto cammino, con le soglie
  delle preferenze.
- **Tratti**: parsing dei `legs` già restituiti da OSRM; nel fallback, stima per
  coppia di tappe.

## 7. Piano a incrementi (ognuno rilasciabile)
1. **Scheda luogo**: componente riusabile, agganciato alla schermata attuale
   (il pin apre la scheda invece di salvare alla cieca). Nessuna modifica allo
   schema. *Valore subito: i dettagli diventano visibili.*
2. **Nuovo flusso, passo ①**: home della sezione, mappa a schermo pieno +
   vassoio + indicatore dei passi, ricerca nell'area visibile e per nome, pin a
   mano, aggiunta diretta al percorso (D3), bozze, migrazione D7. I passi ② e ③
   provvisoriamente mostrano l'elenco e il riordino attuali.
3. **Passo ② Ordina + schema v8**: "Parti da", "Torno qui", suggerimento con
   risparmio + annulla, tempi tra le tappe (`legs`), ricalcolo automatico.
   Migrazione v8 (tutte e 4 le colonne) + `explore-v2.sql`.
4. **Passo ③ Pianifica**: giorno, ora di partenza, durate di visita, scaletta,
   evento con orario nell'itinerario, riepilogo in sola lettura dall'itinerario.
5. **Avvisi**: parser orari, i tre avvisi, sezione "Percorsi e avvisi" in
   Impostazioni, ingresso (`fee`) nella scheda.
6. **Fuori scope, per dopo**: foto (Wikimedia via Wikidata, solo online),
   "Dividi in più giorni" automatico, rifiniture colori.

Ogni incremento: branch feature, `flutter analyze` pulito, test verdi,
CHANGELOG aggiornato; verifica sul Pixel a fine incremento o su richiesta.

## 8. Rischi e punti aperti
- **Orari OSM** spesso assenti o in formati rari: l'avviso "chiuso" sarà
  prudente e parziale per costruzione.
- **Modifiche contemporanee** di due membri sullo stesso percorso: vince
  l'ultima modifica, riga per riga (come il resto dell'app). Accettato, non si
  interviene.
- **Overpass/Photon/OSRM** gratuiti con limiti d'uso: già gestiti con timeout e
  cache. Cercare nell'area visibile riduce le query rispetto al raggio fisso.
- **Dipendenze**: nessun pacchetto nuovo previsto (pannello trascinabile nativo
  Flutter, UUID v5 dal pacchetto `uuid` già presente).
- **Da confermare**: soglie degli avvisi **per dispositivo** (proposta) o
  sincronizzate col profilo (servirebbero colonne su `profiles` + SQL).
