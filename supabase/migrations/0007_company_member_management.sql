-- StockPro member management RPCs. Company owners/admins can add existing accounts and set scoped module permissions.
create or replace function public.list_company_members(target_company uuid)
returns table(user_id uuid, email text, role text, permissions jsonb, created_at timestamptz)
language plpgsql security definer set search_path=public,auth
as $$
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 if not public.is_company_admin(target_company) then raise exception 'Admin permission required'; end if;
 return query select m.user_id,u.email,m.role,m.permissions,m.created_at
 from public.company_members m join auth.users u on u.id=m.user_id
 where m.company_id=target_company order by m.created_at;
end;
$$;
revoke all on function public.list_company_members(uuid) from public,anon;
grant execute on function public.list_company_members(uuid) to authenticated;

create or replace function public.add_company_member_by_email(target_company uuid, member_email text, member_role text default 'staff', member_permissions jsonb default '[]'::jsonb)
returns uuid
language plpgsql security definer set search_path=public,auth
as $$
declare new_user uuid; current_role text;
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 if not public.is_company_admin(target_company) then raise exception 'Admin permission required'; end if;
 select role into current_role from public.company_members where company_id=target_company and user_id=auth.uid();
 if current_role='admin' and member_role in ('owner','admin') then raise exception 'Admins cannot assign admin or owner role'; end if;
 if member_role not in ('manager','staff') and current_role<>'owner' then raise exception 'Only owner may assign owner/admin roles'; end if;
 if member_role not in ('owner','admin','manager','staff') then raise exception 'Invalid role'; end if;
 if member_permissions is null or jsonb_typeof(member_permissions)<>'array' then raise exception 'Permissions must be an array'; end if;
 select id into new_user from auth.users where lower(email)=lower(trim(member_email)) limit 1;
 if new_user is null then raise exception 'ACCOUNT_NOT_FOUND: This email must register in StockPro cloud first.'; end if;
 if new_user=auth.uid() then raise exception 'You are already a company member'; end if;
 insert into public.company_members(company_id,user_id,role,permissions)
 values(target_company,new_user,member_role,member_permissions)
 on conflict(company_id,user_id) do update set role=excluded.role,permissions=excluded.permissions;
 return new_user;
end;
$$;
revoke all on function public.add_company_member_by_email(uuid,text,text,jsonb) from public,anon;
grant execute on function public.add_company_member_by_email(uuid,text,text,jsonb) to authenticated;

create or replace function public.remove_company_member(target_company uuid, member_user uuid)
returns boolean
language plpgsql security definer set search_path=public
as $$
declare actor_role text; target_role text;
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 if not public.is_company_admin(target_company) then raise exception 'Admin permission required'; end if;
 select role into actor_role from public.company_members where company_id=target_company and user_id=auth.uid();
 select role into target_role from public.company_members where company_id=target_company and user_id=member_user;
 if target_role is null then return false; end if;
 if target_role='owner' then raise exception 'Owner membership cannot be removed'; end if;
 if actor_role='admin' and target_role='admin' then raise exception 'Admins cannot remove another admin'; end if;
 if member_user=auth.uid() then raise exception 'Use leave-company workflow to remove yourself'; end if;
 delete from public.company_members where company_id=target_company and user_id=member_user;
 return true;
end;
$$;
revoke all on function public.remove_company_member(uuid,uuid) from public,anon;
grant execute on function public.remove_company_member(uuid,uuid) to authenticated;
