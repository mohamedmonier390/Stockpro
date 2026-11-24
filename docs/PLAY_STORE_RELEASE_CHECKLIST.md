# Google Play commercial release checklist

## Build and app identity
- [ ] Confirm application ID (package name) is final and unchanged from upgrade-compatible builds.
- [ ] Confirm version name/code and stable signing/upload key.
- [ ] Build APK and AAB from a clean CI run; verify both artifacts.
- [ ] Back up the upload keystore and password in secure storage.
- [ ] Test upgrade installation over the current StockPro without uninstalling.
- [ ] Test on supported Android versions, small screens, and tablets.

## Product QA
- [ ] Login/PIN and role permissions.
- [ ] Site creation/editing and meal entry/editing.
- [ ] Recipe consumption and stock balance validation.
- [ ] Receive, issue, transfer, and stocktake.
- [ ] Excel import with valid, duplicate, malformed, and missing warehouse data.
- [ ] Reports and expenses.
- [ ] Backup/restore; confirm data survives app update.
- [ ] Verify no crash, blank page, or incorrect totals in a test dataset.

## Store listing and compliance
- [ ] Final app name, short/long descriptions, screenshots, icon, feature graphic.
- [ ] Public privacy-policy URL and support contact.
- [ ] Complete Play Console Data safety and app-content declarations accurately.
- [ ] Content rating, target audience, and ads declaration.
- [ ] Account-specific testing requirements and review process.
- [ ] Billing/subscriptions only after implementing and testing compliant payment/entitlement flow.
- [ ] Review trademark/name availability and legal operator details.

## Not yet complete
Cloud sync, multi-device accounts, subscription/payment handling, public privacy-policy hosting, final artwork, Play Console review, and production pilot are still pending.
