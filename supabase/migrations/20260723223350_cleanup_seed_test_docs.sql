-- Removes the manual test documents inserted while verifying Faz 5's
-- realtime mark-paid flow (see the two temp_seed_test_doc migrations).
delete from public.documents where fis_no in ('DEMO-SEED-0001', 'DEMO-SEED-0002');
