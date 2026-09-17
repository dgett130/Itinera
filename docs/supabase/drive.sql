-- Itinera — Supabase: link Drive per viaggio (schema v7)
-- Migrazione INCREMENTALE e IDEMPOTENTE. Da eseguire nel SQL Editor.
--
-- Aggiunge una sola colonna a `trips`: il link a una cartella Drive condivisa
-- per le foto del viaggio (inserito a mano o creato dall'app se l'account
-- Google e' collegato). Le RLS di `trips` coprono gia' owner e membri: nessuna
-- policy nuova. Il valore viaggia col normale sync (mapper: drive_url).

alter table public.trips
  add column if not exists drive_url text;
