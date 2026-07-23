-- Ad-hoc test data for manually verifying Faz 7's live badge/banner
-- update. Its effect was removed by cleanup_seed_faz7_test.
insert into public.documents (
  accountant_id, client_id, category, doc_type, period, amount, due_date,
  fis_no, person_name, storage_path, status
)
select
  acc.id, cli.id, 'payment', 'muhtasar', '07/2026-07/2026', 850.00, current_date + 3,
  'DEMO-SEED-0003', cli.full_name, 'seed/demo-muhtasar.pdf', 'pending'
from public.profiles acc
join public.profiles cli on cli.accountant_id = acc.id and cli.full_name = 'Realtime Test AS'
join auth.users u on u.id = acc.id and u.email = 'muhasebeci2.demo@example.com'
where acc.role = 'accountant'
on conflict (client_id, fis_no) do nothing;
