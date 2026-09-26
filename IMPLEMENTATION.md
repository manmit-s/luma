# Luma — Implementation Checkpoint & Continuation Plan

> **Status: Phase 6 complete — release APK built, device sweep is yours.**
> Last verified: `flutter analyze` clean (1 pre-existing info in
> `section_header.dart`), `flutter test` **61/61 passing**,
> `flutter build apk --release` succeeds
> (`build/app/outputs/flutter-apk/app-release.apk`, 51.3 MB, debug-key signed).
> Resume command: `flutter analyze --no-pub`, then `flutter test`.
> Spec sources of truth: `PRD.md`, `SPEC.md`. Do not invent features outside them.
>
> **Build fixes applied (were blocking, now resolved):**
> `permission_handler` pinned to `^11.4.0` (v13's android module demands
> Gradle 9 / AGP 9; our toolchain is Gradle 8.14 / AGP 8.11.1 / KGP 2.2.20 —
> do not upgrade past v11 without upgrading the whole toolchain), plus core
> library desugaring (`desugar_jdk_libs:2.1.4`) required by
> `flutter_local_notifications`' AAR metadata.

## 1. Where we are

### Phase 0 — UI consistency cleanup (DONE)

- Centralized theme in `lib/app/theme/app_theme.dart`: `AppColors`,
  `AppRadii(card 16 / control 24 / compact 12)`, `AppSpacing` + screen/card
  padding tokens. Input fill corrected to `#2C2C2C`; chip/switch/button/
  bottom-sheet/nav theming added; system typography (no bundled font).
- **Deviation from SPEC 44.4 (user choice, keep):** peach `#FFB39A/#121212`
  is the primary CTA everywhere (`PrimaryButton`); plum `#542A52` is the
  brand/selection surface. Do not "fix" this back to plum without asking.
- Reusable widgets in `lib/app/widgets/`: `amount_display.dart`,
  `category_chip.dart` (+`CountBadge`), `luma_buttons.dart`
  (`PrimaryButton` peach / `PlumButton`), `expense_cards.dart`
  (`ExpenseCard` + `PendingExpenseCard` with peach-border pending
  distinction), `summary_card.dart`, `section_header.dart` (+`EmptyState`).
- Formatting centralized in `lib/core/utils/format.dart`: `formatAmount`
  (separators, paise-int safe), `formatTime` (`23 Sep, 1:03 PM`),
  `formatDayLabel` (Today/Yesterday), `greetingFor`, single
  `merchantLabel`/`categoryName` fallbacks.
- `lib/app/app.dart` de-duplicated: one screen padding, 8px list gaps,
  sentence-case sheet titles, integer paise parsing (no float money),
  live export counts (no fake `14/142` numbers), controller totals now
  year-aware.
- Pill dock `lib/app/widgets/luma_nav_bar.dart`: floating dock
  (`H20` margins, `H72`, `R28`, surface 82% + blur 16, 1px border, one soft
  shadow), 5 slots `Home | History | + | Export | Settings` with `+`
  centered, pending badge on Home (`N`/`9+`), **no haptics by design**,
  `extendBody: true` + 128px list bottom padding. Export is a **page**
  (`_ExportPage`), not a sheet; History has no Export button.

### Phase 1 — Persistence with Drift/SQLite (DONE)

- **Decision (locked): Drift 2.26.0 + drift_dev 2.26.0**, NOT `^2.35`
  (`drift >=2.35` breaks version solving against Flutter 3.41 / meta 1.17).
  Deps: `sqlite3_flutter_libs`, `path_provider`, `path`, `build_runner`.
- Schema `lib/data/database/luma_database.dart` (+ generated `.g.dart`,
  regen via `dart run build_runner build --delete-conflicting-outputs`):
  `expenses`, `merchant_profiles` (JSON counts), `categories` (10 defaults),
  `app_settings` (id=1, audit 21:00, onboarding flag), `export_records`.
- `lib/data/database/seed.dart` seeds categories + settings row only.
  **Fresh installs start with empty history** (old 4 demo expenses removed).
- `lib/data/repositories/drift_expense_repository.dart`: desc-ordered
  `getAll`, triple-signal duplicate (ref → fingerprint → amount+merchant+±5min),
  autoIncrement save (`id<=0` insert), `queryUnexported`
  (`lastExportedAt NULL OR updatedAt>lastExportedAt`), `markExported`.
  `MemoryExpenseRepository` kept + extended for tests.
