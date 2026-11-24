-- StockPro Cloud: permission- and scope-aware RLS hardening.
-- Apply after 0001_stockpro_cloud.sql. This replaces the permissive
-- tenant_member_all policies; members no longer get unrestricted writes.

create or replace function public.has_company_permission(target_company uuid, required_permission text)
returns boolean
language sql stable security definer set search_path = public
as $$
  select exists (
    select 1 from public.company_members m
    where m.company_id = target_company
      and m.user_id = auth.uid()
      and (
        m.role in ('owner','admin')
        or coalesce(m.permissions, '[]'::jsonb) ? required_permission
      )
  );
$$;

create or replace function public.can_access_site(target_company uuid, target_site uuid)
returns boolean
language sql stable security definer set search_path = public
as $$
  select exists (
    select 1 from public.company_members m
    where m.company_id = target_company
      and m.user_id = auth.uid()
      and (
        m.role in ('owner','admin')
        or cardinality(m.site_scope) = 0
        or target_site = any(m.site_scope)
      )
  );
$$;

create or replace function public.can_access_warehouse(target_company uuid, target_warehouse uuid)
returns boolean
language sql stable security definer set search_path = public
as $$
  select exists (
    select 1 from public.company_members m
    where m.company_id = target_company
      and m.user_id = auth.uid()
      and (
        m.role in ('owner','admin')
        or cardinality(m.warehouse_scope) = 0
        or target_warehouse = any(m.warehouse_scope)
      )
  );
$$;

-- Remove the broad policies created by migration 0001.
drop policy if exists tenant_member_all on public.sites;
drop policy if exists tenant_member_all on public.warehouses;
drop policy if exists tenant_member_all on public.inventory_items;
drop policy if exists tenant_member_all on public.stock_balances;
drop policy if exists tenant_member_all on public.stock_movements;
drop policy if exists tenant_member_all on public.meal_records;
drop policy if exists tenant_member_all on public.expenses;
drop policy if exists tenant_member_all on public.audit_log;

-- Sites: users need the sites module permission to write; site scope applies.
drop policy if exists sites_read on public.sites;
create policy sites_read on public.sites for select
using (public.is_company_member(company_id) and public.can_access_site(company_id,id));
drop policy if exists sites_insert on public.sites;
create policy sites_insert on public.sites for insert
with check (public.has_company_permission(company_id,'المواقع'));
drop policy if exists sites_update on public.sites;
create policy sites_update on public.sites for update
using (public.has_company_permission(company_id,'المواقع') and public.can_access_site(company_id,id))
with check (public.has_company_permission(company_id,'المواقع') and public.can_access_site(company_id,id));
drop policy if exists sites_delete on public.sites;
create policy sites_delete on public.sites for delete
using (public.has_company_permission(company_id,'المواقع') and public.can_access_site(company_id,id));

-- Warehouses: warehouse scope is enforced on every row.
drop policy if exists warehouses_read on public.warehouses;
create policy warehouses_read on public.warehouses for select
using (public.is_company_member(company_id) and public.can_access_warehouse(company_id,id));
drop policy if exists warehouses_insert on public.warehouses;
create policy warehouses_insert on public.warehouses for insert
with check (public.has_company_permission(company_id,'المخازن'));
drop policy if exists warehouses_update on public.warehouses;
create policy warehouses_update on public.warehouses for update
using (public.has_company_permission(company_id,'المخازن') and public.can_access_warehouse(company_id,id))
with check (public.has_company_permission(company_id,'المخازن') and public.can_access_warehouse(company_id,id));
drop policy if exists warehouses_delete on public.warehouses;
create policy warehouses_delete on public.warehouses for delete
using (public.has_company_permission(company_id,'المخازن') and public.can_access_warehouse(company_id,id));

-- Inventory catalog. Warehouse restrictions are applied to stock records below.
drop policy if exists items_read on public.inventory_items;
create policy items_read on public.inventory_items for select
using (public.is_company_member(company_id));
drop policy if exists items_insert on public.inventory_items;
create policy items_insert on public.inventory_items for insert
with check (public.has_company_permission(company_id,'المخزون'));
drop policy if exists items_update on public.inventory_items;
create policy items_update on public.inventory_items for update
using (public.has_company_permission(company_id,'المخزون'))
with check (public.has_company_permission(company_id,'المخزون'));
drop policy if exists items_delete on public.inventory_items;
create policy items_delete on public.inventory_items for delete
using (public.has_company_permission(company_id,'المخزون'));

