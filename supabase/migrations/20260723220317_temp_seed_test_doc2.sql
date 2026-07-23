-- Ad-hoc test data inserted while manually verifying Faz 5's realtime
-- mark-paid flow. Its effect was removed by cleanup_seed_test_docs.
insert into public.documents (
  accountant_id, client_id, category, doc_type, period, amount, due_date,
  fis_no, person_name, storage_path, status
)
select
  acc.id, cli.id, 'payment', 'kdv', '06/2026-06/2026', 1500.00, current_date,
  'DEMO-SEED-0002', cli.full_name, 'seed/demo-kdv.pdf', 'pending'
from public.profiles acc
join public.profiles cli on cli.accountant_id = acc.id and cli.full_name = 'Realtime Test AS'
join auth.users u on u.id = acc.id and u.email = 'muhasebeci2.demo@example.com'
where acc.role = 'accountant'
on conflict (client_id, fis_no) do nothing;