- `CategorySuggester` interface (`domain/services/category_suggester.dart`);
  `MerchantLearning.learn` is now async; `DriftMerchantLearning`
  (`data/services/drift_merchant_learning.dart`) caches sync suggestions and
  writes JSON counts through to `merchant_profiles`.
- `ExpenseController` depends on abstractions; added `updateExpense`,
  `deleteExpense`, `markExported`, `unexported` getter.
- `lib/main.dart` async bootstrap: open Drift → seed → load learning →
  `controller.load()` → `ProviderScope` overrides; Memory fallback on failure.
  Tests pump `LumaApp` directly (Memory default), unaffected.
- Tests `test/drift_test.dart` (5): seed, roundtrip, SMS dedupe, unexported →
  mark → edit-re-inclusion, learning persistence.

### Phase 2 — Notifications + tap-to-open (DONE)

- Dep `flutter_local_notifications 22.3.1` (uses **v22 named-arg API**:
  `initialize(settings:)`, `show(id:, title:, ...)`, `cancel(id:)`).
- `lib/services/notification/notification_service.dart`: channels
  `expense_alerts` (High) + `daily_audit` (reserved); per-expense notice
  (`₹X spent at Merchant — tap to categorize`, payload = expense id);
  ongoing low-importance pending summary (single id, cancelled at 0);
  cold-start `consumeLaunchPayload()`; fully no-op-safe pre-init
  (tests/desktop). Never throws — store always wins (SPEC 38).
- `app.dart`: `lumaNavigatorKey`; `_handleNotificationTap` (`pending` → Home,
  numeric → Home + post-frame `showCompleteExpense`); drain-queue → notify
  each new pending → sync summary; controller listener keeps summary fresh.
- Native immediacy `SmsInboxReceiver.kt`: after queueing, posts generic
  `Luma — New transaction detected…` on the same channel with tap →
  `MainActivity` (covers app-killed case; Dart upgrades to rich notices on
  open). All receiver work in try/catch; queue write always first.
- Manifest: added `POST_NOTIFICATIONS`. No `INTERNET` added.
- Tests `test/notification_test.dart` (2): pre-init no-throw, payload
  round-trip.

### Phase 3 — Onboarding + SMS permission (DONE, current tip)

- Dep `permission_handler`.
- `services/permissions/sms_permission_service.dart`: states
  `granted/denied/permanentlyDenied/restricted/unavailable`, all
  `MissingPluginException`-safe.
- `data/services/app_settings_store.dart`: single-row settings access;
  null-DB = already-onboarded (tests never blocked).
- `app/widgets/onboarding_sheet.dart`: non-dismissible first-launch sheet
  (SPEC 8 rationale verbatim + on-device privacy row, Enable/Manual);
  `showRestrictedSettingsSheet` 3-step sideload guide (SPEC 40).
- `app/widgets/sms_permission_flow.dart`: shared `requestSmsPermissionFlow`
  + `SmsDisabledBanner`.
- Wiring: `appSettingsStoreProvider` (+ override in `main.dart`);
  `_maybeShowOnboarding()` post-load (400ms settle, persists either path);
  Home is stateful + resume-observer with banner for denied/blocked/
  restricted only; Settings is consumer-stateful with live toggle +
  per-state subtitle + tap-retry.
- Tests `test/permission_test.dart` (2): null-store skip, off-device
  never-throws.
- Full suite: domain (5 incl. SMS dedupe) + drift (5) + notification (2) +
  permission (2) + export (5) + audit (5) + manage (5) + widget (4 nav/dock/
  detail/grouping) = **34 passing**.

## 2c. Phase 5 — history detail/edit + daily audit + hardening (DONE)

- Detail sheet `showExpenseDetail` (SPEC 28): amount, merchant, category chip,
  day+time, note card, Type/Reference/Source/Export rows, raw SMS collapsed
  under `Raw SMS (debug)`; Edit + error-outlined Delete. `openExpense()`
  routes pending → complete-sheet, everything else → detail (Home recent,
  History rows, notification taps).
- Edit sheet `showEditExpense`: prefilled amount/merchant/category/note,
  integer-paise validation, saves via `updateExpense` (bumps `updatedAt` →
  auto re-export). Delete: error-color confirm dialog → `deleteExpense`.
- History: `groupExpensesByDay` (moved to `core/utils/format.dart` for
  testability) renders Today/Yesterday/date headers; filter row now shows all
  10 categories.
