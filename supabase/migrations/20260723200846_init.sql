-- Muhasebeci-Mükellef Belge Takip: initial schema, RLS, storage policies
create extension if not exists pgcrypto;

-- ==================== profiles ====================
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  role text not null check (role in ('accountant', 'client')),
  full_name text not null,
  accountant_id uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

create policy profiles_select on public.profiles
  for select using (id = auth.uid() or accountant_id = auth.uid());

create policy profiles_update_own on public.profiles
  for update using (id = auth.uid()) with check (id = auth.uid());

-- Prevents a user from escalating their own role or re-parenting themselves
-- to a different accountant via the update policy above.
create or replace function public.profiles_lock_sensitive_cols()
returns trigger language plpgsql as $$
begin
  if new.role is distinct from old.role or new.accountant_id is distinct from old.accountant_id then
    if auth.role() <> 'service_role' then
      raise exception 'role/accountant_id cannot be changed by the user';
    end if;
  end if;
  return new;
end;
$$;

create trigger trg_profiles_lock_sensitive
  before update on public.profiles
  for each row execute function public.profiles_lock_sensitive_cols();

-- security definer: lets RLS policies check the caller's role without
-- recursively hitting the profiles RLS policy being evaluated.
create or replace function public.current_role()
returns text language sql stable security definer as $$
  select role from public.profiles where id = auth.uid();
$$;

-- ==================== invites ====================
create table public.invites (
  id uuid primary key default gen_random_uuid(),
  accountant_id uuid not null references public.profiles(id) on delete cascade,
  code text not null unique,
  client_name text not null,
  used_at timestamptz,
  created_at timestamptz not null default now()
);

alter table public.invites enable row level security;

create policy invites_select_own on public.invites
  for select using (accountant_id = auth.uid());

create policy invites_insert_own on public.invites
  for insert with check (accountant_id = auth.uid() and public.current_role() = 'accountant');

create policy invites_delete_unused on public.invites
  for delete using (accountant_id = auth.uid() and used_at is null);

-- ==================== signup trigger ====================
-- Creates the profile row on auth.users insert. For clients, redeems the
-- invite code passed in user metadata and links them to their accountant.
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer as $$
declare
  v_role text := coalesce(new.raw_user_meta_data->>'role', 'client');
  v_full_name text := coalesce(new.raw_user_meta_data->>'full_name', '');
  v_invite_code text := new.raw_user_meta_data->>'invite_code';
  v_accountant_id uuid;
begin
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

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ==================== device_tokens ====================
create table public.device_tokens (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  token text not null,
  platform text not null check (platform in ('android', 'ios')),
  updated_at timestamptz not null default now(),
  unique (user_id, token)
);

alter table public.device_tokens enable row level security;

create policy device_tokens_owner on public.device_tokens
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

create index idx_device_tokens_user on public.device_tokens(user_id);

-- ==================== documents ====================
create table public.documents (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  accountant_id uuid not null references public.profiles(id) on delete cascade,
  client_id uuid not null references public.profiles(id) on delete cascade,
  category text not null check (category in ('payment', 'info', 'unclassified')),
  doc_type text not null check (doc_type in
    ('kdv', 'muhtasar', 'kdv2', 'gecici_vergi', 'damga', 'sgk_prim', 'ise_giris', 'isten_cikis', 'other')),
  period text,
  amount numeric(14, 2),
  due_date date,
  fis_no text,
  person_name text,
  raw_text text,
  storage_path text not null,
  status text not null default 'pending' check (status in ('pending', 'paid', 'no_payment', 'info')),
  paid_at timestamptz,
  seen_at timestamptz,
  unique (client_id, fis_no)
);

alter table public.documents enable row level security;

create index idx_documents_client on public.documents(client_id, status, due_date);
create index idx_documents_accountant on public.documents(accountant_id, created_at desc);

create policy documents_select on public.documents
  for select using (client_id = auth.uid() or accountant_id = auth.uid());

create policy documents_insert_accountant on public.documents
  for insert with check (
    accountant_id = auth.uid()
    and public.current_role() = 'accountant'
    and exists (
      select 1 from public.profiles c
      where c.id = client_id and c.accountant_id = auth.uid()
    )
  );

-- Defense-in-depth column-scoped updates; app code should prefer the
-- narrower mark_document_paid/mark_document_seen RPCs below over raw updates.
create policy documents_update_client on public.documents
  for update using (client_id = auth.uid()) with check (client_id = auth.uid());

create policy documents_update_accountant on public.documents
  for update using (accountant_id = auth.uid()) with check (accountant_id = auth.uid());

create or replace function public.mark_document_paid(p_document_id uuid)
returns void language plpgsql security definer as $$
begin
  update public.documents
  set status = 'paid', paid_at = now()
  where id = p_document_id and client_id = auth.uid() and category = 'payment';
end;
$$;

create or replace function public.mark_document_seen(p_document_id uuid)
returns void language plpgsql security definer as $$
begin
  update public.documents
  set seen_at = coalesce(seen_at, now())
  where id = p_document_id and client_id = auth.uid();
end;
$$;

-- ==================== storage ====================
insert into storage.buckets (id, name, public)
values ('documents', 'documents', false)
on conflict (id) do nothing;

-- Path convention: documents/{accountant_id}/{client_id}/{document_id}.pdf
create policy storage_documents_select on storage.objects
  for select using (
    bucket_id = 'documents' and (
      (storage.foldername(name))[1] = auth.uid()::text or
      (storage.foldername(name))[2] = auth.uid()::text
    )
  );

create policy storage_documents_insert on storage.objects
  for insert with check (
    bucket_id = 'documents' and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy storage_documents_delete on storage.objects
  for delete using (
    bucket_id = 'documents' and (storage.foldername(name))[1] = auth.uid()::text
  );
