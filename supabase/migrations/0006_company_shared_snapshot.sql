-- StockPro company-shared snapshot with optimistic concurrency.
-- Personal snapshots remain untouched; shared snapshot is separate.
create table if not exists public.company_data_snapshots (
  company_id uuid primary key references public.companies(id) on delete cascade,
  payload jsonb not null default '{}'::jsonb check (jsonb_typeof(payload) = 'object'),
  revision bigint not null default 1,
  updated_by uuid references auth.users(id),
  updated_at timestamptz not null default now()
);
alter table public.company_data_snapshots enable row level security;
drop policy if exists company_snapshot_member_read on public.company_data_snapshots;
create policy company_snapshot_member_read on public.company_data_snapshots
  for select to authenticated using (public.is_company_member(company_id));
drop policy if exists company_snapshot_member_write on public.company_data_snapshots;
create policy company_snapshot_member_write on public.company_data_snapshots
  for all to authenticated
  using (public.is_company_member(company_id))
  with check (public.is_company_member(company_id));

create or replace function public.get_company_snapshot(target_company uuid)
returns table(payload jsonb, revision bigint, updated_at timestamptz, updated_by uuid)
language plpgsql security invoker set search_path=public
as $$
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  if not public.is_company_member(target_company) then raise exception 'Company membership required'; end if;
  return query select s.payload,s.revision,s.updated_at,s.updated_by
    from public.company_data_snapshots s where s.company_id=target_company;
end;
$$;
revoke all on function public.get_company_snapshot(uuid) from public;
grant execute on function public.get_company_snapshot(uuid) to authenticated;

create or replace function public.save_company_snapshot(target_company uuid, snapshot jsonb, expected_revision bigint)
returns bigint
language plpgsql security invoker set search_path=public
as $$
declare next_revision bigint;
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  if not public.is_company_member(target_company) then raise exception 'Company membership required'; end if;
  if not public.has_company_permission(target_company,'المزامنة') then raise exception 'Sync permission required'; end if;
  if snapshot is null or jsonb_typeof(snapshot) <> 'object' then raise exception 'Snapshot must be a JSON object'; end if;
  if octet_length(snapshot::text) > 1000000 then raise exception 'Snapshot exceeds 1 MB limit'; end if;
  if expected_revision is null or expected_revision < 0 then raise exception 'Invalid expected revision'; end if;

  if expected_revision=0 then
    insert into public.company_data_snapshots(company_id,payload,revision,updated_by,updated_at)
      values(target_company,snapshot,1,auth.uid(),now())
      on conflict(company_id) do nothing
      returning revision into next_revision;
  else
    update public.company_data_snapshots
      set payload=snapshot, revision=revision+1, updated_by=auth.uid(), updated_at=now()
      where company_id=target_company and revision=expected_revision
      returning revision into next_revision;
  end if;
  if next_revision is null then raise exception 'REVISION_CONFLICT: shared data changed on another device. Refresh/download latest before uploading.'; end if;
  return next_revision;
end;
$$;
revoke all on function public.save_company_snapshot(uuid,jsonb,bigint) from public;
grant execute on function public.save_company_snapshot(uuid,jsonb,bigint) to authenticated;
