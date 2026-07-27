-- Removes the ad-hoc test documents inserted while profiling the
-- glassmorphism restyle's scroll performance and testing the mark-paid
-- fix on the real device (see temp_seed_perf_test /
-- temp_seed_more_pending).
delete from public.documents where fis_no like 'PERFTEST%';
