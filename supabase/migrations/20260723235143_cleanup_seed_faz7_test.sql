-- Removes the manual test document inserted while verifying Faz 7's live
-- badge/banner update (see temp_seed_faz7_test).
delete from public.documents where fis_no = 'DEMO-SEED-0003';
