-- Free-form contact/notes fields an accountant can keep for each of their
-- clients (phone/address/notes) — the app itself never collects these from
-- the client, so this is purely the accountant's own bookkeeping.
create table public.client_contact_info (
  client_id uuid primary key references public.profiles(id) on delete cascade,
  accountant_id uuid not null references public.profiles(id) on delete cascade,
  phone text,
  address text,
  notes text,
  updated_at timestamptz not null default now()
);

alter table public.client_contact_info enable row level security;

create policy client_contact_info_select on public.client_contact_info
  for select using (accountant_id = auth.uid());

create policy client_contact_info_insert on public.client_contact_info
  for insert with check (
    accountant_id = auth.uid()
    and exists (
      select 1 from public.profiles p
      where p.id = client_id and p.accountant_id = auth.uid()
    )
  );

create policy client_contact_info_update on public.client_contact_info
  for update using (accountant_id = auth.uid()) with check (accountant_id = auth.uid());

create policy client_contact_info_delete on public.client_contact_info
  for delete using (accountant_id = auth.uid());
