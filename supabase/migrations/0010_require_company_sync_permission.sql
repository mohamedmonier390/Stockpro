-- Require explicit company-sync permission before exposing the shared operational snapshot.
-- The payload contains company-wide sites, meals, stock, recipes, and expenses.
-- This migration is additive and safe to re-run; it does not change existing data.

drop policy if exists company_snapshot_member_read on public.company_data_snapshots;
drop policy if exists company_snapshot_sync_permission_read on public.company_data_snapshots;

create policy company_snapshot_sync_permission_read
  on public.company_data_snapshots
  for select
  to authenticated
  using (
    public.is_company_member(company_id)
    and public.has_company_permission(company_id, 'المزامنة')
  );

create or replace function public.get_company_snapshot(target_company uuid)
returns table(payload jsonb, revision bigint, updated_at timestamptz, updated_by uuid)
language plpgsql
security invoker
set search_path = public
as $$
begin
  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;

  if not public.is_company_member(target_company) then
    raise exception 'Company membership required';
  end if;

  if not public.has_company_permission(target_company, 'المزامنة') then
    raise exception 'Sync permission required';
  end if;

  return query
    select s.payload, s.revision, s.updated_at, s.updated_by
    from public.company_data_snapshots s
    where s.company_id = target_company;
end;
$$;

revoke all on function public.get_company_snapshot(uuid) from public, anon;
grant execute on function public.get_company_snapshot(uuid) to authenticated;
