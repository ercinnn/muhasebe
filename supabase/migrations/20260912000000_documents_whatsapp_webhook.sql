-- Adds a second, fully independent fan-out target to the existing
-- documents-insert trigger: a WhatsApp notification Edge Function
-- (send-whatsapp-document). Kept as a separate net.http_post call, not
-- merged into the FCM push function, so a WhatsApp/Meta outage or
-- misconfiguration can never affect the already-verified FCM push path —
-- each call is independent fire-and-forget pg_net dispatch.
--
-- Requires two additional Vault secrets before this fires anything
-- (silently no-ops until then, same pattern as edge_function_url below):
--   select vault.create_secret('https://<project-ref>.supabase.co/functions/v1/send-whatsapp-document', 'whatsapp_edge_function_url');
--   select vault.create_secret('<a different random shared secret>', 'whatsapp_webhook_secret');
-- The same whatsapp_webhook_secret value must be set as the Edge
-- Function's WHATSAPP_WEBHOOK_SECRET secret (`supabase secrets set
-- WHATSAPP_WEBHOOK_SECRET=...`) — deliberately a different secret name/
-- value than on-document-insert's WEBHOOK_SECRET, so the two functions
-- can't be confused and one leaking doesn't compromise the other.

create or replace function public.notify_document_insert()
returns trigger language plpgsql security definer as $$
declare
  v_url text;
  v_secret text;
  v_wa_url text;
  v_wa_secret text;
begin
  select decrypted_secret into v_url
  from vault.decrypted_secrets where name = 'edge_function_url';

  select decrypted_secret into v_secret
  from vault.decrypted_secrets where name = 'webhook_secret';

  if v_url is not null then
    perform net.http_post(
      url := v_url,
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'x-webhook-secret', coalesce(v_secret, '')
      ),
      -- raw_text may contain TC kimlik no — never forwarded.
      body := jsonb_build_object('record', to_jsonb(new) - 'raw_text')
    );
  end if;

  select decrypted_secret into v_wa_url
  from vault.decrypted_secrets where name = 'whatsapp_edge_function_url';

  select decrypted_secret into v_wa_secret
  from vault.decrypted_secrets where name = 'whatsapp_webhook_secret';

  if v_wa_url is not null then
    perform net.http_post(
      url := v_wa_url,
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'x-webhook-secret', coalesce(v_wa_secret, '')
      ),
      body := jsonb_build_object('record', to_jsonb(new) - 'raw_text')
    );
  end if;

  return new;
end;
$$;

-- Per-client opt-in flag for WhatsApp document notifications, defaulting
-- to false so the feature can be rolled out to individual test clients
-- (accountant flips this manually via SQL/UI) before being enabled
-- broadly. Only meaningful together with a non-null phone — the
-- send-whatsapp-document function checks both and silently skips
-- otherwise. Also acts as a kill switch while İYS (Turkish commercial
-- electronic message consent regime) applicability is still unresolved.
alter table public.client_contact_info
  add column whatsapp_enabled boolean not null default false;
