-- Itinera — Supabase: CONDIVISIONE viaggi (trip_members + RLS di appartenenza)
-- Superset dello schema owner-only: chi e' MEMBRO di un viaggio ne vede e
-- modifica i dati. Incolla ed esegui nel SQL Editor. Idempotente.
--
-- NOTA CHIAVE (fix 42501): le policy devono accettare l'OWNER *direttamente*
-- (owner_id = auth.uid()), non solo tramite trip_members. Motivo: l'app inserisce
-- con .upsert() che usa RETURNING; Postgres valuta la SELECT policy sulla riga
-- appena creata e, se l'owner non fosse gia' "visibile", l'INSERT ... RETURNING
-- fallirebbe con "new row violates row-level security policy". La membership
-- resta il canale per i COLLABORATORI ed e' creata in automatico da un trigger.

-- 1) Tabella membri --------------------------------------------------------
create table if not exists public.trip_members (
  id            uuid primary key default gen_random_uuid(),
  trip_id       text not null,
  user_id       uuid,
  invited_email text,
  role          text not null default 'editor',   -- 'owner' | 'editor'
  status        text not null default 'pending',  -- 'pending' | 'active'
  created_at    timestamptz not null default now()
);
create unique index if not exists trip_members_trip_user_uidx
  on public.trip_members (trip_id, user_id);
create index if not exists trip_members_email_idx
  on public.trip_members (lower(invited_email));
alter table public.trip_members enable row level security;

-- 2) Funzioni helper (security definer: bypassano la RLS, niente ricorsione) --
create or replace function public.is_trip_member(t text) returns boolean
language sql security definer stable set search_path = public as $$
  select exists(
    select 1 from trip_members m
    where m.trip_id = t and m.user_id = auth.uid() and m.status = 'active'
  );
$$;

create or replace function public.is_trip_owner(t text) returns boolean
language sql security definer stable set search_path = public as $$
  select exists(
    select 1 from trip_members m
    where m.trip_id = t and m.user_id = auth.uid()
      and m.role = 'owner' and m.status = 'active'
  );
$$;

create or replace function public.trip_owner_uid(t text) returns uuid
language sql security definer stable set search_path = public as $$
  select owner_id from trips where id = t;
$$;

-- Reclama gli inviti in sospeso per l'email dell'utente corrente (chiamata al login).
create or replace function public.claim_invites() returns void
language plpgsql security definer set search_path = public as $$
declare
  uemail text := lower(coalesce(auth.jwt() ->> 'email', ''));
begin
  if uemail = '' then return; end if;
  update trip_members
     set user_id = auth.uid(), status = 'active'
   where user_id is null
     and lower(invited_email) = uemail;
end;
$$;

-- 3) RLS: viaggi — l'OWNER passa sempre in modo diretto; i membri via funzione.
drop policy if exists trips_owner_all    on public.trips;
drop policy if exists trips_member_select on public.trips;
drop policy if exists trips_member_update on public.trips;
drop policy if exists trips_owner_insert  on public.trips;
drop policy if exists trips_owner_delete  on public.trips;
drop policy if exists trips_select on public.trips;
drop policy if exists trips_insert on public.trips;
drop policy if exists trips_update on public.trips;
drop policy if exists trips_delete on public.trips;
create policy trips_select on public.trips for select
  using (owner_id = auth.uid() or is_trip_member(id));
create policy trips_insert on public.trips for insert
  with check (owner_id = auth.uid());
create policy trips_update on public.trips for update
  using (owner_id = auth.uid() or is_trip_member(id))
  with check (owner_id = auth.uid() or is_trip_member(id));
create policy trips_delete on public.trips for delete
  using (owner_id = auth.uid() or is_trip_owner(id));

-- 4) RLS: tabelle figlie con trip_id — owner diretto OR membro ---------------
do $$
declare t text;
begin
  foreach t in array array[
    'travelers','bags','packing_items','transport_segments',
    'cost_items','itinerary_days','locations','activities'
  ] loop
    execute format('drop policy if exists %I on public.%I;', t||'_owner_all', t);
    execute format('drop policy if exists %I on public.%I;', t||'_member_all', t);
    execute format(
      'create policy %I on public.%I for all
         using (trip_owner_uid(trip_id) = auth.uid() or is_trip_member(trip_id))
         with check (trip_owner_uid(trip_id) = auth.uid() or is_trip_member(trip_id));',
      t||'_member_all', t
    );
  end loop;
