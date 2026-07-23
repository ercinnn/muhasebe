-- Calls the on-document-insert Edge Function via pg_net whenever a new
-- documents row is inserted, so the client's mobile devices get an FCM
-- push. Kept as a SQL-defined trigger (not a Studio-configured Database
-- Webhook) so it's reproducible across environments via migrations.
--
-- Requires two secrets in Supabase Vault before this actually fires
-- anything (silently no-ops until then — see README below):
--   select vault.create_secret('https://<project-ref>.functions.supabase.co/on-document-insert', 'edge_function_url');
--   select vault.create_secret('<a random shared secret>', 'webhook_secret');
-- The same webhook_secret value must be set as the Edge Function's
-- WEBHOOK_SECRET secret (`supabase secrets set WEBHOOK_SECRET=...`).

create extension if not exists pg_net with schema extensions;

create or replace function public.notify_document_insert()
returns trigger language plpgsql security definer as $$
declare
  v_url text;
  v_secret text;
begin
  select decrypted_secret into v_url
  from vault.decrypted_secrets where name = 'edge_function_url';

  select decrypted_secret into v_secret
  from vault.decrypted_secrets where name = 'webhook_secret';

  if v_url is null then
    -- Secrets not configured yet in this environment — skip silently
    -- rather than failing the insert.
    return new;
  end if;

  perform net.http_post(
    url := v_url,
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'x-webhook-secret', coalesce(v_secret, '')
    ),
    -- raw_text may contain TC kimlik no — never forwarded.
    body := jsonb_build_object('record', to_jsonb(new) - 'raw_text')
  );

  return new;
end;
$$;

create trigger trg_documents_insert_notify
  after insert on public.documents
  for each row execute function public.notify_document_insert();
