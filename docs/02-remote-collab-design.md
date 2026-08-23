# Itinera — Design: account, profilo e viaggi condivisi (Supabase)

> Stato: **proposta** (da approvare). Backend scelto: **Supabase cloud gestito**
> per iniziare, con possibilità di self-hosting sul homelab in seguito senza
> cambiare il codice dell'app.

## 1. Obiettivo

Due grandi feature:

1. **Login + profilo** — account veri (email/password, poi OAuth), con un
   profilo utente (nome visualizzato, avatar). Sostituisce l'attuale login
   HMAC fisso `dgett130/password`.
2. **Viaggi condivisi** — invitare altre persone a un viaggio e collaborare
   (vedere/modificare valigia, tratte, spese, itinerario dello stesso viaggio).

## 2. Principi guida

- **Offline-first mantenuto.** Drift (SQLite) resta la cache locale e la fonte
  di verità *offline*. Supabase (Postgres) diventa il **server di verità**
  online. Si continua a lavorare offline; si sincronizza quando c'è rete.
- **UUID già pronti.** Le PK sono già UUID generate lato client: **lo stesso id
  vale in locale e in remoto**, niente rimappatura. Enorme semplificazione per
  la sincronizzazione.
- **La sicurezza è nel database (RLS), non nel client.** La `anon key` di
  Supabase è pubblica per definizione: a proteggere i dati sono le **Row Level
  Security policy**, non il segreto della chiave.
- **Managed ora, self-host dopo.** Stesso schema e stesso SDK; migrare al
  Supabase self-hostato sul homelab sarà solo un cambio di URL/chiavi.

## 3. Architettura

```
        ┌─────────────── App Flutter ───────────────┐
        │  UI  ─  Riverpod  ─  Repository            │
        │                    │                       │
        │              Drift (SQLite)  ← fonte offline│
        │                    │  ▲                     │
        │            SyncEngine (push/pull)           │
        └────────────────────┼──▲─────────────────────┘
                             ▼  │  HTTPS (supabase_flutter)
                      ┌──────────────────┐
                      │     Supabase      │
                      │  Auth  +  Postgres│  ← server di verità
                      │  + RLS + Realtime │
                      └──────────────────┘
```

- **Modalità dell'app** (riusa il mode-chooser esistente):
  - **Solo locale** (senza account): tutto in Drift, nessuna rete. Invariato.
  - **Account** (login): i viaggi vivono in Supabase e vengono **mirrorati in
    Drift**. Include i viaggi *propri* e quelli *condivisi con te*.

## 4. Modello dati remoto (Postgres)

Rispecchia lo schema Drift. Ogni tabella sincronizzabile aggiunge colonne di
sync. Le PK restano gli **stessi UUID** del locale.

### Nuove tabelle

| Tabella | Campi principali | Note |
|---|---|---|
| `profiles` | `id (=auth.uid)`, `display_name`, `avatar_url`, `created_at` | 1:1 con l'utente auth. Creata da trigger alla registrazione. |
| `trip_members` | `trip_id`, `user_id`, `role (owner/editor)`, `invited_email`, `status (pending/active)`, `created_at` | Appartenenza + permessi + inviti in sospeso. PK `(trip_id, user_id)`. |

### Tabelle sincronizzate (mirror di Drift)

`trips`, `travelers`, `bags`, `packing_items`, `transport_segments`,
`cost_items`, `cost_splits`, `itinerary_days`, `locations`, `activities`.

A ciascuna si aggiungono:

- `owner_id uuid` — chi ha creato la riga (per audit/RLS di scrittura fine).
- `updated_at timestamptz` — per il merge last-write-wins.
- `deleted_at timestamptz null` — **soft delete** (necessario per propagare le
  cancellazioni in sync; niente DELETE fisici).

`trips` aggiunge anche `owner_id` (proprietario del viaggio).

### Dati di riferimento

- `packing_categories`, `activity_categories`: **restano locali/seed** (uguali
  per tutti). Non si sincronizzano.
- `vehicles`, `packing_templates`, `packing_template_items`: **per-utente**
  (owner = utente). Sincronizzati solo per il proprietario (non condivisi nel
  viaggio). Fase 2b, opzionale.
- `app_settings`: **resta locale** (preferenze del device).

## 5. Sicurezza — Row Level Security

Idea: **puoi vedere/modificare le righe dei viaggi di cui sei membro.**

Funzione helper:

```sql
create function is_trip_member(t uuid) returns boolean
language sql security definer stable as $$
  select exists(
    select 1 from trip_members m
    where m.trip_id = t and m.user_id = auth.uid() and m.status = 'active'
  );
$$;
```

Policy (esempio per `packing_items`, replicata sulle altre tabelle-figlie):

```sql
alter table packing_items enable row level security;

create policy "membri leggono"  on packing_items for select
  using (is_trip_member(trip_id));
create policy "membri scrivono" on packing_items for insert
  with check (is_trip_member(trip_id));
create policy "membri aggiornano" on packing_items for update
  using (is_trip_member(trip_id)) with check (is_trip_member(trip_id));
```

- `trips`: SELECT/UPDATE se `is_trip_member(id)`; INSERT se `owner_id = auth.uid()`;
  eliminazione (soft-delete) solo per `role = 'owner'`.
- `trip_members`: leggibile dai membri del viaggio; scrivibile solo dagli
  `owner` (per invitare/rimuovere).
- `profiles`: ognuno legge/aggiorna il proprio; gli altri profili sono
  leggibili in forma minima (nome/avatar) se condividete un viaggio.

## 6. Autenticazione e profilo (Fase 1)

