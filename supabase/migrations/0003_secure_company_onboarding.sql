-- Secure first-company onboarding: authenticated users can create their own
-- tenant and become its owner without needing service-role credentials.
create or replace function public.create_company_for_current_user(company_name text)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  new_company_id uuid;
  clean_name text;
begin
  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;

  clean_name := trim(company_name);
  if clean_name is null or length(clean_name) < 2 or length(clean_name) > 120 then
    raise exception 'Company name must be between 2 and 120 characters';
  end if;

  insert into public.companies(name, plan, subscription_status)
  values (clean_name, 'trial', 'trial')
  returning id into new_company_id;

  insert into public.company_members(company_id, user_id, role, permissions)
  values (new_company_id, auth.uid(), 'owner', '[]'::jsonb);

  return new_company_id;
end;
$$;

revoke all on function public.create_company_for_current_user(text) from public;
grant execute on function public.create_company_for_current_user(text) to authenticated;
