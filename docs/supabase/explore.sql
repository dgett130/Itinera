-- Itinera — Supabase: "Luoghi e percorsi" (schema v4)
-- Migrazione INCREMENTALE e IDEMPOTENTE per installazioni gia' esistenti.
-- Da eseguire nel SQL Editor DOPO sync.sql e collaboration.sql.
--
-- Contiene:
--  1) nuove colonne su trips (coordinate destinazione) e locations (metadati POI)
--  2) due nuove tabelle: sightseeing_routes, sightseeing_route_stops
--  3) indici per il pull incrementale
--  4) RLS "superset condivisione" (owner diretto OR membro del viaggio)
--  5) realtime
--
-- Convenzioni identiche alle altre tabelle: id TEXT = UUID del client, enum come
-- TEXT (nome), colonne di sync owner_id/updated_at/deleted_at con default. Il
-- client NON invia owner_id/updated_at/deleted_at nel mapper: li aggiunge il
-- motore di sync (vedi sync_engine.dart). La cache POI locale NON e' sincronizzata.

-- 1) Nuove colonne ----------------------------------------------------------
alter table public.trips
  add column if not exists destination_lat double precision,
  add column if not exists destination_lng double precision;

alter table public.locations
  add column if not exists external_provider text,
  add column if not exists external_id text,
  add column if not exists poi_category text,
  add column if not exists description text,
  add column if not exists website text,
  add column if not exists opening_hours text,
  add column if not exists wikidata text;

-- 2) Nuove tabelle ----------------------------------------------------------
create table if not exists public.sightseeing_routes (
  id text primary key,
  trip_id text not null,
  day_id text,
  name text not null,
  travel_mode text not null default 'walk',
  optimized boolean not null default false,
  fixed_start boolean not null default false,
  return_to_start boolean not null default false,
  distance_meters integer,
  duration_seconds integer,
  geometry text,
  last_manual_order text,
  calc_source text not null default 'straightLine',
  created_at timestamptz not null default now(),
  owner_id uuid not null default auth.uid(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.sightseeing_route_stops (
  id text primary key,
  route_id text not null,
  trip_id text not null,
  location_id text not null,
  sequence_index integer not null default 0,
  owner_id uuid not null default auth.uid(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

-- 3) Indici -----------------------------------------------------------------
create index if not exists sightseeing_routes_owner_updated_idx
  on public.sightseeing_routes (owner_id, updated_at);
create index if not exists sightseeing_routes_trip_idx
  on public.sightseeing_routes (trip_id);
create index if not exists sightseeing_route_stops_owner_updated_idx
  on public.sightseeing_route_stops (owner_id, updated_at);
create index if not exists sightseeing_route_stops_route_idx
  on public.sightseeing_route_stops (route_id);
create index if not exists sightseeing_route_stops_trip_idx
  on public.sightseeing_route_stops (trip_id);

-- 4) RLS: superset condivisione (owner diretto OR membro del viaggio) --------
-- Stesso pattern di collaboration.sql sezione 4. Le funzioni helper
-- trip_owner_uid()/is_trip_member() sono definite in collaboration.sql.
do $$
declare t text;
begin
  foreach t in array array['sightseeing_routes','sightseeing_route_stops']
  loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('drop policy if exists %I on public.%I;', t||'_owner_all', t);
    execute format('drop policy if exists %I on public.%I;', t||'_member_all', t);
    execute format(
      'create policy %I on public.%I for all
         using (trip_owner_uid(trip_id) = auth.uid() or is_trip_member(trip_id))
         with check (trip_owner_uid(trip_id) = auth.uid() or is_trip_member(trip_id));',
      t||'_member_all', t
    );
    -- 5) Realtime
    begin
      execute format('alter publication supabase_realtime add table public.%I;', t);
    exception when duplicate_object then null;
    end;
  end loop;
end $$;
