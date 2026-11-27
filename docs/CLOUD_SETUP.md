# StockPro Cloud — initial backend setup

This migration creates the multi-company Supabase/Postgres foundation. The Android app currently initializes the Supabase client and offers a database connectivity check, but cloud authentication, data sync, and company onboarding UI are not yet enabled.

## Apply migrations
In Supabase Dashboard → SQL Editor, run in order (only in a test project until security checks are complete):
1. `supabase/migrations/0001_stockpro_cloud.sql`
2. `supabase/migrations/0002_permission_scope_rls.sql`
3. `supabase/migrations/0003_secure_company_onboarding.sql`
4. `supabase/migrations/0004_user_snapshot_sync.sql`
5. `supabase/migrations/0005_secure_existing_permission_functions.sql`
6. `supabase/migrations/0006_company_shared_snapshot.sql`
7. `supabase/migrations/0007_company_member_management.sql`
8. `supabase/migrations/0008_member_owner_protection.sql`
9. `supabase/migrations/0009_enable_company_snapshot_realtime.sql`
10. `supabase/migrations/0010_require_company_sync_permission.sql`
11. `supabase/migrations/0011_member_company_discovery.sql`

Confirm each finishes without errors. Keep a copy of the results. Migration 0011 adds `list_my_companies()`, which returns only the companies for which the signed-in user is already a member, allowing an invited member to link their device. It does not allow searching or joining arbitrary companies.

## What exists
- Company membership and roles.
- Sites, warehouses, items, balances, movements, meals, expenses and audit records.
- Row Level Security (RLS) tenant isolation and module/site/warehouse scope policies.
- Secure RPC `create_company_for_current_user(company_name)`: requires a signed-in Supabase user, creates a trial company and adds that user as owner. It is executable by authenticated users only; no service-role key is used in the app.

## Permission names
The permissions JSON array uses module labels: `المواقع`, `المخازن`, `المخزون`, `الوجبات`, and `المصروفات`. Owners/admins bypass module permissions. Site/warehouse scopes are UUID arrays; empty scope currently means all within the company, so onboarding/invite logic must explicitly set scopes when restrictions are required.

## Production readiness still pending
- Validate policies with multiple test users and negative tests for cross-company/out-of-scope data.
- Move stock transfer posting to a transactional DB function writing paired ledger entries and balances atomically.
- Secure invitations/member provisioning through trusted server functions; never expose service-role secrets.
- Android-side authentication, company selection, cloud sync, idempotency/conflict handling, migration of local data, subscription enforcement, and billing.
- Do not load real customer data until security tests pass.
