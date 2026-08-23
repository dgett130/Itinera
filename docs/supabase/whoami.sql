-- Itinera — sonda diagnostica ESTESA: oltre a auth.uid() riporta il RUOLO
-- Postgres reale sotto cui gira la richiesta REST. Se current_user = 'anon'
-- (invece di 'authenticated') ecco spiegato il 42501: le policy 'to authenticated'
-- non si applicano e scatta il default-deny.
-- Incolla ed esegui nel SQL Editor. Idempotente.

drop function if exists public.whoami();

create or replace function public.whoami()
returns json language sql stable as $$
  select json_build_object(
    'uid',          auth.uid(),
    'jwt_role',     auth.role(),
    'current_user', current_user,
    'session_user', session_user
  );
$$;

grant execute on function public.whoami() to authenticated, anon;
