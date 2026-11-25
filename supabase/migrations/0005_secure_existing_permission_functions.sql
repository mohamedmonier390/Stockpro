-- StockPro cloud safety patch: lock authorization helpers to signed-in users.
-- Applied directly to the linked Supabase project on 2026-11-25; this file records
-- the change for repository reproducibility. Non-destructive and safe to re-run.
revoke execute on function public.is_company_member(uuid) from public, anon;
revoke execute on function public.is_company_admin(uuid) from public, anon;
revoke execute on function public.has_company_permission(uuid, text) from public, anon;
revoke execute on function public.can_access_site(uuid, uuid) from public, anon;
revoke execute on function public.can_access_warehouse(uuid, uuid) from public, anon;

grant execute on function public.is_company_member(uuid) to authenticated;
grant execute on function public.is_company_admin(uuid) to authenticated;
grant execute on function public.has_company_permission(uuid, text) to authenticated;
grant execute on function public.can_access_site(uuid, uuid) to authenticated;
grant execute on function public.can_access_warehouse(uuid, uuid) to authenticated;

create index if not exists audit_log_actor_id_idx on public.audit_log(actor_id);
create index if not exists audit_log_company_id_idx on public.audit_log(company_id);
create index if not exists company_members_user_id_idx on public.company_members(user_id);
create index if not exists expenses_created_by_idx on public.expenses(created_by);
create index if not exists expenses_site_id_idx on public.expenses(site_id);
create index if not exists meal_records_created_by_idx on public.meal_records(created_by);
create index if not exists stock_balances_company_id_idx on public.stock_balances(company_id);
create index if not exists stock_balances_item_id_idx on public.stock_balances(item_id);
create index if not exists stock_movements_created_by_idx on public.stock_movements(created_by);
create index if not exists stock_movements_item_id_idx on public.stock_movements(item_id);
create index if not exists stock_movements_warehouse_id_idx on public.stock_movements(warehouse_id);
create index if not exists warehouses_site_id_idx on public.warehouses(site_id);
