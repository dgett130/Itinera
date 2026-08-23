-- Itinera — Supabase: rubrica amici (per-utente)
-- Incolla ed esegui nel SQL Editor. Idempotente.

create table if not exists public.friends (
  id           uuid primary key default gen_random_uuid(),
  owner_id     uuid not null default auth.uid(),
  friend_email text not null,
  friend_name  text,
  created_at   timestamptz not null default now()
);

-- Un amico non duplicato per lo stesso proprietario.
create unique index if not exists friends_owner_email_uidx
  on public.friends (owner_id, lower(friend_email));

alter table public.friends enable row level security;

drop policy if exists "friends_owner_all" on public.friends;
create policy "friends_owner_all" on public.friends
  for all
  using (owner_id = auth.uid())
  with check (owner_id = auth.uid());
