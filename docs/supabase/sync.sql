-- Itinera — Supabase: schema di sync (dati del viaggio)
-- Modello attuale: SINGOLO UTENTE (owner). Ogni riga appartiene a chi l'ha
-- creata; le policy consentono tutto solo sulle proprie righe.
-- La condivisione (trip_members + RLS di appartenenza) sara' un superset
-- aggiunto in seguito, senza rompere questo schema.
--
-- Convenzioni:
--  * id TEXT = stesso UUID del client (locale == remoto, niente rimappatura)
--  * enum salvati come TEXT (nome), denaro in centesimi (int), pesi in grammi (int)
--  * colonne di sync su ogni tabella: owner_id, updated_at, deleted_at (soft delete)
-- Idempotente.

-- ---------------------------------------------------------------------------
-- Tabelle
-- ---------------------------------------------------------------------------

create table if not exists public.trips (
  id text primary key,
  name text not null,
  destination text,
  country text,
  start_date timestamptz,
  end_date timestamptz,
  trip_type text,
  climate text,
  traveler_count integer not null default 1,
  home_currency text not null default 'EUR',
  cover_image_path text,
  theme_style text,
  notes text,
  created_at timestamptz not null default now(),
  owner_id uuid not null default auth.uid(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.travelers (
  id text primary key,
  trip_id text not null,
  name text not null,
  share_weight double precision not null default 1.0,
  color_hex text,
  is_self_user boolean not null default false,
  sort_order integer not null default 0,
  owner_id uuid not null default auth.uid(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.bags (
  id text primary key,
  trip_id text not null,
  name text not null,
  type text,
  tare_weight_grams integer not null default 0,
  max_weight_grams integer,
  color_hex text,
  sort_order integer not null default 0,
  owner_id uuid not null default auth.uid(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.packing_items (
  id text primary key,
  trip_id text not null,
  category_id text not null,
  bag_id text,
  name text not null,
  quantity integer not null default 1,
  packed_count integer not null default 0,
  unit_weight_grams integer,
  is_essential boolean not null default false,
  notes text,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  owner_id uuid not null default auth.uid(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.transport_segments (
  id text primary key,
  trip_id text not null,
  sequence_index integer not null default 0,
  mode text,
  origin_label text not null default '',
  origin_lat double precision,
  origin_lng double precision,
  destination_label text not null default '',
  destination_lat double precision,
  destination_lng double precision,
  distance_km double precision,
  distance_source text,
  detour_factor double precision not null default 1.3,
  is_round_trip boolean not null default false,
  departure_at timestamptz,
  arrival_at timestamptz,
  vehicle_id text,
  consumption_snapshot double precision,
  consumption_unit_snapshot text,
  fuel_price_cents_snapshot integer,
  manual_cost_cents integer,
  provider text,
  booking_ref text,
  seat_info text,
  notes text,
  owner_id uuid not null default auth.uid(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.cost_items (
  id text primary key,
  trip_id text not null,
  segment_id text,
  category text,
  description text,
  amount_cents integer not null default 0,
  currency text not null default 'EUR',
  date timestamptz,
  status text,
  paid_by_traveler_id text,
  split_method text,
  receipt_photo_path text,
  created_at timestamptz not null default now(),
  owner_id uuid not null default auth.uid(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.cost_splits (
  id text primary key,
  cost_item_id text not null,
  traveler_id text not null,
  share_weight double precision not null default 1.0,
  share_amount_cents integer not null default 0,
  settled boolean not null default false,
  owner_id uuid not null default auth.uid(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.itinerary_days (
  id text primary key,
  trip_id text not null,
  date timestamptz,
  day_index integer not null default 0,
  title text,
  notes text,
  sort_index integer not null default 0,
  owner_id uuid not null default auth.uid(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.locations (
  id text primary key,
  trip_id text not null,
  label text not null,
  address text,
  latitude double precision,
  longitude double precision,
  place_type text,
  notes text,
  source text,
  owner_id uuid not null default auth.uid(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.activities (
  id text primary key,
  day_id text not null,
  trip_id text not null,
  title text not null,
  category_id text,
  start_minutes integer,
  end_minutes integer,
  is_all_day boolean not null default false,
  location_id text,
  cost_cents integer,
  currency text not null default 'EUR',
  status text,
  ignore_conflict boolean not null default false,
  notes text,
  booking_ref text,
  booking_url text,
  sort_index integer not null default 0,
  created_at timestamptz not null default now(),
  owner_id uuid not null default auth.uid(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

-- ---------------------------------------------------------------------------
-- Indici utili per il pull incrementale
-- ---------------------------------------------------------------------------
create index if not exists trips_owner_updated_idx            on public.trips (owner_id, updated_at);
create index if not exists travelers_owner_updated_idx        on public.travelers (owner_id, updated_at);
create index if not exists bags_owner_updated_idx             on public.bags (owner_id, updated_at);
create index if not exists packing_items_owner_updated_idx    on public.packing_items (owner_id, updated_at);
create index if not exists transport_segments_owner_upd_idx   on public.transport_segments (owner_id, updated_at);
create index if not exists cost_items_owner_updated_idx       on public.cost_items (owner_id, updated_at);
create index if not exists cost_splits_owner_updated_idx      on public.cost_splits (owner_id, updated_at);
create index if not exists itinerary_days_owner_updated_idx   on public.itinerary_days (owner_id, updated_at);
create index if not exists locations_owner_updated_idx        on public.locations (owner_id, updated_at);
create index if not exists activities_owner_updated_idx       on public.activities (owner_id, updated_at);

-- ---------------------------------------------------------------------------
-- RLS: ognuno vede/gestisce solo le proprie righe (owner_id = auth.uid())
-- ---------------------------------------------------------------------------
do $$
declare t text;
begin
  foreach t in array array[
    'trips','travelers','bags','packing_items','transport_segments',
    'cost_items','cost_splits','itinerary_days','locations','activities'
  ] loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('drop policy if exists %I on public.%I;', t||'_owner_all', t);
    execute format(
      'create policy %I on public.%I for all
         using (owner_id = auth.uid())
         with check (owner_id = auth.uid());',
      t||'_owner_all', t
    );
    -- Realtime: notifica dei cambiamenti (per la sync push da altri device)
    begin
      execute format('alter publication supabase_realtime add table public.%I;', t);
    exception when duplicate_object then null;
    end;
  end loop;
end $$;
