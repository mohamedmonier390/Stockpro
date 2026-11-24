# StockPro Cloud — initial backend setup

These migrations create the multi-company Supabase/Postgres foundation. The Android app initializes the Supabase client and exposes an optional Cloud Account screen with email/password sign-up, sign-in, a database connectivity check, and first-company creation through the authenticated onboarding RPC. This is account/company setup only: the operational records already stored on the device are not migrated, uploaded, or synchronized to Supabase. The cloud account is separate from the local PIN login.

## Apply migrations
In Supabase Dashboard → SQL Editor, run in order:
1. `supabase/migrations/0001_stockpro_cloud.sql`
2. `supabase/migrations/0002_permission_scope_rls.sql`
3. `supabase/migrations/0003_secure_company_onboarding.sql`

Confirm each finishes without errors. Keep a copy of the results.

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
- Company selection and linking the authenticated cloud membership to the operational screens.
- Cloud sync, idempotency/conflict handling, migration of local data, remote backup, subscription enforcement, and billing.
- A customer-facing privacy notice covering the optional Supabase account/company setup before commercial distribution.
- Do not load real customer data until security tests pass.