-- Stock balances: only warehouse-scoped users with inventory permission can modify.
drop policy if exists balances_read on public.stock_balances;
create policy balances_read on public.stock_balances for select
using (public.is_company_member(company_id) and public.can_access_warehouse(company_id,warehouse_id));
drop policy if exists balances_insert on public.stock_balances;
create policy balances_insert on public.stock_balances for insert
with check (public.has_company_permission(company_id,'المخزون') and public.can_access_warehouse(company_id,warehouse_id));
drop policy if exists balances_update on public.stock_balances;
create policy balances_update on public.stock_balances for update
using (public.has_company_permission(company_id,'المخزون') and public.can_access_warehouse(company_id,warehouse_id))
with check (public.has_company_permission(company_id,'المخزون') and public.can_access_warehouse(company_id,warehouse_id));
drop policy if exists balances_delete on public.stock_balances;
create policy balances_delete on public.stock_balances for delete
using (public.has_company_permission(company_id,'المخزون') and public.can_access_warehouse(company_id,warehouse_id));

-- Movement ledger: read requires membership/scope; insert and corrections require inventory permission.
drop policy if exists movements_read on public.stock_movements;
create policy movements_read on public.stock_movements for select
using (public.is_company_member(company_id) and public.can_access_warehouse(company_id,warehouse_id));
drop policy if exists movements_insert on public.stock_movements;
create policy movements_insert on public.stock_movements for insert
with check (public.has_company_permission(company_id,'المخزون') and public.can_access_warehouse(company_id,warehouse_id));
drop policy if exists movements_update on public.stock_movements;
create policy movements_update on public.stock_movements for update
using (public.has_company_permission(company_id,'المخزون') and public.can_access_warehouse(company_id,warehouse_id))
with check (public.has_company_permission(company_id,'المخزون') and public.can_access_warehouse(company_id,warehouse_id));
drop policy if exists movements_delete on public.stock_movements;
create policy movements_delete on public.stock_movements for delete
using (public.has_company_permission(company_id,'المخزون') and public.can_access_warehouse(company_id,warehouse_id));

-- Meals: site scopes apply; writes require the meals module.
drop policy if exists meals_read on public.meal_records;
create policy meals_read on public.meal_records for select
using (public.is_company_member(company_id) and public.can_access_site(company_id,site_id));
drop policy if exists meals_insert on public.meal_records;
create policy meals_insert on public.meal_records for insert
with check (public.has_company_permission(company_id,'الوجبات') and public.can_access_site(company_id,site_id));
drop policy if exists meals_update on public.meal_records;
create policy meals_update on public.meal_records for update
using (public.has_company_permission(company_id,'الوجبات') and public.can_access_site(company_id,site_id))
with check (public.has_company_permission(company_id,'الوجبات') and public.can_access_site(company_id,site_id));
drop policy if exists meals_delete on public.meal_records;
create policy meals_delete on public.meal_records for delete
using (public.has_company_permission(company_id,'الوجبات') and public.can_access_site(company_id,site_id));

-- Expenses: users must have the expenses module and be within site scope.
drop policy if exists expenses_read on public.expenses;
create policy expenses_read on public.expenses for select
using (public.is_company_member(company_id) and (site_id is null or public.can_access_site(company_id,site_id)));
drop policy if exists expenses_insert on public.expenses;
create policy expenses_insert on public.expenses for insert
with check (public.has_company_permission(company_id,'المصروفات') and (site_id is null or public.can_access_site(company_id,site_id)));
drop policy if exists expenses_update on public.expenses;
create policy expenses_update on public.expenses for update
using (public.has_company_permission(company_id,'المصروفات') and (site_id is null or public.can_access_site(company_id,site_id)))
with check (public.has_company_permission(company_id,'المصروفات') and (site_id is null or public.can_access_site(company_id,site_id)));
drop policy if exists expenses_delete on public.expenses;
create policy expenses_delete on public.expenses for delete
using (public.has_company_permission(company_id,'المصروفات') and (site_id is null or public.can_access_site(company_id,site_id)));

-- Audit history is read-only for regular members; append-only for authenticated actors.
drop policy if exists audit_read on public.audit_log;
create policy audit_read on public.audit_log for select
using (public.is_company_admin(company_id));
drop policy if exists audit_insert on public.audit_log;
create policy audit_insert on public.audit_log for insert
with check (public.is_company_member(company_id) and (actor_id is null or actor_id = auth.uid()));
drop policy if exists audit_update on public.audit_log;
create policy audit_update on public.audit_log for update using (false);
drop policy if exists audit_delete on public.audit_log;
create policy audit_delete on public.audit_log for delete using (false);

-- Never allow regular members to create or change membership/roles.
drop policy if exists membership_admin_write on public.company_members;
create policy membership_admin_write on public.company_members for all
using (public.is_company_admin(company_id))
with check (public.is_company_admin(company_id));
