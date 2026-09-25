# Luma
## Technical Implementation Specification

Version: 1.0
Platform: Android
Framework: Flutter
Architecture: Local-first
Backend: None

---

# 1. Implementation Rules

The coding agent MUST follow this specification.

The coding agent MUST NOT:

- Invent additional product features.
- Add cloud infrastructure.
- Add authentication.
- Add analytics.
- Add telemetry.
- Add remote APIs unless explicitly required.
- Replace local functionality with cloud functionality.
- Change the export workflow without explicit instruction.
- Change the core notification workflow without explicit instruction.

If a requirement is ambiguous, prefer the simplest implementation consistent with this specification.

Do not create placeholder functionality and describe it as complete.

---

# 2. Platform

Primary target:

Android 16+

The application is not required to support iOS.

Android-specific functionality is allowed and expected.

The application will be installed as a private APK.

---

# 3. Flutter Architecture

Use:

Flutter
Dart
Material 3

Recommended architecture:

Presentation
    ↓
Application / State Management
    ↓
Domain
    ↓
Repositories
    ↓
Local Data / Android Platform Services

Recommended state management:

Riverpod

The implementation must avoid putting business logic directly inside widgets.

---

# 4. Local Database

Use a local database.

Preferred implementation:

Isar

The database must contain at minimum:

Expense
MerchantProfile
Category
AppSettings
ExportRecord

No remote database is required.

---

# 5. Expense Model

Conceptual model:

Expense

Fields:

id
amount
merchant
categoryId
note
timestamp
transactionType
status
referenceNumber
rawSms
source
createdAt
updatedAt
lastExportedAt
smsFingerprint

Types:

id:
local database ID

amount:
integer representing minor currency units

Example:

₹200.90

should be stored as:

20090

Do NOT use floating-point values for monetary storage.

merchant:
String?

categoryId:
String?

note:
String?

timestamp:
DateTime

transactionType:
enum

Values:

DEBIT
CREDIT
UNKNOWN

status:
enum

Values:

PENDING
COMPLETED
IGNORED

referenceNumber:
String?

rawSms:
String?

source:
enum

Values:

SMS
MANUAL

createdAt:
DateTime

updatedAt:
DateTime

lastExportedAt:
DateTime?

smsFingerprint:
String?

---

# 6. MerchantProfile

MerchantProfile represents learned user behavior.

Fields:

id
normalizedMerchant
displayMerchant
categoryCounts
lastUsedCategory
totalTransactions
updatedAt

categoryCounts should represent how often the user selected each category.

Example:

Google India Dig

Subscriptions: 8
Shopping: 1

Suggested category:

Subscriptions

The suggestion algorithm must be deterministic and local.

---

# 7. Category Model

Initial categories:

FOOD
TRAVEL
SHOPPING
BILLS
SUBSCRIPTIONS
ENTERTAINMENT
HEALTH
EDUCATION
PERSONAL
OTHER

Each category should have:

id
name
icon identifier
sortOrder
isDefault

Categories should be stored locally.

---

# 8. SMS Permission

The Android application must request the required SMS permissions at runtime.

At minimum investigate/use:

android.permission.RECEIVE_SMS

The application should not request unnecessary SMS permissions.

The application must explain why SMS permission is required before requesting it.

Permission rationale:

"Luma reads incoming transaction SMS messages so it can automatically detect expenses and remind you to record them."

The application must not claim that SMS is uploaded.

---

# 9. Android SMS Receiver

Implement a native Android BroadcastReceiver.

Listen for:

android.provider.Telephony.SMS_RECEIVED

The receiver must:

1. Receive SMS.
2. Extract message text.
3. Identify likely financial transaction messages.
4. Pass relevant SMS data into the transaction processing layer.
5. Return quickly.

The BroadcastReceiver must not perform expensive work synchronously.

Longer processing should be delegated appropriately.

---

# 10. SMS Parsing

Create a dedicated parser abstraction.

Example:

abstract class SmsTransactionParser {
    ParsedTransaction? parse(SmsMessage message);
}

Do not place bank-specific regex directly inside the BroadcastReceiver.

Bank-specific parsing should be modular.

Example architecture:

SmsParser
    ├── GenericTransactionParser
    ├── SbiParser
    ├── HdfcParser
    └── ...

Do not create bank-specific parsers unless necessary for actual observed SMS formats.

