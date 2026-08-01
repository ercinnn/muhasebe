-- Self-service account freeze (temporary, reversible login block) and
-- delete (soft-delete/anonymize — see CLAUDE.md: documents.accountant_id /
-- client_id are ON DELETE CASCADE from profiles, so hard-deleting
-- auth.users here would wipe the *other* party's document history too.
-- Real auth.users removal is a separate manual admin step, done later once
-- retention period has passed).
alter table public.profiles add column frozen_at timestamptz;
alter table public.profiles add column deleted_at timestamptz;

create or replace function public.freeze_own_account()
returns void language plpgsql security definer as $$
begin
  update public.profiles
  set frozen_at = now()
  where id = auth.uid() and deleted_at is null;
end;
$$;

create or replace function public.unfreeze_own_account()
returns void language plpgsql security definer as $$
begin
  update public.profiles
  set frozen_at = null
  where id = auth.uid() and deleted_at is null;
end;
$$;

-- Anonymizes the profile and clears device push tokens; auth.users itself
-- is left intact (see comment above) so `resolveRedirect` can keep gating
-- on `deleted_at` even from a second still-signed-in device/session.
create or replace function public.delete_own_account()
returns void language plpgsql security definer as $$
begin
  update public.profiles
  set deleted_at = now(), frozen_at = null, full_name = 'Silinmiş Kullanıcı'
  where id = auth.uid();

  delete from public.device_tokens where user_id = auth.uid();
end;
$$;
