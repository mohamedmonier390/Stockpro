# StockPro Cloud — initial backend setup

This migration creates the first multi-company database foundation for Supabase/Postgres. It is **not yet connected to the Android app**.

## Apply
1. Open your Supabase project.
2. Go to SQL Editor → New query.
3. Copy all of `supabase/migrations/0001_stockpro_cloud.sql`, run it, and confirm there are no errors.
4. Do not share your service-role key. For app integration we will use the project URL and public anon/publishable key only; server-side privileged operations must be done through trusted functions/Edge Functions.

## Included
- Companies and user membership/roles.
- Sites, warehouses, inventory items and independent warehouse balances.
- Stock movement ledger (receipt, issue, transfers, adjustments).
- Meal records and expenses.
- Audit trail.
- Row-Level Security (RLS) policies for company/tenant isolation.

## Important next implementation
- Secure onboarding function that creates a company and owner membership atomically (not by exposing privileged keys).
- Invitation/registration flow, membership and permission enforcement.
- Offline-first sync with stable UUIDs, idempotency keys, conflict rules and a pending-sync queue.
- Server-side plan enforcement, billing integration, subscription lifecycle.
- Cloud export/restore and automated tests for cross-company isolation.
- App configuration for Supabase URL + anon key and gradual migration of local data.

**Do not use this schema for production customer data until RLS policies and onboarding have been tested with separate accounts/companies.**