Start with a generic parser capable of the user's observed SMS format.

---

# 11. Parser Output

ParsedTransaction:

amount
transactionType
merchant
timestamp
referenceNumber
accountIdentifier
rawMessage
confidence

The parser must never invent missing information.

If merchant cannot be extracted:

merchant = null

If reference number cannot be extracted:

referenceNumber = null

---

# 12. Transaction Detection

The parser should identify debit/payment SMS messages using transaction keywords.

Examples:

debited
debit
spent
paid
payment
UPI
withdrawn

The parser must avoid treating unrelated SMS messages as expenses.

False positives should be minimized.

---

# 13. Amount Parsing

Support common formats:

Rs.200
Rs 200
INR 200
₹200
₹200.90
INR 200.90

Normalize to integer minor units.

Examples:

₹200 → 20000 paise
₹200.90 → 20090 paise

The database must never store currency as a floating-point number.

---

# 14. Merchant Parsing

Merchant extraction should use the bank message format.

If multiple possible merchant strings exist, choose the most likely payee/merchant.

The parser should preserve the raw SMS so parser behavior can be improved later.

Do not attempt to retrieve the original UPI note from the bank SMS.

---

# 15. Duplicate Detection

Before inserting an SMS transaction:

1. Check reference number if available.
2. Check SMS fingerprint.
3. Check matching amount + merchant + timestamp within a reasonable window.

If an existing matching transaction is found:

Do not create a second expense.

---

# 16. SMS Fingerprint

Generate a deterministic hash from normalized SMS content.

Normalization should include:

- Trim whitespace.
- Normalize repeated whitespace.
- Normalize casing where appropriate.

Store:

smsFingerprint

Use this to prevent duplicate processing.

---

# 17. Notification System

Use:

flutter_local_notifications

Notifications must be created immediately after a valid expense is inserted.

Notification payload must contain the local Expense ID.

Tapping the notification must navigate directly to:

Expense Detail / Complete Expense

The app must not open only the home screen.

---

# 18. Notification Content

Example:

Title:

Luma

Body:

₹200.90 spent at Google India Dig

If merchant is unavailable:

₹200.90 spent

Notification action:

Open expense

The notification should be concise.

---

# 19. Notification Channels

Create an Android notification channel:

expense_alerts

Importance:

High

Purpose:

New detected expense

Create another channel if required for daily reminders:

daily_audit

Do not use maximum notification importance unnecessarily.

---

# 20. Pending Expense UI

The pending expense screen must display:

Amount prominently.

Example:

₹200.90

Below:

Google India Dig
23 Sep, 1:03 PM

Then:

"What was this for?"

Category selection.

The suggested category should be visually distinguished but not forced.

Example:

Suggested

[Subscriptions]

Other categories:

[Food]
[Travel]
[Shopping]
[Bills]
[More]

Then:

Optional note

[Add a note...]

Primary action:

Save Expense

---

# 21. Interaction Requirement

Categorization should require as few interactions as practical.

Ideal flow:

Notification
→ tap
→ tap suggested category
→ Save

If a suggestion is already highly confident, the UI should make it extremely easy to accept.

---

# 22. Learning Algorithm

Version 1 MUST NOT use an external machine-learning service.

Use local frequency-based learning.

For each normalized merchant:

Maintain counts:

merchant → category → count

Example:

uber
    travel: 15
    food: 1

Suggested category:

travel

Confidence can be calculated as:

highestCount / totalCount

Example:

15 / 16 = 93.75%

---

# 23. Suggestion Threshold

Initial behavior:

If merchant has never been categorized:

No suggestion.

If merchant has historical categorization:

Suggest highest-frequency category.

Optionally display confidence internally.

Do not display confusing ML terminology to the user.

The system should remain deterministic.

---

# 24. Learning Update

When user saves a category:

merchantProfile.categoryCounts[category] += 1

Update lastUsedCategory.

Update totalTransactions.

The system must learn from the user's final selection, not from its own suggestion.

---

# 25. Merchant Normalization

Merchant strings should be normalized before learning.

Normalization may include:

- Lowercase
- Trim whitespace
- Collapse repeated spaces
- Remove obvious transaction-specific identifiers
- Remove punctuation where appropriate

Example:

"Google India Dig"
"GOOGLE INDIA DIG"
"Google India Dig "

should map to the same normalized merchant.

