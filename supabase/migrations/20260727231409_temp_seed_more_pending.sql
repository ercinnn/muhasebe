-- A handful of fresh pending payments for the real-device test client —
-- the earlier perf-test batch (PERFTEST-*) all got marked paid while
-- testing the mark-paid button fix. Removed alongside it by
-- cleanup_seed_perf_test.
insert into public.documents (
  accountant_id, client_id, category, doc_type, period, amount, due_date,
  fis_no, person_name, storage_path, status
)
select
  acc.id,
  cli.id,
  'payment',
  (array['kdv', 'muhtasar', 'kdv2', 'gecici_vergi', 'sgk_prim'])[1 + (offsets.n % 5)],
  to_char(current_date, 'MM/YYYY'),
  (750 + offsets.n * 220.0)::numeric(14, 2),
  current_date + offsets.d,
  'PERFTEST2-' || lpad(offsets.n::text, 4, '0'),
  cli.full_name,
  'seed/perftest-demo.pdf',
  'pending'
from public.profiles acc
join public.profiles cli on cli.accountant_id = acc.id and cli.id = '2a15dda2-a1d1-4817-843f-81fc0a406922'
join auth.users u on u.id = acc.id
cross join lateral unnest(
  array[-4, -1, 0, 2, 6]
) with ordinality as offsets(d, n)
where acc.role = 'accountant'
on conflict (client_id, fis_no) do nothing;
