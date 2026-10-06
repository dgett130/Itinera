-- Itinera — Supabase: "Luoghi e percorsi" a passi (schema v8)
-- Migrazione INCREMENTALE e IDEMPOTENTE. Da eseguire nel SQL Editor DOPO
-- explore.sql, e PRIMA di installare la versione dell'app con lo schema v8
-- (altrimenti il push di percorsi, tappe e luoghi viene rifiutato perche'
-- le colonne non esistono).
--
-- Solo colonne nuove, tutte nullable: i client vecchi le ignorano e l'upsert
-- aggiorna solo le colonne inviate, quindi non azzera i valori nuovi.
-- RLS INVARIATE: le policy di membership (owner diretto OR membro del
-- viaggio) coprono gia' le nuove colonne.

-- Percorso: ora di partenza (minuti da mezzanotte) e tratti tra le tappe
-- come JSON [{m,s}] (metri, secondi).
alter table public.sightseeing_routes
  add column if not exists start_minutes integer,
  add column if not exists legs text;

-- Tappa: durata della visita in minuti (null = predefinita per categoria,
-- 0 = solo punto di partenza).
alter table public.sightseeing_route_stops
  add column if not exists visit_minutes integer;

-- Luogo: tag OSM "fee" (ingresso gratuito/a pagamento).
alter table public.locations
  add column if not exists fee text;

-- Ricarica la cache dello schema di PostgREST (le colonne nuove diventano
-- subito visibili alle API).
notify pgrst, 'reload schema';
