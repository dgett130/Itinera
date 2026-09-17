-- Itinera — Supabase: Notifiche (centro in-app + base per push FCM)
-- Migrazione INCREMENTALE e IDEMPOTENTE. Eseguire nel SQL Editor DOPO
-- friends.sql, collaboration.sql e bacheca.sql.
--
-- Contiene:
--  1) profiles.is_admin (per i messaggi di sistema)
--  2) device_tokens        — token FCM per utente/dispositivo
--  3) notification_prefs    — preferenze per categoria (una riga per utente)
--  4) notifications         — inbox del centro notifiche in-app (+ realtime)
--  5) push_notification()   — helper security definer per inserire notifiche
--  6..8) trigger sugli eventi: richiesta amicizia, viaggio condiviso, nuovo
--        documento in bacheca → popolano l'inbox (l'invio push vero è la Fase B,
--        Edge Function `send-push` invocata da un webhook su notifications).

-- 1) Flag admin -------------------------------------------------------------
alter table public.profiles
  add column if not exists is_admin boolean not null default false;

-- 2) Token FCM --------------------------------------------------------------
create table if not exists public.device_tokens (
  token      text primary key,
  user_id    uuid not null default auth.uid(),
  platform   text,
  updated_at timestamptz not null default now()
);
create index if not exists device_tokens_user_idx on public.device_tokens(user_id);
alter table public.device_tokens enable row level security;
drop policy if exists device_tokens_own on public.device_tokens;
create policy device_tokens_own on public.device_tokens for all
  using (user_id = auth.uid()) with check (user_id = auth.uid());

-- 3) Preferenze per categoria ----------------------------------------------
create table if not exists public.notification_prefs (
  user_id         uuid primary key default auth.uid(),
  push_enabled    boolean not null default true,   -- master
  friend_requests boolean not null default true,
  shared_trips    boolean not null default true,
  new_documents   boolean not null default true,
  system_messages boolean not null default true,
  updated_at      timestamptz not null default now()
);
alter table public.notification_prefs enable row level security;
drop policy if exists notification_prefs_own on public.notification_prefs;
create policy notification_prefs_own on public.notification_prefs for all
  using (user_id = auth.uid()) with check (user_id = auth.uid());

-- 4) Inbox notifiche --------------------------------------------------------
create table if not exists public.notifications (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null,   -- destinatario
  type       text not null,   -- friend_request|friend_accepted|shared_trip|new_document|system
  title      text not null,
  body       text,
  data       jsonb not null default '{}'::jsonb,  -- es. { trip_id, actor_id, route }
  read_at    timestamptz,
  created_at timestamptz not null default now()
);
create index if not exists notifications_user_created_idx
  on public.notifications(user_id, created_at desc);
alter table public.notifications enable row level security;
-- L'utente vede/segna-letta/cancella solo le proprie. L'inserimento avviene da
-- funzioni security definer (trigger) o dall'admin.
drop policy if exists notifications_select_own on public.notifications;
drop policy if exists notifications_update_own on public.notifications;
drop policy if exists notifications_delete_own on public.notifications;
drop policy if exists notifications_admin_insert on public.notifications;
create policy notifications_select_own on public.notifications for select
  using (user_id = auth.uid());
create policy notifications_update_own on public.notifications for update
  using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy notifications_delete_own on public.notifications for delete
  using (user_id = auth.uid());
create policy notifications_admin_insert on public.notifications for insert
  with check (exists(select 1 from profiles p
                     where p.id = auth.uid() and p.is_admin));

do $$ begin
  begin
    alter publication supabase_realtime add table public.notifications;
  exception when duplicate_object then null;
  end;
end $$;
-- Serve perche' Realtime consegni gli eventi DELETE rispettando la RLS: senza
-- REPLICA IDENTITY FULL il DELETE invia solo la PK (niente user_id da validare)
-- e il client non riceve l'evento, quindi una notifica eliminata resta a schermo
-- finche' non si ricarica.
alter table public.notifications replica identity full;

-- 5) Helper: inserisce una notifica (bypassa RLS) ---------------------------
create or replace function public.push_notification(
  p_user uuid, p_type text, p_title text, p_body text,
  p_data jsonb default '{}'::jsonb
) returns void language plpgsql security definer set search_path = public as $$
begin
  if p_user is null then return; end if;
  insert into notifications(user_id, type, title, body, data)
  values (p_user, p_type, p_title, p_body, coalesce(p_data, '{}'::jsonb));
end;
$$;

-- 6) Amicizia: nuova richiesta + accettazione -------------------------------
create or replace function public.notify_friend_request() returns trigger
language plpgsql security definer set search_path = public as $$
declare rname text;
begin
  if new.status = 'pending' then
    select display_name into rname from profiles where id = new.requester_id;
    perform push_notification(
      new.addressee_id, 'friend_request',
      'Nuova richiesta di amicizia',
      coalesce(rname, 'Qualcuno') || ' vuole essere tuo amico',
      jsonb_build_object('actor_id', new.requester_id, 'route', '/friends'));
  end if;
  return new;
