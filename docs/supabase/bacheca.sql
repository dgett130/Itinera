-- Itinera — Supabase: "Bacheca del viaggio" (schema v6)
-- Migrazione INCREMENTALE e IDEMPOTENTE per installazioni gia' esistenti.
-- Da eseguire nel SQL Editor DOPO sync.sql, collaboration.sql ed explore.sql.
--
-- Contiene:
--  1) tabella metadati `trip_files` (i BYTE stanno su Storage, non qui)
--  2) indici per il pull incrementale
--  3) RLS "superset condivisione" (owner diretto OR membro del viaggio)
--  4) realtime
--  5) bucket Storage privato `trip-files` + RLS su storage.objects
--
-- Convenzioni identiche alle altre tabelle: id TEXT = UUID del client, colonne
-- di sync owner_id/updated_at/deleted_at con default (le aggiunge il motore di
-- sync, non il client). Le funzioni helper trip_owner_uid()/is_trip_member()
-- sono definite in collaboration.sql.
--
-- Convenzione del percorso nel bucket: `<tripId>/<fileId>`, cosi' la PRIMA
-- cartella dell'oggetto identifica il viaggio e guida le policy di storage.

-- 1) Tabella metadati -------------------------------------------------------
create table if not exists public.trip_files (
  id           text primary key,
  trip_id      text not null,
  name         text not null,
  storage_path text not null,
  mime_type    text,
  size_bytes   integer,
  uploaded_by  uuid,
  created_at   timestamptz not null default now(),
  owner_id     uuid not null default auth.uid(),
  updated_at   timestamptz not null default now(),
  deleted_at   timestamptz
);

-- 2) Indici -----------------------------------------------------------------
create index if not exists trip_files_owner_updated_idx
  on public.trip_files (owner_id, updated_at);
create index if not exists trip_files_trip_idx
  on public.trip_files (trip_id);

-- 3) RLS: superset condivisione (owner diretto OR membro del viaggio) --------
alter table public.trip_files enable row level security;
drop policy if exists trip_files_owner_all  on public.trip_files;
drop policy if exists trip_files_member_all on public.trip_files;
create policy trip_files_member_all on public.trip_files for all
  using (trip_owner_uid(trip_id) = auth.uid() or is_trip_member(trip_id))
  with check (trip_owner_uid(trip_id) = auth.uid() or is_trip_member(trip_id));

-- 4) Realtime ---------------------------------------------------------------
do $$
begin
  begin
    alter publication supabase_realtime add table public.trip_files;
  exception when duplicate_object then null;
  end;
end $$;

-- 5) Storage: bucket privato + RLS su storage.objects -----------------------
-- Bucket privato (accesso solo via URL firmato). Limite 25 MB per file, in
-- linea con il cap lato client.
insert into storage.buckets (id, name, public, file_size_limit)
values ('trip-files', 'trip-files', false, 26214400)
on conflict (id) do update set file_size_limit = excluded.file_size_limit;

-- Le policy usano la PRIMA cartella del percorso (= trip_id) per decidere
-- l'accesso: solo owner o membri del viaggio possono leggere/scrivere/eliminare.
drop policy if exists trip_files_obj_select on storage.objects;
drop policy if exists trip_files_obj_insert on storage.objects;
drop policy if exists trip_files_obj_update on storage.objects;
drop policy if exists trip_files_obj_delete on storage.objects;

create policy trip_files_obj_select on storage.objects for select
  using (
    bucket_id = 'trip-files'
    and (
      trip_owner_uid((storage.foldername(name))[1]) = auth.uid()
      or is_trip_member((storage.foldername(name))[1])
    )
  );

create policy trip_files_obj_insert on storage.objects for insert
  with check (
    bucket_id = 'trip-files'
    and (
      trip_owner_uid((storage.foldername(name))[1]) = auth.uid()
      or is_trip_member((storage.foldername(name))[1])
    )
  );

create policy trip_files_obj_update on storage.objects for update
  using (
    bucket_id = 'trip-files'
    and (
      trip_owner_uid((storage.foldername(name))[1]) = auth.uid()
      or is_trip_member((storage.foldername(name))[1])
    )
  )
  with check (
    bucket_id = 'trip-files'
    and (
      trip_owner_uid((storage.foldername(name))[1]) = auth.uid()
      or is_trip_member((storage.foldername(name))[1])
    )
  );

create policy trip_files_obj_delete on storage.objects for delete
  using (
    bucket_id = 'trip-files'
    and (
      trip_owner_uid((storage.foldername(name))[1]) = auth.uid()
      or is_trip_member((storage.foldername(name))[1])
    )
  );
