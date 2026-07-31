-- Google OAuth sign-in/sign-up support.
--
-- `handle_new_user` used to run unconditionally on every `auth.users` insert
-- and `raise exception` when a client's invite code was missing/invalid.
-- That's correct for our own signUp() calls (which always pass `role` in
-- `data`), but Google's OAuth callback also inserts into `auth.users` with
-- provider-supplied metadata (name/email/avatar, no `role` key) — the old
-- trigger would abort that insert and the user could never even reach the
-- app to enter an invite code. Now it only provisions a profile when our
-- app explicitly supplied a `role`; OAuth signups land with a session but no
-- profiles row, and the app routes them to a completion screen that calls
-- complete_oauth_signup() below.
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer as $$
declare
  v_role text := new.raw_user_meta_data->>'role';
  v_full_name text := coalesce(new.raw_user_meta_data->>'full_name', '');
  v_invite_code text := new.raw_user_meta_data->>'invite_code';
  v_accountant_id uuid;
begin
  if v_role is null then
    return new;
  end if;

  if v_role = 'client' then
    select accountant_id into v_accountant_id
    from public.invites
    where code = v_invite_code and used_at is null
    for update;

    if v_accountant_id is null then
      raise exception 'Geçersiz veya kullanılmış davet kodu';
    end if;

    update public.invites set used_at = now() where code = v_invite_code;
  end if;

  insert into public.profiles (id, role, full_name, accountant_id)
  values (new.id, v_role, v_full_name, v_accountant_id);

  return new;
end;
$$;

-- Called by the app right after a Google sign-in that landed without a
-- profiles row (see handle_new_user above). Mirrors its provisioning logic,
-- but driven by auth.uid() + user-supplied form fields instead of signUp()
-- metadata.
create or replace function public.complete_oauth_signup(
  p_role text,
  p_full_name text,
  p_invite_code text default null
)
returns void language plpgsql security definer as $$
declare
  v_accountant_id uuid;
begin
  if auth.uid() is null then
    raise exception 'Oturum bulunamadı';
  end if;

  if exists (select 1 from public.profiles where id = auth.uid()) then
    raise exception 'Profil zaten oluşturulmuş';
  end if;

  if p_role = 'client' then
    select accountant_id into v_accountant_id
    from public.invites
    where code = p_invite_code and used_at is null
    for update;

    if v_accountant_id is null then
      raise exception 'Geçersiz veya kullanılmış davet kodu';
    end if;

    update public.invites set used_at = now() where code = p_invite_code;
  end if;

  insert into public.profiles (id, role, full_name, accountant_id)
  values (auth.uid(), p_role, p_full_name, v_accountant_id);
end;
$$;
