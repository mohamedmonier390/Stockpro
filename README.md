# StockPro — Site Catering & Inventory (Flutter)

Arabic RTL Android prototype for managing a catering company that serves multiple remote sites.

## Current features

- **Sites & contracts:** create a site, client, and contracted breakfast/lunch/dinner prices.
- **Daily meal counts:** record variable meal quantities per site and calculate revenue using the contract prices. Extra unpriced meals are tracked separately.
- **Ingredients:** create stock items with a code, unit, unit cost, current balance, and low-stock threshold.
- **Stock movements:** receive and issue ingredients, keep a movement history, and prevent an issue larger than the available balance.
- **Meal recipes:** configure ingredient quantity per breakfast, lunch, or dinner. Saving a daily meal record deducts the calculated quantities and records the consumption against the site.
- **Monthly summary:** show meal count, revenue, recipe-based ingredient cost, and an estimated margin after ingredient cost.

## Data and calculation limits

- Data is stored locally on the device with shared_preferences; there is **no cloud sync or multi-user sharing** yet. Uninstalling the app or clearing its data may remove the records. Export and backup are not implemented.
- Stock and recipe quantities support fractional values (up to three displayed decimal places), in the unit entered for each ingredient.
- Recipe-based monthly costs are estimates based on the **current** recipe setup and current ingredient unit costs. Historical recipe/cost snapshots, labor, transport, overhead, taxes, and wastage are not yet included. Do not treat the margin as a final accounting profit.
- Barcode camera scanning, supplier purchase invoices, approval workflows, and central reporting are not implemented.
- The app is a prototype. Validate it with sample data before operational use.

## Build locally

    flutter pub get
    flutter run
    flutter build apk --release

APK output: build/app/outputs/flutter-apk/app-release.apk

## Build on GitHub

Open Actions → Build StockPro APK. A push to main or a manual Run workflow starts the build. After a successful run, download the stockpro-apk artifact.
