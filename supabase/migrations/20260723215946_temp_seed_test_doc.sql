-- Ad-hoc test data inserted while manually verifying Faz 5's realtime
-- mark-paid flow (no-op: target account/client didn't match, 0 rows
-- affected — see the follow-up temp_seed_test_doc2 migration). Its effect
-- was removed by cleanup_seed_test_docs.
insert into public.documents (
  accountant_id, client_id, category, doc_type, period, amount, due_date,
  fis_no, person_name, storage_path, status
)
select
  acc.id, cli.id, 'payment', 'kdv', '06/2026-06/2026', 1500.00, current_date,
  'DEMO-SEED-0001', cli.full_name, 'seed/demo-kdv.pdf', 'pending'
from public.profiles acc
join public.profiles cli on cli.accountant_id = acc.id and cli.full_name = 'Test Mukellef'
join auth.users u on u.id = acc.id and u.email = 'muhasebeci.demo@example.com'
where acc.role = 'accountant'
on conflict (client_id, fis_no) do nothing;
