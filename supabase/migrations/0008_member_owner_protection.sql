-- Tighten member promotion/demotion: never alter the company owner or create a second owner.
create or replace function public.add_company_member_by_email(target_company uuid, member_email text, member_role text default 'staff', member_permissions jsonb default '[]'::jsonb)
returns uuid
language plpgsql security definer set search_path=public,auth
as $$
declare new_user uuid; current_role text; existing_role text;
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 if not public.is_company_admin(target_company) then raise exception 'Admin permission required'; end if;
 select role into current_role from public.company_members where company_id=target_company and user_id=auth.uid();
 if current_role<>'owner' and member_role not in ('manager','staff') then raise exception 'Only owner can assign admin role'; end if;
 if member_role not in ('admin','manager','staff') then raise exception 'Invalid role'; end if;
 if member_permissions is null or jsonb_typeof(member_permissions)<>'array' then raise exception 'Permissions must be an array'; end if;
 select id into new_user from auth.users where lower(email)=lower(trim(member_email)) limit 1;
 if new_user is null then raise exception 'ACCOUNT_NOT_FOUND: This email must register in StockPro cloud first.'; end if;
 if new_user=auth.uid() then raise exception 'You are already a company member'; end if;
 select role into existing_role from public.company_members where company_id=target_company and user_id=new_user;
 if existing_role='owner' then raise exception 'Owner membership cannot be modified'; end if;
 if current_role='admin' and existing_role='admin' then raise exception 'Admins cannot change another admin'; end if;
 insert into public.company_members(company_id,user_id,role,permissions)
 values(target_company,new_user,member_role,member_permissions)
 on conflict(company_id,user_id) do update set role=excluded.role,permissions=excluded.permissions;
 return new_user;
end;
$$;
revoke all on function public.add_company_member_by_email(uuid,text,text,jsonb) from public,anon;
grant execute on function public.add_company_member_by_email(uuid,text,text,jsonb) to authenticated;
