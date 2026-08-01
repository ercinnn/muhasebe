-- Security-review follow-up for the account freeze/delete and client
-- contact info features added in the two preceding migrations.

-- 1) client_contact_info_update was missing the same client-ownership
-- check the insert policy already has. Since client_id is the primary key
-- and wasn't excluded from UPDATE, an accountant could repoint their own
-- row's client_id at a client that isn't theirs (accountant_id on the row
-- stays their own, so `using`/`with check` on the old policy both still
-- passed).
drop policy client_contact_info_update on public.client_contact_info;
create policy client_contact_info_update on public.client_contact_info
  for update using (accountant_id = auth.uid()) with check (
    accountant_id = auth.uid()
    and exists (
      select 1 from public.profiles p
      where p.id = client_id and p.accountant_id = auth.uid()
    )
  );

-- 2) profiles_lock_sensitive_cols only protected role/accountant_id.
-- frozen_at/deleted_at are meant to change *only* via
-- freeze_own_account/unfreeze_own_account/delete_own_account — otherwise
-- profiles_update_own (id = auth.uid(), no column restriction) lets a user
-- silently self-revert a "permanent" deletion or a freeze with a raw
-- PostgREST PATCH, bypassing those RPCs entirely. The three RPCs flip a
-- transaction-local GUC so the trigger can tell an RPC-driven change from
-- a raw client update without also having to treat every authenticated
-- call as privileged (unlike role/accountant_id, these columns *do* have a
-- legitimate user-facing mutation path, so `auth.role() <> 'service_role'`
-- isn't the right gate here).
create or replace function public.profiles_lock_sensitive_cols()
returns trigger language plpgsql as $$
begin
  if new.role is distinct from old.role or new.accountant_id is distinct from old.accountant_id then
    if auth.role() <> 'service_role' then
      raise exception 'role/accountant_id cannot be changed by the user';
    end if;
  end if;
  if (new.frozen_at is distinct from old.frozen_at or new.deleted_at is distinct from old.deleted_at)
     and coalesce(current_setting('app.allow_account_state_change', true), '') <> 'on' then
    raise exception 'frozen_at/deleted_at can only be changed via freeze_own_account/unfreeze_own_account/delete_own_account';
  end if;
  return new;
end;
$$;

create or replace function public.freeze_own_account()
returns void language plpgsql security definer as $$
begin
  perform set_config('app.allow_account_state_change', 'on', true);
  update public.profiles
  set frozen_at = now()
  where id = auth.uid() and deleted_at is null;
end;
$$;

create or replace function public.unfreeze_own_account()
returns void language plpgsql security definer as $$
begin
  perform set_config('app.allow_account_state_change', 'on', true);
  update public.profiles
  set frozen_at = null
  where id = auth.uid() and deleted_at is null;
end;
$$;

create or replace function public.delete_own_account()
returns void language plpgsql security definer as $$
begin
  perform set_config('app.allow_account_state_change', 'on', true);
  update public.profiles
  set deleted_at = now(), frozen_at = null, full_name = 'Silinmiş Kullanıcı'
  where id = auth.uid();

  delete from public.device_tokens where user_id = auth.uid();
end;
$$;
