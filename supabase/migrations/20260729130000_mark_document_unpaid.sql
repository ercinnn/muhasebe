-- Symmetric counterpart to mark_document_paid: lets a client revert a paid
-- payment document back to pending (used by the "Ödenenler" screen's
-- "Ödenmedi" action). Guarded to only affect rows the client already
-- marked paid, mirroring mark_document_paid's own guards.
create or replace function public.mark_document_unpaid(p_document_id uuid)
returns void language plpgsql security definer as $$
begin
  update public.documents
  set status = 'pending', paid_at = null
  where id = p_document_id
    and client_id = auth.uid()
    and category = 'payment'
    and status = 'paid';
end;
$$;
