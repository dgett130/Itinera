-- Itinera — Supabase Fase 1: account + profilo
-- Incolla ed esegui nel SQL Editor del progetto Supabase.
-- Idempotente: puoi rieseguirlo senza problemi.

-- 1) Tabella profili (1:1 con auth.users) ------------------------------------
create table if not exists public.profiles (
  id          uuid primary key references auth.users (id) on delete cascade,
  display_name text,
  avatar_url   text,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

alter table public.profiles enable row level security;

-- 2) RLS: ognuno vede/gestisce solo il proprio profilo ------------------------
drop policy if exists "profiles_self_select" on public.profiles;
create policy "profiles_self_select" on public.profiles
  for select using (auth.uid() = id);

drop policy if exists "profiles_self_insert" on public.profiles;
create policy "profiles_self_insert" on public.profiles
  for insert with check (auth.uid() = id);

drop policy if exists "profiles_self_update" on public.profiles;
create policy "profiles_self_update" on public.profiles
  for update using (auth.uid() = id) with check (auth.uid() = id);

-- 3) Trigger: crea la riga profilo alla registrazione -------------------------
--    Copia display_name dai metadata; fallback = parte locale dell'email.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, display_name)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'display_name',
             split_part(new.email, '@', 1))
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- 4) (Consigliato per i test) Disattiva la conferma via email:
--    Dashboard → Authentication → Providers → Email → "Confirm email" = OFF.
--    Cosi' dopo la registrazione sei subito loggato. In produzione lasciala ON.
