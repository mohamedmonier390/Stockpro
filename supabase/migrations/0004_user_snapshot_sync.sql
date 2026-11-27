-- StockPro cloud sync phase 1: per-user snapshots across devices.
-- Apply after 0001-0003. This does NOT share a user's local data with other
-- company members; shared team sync will use normalized business tables later.
create table if not exists public.user_data_snapshots (
  company_id uuid not null references public.companies(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  payload jsonb not null default '{}'::jsonb,
  revision bigint not null default 1,
  updated_at timestamptz not null default now(),
  primary key (company_id, user_id),
  constraint snapshot_payload_object check (jsonb_typeof(payload) = 'object')
);

alter table public.user_data_snapshots enable row level security;

drop policy if exists snapshot_owner_access on public.user_data_snapshots;
create policy snapshot_owner_access on public.user_data_snapshots
for all using (
  user_id = auth.uid() and public.is_company_member(company_id)
)
with check (
  user_id = auth.uid() and public.is_company_member(company_id)
);

create index if not exists user_data_snapshots_updated_idx
  on public.user_data_snapshots(company_id, updated_at desc);

-- Atomic save. Caller may save only their own snapshot and must be a company member.
create or replace function public.save_user_snapshot(target_company uuid, snapshot jsonb)
returns bigint
language plpgsql security invoker set search_path=public
as $$
declare next_revision bigint;
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  if not public.is_company_member(target_company) then raise exception 'Company membership required'; end if;
  if snapshot is null or jsonb_typeof(snapshot) <> 'object' then raise exception 'Snapshot must be a JSON object'; end if;
  if octet_length(snapshot::text) > 1000000 then raise exception 'Snapshot exceeds 1 MB limit'; end if;

  insert into public.user_data_snapshots(company_id,user_id,payload,revision,updated_at)
  values(target_company,auth.uid(),snapshot,1,now())
  on conflict(company_id,user_id) do update
    set payload=excluded.payload,
        revision=public.user_data_snapshots.revision+1,
        updated_at=now()
  returning revision into next_revision;
  return next_revision;
end;
$$;

revoke all on function public.save_user_snapshot(uuid,jsonb) from public;
grant execute on function public.save_user_snapshot(uuid,jsonb) to authenticated;

create or replace function public.get_user_snapshot(target_company uuid)
returns table(payload jsonb, revision bigint, updated_at timestamptz)
language sql security invoker set search_path=public
as $$
  select s.payload,s.revision,s.updated_at
  from public.user_data_snapshots s
  where s.company_id=target_company and s.user_id=auth.uid()
    and public.is_company_member(target_company);
$$;

revoke all on function public.get_user_snapshot(uuid) from public;
grant execute on function public.get_user_snapshot(uuid) to authenticated;
