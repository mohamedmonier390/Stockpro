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

This branch prepares the commercial release candidate. The current app is still **local-only**:
- Data is stored on the device with SharedPreferences.
- No cloud database, multi-device synchronization, online account system, subscription enforcement, or remote backup is active.
- Local PIN/user permissions are convenience controls, not enterprise-grade identity/security.
- Uninstalling or clearing app data can remove records. Export backups regularly and store them securely.

Do not describe cloud synchronization or subscription features as available until implemented, tested, and deployed.

## Release artifacts

The GitHub Actions workflow builds:
- Signed APK for direct Android installation.
- Signed Android App Bundle (AAB) for Google Play submission.

The Android application ID and release signing key must remain unchanged for upgrades to existing installations. The workflow depends on repository secrets:
- `STOCKPRO_KEYSTORE_BASE64`
- `STOCKPRO_KEYSTORE_PASSWORD`

**Never rotate or replace the signing key casually.** Back up the upload keystore and its password securely.

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
