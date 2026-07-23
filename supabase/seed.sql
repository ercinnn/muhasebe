-- Demo data for local development.
-- Creates one accountant and one open invite code they could hand to a client.
-- Actual auth.users rows must go through Supabase Auth (signup flow), so this
-- seed only pre-populates an invite; profiles are created by the
-- handle_new_user trigger once real accounts sign up through the app.

insert into public.invites (id, accountant_id, code, client_name)
select
  gen_random_uuid(),
  u.id,
  'DEMO1234',
  'Demo Mükellef A.Ş.'
from auth.users u
where u.email = 'muhasebeci@demo.local'
on conflict (code) do nothing;