- Daily audit (exact, user chose exact over inexact): fully native
  `DailyAudit.kt` — `setExactAndAllowWhileIdle` 21:00 (falls back to inexact
  when the OS withholds exact permission), counts `status = 0` rows
  read-only from `luma.sqlite`, notifies `Luma Daily Check` on
  `daily_audit` only when count > 0, then rolls the schedule forward.
  `BOOT_COMPLETED/MY_PACKAGE_REPLACED` reschedules without opening the app;
  Dart `DailyAuditService` bridges toggle/time over `luma/sms`
  (`scheduleAudit`/`cancelAudit`), `MainActivity` extended to `when()`.
  Settings toggle persists to `app_settings` (+ new store accessors) and
  schedules/cancels; app start re-asserts the alarm (heals reboots on open).
  Manifest: `SCHEDULE_EXACT_ALARM` + `USE_EXACT_ALARM` +
  `RECEIVE_BOOT_COMPLETED`, `DailyAuditReceiver` (non-exported, fire + boot
  filters).
- SMS hardening: merchant extraction strips trailing punctuation and rejects
  <2-char scraps (never invents a merchant). Privacy audit: no
  print/debugPrint/log in lib, no `INTERNET` in the release manifest
  (`profile/` manifest's INTERNET is Flutter's dev-only default), no network
  or analytics deps.
- Tests: `audit_test.dart` (4 next-fire boundaries + channel no-throw),
  `manage_test.dart` (edit persistence, edit→re-export, delete, 2 grouping),
  widget detail-open→edit + history-grouping (large 800×1200 test surface to
  avoid fold issues).

## 2b. Phase 4 — XLSX export + share (DONE)

- Deps `excel 4.0.6 + share_plus 13.3.1` (uses current `SharePlus.instance.share(
  ShareParams(files:, text:))` API; static `Share.shareXFiles` is deprecated).
  share_plus bundles its own FileProvider — no manifest work needed. No
  `INTERNET` in manifest, no network deps; own code makes zero network calls.
- `lib/services/export/export_service.dart`: stable columns
  Date/Time/Amount/Merchant/Category/Note/Transaction Type/Reference Number;
  Amount as numeric `DoubleCellValue`; filename
  `Luma_Expenses_YYYY-MM-DD_HH-mm.xlsx`; SPEC 34 sequence
  query → generate → verify → `markExported` → share; failure throws
  `ExportException('Could not create the Excel file.')`; empty throws
  mode-specific message; writes to temp dir; records to `export_records`
  (best-effort, never fails the export).
- `_ExportPage` is stateful with per-button `Generating…` state, success
  snackbar + `controller.load()` refresh + share sheet, error snackbars.
  Uses `controller.unexported` (includes edited-after-export) for counts.
- Tests `test/export_test.dart` (5): empty throws unmarked, single-file
  readable with header/columns/numeric amount + marks persisted, Day1/Day2
  incremental no-dupe + full history, edited re-inclusion, oldest-first
  ordering. `MemoryExpenseRepository.clearForTest()` added for isolation.
