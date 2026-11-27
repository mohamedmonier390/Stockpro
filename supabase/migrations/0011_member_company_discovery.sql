-- Allow a signed-in member to discover only companies they already belong to.
-- This enables invited users to link their device without exposing other tenants.
create or replace function public.list_my_companies()
returns table(company_id uuid, company_name text, member_role text, member_permissions jsonb)
language sql
security definer
set search_path = public
as $$
  select c.id, c.name, m.role, m.permissions
  from public.company_members m
  join public.companies c on c.id = m.company_id
  where m.user_id = auth.uid()
  order by c.created_at, c.name;
$$;

revoke all on function public.list_my_companies() from public, anon;
grant execute on function public.list_my_companies() to authenticated;
