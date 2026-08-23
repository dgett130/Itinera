-- Itinera — Supabase: AMICI tra utenti reali (richiesta + accettazione) + ricerca
-- Sostituisce la vecchia rubrica 'friends' (email libere). Idempotente.
-- Le funzioni sono SECURITY DEFINER: leggono profiles + auth.users.email in modo
-- controllato (ricerca amici) senza esporre l'intera tabella.

drop table if exists public.friends cascade;

-- Amicizia fra due utenti (una riga per coppia).
create table if not exists public.friendships (
  id            uuid primary key default gen_random_uuid(),
  requester_id  uuid not null,
  addressee_id  uuid not null,
  status        text not null default 'pending',   -- 'pending' | 'accepted'
  created_at    timestamptz not null default now(),
  unique (requester_id, addressee_id),
  check (requester_id <> addressee_id)
);
alter table public.friendships enable row level security;

drop policy if exists friendships_rw on public.friendships;
create policy friendships_rw on public.friendships for all
  using (requester_id = auth.uid() or addressee_id = auth.uid())
  with check (requester_id = auth.uid() or addressee_id = auth.uid());

-- Ricerca utenti per email esatta o nome (min 3 caratteri per non "sfogliare"
-- l'anagrafica). Ritorna la relazione con l'utente corrente per scegliere l'azione.
create or replace function public.search_users(q text)
returns table(id uuid, display_name text, email text, relation text)
language sql security definer stable set search_path = public, auth as $$
  select p.id,
         p.display_name,
         u.email,
         case
           when f.status = 'accepted' then 'friend'
           when f.status = 'pending' and f.requester_id = auth.uid() then 'pending_out'
           when f.status = 'pending' then 'pending_in'
           else 'none'
         end as relation
  from profiles p
  join auth.users u on u.id = p.id
  left join friendships f
    on (f.requester_id = auth.uid() and f.addressee_id = p.id)
    or (f.addressee_id = auth.uid() and f.requester_id = p.id)
  where p.id <> auth.uid()
    and length(trim(q)) >= 3
    and (lower(u.email) = lower(trim(q))
         or p.display_name ilike '%' || trim(q) || '%')
  order by (lower(u.email) = lower(trim(q))) desc, p.display_name
  limit 12;
$$;
grant execute on function public.search_users(text) to authenticated;

-- Elenco amici accettati (con nome/email).
create or replace function public.list_friends()
returns table(friendship_id uuid, user_id uuid, display_name text, email text)
language sql security definer stable set search_path = public, auth as $$
  select f.id,
         p.id,
         p.display_name,
         u.email
  from friendships f
  join profiles p on p.id = case when f.requester_id = auth.uid()
                                 then f.addressee_id else f.requester_id end
  join auth.users u on u.id = p.id
  where f.status = 'accepted'
    and (f.requester_id = auth.uid() or f.addressee_id = auth.uid())
  order by p.display_name;
$$;
grant execute on function public.list_friends() to authenticated;

-- Richieste di amicizia RICEVUTE ancora in sospeso.
create or replace function public.list_friend_requests()
returns table(friendship_id uuid, user_id uuid, display_name text, email text)
language sql security definer stable set search_path = public, auth as $$
  select f.id, p.id, p.display_name, u.email
  from friendships f
  join profiles p on p.id = f.requester_id
  join auth.users u on u.id = p.id
  where f.status = 'pending' and f.addressee_id = auth.uid()
  order by f.created_at desc;
$$;
grant execute on function public.list_friend_requests() to authenticated;

-- Invia una richiesta (se esiste gia' quella inversa, la accetta).
create or replace function public.send_friend_request(target uuid)
returns void language plpgsql security definer set search_path = public as $$
begin
  if target is null or target = auth.uid() then return; end if;
  update friendships set status = 'accepted'
   where requester_id = target and addressee_id = auth.uid() and status = 'pending';
  if found then return; end if;
  insert into friendships (requester_id, addressee_id, status)
  values (auth.uid(), target, 'pending')
  on conflict (requester_id, addressee_id) do nothing;
end; $$;
grant execute on function public.send_friend_request(uuid) to authenticated;

-- Rispondi a una richiesta ricevuta (accept=true accetta, false rifiuta).
create or replace function public.respond_friend_request(req uuid, accept boolean)
returns void language plpgsql security definer set search_path = public as $$
begin
  if accept then
    update friendships set status = 'accepted'
     where id = req and addressee_id = auth.uid();
  else
    delete from friendships where id = req and addressee_id = auth.uid();
  end if;
end; $$;
grant execute on function public.respond_friend_request(uuid, boolean) to authenticated;

-- Rimuovi un'amicizia (o annulla una richiesta inviata).
create or replace function public.remove_friend(fid uuid)
returns void language plpgsql security definer set search_path = public as $$
begin
  delete from friendships
   where id = fid and (requester_id = auth.uid() or addressee_id = auth.uid());
end; $$;
grant execute on function public.remove_friend(uuid) to authenticated;
