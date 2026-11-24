# StockPro Cloud — initial backend setup

This migration creates a multi-company Supabase/Postgres foundation. It is **not yet connected to the Android app**.

## Apply migrations
1. Open your Supabase project → SQL Editor.
2. Run `supabase/migrations/0001_stockpro_cloud.sql`.
3. Then run `supabase/migrations/0002_permission_scope_rls.sql`.
4. Check both complete without errors. Keep a copy of the SQL output.

## What is present
- Company membership and roles.
- Sites, warehouses, items, balances, movements, meals, expenses and audit records.
- Row Level Security (RLS) and a second migration to replace the first broad member policy with module permission checks and site/warehouse scopes.

## Permission names
The permissions JSON array must use the same module labels as the app: `المواقع`, `المخازن`, `المخزون`, `الوجبات`, and `المصروفات`. Owners/admins bypass module permissions. Site/warehouse scopes are UUID arrays; empty scope currently means all within the company, so invitation setup must explicitly set scopes if the user is to be restricted.

## Not production-ready yet
- Scope helper behavior and policies must be validated with separate test accounts, including negative tests for cross-company access and out-of-scope rows.
- Stock transfer posting should be moved to a transactional database function that writes paired ledger entries and updates balances atomically; client-side writes must not be trusted for this.
- Secure company-owner onboarding and invites must use a trusted server function (never expose service-role secrets).
- App-side Supabase connection, authentication, company selection, offline sync, idempotency/conflict handling, data migration, subscription enforcement, and billing are still pending.
- Do not load production customer data until policy tests are complete.
