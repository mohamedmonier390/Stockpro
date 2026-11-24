-- StockPro Business Cloud foundation (Supabase/Postgres)
-- Apply in Supabase SQL Editor. RLS keeps tenant data isolated.
create extension if not exists pgcrypto;

create table if not exists public.companies (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  plan text not null default 'trial' check (plan in ('trial','starter','business','pro','enterprise')),
  subscription_status text not null default 'trial' check (subscription_status in ('trial','active','past_due','cancelled','expired')),
  created_at timestamptz not null default now()
);

create table if not exists public.company_members (
  company_id uuid not null references public.companies(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null default 'staff' check (role in ('owner','admin','manager','staff')),
  permissions jsonb not null default '[]'::jsonb,
  site_scope uuid[] not null default '{}',
  warehouse_scope uuid[] not null default '{}',
  created_at timestamptz not null default now(),
  primary key(company_id,user_id)
);

create or replace function public.is_company_member(target_company uuid)
returns boolean language sql stable security definer set search_path=public
as $$ select exists(select 1 from public.company_members m where m.company_id=target_company and m.user_id=auth.uid()) $$;

create or replace function public.is_company_admin(target_company uuid)
returns boolean language sql stable security definer set search_path=public
as $$ select exists(select 1 from public.company_members m where m.company_id=target_company and m.user_id=auth.uid() and m.role in ('owner','admin')) $$;

create table if not exists public.sites (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies(id) on delete cascade,
  name text not null,
  client_name text not null default '',
  breakfast_price numeric(12,2) not null default 0,
  lunch_price numeric(12,2) not null default 0,
  dinner_price numeric(12,2) not null default 0,
  archived boolean not null default false,
  created_at timestamptz not null default now(),
  unique(company_id,name)
);

create table if not exists public.warehouses (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies(id) on delete cascade,
  site_id uuid references public.sites(id) on delete set null,
  name text not null,
  manager_name text not null default '',
  is_main boolean not null default false,
  created_at timestamptz not null default now(),
  unique(company_id,name)
);

create table if not exists public.inventory_items (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies(id) on delete cascade,
  code text not null default '',
  name text not null,
  unit text not null default '',
  cost numeric(12,4) not null default 0,
  minimum_stock numeric(12,3) not null default 0,
  archived boolean not null default false,
  created_at timestamptz not null default now(),
  unique(company_id,code)
);

create table if not exists public.stock_balances (
  company_id uuid not null references public.companies(id) on delete cascade,
  warehouse_id uuid not null references public.warehouses(id) on delete cascade,
  item_id uuid not null references public.inventory_items(id) on delete cascade,
  quantity numeric(14,3) not null default 0,
  updated_at timestamptz not null default now(),
  primary key(warehouse_id,item_id)
);

create table if not exists public.stock_movements (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies(id) on delete cascade,
  item_id uuid not null references public.inventory_items(id),
  warehouse_id uuid not null references public.warehouses(id),
  movement_type text not null check (movement_type in ('receipt','issue','transfer_in','transfer_out','adjustment')),
  quantity numeric(14,3) not null check(quantity > 0),
  reference text not null default '',
  notes text not null default '',
  occurred_at timestamptz not null default now(),
  created_by uuid references auth.users(id)
);

create table if not exists public.meal_records (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies(id) on delete cascade,
  site_id uuid not null references public.sites(id),
  service_date date not null,
  breakfast integer not null default 0 check(breakfast>=0),
  lunch integer not null default 0 check(lunch>=0),
  dinner integer not null default 0 check(dinner>=0),
  extra_meals integer not null default 0 check(extra_meals>=0),
  created_by uuid references auth.users(id),
  updated_at timestamptz not null default now(),
  unique(site_id,service_date)
);

create table if not exists public.expenses (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies(id) on delete cascade,
  site_id uuid references public.sites(id),
  category text not null default 'Other',
  note text not null default '',
  amount numeric(12,2) not null check(amount>=0),
  expense_date date not null default current_date,
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now()
);

create table if not exists public.audit_log (
  id bigint generated always as identity primary key,
  company_id uuid not null references public.companies(id) on delete cascade,
  actor_id uuid references auth.users(id),
  action text not null,
  entity text not null,
  entity_id text not null default '',
  details jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

-- RLS tenant boundaries. Admin-level mutations are restricted where applicable.
do $$ declare t text; begin
  foreach t in array array['companies','company_members','sites','warehouses','inventory_items','stock_balances','stock_movements','meal_records','expenses','audit_log'] loop
    execute format('alter table public.%I enable row level security',t);
  end loop;
end $$;

drop policy if exists company_member_read on public.companies;
create policy company_member_read on public.companies for select using (public.is_company_member(id));
drop policy if exists company_admin_update on public.companies;
create policy company_admin_update on public.companies for update using (public.is_company_admin(id)) with check (public.is_company_admin(id));

drop policy if exists membership_read on public.company_members;
create policy membership_read on public.company_members for select using (public.is_company_member(company_id));
drop policy if exists membership_admin_write on public.company_members;
create policy membership_admin_write on public.company_members for all using (public.is_company_admin(company_id)) with check (public.is_company_admin(company_id));

do $$ declare t text; begin
  foreach t in array array['sites','warehouses','inventory_items','stock_balances','stock_movements','meal_records','expenses','audit_log'] loop
    execute format('drop policy if exists tenant_member_all on public.%I',t);
    execute format('create policy tenant_member_all on public.%I for all using (public.is_company_member(company_id)) with check (public.is_company_member(company_id))',t);
  end loop;
end $$;

create index if not exists stock_movements_company_date_idx on public.stock_movements(company_id,occurred_at desc);
create index if not exists meals_company_date_idx on public.meal_records(company_id,service_date desc);
create index if not exists expenses_company_date_idx on public.expenses(company_id,expense_date desc);
