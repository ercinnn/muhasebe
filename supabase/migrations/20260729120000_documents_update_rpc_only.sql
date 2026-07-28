-- Close a direct-UPDATE gap on public.documents.
--
-- documents_update_client / documents_update_accountant only scoped
-- updates by row ownership (client_id/accountant_id = auth.uid()) with no
-- column restriction. A client (or accountant) with a valid JWT could call
-- PostgREST directly — bypassing the app UI entirely — and rewrite any
-- column on their own row (amount, due_date, status, category, ...),
-- sidestepping mark_document_paid's category/status checks.
--
-- The Flutter app has never issued a raw .update() against documents: it
-- only inserts (accountant upload flow) and calls the two security-definer
-- RPCs below, which are already the sole intended write path per the
-- "Defense-in-depth" comment on the original policies. Dropping these
-- policies removes the unused bypass without changing any app behavior.
drop policy if exists documents_update_client on public.documents;
drop policy if exists documents_update_accountant on public.documents;
