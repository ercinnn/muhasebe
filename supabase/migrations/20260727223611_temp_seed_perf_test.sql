-- Ad-hoc test data for profiling PaymentsScreen's glassmorphism restyle
-- scroll performance on the physical Samsung A51 (see glass-restyle plan).
-- 19 extra pending payments for the real-device test client, spread across
-- overdue/soon/upcoming due-date urgencies. Its effect is removed by
-- cleanup_seed_perf_test once profiling is done.
insert into public.documents (
  accountant_id, client_id, category, doc_type, period, amount, due_date,
  fis_no, person_name, storage_path, status
)
select
  acc.id,
  cli.id,
  'payment',
  (array['kdv', 'muhtasar', 'kdv2', 'gecici_vergi', 'damga', 'sgk_prim', 'other'])[1 + (offsets.n % 7)],
  to_char(current_date, 'MM/YYYY'),
  (500 + offsets.n * 137.5)::numeric(14, 2),
  current_date + offsets.d,
  'PERFTEST-' || lpad(offsets.n::text, 4, '0'),
  cli.full_name,
  'seed/perftest-demo.pdf',
  'pending'
from public.profiles acc
join public.profiles cli on cli.accountant_id = acc.id and cli.id = '2a15dda2-a1d1-4817-843f-81fc0a406922'
join auth.users u on u.id = acc.id
cross join lateral unnest(
  array[-10, -7, -5, -3, -2, -1, 0, 0, 1, 2, 3, 4, 5, 7, 10, 14, 20, 30, 45]
) with ordinality as offsets(d, n)
where acc.role = 'accountant'
on conflict (client_id, fis_no) do nothing;
