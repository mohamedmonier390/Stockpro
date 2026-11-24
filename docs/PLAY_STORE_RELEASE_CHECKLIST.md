# Google Play commercial release checklist

## Build and app identity
- [ ] Confirm application ID (package name) is final and unchanged from upgrade-compatible builds.
- [ ] Confirm version name/code and stable signing/upload key.
- [ ] Build APK and AAB from a clean CI run; verify both artifacts.
- [ ] Confirm the artifact uses the permanent upload key. The current main workflow only uploads a CI/debug-signed APK and does not produce an AAB; it is not Play Store-ready.
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

## Known business and reporting decisions before production
- Historical revenue is recalculated using the site's current meal prices; the daily meal record does not yet snapshot the contract prices that applied on its date. Changing a contract price can therefore restate older reports.
- Historical raw-material cost is recalculated using the current recipe quantities and current item unit costs; recipe/cost changes can restate older profitability reports.
- Low-stock count currently compares the combined balance across the user's visible warehouses with one item-level minimum. It may not flag a shortage in one warehouse when another warehouse has surplus. Confirm whether minimum levels should be maintained per warehouse.
- Extra meals are explicitly unpriced and are excluded from both revenue and recipe-based material cost until prices/recipes are defined.

These accounting and stock-control rules need an agreed policy and regression tests before reports are used as audited financial records.

## Not yet complete
Operational cloud sync, multi-device accounts, subscription/payment enforcement, stable Play Store signing/AAB workflow, public privacy-policy hosting, final artwork, Play Console review, and a production pilot are still pending.
