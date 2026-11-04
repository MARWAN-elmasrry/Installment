# حاسبة التقسيط – مؤسسة مصر مباشر
# Installment Calculator – Misr Mobasher (Flutter, Android, 100% offline)

Replaces the Excel file **نظام التقسيط الجديد.xlsx** with a fast Arabic (RTL)
Android app. No backend, no API calls, no login. The release manifest does
**not** declare the `INTERNET` permission, so the app cannot go online at all.
Calculation history is stored locally in SQLite (`sqflite`).

## The three systems (formulas copied from the Excel file)

| # | System | Excel cells |
|---|--------|-------------|
| 1 | الثلث بفوايد 36% – adjusted = cash + 2000; min down = adjusted / 3; interest = (adjusted − down) × months × 0.03; monthly = (remaining + interest) / months; total = monthly × months + down | B4, E4, F4, E6, F6, E8, F8 |
| 2 | بدون فوائد 6 شهور – adjusted = cash + 1000; min down = adjusted / 2; admin fees = adjusted × 8%; monthly = min down / 6; total = monthly × 6 + min down + fees | B16, C16, D16, E16, C18 |
| 3 | مقدم 75% – min down = cash × 0.75; interest = (cash − down) × months × 0.03; monthly = (remaining + interest) / months; total = monthly × months + down | B24, E24, F24 |

The 300 EGP inquiry fee is **displayed separately and never added to totals**
(it is not part of the Excel formulas). All formulas live in
`lib/services/installment_calculator.dart` with comments.

## Project layout

```
lib/
  main.dart, app.dart            app entry, RTL/Arabic setup
  models/                        InstallmentType, InstallmentResult, HistoryRecord
  services/                      installment_calculator.dart  <- all formulas
                                 installment_validator.dart   <- Arabic validation
                                 history_database.dart        <- SQLite
  screens/                       home_shell (single Scaffold + bottom nav),
                                 home_tab, calculator_tab, history_tab
  widgets/                       reusable widgets
  utils/                         theme, formatters/parsers
test/                            formula, validation and formatting tests
assets/fonts, assets/images      bundled font + app icon (no network needed)
android/                         Android project
```

## Build the APK

Requirements: Flutter SDK (stable, 3.24 or newer), Android Studio or the
Android command-line SDK, JDK 17+.

```bash
cd installment_app
flutter pub get            # also creates pubspec.lock
flutter analyze
flutter test
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

If Flutter complains about missing Android files (for example the Gradle
wrapper, or an AGP/Kotlin version your Flutter wants updated), run this once
inside the project folder; it only adds missing files and never touches `lib/`:

```bash
flutter create . --platforms=android --org com.misrmobasher --project-name installment_app
```

Smaller per-phone APKs: `flutter build apk --release --split-per-abi`.

## Install the APK on a phone

1. Copy `app-release.apk` to the phone (USB, Drive, WhatsApp, etc.).
2. Open it from the Files app.
3. If asked, allow "Install unknown apps" for that app (Settings → Apps →
   Special access → Install unknown apps).
4. Tap **Install**, then open "تقسيط مصر مباشر".

The phone does not need Flutter or any development tools.

## Signing note

The release build is signed with the debug key so it installs directly. That is
fine for sideloading on your own devices. For Google Play, create a keystore,
add `android/key.properties`, and configure `signingConfigs` in
`android/app/build.gradle.kts`. Never commit keystores.

## Fonts

Bundled font: **DejaVu Sans** (free license, full Arabic support). To use
Cairo or Tajawal instead, put the `.ttf` files in `assets/fonts/` and change the
two `asset:` paths under `fonts:` in `pubspec.yaml` (keep `family: AppFont`).

## Modify the project

Open the folder in Android Studio or VS Code (Flutter + Dart plugins).
To change a rate or fee, edit the constants at the top of
`lib/services/installment_calculator.dart`, then update the matching test in
`test/installment_calculator_test.dart`.

## Build the APK online (no installation needed) - GitHub Actions

1. Create a free GitHub account and a new **private** repository.
2. Upload the contents of this folder (the files inside `installment_app`,
   not the folder itself). Make sure `.github/workflows/build_apk.yml` is
   included. If your browser skips hidden folders, use
   "Add file -> Create new file", type the name
   `.github/workflows/build_apk.yml` and paste the file's content.
3. Open the **Actions** tab -> **Build APK** -> **Run workflow**.
4. After 5-10 minutes open the finished run and download
   **installment_app_apk** from the *Artifacts* section. Unzip it to get
   `app-release.apk`.

Analyze and test results appear in the run log. They do not block the APK.
