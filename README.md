# Luma — Personal Expense Memory

> You should never have to remember to remember an expense.

Luma is a private, local-first Android expense tracker built with Flutter. It watches incoming bank transaction SMS, creates a pending expense automatically, and nudges you instantly so you can categorize it in seconds — no manual amount entry, no reconstructing UPI history later.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-%5E3.11.5-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android_16%2B-3DDC84?logo=android&logoColor=white)](https://developer.android.com)
[![State](https://img.shields.io/badge/State-Riverpod-542A52)](https://riverpod.dev)
[![DB](https://img.shields.io/badge/DB-Drift_%2B_SQLite-003B57)](https://drift.simonbinder.eu)
[![Privacy](https://img.shields.io/badge/Privacy-Local--first_%E2%80%A2_No_cloud-121212)](./PRD.md)
[![Version](https://img.shields.io/badge/Version-1.1.0%2B3-FFB39A)](./pubspec.yaml)

---
[![promotion-banner.png](https://i.postimg.cc/L5jWRCkR/promotion-banner.png)](https://postimg.cc/7JY9nNQQ)
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

### Automatic SMS detection
- Native Android `BroadcastReceiver` for `android.provider.Telephony.SMS_RECEIVED`
- Queues detected messages for processing when the app resumes or opens
- Parser coverage for SBI, HDFC, ICICI, Axis, Kotak, PNB, BOB, and many more Indian bank formats
- Handles debit, credit, and unknown direction without guessing credit messages as debit
- Extracts amount, merchant, timestamp, reference, bank/account hints, and raw SMS
- Supports rupee and INR formats, comma-separated amounts, paise, and 12/24-hour timestamps
- Stores money as integer minor units (paise), never as floating-point values
- Triple-signal duplicate prevention: reference number, normalized SMS fingerprint, then amount/merchant/time window

### Money and payment sources
- Track a physical cash wallet and named bank/wallet sources
- Assign opening balances, account suffixes, nicknames, and active state
- Match incoming SMS to configured sources using bank and account hints
- Record internal transfers between sources
- View source-level income, expenses, transfer activity, closing balance, and an overall financial summary
- Initial cash starting balance is collected during onboarding

### Expense workflow
- Every SMS transaction starts in the pending queue until reviewed
- Complete, ignore, edit, or delete pending and completed expenses
- Add manual expenses for cash, missed SMS entries, corrections, and backfills
- Search history and filter by category
- Date-grouped history with expandable expense details and optional raw SMS debug view
- Re-edited completed expenses are included again in the next incremental export

### Smart local category learning
- Deterministic merchant frequency learning stored locally in Drift
- Normalizes merchant names before matching
- Suggests the category most frequently chosen for that merchant
- Learns from the final user choice rather than the suggested choice

### Subscriptions and expected payments
- Add monthly or yearly subscriptions with merchant patterns
- Track active, trial, cancelled, and expired statuses
- Generate a forward payment horizon and match debit SMS to expected payments
- Surface amount mismatches and missed or upcoming renewals
- Optional cancellation and payment reminder settings

### Notifications and audit
- Tap-to-open notifications for individual pending expenses
- Ongoing pending-summary notification
- Native SMS receiver notice for app-killed detection
- Optional native 21:00-style daily audit, configurable in Settings
- Boot and app-launch rescheduling so audit reminders heal after reboot

### Category management and themes
- Add, rename, reorder, and delete custom categories
- Default categories are protected from accidental deletion
- Icon and color selection for custom categories
- Four themes: Luma Original (Plum × Peach), Rosé Grove, Lavender Latte, and Sage Soufflé

### Excel export, backup, and restore
- Full history export or incremental export since the last export
- Multi-sheet `.xlsx` with ledger, accounts, wallets, transfers, and financial summary worksheets
- Opening/closing balance and running-balance calculations
- Stable numeric amount storage and chronological rows
- Saves export copies and a full-backup copy where supported
- Android share sheet integration through `share_plus`
- Restore legacy or multi-bank backups by file picker or detected backup path

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
[![Luma-Offline-Finance-Flow.png](https://i.postimg.cc/Ght99p6k/Luma-Offline-Finance-Flow.png)](https://postimg.cc/CzywQwh1)
<!-- ```
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
``` -->

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
| State | `flutter_riverpod ^2.6.1` — controllers keep UI and business logic separate |
| Local DB | `drift 2.26.0` + `sqlite3_flutter_libs`, `path_provider`, `path` |
| SMS permission | `permission_handler ^11.4.0` + native Kotlin receiver |
| Notifications | `flutter_local_notifications ^22.3.1`; channels `expense_alerts` and `daily_audit` |
| Export/backup | `excel ^4.0.6`, `share_plus ^13.3.0`, `file_picker ^13.4.0` |
| Hashing | `crypto ^3.0.6` for normalized SMS fingerprints |
| Codegen | `drift_dev 2.26.0`, `build_runner ^2.5.4` |
| Assets/UI | `flutter_svg ^2.0.17`, Material 3, centralized theme tokens |
| Lint | `flutter_lints ^6.0.0` |

Platform target: **Android 16+, private sideloaded APK**. iOS / desktop / web folders are default Flutter scaffolding so the project stays runnable everywhere, but SMS detection is Android-only.

---

## Project structure

```
lib/
  app/
    app.dart                 # Luma shell, tabs, onboarding, sheets, backup restore
    providers.dart           # Riverpod controller and service providers
    theme/app_theme.dart     # palettes, tokens, and Material 3 theme
    widgets/                 # balances, cards, chips, onboarding, categories,
                             # subscriptions, sources, permission flow, and nav UI
  application/
    expense_controller.dart
    category_controller.dart
    source_controller.dart
    subscription_controller.dart
  core/
    utils/format.dart
    utils/sms_fingerprint.dart
  data/
    database/                # Drift schema, migrations, seed, generated code
    repositories/            # Drift and memory implementations
    services/                # settings and merchant learning persistence
  domain/
    entities/                # expenses, categories, sources, transfers, subscriptions
    repositories/            # repository contracts
    services/                # SMS parser, learning, subscriptions, matching
  services/
    audit/                   # native-style daily audit bridge
    export/                  # XLSX export, backup, and restore
    notification/            # local notification and payload routing
    permissions/             # runtime SMS permission handling
    sms/                     # native queue drain and inbox scan
  main.dart                  # Drift bootstrap and memory fallback

android/app/src/main/kotlin/com/example/luma/
  MainActivity.kt             # SMS queue, audit schedule, settings bridge
  SmsInboxReceiver.kt         # SMS_RECEIVED queue + immediate notice
  DailyAuditReceiver.kt       # exact audit, reboot and package reschedule
  SmsInboxScanner.kt          # inbox scan support

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

Generated files use names such as `Luma_Expenses_2026-09-25_20-15.xlsx` and `luma_backup_latest.xlsx`.

The workbook contains:

- **Expenses** — summary, ledger, running balance, date, time, merchant, category, direction, amount, running balance, note, reference, and payment source
- **Accounts** — bank sources and account metadata
- **Wallets** — wallet sources and opening balances
- **Transfers** — source-to-source internal transfers
- **Financial Summary** — opening/income/expenses/transfers/closing balance by source

Additional behavior:

- Full history exports every expense.
- Incremental export includes `lastExportedAt == null` OR `updatedAt > lastExportedAt`.
- Export timestamps are committed only after the workbook is written and verified.
- Backup restore supports current multi-source workbooks and legacy pre-multi-bank backups.
- Amounts are numeric spreadsheet values; financial values are never written from floating-point arithmetic.

---

## Offline & data safety

These work in airplane mode: viewing, adding, editing, categorizing, learning merchant preferences, receiving/processing SMS when Android delivers it, notifications, XLSX generation.

Financial data lives in app-private storage. Only the XLSX you explicitly generate is exposed to the share sheet.

---

## Testing

```bash
flutter test
```

The test suite spans 19 test files and covers:
- Amount, date, merchant, reference, debit/credit, and unrelated-SMS parsing
- Duplicate detection across reference, fingerprint, and time-window signals
- Merchant normalization and deterministic category learning
- Drift persistence, migrations, edits, deletes, and incremental export filtering
- XLSX generation, running balance, backup save locations, legacy restore, and multi-source restore
- Notifications and tap payload routing
- SMS permissions and restricted-settings behavior
- Onboarding and initial balance
- Categories, themes, subscriptions, and source-of-money balances
- SMS inbox watch and scan behavior
- Widget sheets and navigation surfaces

---

## Scope boundaries

Luma remains local-first. It does not add bank APIs, UPI APIs, cloud sync, accounts, analytics, ads, remote ML, or server-side data storage.

The implemented roadmap now also includes subscriptions, multi-source balances, internal transfers, category themes, and XLSX backup/restore. Future parser improvements should be driven by real SMS formats and kept offline unless the product explicitly changes scope.

---

## Docs

- [`PRD.md`](./PRD.md) — what Luma is, who it’s for, pending workflow, export behavior, UX philosophy
- [`SPEC.md`](./SPEC.md) — original technical constraints and implementation rules
- [`IMPLEMENTATION.md`](./IMPLEMENTATION.md) — implementation history and continuation notes

If the docs and the code disagree, the docs win — update the code.

---

## Privacy note

Luma is built for one person’s private finances. There is no server to send data to, even if you wanted to. If you fork this, keep it that way: don’t add analytics, crash reporting, or remote logging without a very good reason and explicit consent.

---

Built with Flutter, Drift, and a healthy distrust of “I’ll write it down later.”
