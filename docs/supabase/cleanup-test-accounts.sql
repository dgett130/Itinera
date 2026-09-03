-- Itinera — pulizia account di test (una tantum). Esegui nel SQL Editor.
-- Cancella dati + riga auth.users per gli account elencati. NON tocca
-- dgettatelli@gmail.com (account reale). Modifica la lista se serve.

do $$
declare
  uid uuid;
  emails text[] := array[
    'test1@itinera.app',
    'test2@itinera.app',
    'test5@itinera.app',
    'dgettatelli+itinera@gmail.com'
  ];
begin
  for uid in select id from auth.users where email = any(emails) loop
    delete from cost_splits cs using cost_items ci
      where cs.cost_item_id = ci.id and ci.trip_id in (select id from trips where owner_id = uid);
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
    delete from trip_members where user_id = uid;
    delete from friendships  where requester_id = uid or addressee_id = uid;
    delete from profiles     where id = uid;
    delete from auth.users   where id = uid;
  end loop;
end $$;