Do not aggressively strip meaningful merchant information.

---

# 26. Home Screen

Home screen structure:

Header:

Luma

Current period summary:

This Month
₹X,XXX

Today:

₹XXX

Pending:

X expenses

Recent Expenses

List of latest expenses.

Primary actions:

Add Expense
History
Export

The UI should not become a dashboard full of meaningless charts.

---

# 27. Expense History Screen

Features:

- Date grouping
- Search
- Category filtering
- Date filtering
- Expense detail
- Edit expense
- Delete expense

The user should be able to quickly locate a transaction.

---

# 28. Expense Detail

Display:

Amount
Merchant
Category
Date/time
Note
Transaction reference
Source

Source should display:

SMS detected

or:

Manually added

The raw SMS should not normally be shown in the primary UI.

It may be available under an advanced/debug section.

---

# 29. Manual Expense Screen

Fields:

Amount
Merchant/Description
Category
Date/time
Note

Amount is required.

Category is required for a completed manual expense.

Merchant/description may be optional.

---

# 30. Export Screen

When the user taps Export:

Display two choices:

## Full History

"Export all expenses"

## Since Last Export

"Export only expenses not included in a previous export"

Do not make the user configure date ranges for Version 1.

---

# 31. XLSX Generation

Use a Flutter-compatible XLSX generation library.

Generate a real `.xlsx` file.

Required columns:

Date
Time
Amount
Merchant
Category
Note
Transaction Type
Reference Number

Maintain stable column order.

Currency should be represented as numeric spreadsheet values where practical.

---

# 32. Export Filename

Use:

Luma_Expenses_YYYY-MM-DD_HH-mm.xlsx

Example:

Luma_Expenses_2026-09-25_20-15.xlsx

---

# 33. Export Tracking

Each Expense contains:

lastExportedAt

For "Since Last Export":

Include expenses where:

lastExportedAt == null

For future-safe behavior, the implementation should consider whether modified expenses need to be exported again.

Preferred implementation:

If:

updatedAt > lastExportedAt

then include the expense in the next incremental export.

After generating the export:

lastExportedAt = export timestamp

for the included records.

---

# 34. Export Transactionality

Do not update export timestamps before successful XLSX generation.

Correct sequence:

1. Query records.
2. Generate XLSX.
3. Verify file exists.
4. Update export metadata.
5. Open Android share sheet.

If XLSX generation fails:

Do not update export metadata.

---

# 35. Sharing

Use Android's native share mechanism.

The exported file should be shared using:

application/vnd.openxmlformats-officedocument.spreadsheetml.sheet

The app should provide a share sheet.

The user can choose Gmail.

Luma must not implement SMTP.

Luma must not require Gmail credentials.

---

# 36. Privacy

Do not add:

Firebase Analytics
Crash reporting services
Sentry
PostHog
Mixpanel
Remote logging
Cloud databases
Remote AI APIs

unless explicitly requested later.

---

# 37. Network Access

The application should ideally declare no INTERNET permission unless technically required by a dependency.

If any dependency introduces INTERNET permission unnecessarily, evaluate whether it can be removed.

The application's own code must not perform network requests.

---

# 38. Error Handling

SMS parsing failure:

Do not crash.

Store/log locally where useful.

Do not show an error notification for every unrecognized SMS.

Database failure:

Show a clear local error.

Export failure:

Show:

"Could not create the Excel file."

Do not mark transactions as exported.

Notification failure:

The expense must still remain stored.

---

# 39. Permission UX

First launch should explain:

"Luma watches transaction SMS messages so it can automatically remind you when you spend money."

Then request SMS permission.

If permission is denied:

The app should still allow manual expense tracking.

The app should display a clear indication:

"Automatic transaction detection is disabled."

The user should be able to revisit permission instructions from Settings.

---

# 40. Android Restricted Settings

Because the application is sideloaded and SMS permissions may be subject to Android's restricted-settings protections, the onboarding flow should account for permission failure.

If Android prevents granting SMS permission:

Show instructions explaining that the user may need to enable the app's restricted settings from Android system settings before granting SMS permission.

Do not attempt to bypass Android security controls.

---

# 41. App Settings

Settings should include:

SMS detection status
Notification status
Categories
Daily audit reminder
Export preferences
About

The settings screen should remain small.

Do not add unnecessary configuration.

---

# 42. Daily Audit