- **Metodo**: email + password per iniziare. OAuth Google/Apple in seguito
  (config lato Supabase, poche righe nell'app).
- **Registrazione** → trigger Postgres crea la riga `profiles`.
- **Sessione**: `supabase_flutter` gestisce token e refresh, persistiti in modo
  sicuro sul device. `RootGate` diventa reattivo allo stato auth.
- **Profilo**: schermata per nome visualizzato + avatar (upload su Supabase
  Storage, opzionale in Fase 1b).

Flusso schermate:

```
avvio ─ RootGate
  ├─ modalità non scelta      → ModeChooser (Solo locale / Account)
  ├─ Account, non loggato     → Login / Registrazione
  └─ loggato (o Solo locale)  → Home viaggi
```

## 7. Condivisione di un viaggio (Fase 2)

- Dal dettaglio viaggio: **"Persone"** → lista membri + **"Invita"**.
- **Invito via email**: si scrive una riga in `trip_members` con
  `invited_email`, `status = 'pending'`. Quando quell'utente si registra/accede
  con quella email, un trigger lo "attiva" (collega `user_id`).
- **Ruoli**: `owner` (crea/elimina, gestisce membri) ed `editor` (modifica
  contenuti). `viewer` (sola lettura) opzionale più avanti.
- La divisione spese usa i **viaggiatori** (`travelers`), che restano entità del
  viaggio: un membro-utente può essere collegato a un viaggiatore (campo
  opzionale `travelers.user_id`) per "questa spesa l'ho pagata io".

## 8. Sincronizzazione (Fase 2)

Modello **pull+push a livello di riga, last-write-wins su `updated_at`**.
Adeguato a quest'app (non serve co-editing tipo Google Docs).

- **Pull**: per ogni viaggio di cui sei membro, scarica le righe con
  `updated_at > lastSyncAt` (incluse quelle con `deleted_at`), applicandole in
  Drift (upsert / soft-delete).
- **Push**: invia le righe locali "sporche" (modificate dopo l'ultimo sync).
- **Conflitto**: vince l'`updated_at` più recente (per riga). Semplice e
  prevedibile.
- **Quando**: al login, all'apertura di un viaggio, su pull-to-refresh, e —
  Fase 2b — in tempo reale via **Realtime** (subscription per viaggio aperto).
- **Tracciamento locale**: aggiungere in Drift una colonna `dirty`/`syncedAt`
  o una tabella `_pending_changes`. (Richiede una micro-migrazione schema v4.)

## 9. Impatti sul codice esistente

- **Dipendenza**: `supabase_flutter`.
- **Config**: `SUPABASE_URL` + `SUPABASE_ANON_KEY` via `--dart-define`
  (o file gitignorato). La anon key è pubblica: nessun segreto reale.
- **Sostituzioni**:
  - `SyncService`/`RemoteApi` (document-sync HMAC) → **deprecati**, sostituiti da
    `AuthService` + `SupabaseSyncEngine`.
  - `server/` (Dart shelf) → **ritirato** per la modalità account; può restare
    come opzione di *backup locale* self-hosted, ma non è più il path primario.
  - `ModeChooser`: "Con il mio server" → **"Account (sync + collaborazione)"**.
  - `LoginScreen`: da URL+HMAC → email/password Supabase (+ registrazione).
  - `SettingsScreen`: sezione Account (profilo, logout, stato sync).
- **Repository**: restano su Drift; il `SupabaseSyncEngine` gira accanto e
  concilia. I repository **non** parlano direttamente con Supabase (mantiene
  l'offline-first e disaccoppia).
- **Migrazione schema Drift v4**: colonne di sync (`updatedAt` c'è già su alcune
  tabelle; aggiungere `deleted_at`/`dirty` dove serve) — codegen mirato come per
  la v3.

## 10. Fasi di consegna

- **Fase 1 — Account + profilo** *(feature completa e utile da sola)*
  1. Progetto Supabase + tabella `profiles` + trigger.
  2. `supabase_flutter`, config, `AuthService`.
  3. UI: registrazione, login, profilo; `RootGate` reattivo all'auth.
  4. Settings: sezione Account + logout.
- **Fase 2 — Condivisione + sync**
  1. Schema remoto (tabelle mirror + `trip_members`) + RLS.
  2. `SupabaseSyncEngine` (pull/push, soft-delete, last-write-wins) + migrazione
     Drift v4.
  3. UI "Persone" del viaggio + inviti via email.
  4. (2b) Realtime + avatar/storage + collegamento membro↔viaggiatore.

## 11. Decisioni da confermare (con i miei default proposti)

| Tema | Default proposto |
|---|---|
| Metodo login iniziale | Email + password (OAuth dopo) |
| Ruoli | `owner` + `editor` (viewer più avanti) |
| Invito | Via **email** (l'invitato crea/usa un account con quella email) |
| Quando loggato | Tutti i tuoi viaggi vanno in cloud e si sincronizzano; "Solo locale" resta senza account |
| Conflitti | Last-write-wins per riga (`updated_at`) |
| Categorie/impostazioni | Restano locali (non sincronizzate) |

## 12. Cosa serve da te (setup Supabase)

1. Crea un account su supabase.com e un **New project** (region EU es. Frankfurt).
2. Da **Project Settings → API** copiami: **Project URL** e **anon public key**.
   (La `service_role` key **non** va nell'app: tienila privata.)
3. Nulla da configurare a mano nel DB: gli script SQL (tabelle, RLS, trigger) li
   preparo io e li applichi con un copia-incolla nel **SQL Editor**.

Con URL + anon key parto dalla **Fase 1** (account + profilo).
