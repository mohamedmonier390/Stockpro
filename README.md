# StockPro — Flutter Arabic inventory MVP

Arabic RTL Android inventory and sales prototype.

## Included in this starter
- Dashboard with sales, estimated profit, item count, low-stock count, and inventory cost value
- Add item form: name, item code/barcode, purchase price, sale price, stock quantity, minimum stock
- Product listing
- Simple sale: validates stock, deducts quantity, and calculates sale total and estimated gross profit
- Arabic RTL navigation
- GitHub Actions workflow to build a release APK

## Current limitation
Data is stored in memory only and resets after the app is closed. Persistent local database, barcode camera scanning, purchase/stock movement records, invoice history, export and backup are planned next.

## Build locally
```bash
flutter pub get
flutter run
flutter build apk --release
```

APK: `build/app/outputs/flutter-apk/app-release.apk`

## Build on GitHub
Open **Actions** → **Build StockPro APK** → **Run workflow**. When completed, download the `stockpro-apk` artifact.