- Post-Phase-4 fixes: `main.dart` fallback scope now also provides an
  `ExportService` (previously a failed Drift init left Generate XLSX
  silently dead); `_runExport` distinguishes missing-service / generation /
  share failures with distinct snackbars + `debugPrint` lines; file writing
  is injectable (`writeFile`, sync variant for widget tests — real dart:io
  awaits deadlock under flutter_test's FakeAsync).
- `test/export_ui_test.dart`: Export page + real service end-to-end
  (generation, file, marks), share step stubbed (no channel in tests).

## 2. Architecture map (what lives where)

```
lib/
  main.dart                      async bootstrap + provider overrides
  app/
    app.dart                     LumaApp, 4 tabs, sheets, _ExportPage
    theme/app_theme.dart         tokens + Material3 theme
    widgets/                     amount, chips, buttons, cards, summary,
                                 section header/empty, nav dock, onboarding,
                                 sms flow
  application/expense_controller.dart   UI-facing state, SMS ingest
  domain/
    entities/                    Expense, Category (pure)
    services/                    parser, normalizer, learning, suggester iface
    repositories/                ExpenseRepository iface (+export methods)
  data/
    database/                    drift schema + seed (+ generated .g.dart)
    repositories/                drift + memory implementations
    services/                    drift learning, app-settings store
  services/
    notification/                local notifications (Dart side)
    permissions/                 SMS permission wrapper
  core/utils/                    sms_fingerprint, format
android/app/src/main/
  AndroidManifest.xml            RECEIVE_SMS + POST_NOTIFICATIONS +
                                 SCHEDULE/USE_EXACT_ALARM + BOOT_COMPLETED
  kotlin/.../SmsInboxReceiver.kt queue + generic instant notice
  kotlin/.../DailyAudit.kt       exact 21:00 audit + boot reschedule
  kotlin/.../MainActivity.kt     drainSmsQueue + scheduleAudit/cancelAudit
```

## 3. Locked decisions (do not revisit without asking)

1. Peach CTAs everywhere; plum = selection/brand (SPEC deviation, §1).
2. Drift 2.26.0 pinned (see §1 for why).
3. Empty history on fresh install (no demo seeds).
4. Export = full page in dock; `+` centered; no nav haptics.
5. Daily audit = **exact 21:00 alarm** (user chose exact over inexact).
6. No backend, no analytics, no `INTERNET` (SPEC 36–37).
7. Dark theme is canonical; no custom light theme for v1 (SPEC 44.8).

## 4. What to do next — Phase 6: test matrix + release (SPEC 49–52, 55)

> Phases 4–5 are done and both APKs compile (incl. `DailyAudit.kt`).
> Phase 6 test work is done (50/50) plus 3 sheet-lifecycle regression tests , 1 SMS-watch chain test , 4 SBI-format regression tests and 3 name-feature tests. What remains is all on-device.

## 4b. SPEC 55 Definition-of-Done walk (code-verified vs needs-device)

Code-verified (tests / analyze / builds — done):
[x] App launches (widget tests + both APKs built)
[x] Database works offline (Drift; airplane-mode safe by construction)
[x] Transaction SMS is parsed (spec_matrix: amounts, types, refs)
[x] Expense is stored (repository + controller tests)
[x] Duplicate SMS creates no duplicate (ref / fingerprint / ±5-min window)
[x] Expense can be categorized (complete flow, ≤3 taps: tap notice → tap
category → Save)
[x] Merchant learning works (frequency + persistence across instances)
[x] Manual expenses work (controller + sheets)
[x] History works (grouped, search merchant+note, all-category filter)
[x] Pending expenses work (badge, summary card, summary notification)
[x] XLSX full export works (readable file, stable columns, numeric amounts)
[x] XLSX incremental export works without duplicates (Day1/Day2 test)
[x] Export state is persisted (marks only after verified generation)
[x] Modified expenses handled correctly (re-inclusion tests)
[x] App works without internet (no INTERNET perm, zero network calls)
[x] No financial data sent to a Luma backend (privacy audit §2c)
[x] Core unit tests pass (61/61)
[—] Light mode / dark mode: N/A per SPEC 44.8 (dark is canonical)

Needs your device (Android 16, airplane mode on where noted):
[ ] Onboarding + SMS permission incl. restricted-settings path (fresh
install → sheet → Enable → system grant; then deny-twice path)
[ ] Incoming SMS detected end-to-end (send PRD 7 sample SMS from another
phone; check instant native notice even with app killed)
[ ] Rich notification appears and tap opens the exact expense
[ ] Daily audit: set device clock to 20:59 with a pending expense → 21:00
`Luma Daily Check`; repeat with zero pending → silence; reboot → alarm
re-armed (fires next 21:00 without opening the app)
[ ] Share sheet opens from both Export buttons; Gmail receives a valid xlsx
[ ] Process restart (force-stop → relaunch: data + sums intact) and reboot
[ ] Full airplane-mode sweep: add/edit/delete/categorize/export all work;
then incremental export deltas stay correct across days

## 4c. Sideload + sweep guide (copy-paste ready)

```
# 1. Install (APK is debug-key signed — fine for private sideload)
adb install -r build/app/outputs/flutter-apk/app-release.apk
# 2. Watch native logs while testing SMS/alarm paths
adb logcat -c; adb logcat | Select-String "Luma|SmsInbox|DailyAudit"
# 3. Inspect the on-device database if numbers ever look wrong
adb exec-out run-as com.example.luma ls -l app_flutter/
```

## 7. Resume checklist (first session back)

- [ ] `flutter analyze --no-pub` (expect only `section_header.dart` info).
- [ ] `flutter test` (expect 61/61).
- [ ] Keep `drift: 2.26.0` + `permission_handler: ^11.4.0` pinned (see top note);
  run codegen after any schema change.
- [ ] Never add `INTERNET`, Firebase, analytics, or cloud DBs.
