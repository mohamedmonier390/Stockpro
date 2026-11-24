# StockPro Business

Flutter Android app for catering operations across multiple sites, with Arabic RTL interface.

## Product scope

- Site/client contracts and meal-price records.
- Daily breakfast, lunch, dinner, and extra meal counts.
- Ingredient catalog, unit/cost/opening balances, and low-stock thresholds.
- Separate balances by warehouse.
- Receipts, issues, transfer-out/transfer-in, stocktake adjustments, and movement history.
- Recipe-based ingredient consumption when meal counts are recorded.
- Site expenses and reporting.
- Local users, PIN login, permissions, and audit log.
- Excel import and local JSON backup/restore.

## Current release-candidate status

This branch prepares the commercial release candidate. The **operational business data remains local-only**, while a separate optional Supabase account/onboarding screen is available:
- Site contracts, meal records, recipes, items, warehouse balances and movements, expenses, local users, and audit records are stored on the device with SharedPreferences.
- The optional Cloud Account screen supports Supabase email/password sign-up/sign-in and first-company creation through the authenticated `create_company_for_current_user` RPC, after the three database migrations are applied.
- Cloud account identity is separate from local PIN users. Creating a cloud account/company does not migrate or synchronize the device's operating records.
- Operational cloud sync, multi-device synchronization, remote operational-data backup, and subscription/payment enforcement are not active.
- Local PIN/user permissions remain device-local convenience controls, not centralized enterprise identity/security.
- Uninstalling or clearing app data can remove records. Export backups regularly and store them securely.

Do not describe operational cloud synchronization or subscription/payment features as available until implemented, security-tested, and deployed.

## Release artifacts

The current main-branch GitHub Actions workflow (`.github/workflows/build-apk.yml`) generates the Android project files and uploads an installable release-mode APK named `stockpro-apk`. It currently uses CI/debug signing and **does not build a Play Store AAB or use the stable upload keystore**. Treat this as a CI/test artifact only; do not submit it to Google Play or use it as a production upgrade package.

Before a store release, confirm the permanent Android application ID and the original upload key, restore a protected signing configuration, build both APK/AAB as required, and verify the artifacts from a clean run. **Never rotate or replace the signing key casually.** Keep the keystore and password out of Git and back them up securely.

## Build locally

```bash
flutter pub get
flutter analyze
flutter build apk --release
flutter build appbundle --release
```

## Proposed pricing (not yet enabled in-app)

Pricing is a market-entry hypothesis for Egypt, to validate with customers:
- Starter: EGP 149/month — one site/warehouse.
- Business: EGP 299/month — small team, up to a few locations.
- Pro: EGP 499/month — multi-site operations.
- Enterprise: custom quotation.

These prices are not active plans or payments. Cloud hosting, support level, storage, user/site limits, and payment method must be finalized before sales.

## Commercial release checklist

See `docs/PLAY_STORE_RELEASE_CHECKLIST.md`, `docs/PRIVACY_POLICY_DRAFT.md`, and `docs/COMMERCIAL_PLAN.md`.
