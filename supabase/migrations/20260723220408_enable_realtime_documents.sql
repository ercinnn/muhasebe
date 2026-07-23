-- Required for supabase_flutter's .stream() (postgres_changes realtime) to
-- work on this table — without it, subscribing throws RealtimeSubscribeException.
-- Needed by the client's Ödemeler/Takvim screens and the accountant's
-- Gönderilenler screen so "ödendi" updates propagate live on both sides.
alter publication supabase_realtime add table public.documents;
