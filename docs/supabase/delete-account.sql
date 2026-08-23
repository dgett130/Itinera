-- Itinera — cancellazione account (diritto all'oblio).
-- Il client non può eliminare il proprio utente auth con la anon key: lo fa
-- questa funzione SECURITY DEFINER, che rimuove TUTTI i dati dell'utente e poi
-- la riga in auth.users (logout permanente). Idempotente. Esegui nel SQL Editor.

create or replace function public.delete_account()
returns void
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  uid uuid := auth.uid();
begin
  if uid is null then
    raise exception 'Non autenticato';
  end if;

  -- 1) Figli dei viaggi di PROPRIETA' dell'utente
  delete from cost_splits cs using cost_items ci
    where cs.cost_item_id = ci.id
      and ci.trip_id in (select id from trips where owner_id = uid);
  delete from activities        where trip_id in (select id from trips where owner_id = uid);
  delete from locations         where trip_id in (select id from trips where owner_id = uid);
  delete from itinerary_days    where trip_id in (select id from trips where owner_id = uid);
  delete from cost_items        where trip_id in (select id from trips where owner_id = uid);
  delete from transport_segments where trip_id in (select id from trips where owner_id = uid);
  delete from packing_items     where trip_id in (select id from trips where owner_id = uid);
  delete from bags              where trip_id in (select id from trips where owner_id = uid);
  delete from travelers         where trip_id in (select id from trips where owner_id = uid);
  delete from trip_members      where trip_id in (select id from trips where owner_id = uid);
  delete from trips             where owner_id = uid;

  -- 2) Appartenenze ad altri viaggi + amicizie + profilo
  delete from trip_members where user_id = uid;
  delete from friendships  where requester_id = uid or addressee_id = uid;
  delete from profiles     where id = uid;

  -- 3) Utente di autenticazione (accesso rimosso definitivamente)
  delete from auth.users where id = uid;
end;
$$;

grant execute on function public.delete_account() to authenticated;