If enabled:

At the configured time, check today's transactions.

If pending expenses exist:

Show:

"Luma Daily Check

You have X expenses waiting to be completed."

If there are no pending expenses:

Do not notify.

Default:

Enabled

Default time:

21:00

This can be changed later.

---

# 43. Design System

Luma uses a dark-first, modern, minimal visual design.

The interface should feel:

- Modern
- Minimal
- Premium
- Personal
- Calm
- Focused
- Fast

Luma is a personal expense-memory tool, not a conventional banking application or accounting dashboard.

The UI should prioritize:

- Fast comprehension
- Minimal interaction
- Clear visual hierarchy
- Large, readable expense amounts
- Strong distinction between pending and completed expenses
- Easy one-handed interaction
- Low visual noise

Avoid:

- Excessive gradients
- Glassmorphism everywhere
- Heavy shadows
- Huge illustrations
- Financial-dashboard clichés
- Unnecessary charts
- Excessive decorative elements
- Excessive animations
- Excessive use of accent colors
- Dense tables in the primary mobile interface
- UI elements that exist only for visual decoration

Use:

- Material 3 as the Flutter UI foundation
- Rounded cards
- Clear typography
- Strong hierarchy
- Large readable amounts
- Subtle motion
- Generous spacing
- Consistent component geometry
- Clear touch targets
- Dark surfaces with restrained accents

The UI must feel intentionally designed rather than like unmodified default Material widgets.

Material 3 components may be customized to conform to the Luma design system.

---

# 44. Color System

Luma uses the following mandatory dark color palette.

Do not introduce arbitrary colors throughout the application.

All application colors MUST be defined centrally.

## 44.1 Backgrounds & Surfaces

Main Background:

    #121212

Use for:

- Main application background
- Screen/scaffold background
- Large areas of empty space

Surface / Card Background:

    #1E1E1E

Use for:

- Expense cards
- Dashboard cards
- List items
- Standard elevated content areas

Elevated Surface:

    #2C2C2C

Use for:

- Modals
- Bottom sheets
- Dialogs
- Elevated menus
- Input fields
- Higher-elevation interactive surfaces

The visual hierarchy should generally follow:

    #121212
        ↓
    #1E1E1E
        ↓
    #2C2C2C

Large areas of the UI should remain dark and neutral.

Do not make the application predominantly purple or peach.

---

## 44.2 Primary & Secondary Accents

Primary Accent / Plum:

    #542A52

Use for:

- Primary brand identity
- Primary buttons where appropriate
- Selected controls
- Active navigation states
- Important interactive elements
- Selected categories
- Primary visual emphasis

Secondary Accent / Peach:

    #FFB39A

Use for:

- High-emphasis call-to-action buttons
- Important active states
- High-priority icons
- Important interactive elements
- Selected/highlighted elements where additional emphasis is required

Peach is an emphasis color and must NOT be used indiscriminately.

It should remain visually distinctive against the dark interface.

Plum should establish the Luma identity.

Peach should draw attention to actions or information that deserve immediate attention.

Do not use Plum and Peach simultaneously on every component.

---

## 44.3 Text & Typography Colors

Primary Text:

    #F0F0F0

Use for:

- Screen headings
- Expense amounts
- Primary labels
- Important information
- Primary content

Secondary Text:

    #A0A0A0

Use for:

- Subtitles
- Merchant metadata
- Dates
- Supporting descriptions
- Secondary information

Disabled Text:

    #666666

Use for:

- Disabled controls
- Inactive information
- Unavailable actions

Text on Buttons:

    #FFFFFF

Use for:

- Button labels when the button background requires white text

For buttons using Peach as the background, use:

    #121212

for button text where contrast and readability are appropriate.

---

## 44.4 UI Elements & Semantic States

Borders / Dividers:

    #333333

Use for:

- Card borders where necessary
- Dividers
- Input outlines
- Section separation

Do not add borders to every component.

Primary Button:

    Background: #542A52
    Text: #FFFFFF

Secondary / High-Emphasis Button:

    Background: #FFB39A
    Text: #121212

Success / Positive Action:

    #4CAF50

Use for:

- Successful save states
- Successful export states
- Positive completion indicators
- Confirmation feedback

Error / Destructive Action:

    #CF6679

Use for:

- Delete actions
- Destructive confirmations
- Validation errors
- Failed operations

