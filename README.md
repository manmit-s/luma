# Luma — Personal Expense Memory

> You should never have to remember to remember an expense.

Luma is a private, local-first Android expense tracker built with Flutter. It watches incoming bank transaction SMS, creates a pending expense automatically, and nudges you instantly so you can categorize it in seconds — no manual amount entry, no reconstructing UPI history later.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-%5E3.11.5-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android_16%2B-3DDC84?logo=android&logoColor=white)](https://developer.android.com)
[![State](https://img.shields.io/badge/State-Riverpod-542A52)](https://riverpod.dev)
[![DB](https://img.shields.io/badge/DB-Drift_%2B_SQLite-003B57)](https://drift.simonbinder.eu)
[![Privacy](https://img.shields.io/badge/Privacy-Local--first_%E2%80%A2_No_cloud-121212)](./PRD.md)
[![Version](https://img.shields.io/badge/Version-1.0.0%2B1-FFB39A)](./pubspec.yaml)

---

## Why Luma exists

The usual flow fails:

1. You pay via UPI.
2. Bank sends an SMS.
3. You think “I’ll record this later.”
4. You forget.
5. Days later you dig through UPI history trying to remember what ₹200.90 was for.

Luma changes it to:

```
UPI payment → Bank SMS → Luma detects → Pending expense + notification → Tap → Tap category → Done
```

The amount, merchant, time, and reference are already filled in from the SMS. You normally only pick a category and optionally add a note.

Full product thinking lives in [`PRD.md`](./PRD.md). Build rules live in [`SPEC.md`](./SPEC.md).

---

## Features

### Automatic detection
- Native Android `BroadcastReceiver` for `android.provider.Telephony.SMS_RECEIVED`
- Fast, lightweight receiver — heavy parsing is delegated off the main path
- Generic transaction parser with modular bank-specific extension points
- Extracts amount, type (debit / credit / unknown), merchant, timestamp, reference, account hint, raw SMS
- Supports `Rs.200`, `Rs 200`, `INR 200`, `₹200`, `₹200.90`, etc., stored as integer minor units (paise) — never floats

### Anti-forgetting UX
- Every new expense starts as `PENDING`
- High-visibility notification immediately after detection:
  - `₹200.90 spent at Google India Dig — Tap to categorize`
  - Tapping opens the exact expense, not just the home screen
- Dedicated pending queue on Home (“Needs attention”)
- Optional daily audit at 21:00: “You have X expenses waiting to be completed”
- Ideal flow is 3 taps: notification → suggested category → Save

### Learning, not AI hype
- Fully local, deterministic frequency learning per normalized merchant
- Normalization: lowercase, trim, collapse whitespace, strip noise — `GOOGLE INDIA DIG` == `google india dig`
- Suggestion = highest-frequency category for that merchant
- Confidence = `highestCount / totalCount` (internal only, no ML jargon in UI)
- Learns from your final choice, not its own suggestion — you can always override

### Manual expenses
- Same `Expense` model for cash, missed SMS, corrections, and backfills
- Amount (required), merchant (optional), category (required), date/time, note

### History that’s actually usable
- Date-grouped list, search by merchant/note, category filter
- Expense detail shows amount, merchant, category, time, note, reference, source (`SMS detected` / `Manually added`)
- Raw SMS hidden under advanced/debug only
- Edit amount, merchant, category, note, date/time. Delete supported.

### Excel export that respects your workflow
- Real `.xlsx` generation, stable column order:
  `Date | Time | Amount | Merchant | Category | Note | Transaction Type | Reference Number`
- Two modes:
  - **Full History** — everything
  - **Since Last Export** — only `lastExportedAt == null` or `updatedAt > lastExportedAt`
- Filename: `Luma_Expenses_YYYY-MM-DD_HH-mm.xlsx`
- Correct transactionality: query → generate → verify file → update export timestamps → open share sheet
- Share via Android share sheet (`application/vnd.openxmlformats-officedocument.spreadsheetml.sheet`) — pick Gmail or anything else. No SMTP, no credentials in Luma.
- Tracking means “included in a file Luma generated”, not “delivered to recipient” — Luma never claims Gmail sent it.

### Privacy by architecture
- No backend. No accounts. No sync. No analytics. No crash reporters. No remote logging.
- All SMS content, expenses, categories, notes, merchant profiles, export history, and settings stay in app-private storage
- No `INTERNET` permission in app code — network is only touched if you explicitly share via another app like Gmail
- Production builds never log full SMS bodies, account numbers, or references

### Premium dark UI
Dark-first, calm, minimal — designed to feel personal, not like a bank ERP.

| Token | Value | Used for |
|---|---|---|
| Background | `#121212` | Scaffold, large empty areas |
| Surface | `#1E1E1E` | Cards, list items, dashboard |
| Elevated | `#2C2C2C` | Sheets, dialogs, inputs |
| Plum | `#542A52` | Brand, selected states, nav indicator |
| Peach | `#FFB39A` | Primary CTA, high emphasis |
| Text primary | `#F0F0F0` | Amounts, headings |
| Text secondary | `#A0A0A0` | Merchants, dates, subtitles |
| Border | `#333333` | Dividers, input outlines |
| Success | `#4CAF50` | Save / export success |
| Error | `#CF6679` | Delete, validation, failures |

- Material 3 foundation, centralized in `lib/app/theme/` (`AppColors`, `AppRadii`, `AppSpacing`, `buildLumaTheme()`)
- No `ColorScheme.fromSeed()` shortcuts, no raw `Color(0xFF...)` scattered in widgets
- Large readable amounts, rounded cards (16), pill controls (24), generous spacing, subtle motion only
- Reusable components: `ExpenseCard`, `PendingExpenseCard`, `AmountDisplay`, `CategoryChip`, `PrimaryButton`, `PlumButton`, `SectionHeader`, `SummaryCard`, `EmptyState`, `LumaNavBar`

---

## How it works

```
┌─────────────┐     ┌──────────────────┐     ┌───────────────────┐     ┌──────────────┐
│ Bank SMS    │────▶│ SmsInboxReceiver │────▶│ SmsTransaction    │────▶│ Expense      │
│ (Android)   │     │ (Kotlin, native) │     │ Parser (Dart)     │     │ Controller   │
└─────────────┘     └──────────────────┘     └───────────────────┘     └──────┬───────┘
                                                                              │
                                        ┌─────────────────────────────────────┼──────────────────┐
                                        │                                     │                  │
                                 Duplicate check                        Merchant learning   Notification
                                 (ref no → fingerprint →                (suggest category)  (flutter_local_
                                  amount+merchant+time)                                     notifications)
                                        │                                                        │
                                        ▼                                                        ▼
                                 Drift (SQLite)                                          Tap → Complete
                                 local-only                                              expense sheet
```

Duplicate prevention order:
1. `referenceNumber` if present (preferred unique ID)
2. `smsFingerprint` (SHA-normalized hash via `crypto`)
3. `amount + merchant + timestamp` window match

If a match is found, no second expense is created.

---

## Tech stack

| Layer | Choice |
|---|---|
| Framework | Flutter + Dart (`sdk: ^3.11.5`), Material 3 |
| State | `flutter_riverpod ^2.6.1` — business logic stays out of widgets |
| Local DB | `drift 2.26.0` + `sqlite3_flutter_libs`, `path_provider`, `path` |
| SMS permission | `permission_handler ^13.0.2` + native Kotlin receiver |
| Notifications | `flutter_local_notifications ^22.3.1`, channels `expense_alerts` (high) + `daily_audit` |
| Hashing | `crypto ^3.0.6` for SMS fingerprints |
| Codegen | `drift_dev`, `build_runner` |
| Lint | `flutter_lints ^6.0.0` |

Platform target: **Android 16+, private sideloaded APK**. iOS / desktop / web folders are default Flutter scaffolding so the project stays runnable everywhere, but SMS detection is Android-only.

---

## Project structure

```
lib/
  app/
    app.dart                 # LumaApp, Home / History / Export / Settings, sheets
    theme/app_theme.dart     # AppColors, radii, spacing, buildLumaTheme()
    widgets/                 # amount_display, category_chip, expense_cards,
                             # luma_buttons, luma_nav_bar, onboarding_sheet,
                             # section_header, sms_permission_flow, summary_card
  application/
    expense_controller.dart  # processSms, complete, addManual, dedupe, totals
  core/
    utils/format.dart        # amount + time formatting
    utils/sms_fingerprint.dart
  data/
    database/
      luma_database.dart     # Drift tables: Expense, MerchantProfile, Category,
      luma_database.g.dart   # AppSettings, ExportRecord
      seed.dart              # default categories + settings
    repositories/
      drift_expense_repository.dart
      memory_expense_repository.dart  # fallback + tests
    services/
      app_settings_store.dart
      drift_merchant_learning.dart
  domain/
    entities/expense.dart    # amount in minor units, DEBIT/CREDIT/UNKNOWN,
    entities/category.dart   # PENDING/COMPLETED/IGNORED, SMS/MANUAL
    repositories/expense_repository.dart
    services/
      sms_transaction_parser.dart
      merchant_normalizer.dart
      merchant_learning.dart
      category_suggester.dart
  services/
    notification/notification_service.dart
    permissions/sms_permission_service.dart
  main.dart                  # Drift init → seed → controller → ProviderScope,
                             # falls back to in-memory if DB fails

android/app/src/main/kotlin/com/example/luma/
  MainActivity.kt
  SmsInboxReceiver.kt        # SMS_RECEIVED → MethodChannel luma/sms drainSmsQueue

test/
  domain_test.dart            # normalizer, parser, learning, dedupe
  drift_test.dart
  notification_test.dart
  permission_test.dart
  widget_test.dart
```

Architecture follows `PRD` / `SPEC`:

```
Presentation → Application (Riverpod) → Domain → Repositories → Local Data / Android services
```

---

## Getting started

### Prerequisites
- Flutter 3.x (`flutter doctor` clean)
- Android SDK + a physical Android device (emulator can’t receive real bank SMS easily)
- Dart `^3.11.5`

### Run

```bash
flutter pub get
flutter run
```

### Codegen (Drift)

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Analyze + test

```bash
flutter analyze
flutter test
```

### Build a release APK for sideloading

```bash
flutter build apk --release
# output: build/app/outputs/flutter-apk/app-release.apk
```

Install the APK on your phone manually — this is a private app, not a Play Store release.

---

## Permissions & onboarding

1. First launch explains: *“Luma reads incoming transaction SMS messages so it can automatically detect expenses and remind you to record them.”*
2. Then requests `android.permission.RECEIVE_SMS` at runtime.
3. If denied: manual tracking still works, and Home shows `Automatic transaction detection is disabled`.
4. Sideloaded apps on newer Android may hit **Restricted Settings** — if the system blocks the grant, Luma shows steps to allow restricted settings for Luma in system Settings first. It never tries to bypass Android security.
5. Notification permission is requested for `expense_alerts` + `daily_audit`.

---

## Export format

Generated file: `Luma_Expenses_2026-09-25_20-15.xlsx`

| Date | Time | Amount | Merchant | Category | Note | Transaction Type | Reference Number |
|---|---|---|---|---|---|---|---|
| 2026-09-25 | 13:03 | 200.90 | Google India Dig | Subscriptions | domain renewal | DEBIT | 123456789 |

- Amounts are numeric spreadsheet values where practical, not strings.
- Incremental export includes `lastExportedAt == null` OR `updatedAt > lastExportedAt`, then stamps `lastExportedAt = export timestamp` only after the file is verified.
- Failed generation shows `Could not create the Excel file.` and touches no export state.

---

## Offline & data safety

These work in airplane mode: viewing, adding, editing, categorizing, learning merchant preferences, receiving/processing SMS when Android delivers it, notifications, XLSX generation.

Financial data lives in app-private storage. Only the XLSX you explicitly generate is exposed to the share sheet.

---

## Testing

```bash
flutter test
```

Covered:
- Amount parsing (`₹200` → `20000`, `₹200.90` → `20090`)
- Merchant parsing + missing merchant / missing reference handling
- Debit vs credit vs unrelated SMS (OTP must be ignored)
- Duplicate detection (same ref, same fingerprint, same amount+merchant+time)
- Merchant normalization (`Google India Dig` == `GOOGLE-INDIA DIG`)
- Category learning + suggestion threshold
- Export filtering: empty, single, multiple, full vs incremental, modified-after-export, failed export
- Notification payload → correct expense routing
- Permission states including denied / permanently denied / restricted

---

## Roadmap (deliberately narrow)

V1 will **not** include: bank APIs, UPI APIs, cloud sync, accounts, social, shared budgets, investments, credit scores, ads, subscriptions, crypto, recommendations, chatbots, or server ML. See `PRD.md` §27.

What *is* on the table after V1 ships:
- Keyword rules for suggestions
- Export preferences polish
- Better parser coverage as real SMS formats are observed
- Intentionally-designed light theme (no auto-invert)

Definition of done is checklist-driven in `SPEC.md` §55 — from “SMS produces a pending expense” through “incremental export has no duplicates” to “works without internet”.

---

## Docs

- [`PRD.md`](./PRD.md) — what Luma is, who it’s for, pending workflow, export behavior, UX philosophy
- [`SPEC.md`](./SPEC.md) — how to build it: models, parser, duplicate detection, notifications, learning algorithm, theme tokens, tests, privacy constraints

If the docs and the code disagree, the docs win — update the code.

---

## Privacy note

Luma is built for one person’s private finances. There is no server to send data to, even if you wanted to. If you fork this, keep it that way: don’t add analytics, crash reporting, or remote logging without a very good reason and explicit consent.

---

Built with Flutter, Drift, and a healthy distrust of “I’ll write it down later.”