end;
$$;
drop trigger if exists trg_notify_friend_request on public.friendships;
create trigger trg_notify_friend_request after insert on public.friendships
  for each row execute function notify_friend_request();

create or replace function public.notify_friend_accepted() returns trigger
language plpgsql security definer set search_path = public as $$
declare aname text;
begin
  if new.status = 'accepted' and old.status is distinct from 'accepted' then
    select display_name into aname from profiles where id = new.addressee_id;
    perform push_notification(
      new.requester_id, 'friend_accepted',
      'Richiesta accettata',
      coalesce(aname, 'Il tuo contatto') || ' ha accettato la richiesta',
      jsonb_build_object('actor_id', new.addressee_id, 'route', '/friends'));
  end if;
  return new;
end;
$$;
drop trigger if exists trg_notify_friend_accepted on public.friendships;
create trigger trg_notify_friend_accepted after update on public.friendships
  for each row execute function notify_friend_accepted();

-- 7) Viaggio condiviso: nuovo membro (non owner) con user_id ----------------
create or replace function public.notify_shared_trip() returns trigger
language plpgsql security definer set search_path = public as $$
declare tname text; owner uuid;
begin
  if new.user_id is not null and coalesce(new.role, '') <> 'owner'
     and (tg_op = 'INSERT' or new.user_id is distinct from old.user_id) then
    select name, owner_id into tname, owner from trips where id = new.trip_id;
    if new.user_id <> owner then
      perform push_notification(
        new.user_id, 'shared_trip',
        'Sei stato aggiunto a un viaggio',
        coalesce(tname, 'Un viaggio') || ' è stato condiviso con te',
        jsonb_build_object('trip_id', new.trip_id,
                           'route', '/trip/' || new.trip_id));
    end if;
  end if;
  return new;
end;
$$;
drop trigger if exists trg_notify_shared_trip_ins on public.trip_members;
drop trigger if exists trg_notify_shared_trip_upd on public.trip_members;
create trigger trg_notify_shared_trip_ins after insert on public.trip_members
  for each row execute function notify_shared_trip();
create trigger trg_notify_shared_trip_upd after update on public.trip_members
  for each row execute function notify_shared_trip();

-- 8) Nuovo documento in bacheca → tutti i membri tranne chi l'ha caricato ----
create or replace function public.notify_new_document() returns trigger
language plpgsql security definer set search_path = public as $$
declare tname text; owner uuid; uploader uuid; m record;
begin
  uploader := coalesce(new.uploaded_by,
                       '00000000-0000-0000-0000-000000000000'::uuid);
  select name, owner_id into tname, owner from trips where id = new.trip_id;
  if owner is not null and owner <> uploader then
    perform push_notification(owner, 'new_document', 'Nuovo documento in bacheca',
      coalesce(new.name, 'Un file') || ' aggiunto a ' || coalesce(tname, 'un viaggio'),
      jsonb_build_object('trip_id', new.trip_id,
                         'route', '/trip/' || new.trip_id || '/files'));
  end if;
  for m in select user_id from trip_members
           where trip_id = new.trip_id and user_id is not null
             and status = 'active' and user_id <> uploader
             and user_id is distinct from owner loop
    perform push_notification(m.user_id, 'new_document', 'Nuovo documento in bacheca',
      coalesce(new.name, 'Un file') || ' aggiunto a ' || coalesce(tname, 'un viaggio'),
      jsonb_build_object('trip_id', new.trip_id,
                         'route', '/trip/' || new.trip_id || '/files'));
  end loop;
  return new;
end;
$$;
drop trigger if exists trg_notify_new_document on public.trip_files;
create trigger trg_notify_new_document after insert on public.trip_files
  for each row execute function notify_new_document();

-- 9) Messaggi di sistema (admin) -------------------------------------------
-- L'admin invia un messaggio a un utente (p_target) o a tutti (p_target null).
-- Ogni riga inserita fa partire il push via webhook su notifications.
create or replace function public.send_system_message(
  p_title text, p_body text, p_target uuid default null
) returns integer language plpgsql security definer set search_path = public as $$
declare n integer := 0;
begin
  if not exists(select 1 from profiles where id = auth.uid() and is_admin) then
    raise exception 'Non autorizzato: serve un account admin.';
  end if;
  if p_target is not null then
    insert into notifications(user_id, type, title, body)
    values (p_target, 'system', p_title, p_body);
    n := 1;
  else
    insert into notifications(user_id, type, title, body)
    select id, 'system', p_title, p_body from profiles;
    get diagnostics n = row_count;
  end if;
  return n;
end;
$$;