Input Field:

    Background: #2C2C2C
    Text: #F0F0F0
    Supporting Text: #A0A0A0
    Border: #333333

---

## 44.5 Color Usage Rules

The application should be predominantly dark and neutral.

The approximate visual hierarchy should be:

    Background
        #121212

    Standard surfaces
        #1E1E1E

    Elevated surfaces
        #2C2C2C

    Brand interaction
        #542A52

    High-emphasis interaction
        #FFB39A

    Semantic states
        #4CAF50 / #CF6679

Do not use accent colors merely to make screens visually busy.

Color should communicate hierarchy and interaction.

Peach should be visually special.

Plum should communicate Luma's primary identity.

Green and red/pink are reserved for semantic states and must not be used as decorative colors.

Interactive elements must remain understandable through shape, typography, position, and labels, not color alone.

---

## 44.6 Flutter Theme Implementation

All colors MUST be defined centrally.

Recommended structure:

    lib/
      app/
        theme/
          app_colors.dart
          app_theme.dart

Define semantic color constants such as:

    AppColors.background
    AppColors.surface
    AppColors.surfaceElevated
    AppColors.plum
    AppColors.peach
    AppColors.textPrimary
    AppColors.textSecondary
    AppColors.textDisabled
    AppColors.border
    AppColors.success
    AppColors.error

Widgets MUST reference the centralized theme.

Do NOT repeatedly use raw color values such as:

    Color(0xFF542A52)

inside individual widgets.

The Luma palette must be represented through a centralized ColorScheme/theme configuration.

Do not use Flutter's default Material 3 colors as the final visual palette.

Do not use:

    ColorScheme.fromSeed()

with an arbitrary seed color as the final implementation.

The resulting Material 3 ColorScheme must explicitly conform to the Luma palette.

---

## 44.7 Dark Theme

Dark theme is the canonical Luma visual identity.

Dark mode is the primary and default theme.

The application should remain visually coherent when Android system dark mode settings are applied.

Material 3 components must be customized where necessary so that their default colors do not conflict with the Luma palette.

---

## 44.8 Light Theme

A separate custom light theme is NOT required for Version 1.

Do not automatically invert the dark palette to create a light theme.

If light theme support is implemented later, it must be intentionally designed around the Luma brand identity.

Dark theme remains the reference design against which all UI decisions should be made.

---

# 45. Typography

Luma uses modern, clean sans-serif typography.

Prefer platform/system typography unless a bundled font is specifically required.

Typography should prioritize readability over decorative styling.

## 45.1 Hierarchy

Display:

Used for:

- Large expense amounts
- Monthly spending totals
- Important financial figures

Display text should be visually dominant without occupying unnecessary screen space.

Title:

Used for:

- Screen titles
- Major section headings
- Primary card headings

Body:

Used for:

- Merchant names
- Categories
- Expense descriptions
- Main content

Caption:

Used for:

- Timestamp
- Transaction metadata
- Export information
- Supporting details

---

## 45.2 Expense Amounts

Expense amounts are among the most important pieces of information in Luma.

They should:

- Be immediately readable
- Have strong visual hierarchy
- Use primary text color where appropriate
- Avoid unnecessary decorative formatting

Example:

    ₹200.90

should visually dominate:

    Google India Dig
    1:03 PM
    Subscriptions

when displayed in an expense detail or pending-expense context.

---

## 45.3 Font Weight

Use a restrained number of font weights.

Recommended hierarchy:

- Regular for supporting content
- Medium for labels and secondary emphasis
- Semi-bold or bold for headings and important amounts

Avoid excessive font-weight variation.

Do not make every piece of text bold.

---

## 45.4 Typography Color Usage

Primary information:

    #F0F0F0

Secondary information:

    #A0A0A0

Disabled information:

    #666666

Typography must maintain sufficient contrast against its surface.

Critical information should never depend on low-contrast secondary text.

---

## 45.5 Spacing & Readability

Typography should be paired with generous spacing.

Avoid:

- Dense blocks of information
- Crowded cards
- Excessive metadata
- Multiple competing text hierarchies

Important information should have sufficient visual separation.

The user should be able to understand an expense card in a quick glance.

---

## 45.6 Component Geometry

Use consistent geometry throughout the application.

Cards, buttons, input fields, and interactive controls should use a consistent rounded-corner language.

Do not assign arbitrary corner radii to individual widgets.