end $$;

-- 5) RLS: cost_splits (via cost_items -> trip_id) --------------------------
drop policy if exists cost_splits_owner_all  on public.cost_splits;
drop policy if exists cost_splits_member_all on public.cost_splits;
create policy cost_splits_member_all on public.cost_splits for all
  using (exists(select 1 from cost_items ci where ci.id = cost_item_id
    and (trip_owner_uid(ci.trip_id) = auth.uid() or is_trip_member(ci.trip_id))))
  with check (exists(select 1 from cost_items ci where ci.id = cost_item_id
    and (trip_owner_uid(ci.trip_id) = auth.uid() or is_trip_member(ci.trip_id))));

-- 6) RLS: trip_members ------------------------------------------------------
drop policy if exists trip_members_select        on public.trip_members;
drop policy if exists trip_members_owner_insert  on public.trip_members;
drop policy if exists trip_members_owner_update  on public.trip_members;
drop policy if exists trip_members_owner_delete  on public.trip_members;
create policy trip_members_select on public.trip_members for select
  using (is_trip_member(trip_id) or user_id = auth.uid()
         or trip_owner_uid(trip_id) = auth.uid());
create policy trip_members_owner_insert on public.trip_members for insert
  with check (
    is_trip_owner(trip_id)
    or trip_owner_uid(trip_id) = auth.uid()
    or (user_id = auth.uid() and role = 'owner')
  );
create policy trip_members_owner_update on public.trip_members for update
  using (trip_owner_uid(trip_id) = auth.uid() or is_trip_owner(trip_id))
  with check (trip_owner_uid(trip_id) = auth.uid() or is_trip_owner(trip_id));
create policy trip_members_owner_delete on public.trip_members for delete
  using (trip_owner_uid(trip_id) = auth.uid() or is_trip_owner(trip_id));

-- 7) RLS: profiles leggibili tra co-membri (per mostrare nome/avatar) -------
drop policy if exists "profiles_self_select" on public.profiles;
drop policy if exists "profiles_comember_select" on public.profiles;
create policy "profiles_comember_select" on public.profiles for select using (
  id = auth.uid()
  or exists(
    select 1 from trip_members m1
    join trip_members m2 on m1.trip_id = m2.trip_id
    where m1.user_id = auth.uid() and m1.status = 'active'
      and m2.user_id = profiles.id and m2.status = 'active'
  )
);

-- 8) Trigger su trips -------------------------------------------------------
-- 8a) La proprieta' non cambia in update (un membro che modifica un viaggio
--     condiviso non "ruba" owner_id: resta all'autore).
create or replace function public.preserve_trip_owner() returns trigger
language plpgsql as $$
begin
  new.owner_id := old.owner_id;
  return new;
end;
$$;
drop trigger if exists trips_preserve_owner on public.trips;
create trigger trips_preserve_owner before update on public.trips
  for each row execute function public.preserve_trip_owner();

-- 8b) Alla creazione del viaggio, l'autore diventa subito membro 'owner'
--     attivo (serve alla lista membri e all'accesso dei collaboratori).
create or replace function public.add_owner_membership() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into trip_members (trip_id, user_id, role, status)
  values (new.id, new.owner_id, 'owner', 'active')
  on conflict (trip_id, user_id) do nothing;
  return new;
end;
$$;
drop trigger if exists trips_add_owner on public.trips;
create trigger trips_add_owner after insert on public.trips
  for each row execute function public.add_owner_membership();

-- 9) Realtime su trip_members ----------------------------------------------
do $$ begin
  alter publication supabase_realtime add table public.trip_members;
exception when duplicate_object then null; end $$;

-- 10) Pulizia righe di test lasciate dalla diagnosi (facoltativa) ----------
delete from public.trips where name in ('ProvaSync','SQLtest-plain','SQLtest-returning');