Define common dimensions centrally where practical.

Touch targets must be sufficiently large for comfortable mobile interaction.

---

## 45.7 Motion

Use subtle motion to communicate state changes.

Appropriate animations include:

- Expense appearing in a list
- Category selection
- Pending → Completed transition
- Save confirmation
- Dashboard value updates
- Bottom-sheet/dialog transitions

Animations must:

- Be short
- Not delay interaction
- Not distract from financial information
- Have a clear purpose

Do not add animation merely because an animation is possible.

---

## 45.8 Component Consistency

Repeated UI patterns must use reusable components.

Examples:

- ExpenseCard
- AmountDisplay
- CategoryChip
- PrimaryButton
- SecondaryButton
- PendingExpenseCard
- SectionHeader
- EmptyState

Do not duplicate styling logic across screens.

Changes to the Luma design system should be achievable centrally without manually editing every screen.

# 46. Animations

Animations should be subtle.

Useful animations:

- Expense appearing in list
- Category selection
- Save confirmation
- Pending → Completed transition
- Dashboard number updates

Avoid animations that delay user interaction.

---

# 47. Navigation

Recommended navigation:

Home
History
Settings

Do not create bottom navigation for every possible feature.

Export can be accessible from Home and History.

Pending expenses should be prominently accessible from Home.

---

# 48. Project Structure

Recommended:

lib/
  app/
    app.dart
    router.dart
    theme/

  core/
    constants/
    errors/
    utils/

  data/
    database/
    models/
    repositories/

  features/
    dashboard/
    expenses/
    sms/
    notifications/
    export/
    settings/
    onboarding/

  services/
    sms/
    notification/
    export/
    sharing/

  providers/

android/
  app/
    src/
      main/
        kotlin/
          ...

Keep Android-specific SMS code inside the Android/platform layer.

---

# 49. Testing Requirements

Unit tests must cover:

Amount parsing
Merchant parsing
Transaction classification
Duplicate detection
Merchant normalization
Category learning
Export filtering

Example test:

Input:

"Your A/C XX1234 debited by Rs.200.90 on 23-09-2026..."

Expected:

amount = 20090
transactionType = DEBIT

---

# 50. Export Tests

Test:

Empty history
Single expense
Multiple expenses
Full export
Incremental export
Previously exported expense
Modified previously exported expense
Failed export

---

# 51. SMS Tests

Test:

Valid debit SMS
Valid credit SMS
Unrelated SMS
Malformed SMS
Missing merchant
Missing reference number
Duplicate SMS
Multiple SMS segments

---

# 52. Offline Requirement

The following must work with airplane mode enabled:

Viewing expenses
Adding expenses
Editing expenses
Categorizing expenses
Learning merchant preferences
Receiving/processing SMS when Android delivers it
Notifications
Generating XLSX

The app must not require an internet connection for normal operation.

---

# 53. Data Safety

All financial data must remain inside application-private storage.

Do not write financial data to publicly accessible external storage unless required for an explicitly generated export.

Generated XLSX files are user-created export artifacts and may be shared through Android.

---

# 54. Logging

Development logs may contain diagnostic information.

Production builds must NOT log:

- Full SMS bodies
- Financial account numbers
- Full transaction references
- Sensitive financial information

Logs should be minimal.

---

# 55. Definition of Done

Version 1 is complete only when:

[ ] App launches successfully.
[ ] Database works offline.
[ ] SMS permission onboarding works.
[ ] Incoming SMS can be detected.
[ ] Transaction SMS is parsed.
[ ] Expense is stored.
[ ] Duplicate SMS does not create duplicate expense.
[ ] Notification appears.
[ ] Notification opens correct expense.
[ ] Expense can be categorized.
[ ] Merchant learning works.
[ ] Manual expenses work.
[ ] History works.
[ ] Pending expenses work.
[ ] Daily audit works.
[ ] XLSX full export works.
[ ] XLSX incremental export works.
[ ] Export state is persisted.
[ ] Modified expenses are handled correctly.
[ ] Android share sheet opens.
[ ] Gmail can receive the generated XLSX through sharing.
[ ] App works without internet.
[ ] No financial data is sent to a Luma backend.
[ ] Light mode works.
[ ] Dark mode works.
[ ] Core unit tests pass.
[ ] App survives process restart.
[ ] Pending expenses survive reboot.