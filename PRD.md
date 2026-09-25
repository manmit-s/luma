# Luma
## Personal Expense Memory & Tracking App

Version: 1.0
Status: Implementation Specification
Platform: Android
Framework: Flutter
Primary User: Single personal user
Distribution: Private / sideloaded APK
Backend: None
Cloud Storage: None

---

# 1. Product Overview

Luma is a private, local-first Android expense tracking application designed around one specific problem:

The user frequently makes UPI transactions but forgets to manually record them in an expense spreadsheet.

Traditional expense trackers require the user to remember to open an app, enter the transaction, enter the amount, select a category, and save it.

This workflow fails for the intended user because the user often forgets to record transactions immediately.

Luma solves this by monitoring incoming transaction SMS messages on the user's Android device.

When a transaction SMS is received, Luma:

1. Detects the transaction.
2. Extracts relevant information from the SMS.
3. Creates a local expense record.
4. Immediately reminds the user to complete the expense record.
5. Minimizes the amount of information the user has to enter manually.
6. Learns the user's categorization habits over time.
7. Stores all data locally on the device.
8. Allows the user to export expense history as an Excel spreadsheet.
9. Allows the user to send the exported spreadsheet through the Android share/email system.
10. Supports both full-history exports and incremental exports since the previous export.

The app is not intended to be a general-purpose finance application.

It is specifically an anti-forgetting system for personal expense tracking.

---

# 2. Core Product Principle

The most important product principle is:

> The user should never have to remember to remember an expense.

Luma must proactively interrupt the user when a transaction occurs.

The app should require the minimum possible interaction from the user.

The user should NOT have to manually enter:

- Transaction amount
- Transaction time
- Merchant/payee
- Transaction reference number

when those values can be extracted from the SMS.

The user should normally only need to:

- Confirm/categorize the expense
- Optionally add a short note

---

# 3. Target User

The application has exactly one primary user.

The user:

- Uses Android.
- Makes UPI transactions.
- Receives bank transaction SMS messages.
- Frequently forgets to record expenses.
- Wants to maintain an expense history.
- Currently relies on Excel/manual records.
- Eventually sends the expense history to their father through email.
- Does not want financial information stored on a remote server.

The UX should therefore prioritize speed and low cognitive effort over generalized flexibility.

---

# 4. Problem Statement

Current workflow:

1. User makes UPI transaction.
2. Bank sends SMS.
3. User intends to record expense.
4. User forgets.
5. Several transactions accumulate.
6. User later checks UPI history.
7. User manually reconstructs expenses.
8. User may not remember what individual transactions were for.
9. Expense totals become difficult to reconcile with account balance.
10. Excel record becomes incomplete or delayed.

Luma changes this workflow to:

1. User makes UPI transaction.
2. Bank sends SMS.
3. Luma detects SMS.
4. Luma creates pending expense automatically.
5. Luma immediately reminds user.
6. User categorizes/adds optional note.
7. Expense becomes part of local history.
8. User periodically exports the spreadsheet.
9. User sends the spreadsheet to their father.

---

# 5. Important Constraint: UPI Notes

UPI transactions may contain a note/remark entered by the user during payment.

That note is NOT guaranteed to appear in the bank's transaction SMS.

Therefore:

Luma MUST NOT assume that the UPI note is available in the SMS.

The SMS parser should rely only on information actually present in the SMS.

If the UPI note is unavailable, the user may manually enter a note in Luma.

Luma must never claim that the bank SMS contains the original UPI note.

---

# 6. Privacy Model

Luma is local-first.

There is no application backend.

There is no Luma account.

There is no cloud database.

There is no analytics server.

There is no telemetry.

There is no automatic upload of financial information.

The following information must remain on-device:

- SMS content
- Parsed transactions
- Expense history
- Categories
- Notes
- Merchant mappings
- Learning/personalization data
- Export history
- Application settings

Internet access is only required when the user explicitly chooses to send/export data using an external Android application such as Gmail.

Luma itself must not automatically transmit expense information to a remote service.

---

# 7. SMS Detection

Luma must monitor incoming SMS messages relevant to financial transactions.

The app should primarily target debit/payment transaction messages.

Example:

"Your A/C XXXX debited by Rs.200.90 on 23-09-2026. Avl Bal Rs.XXXX. UPI Ref..."

The exact SMS wording varies by bank.

The parser must therefore be modular and configurable.

The system should extract where possible:

- Amount
- Transaction type
- Merchant/payee
- Timestamp
- Reference number
- Account identifier if useful
- Raw SMS body

The raw SMS should be stored locally to allow debugging and parser improvements.

---

# 8. Transaction Types

Luma should distinguish at minimum:

- EXPENSE / DEBIT
- INCOME / CREDIT
- UNKNOWN

Version 1 is primarily focused on expenses/debits.

Credit transactions must not automatically become expenses.

If a credit SMS is detected, the application may store it as a transaction but must not include it in expense totals unless explicitly supported by the implementation.

---

# 9. Duplicate Prevention

Banks may send multiple SMS messages for the same transaction.

Luma must prevent duplicate expense records.

Duplicate detection should use multiple signals where available:

- Transaction/reference number
- Amount
- Timestamp
- Merchant
- SMS fingerprint/hash

A transaction reference number is the preferred unique identifier.

If no reference number exists, a deterministic fingerprint should be generated from available transaction data.

---

# 10. Pending Expense Workflow

Every newly detected expense should initially have:

status = PENDING

The pending expense should trigger an immediate user notification.

The notification should clearly show:

- Amount
- Merchant/payee if available
- Transaction time

Example:

"Luma
₹200.90 spent
Google India Dig
Tap to categorize"

The notification should not require the user to manually enter the amount.

---

# 11. Notification Behaviour

The notification is the core UX of the application.

It should:

- Appear immediately after transaction detection.
- Be high visibility.
- Open directly to the relevant expense when tapped.
- Clearly communicate that an expense needs attention.

The notification should NOT repeatedly spam the user unnecessarily.

The app may maintain a persistent pending-expense notification if the expense remains incomplete.

The user should be able to see pending expenses from the app.

---

# 12. Expense Entry UX

Opening a pending expense should display:

Amount
Merchant
Date/time
Category
Optional note

The amount, merchant and timestamp should already be populated.

The user should be able to categorize with a single tap.

Example categories:

- Food
- Travel
- Shopping
- Bills
- Subscriptions
- Entertainment
- Health
- Education
- Personal
- Other

Categories should be configurable in the future.

---

# 13. Learning / Personalization

Luma should learn the user's categorization habits over time.

This is NOT intended to be a large AI/ML system.

The first implementation should use local behavioral learning.

Example:

If the user repeatedly categorizes:

Google India Dig → Subscriptions

then future transactions from the same merchant should automatically suggest:

Subscriptions

The system should maintain local merchant/category associations.

The user must remain able to override the suggestion.

The system should improve its confidence based on repeated user choices.

No remote machine-learning service should be used.

---

# 14. Suggested Category

When a new transaction arrives, Luma should attempt to determine a suggested category.

Possible signals:

1. Exact merchant match.
2. Normalized merchant match.
3. Historical merchant/category frequency.
4. Optional keyword rules.
5. Previously observed transaction patterns.

The application should show the suggestion as a suggestion, not silently force the category.

Example:

"Suggested: Subscriptions"

The user can change it.

---

# 15. Manual Expenses

The user must also be able to manually create an expense.

This is necessary for:

- Cash expenses
- Transactions that did not generate an SMS
- Missed transactions
- Corrections
- Historical entries

Manual expenses should use the same Expense model as SMS-derived expenses.

---

# 16. Expense History

The main application should provide a history of expenses.

Each expense should display:

- Amount
- Merchant/description
- Category
- Date/time
- Optional note

Expenses should be grouped by date.

Example:

TODAY

₹200.90
Google India Dig
Subscriptions

₹85
College Canteen
Food

YESTERDAY

₹120
Uber
Travel

---

# 17. Dashboard

The home screen should prioritize useful information rather than financial-app decoration.

It should show:

- Today's spending
- Current month's spending
- Number of pending expenses
- Recent transactions
- Quick access to history
- Quick manual expense action
- Export action

The dashboard should make the user's financial state understandable at a glance.

---

# 18. Pending Expenses

The app must have a dedicated pending state.

Pending expenses are transactions detected by SMS but not yet completed by the user.

Example:

3 transactions need attention

₹200.90 Google India Dig
₹85 Canteen
₹40 Uber

The user should be able to process them sequentially.

---

# 19. Daily Reminder / Audit

Luma should optionally perform a daily audit.

Example:

"You made 4 transactions today.
1 expense is still incomplete."

This is intended to catch transactions where the user ignored the immediate notification.

The feature must be configurable.

---

# 20. Export

Luma must support Excel export.

The output format should be `.xlsx`.

The spreadsheet should contain useful columns such as:

- Date
- Time
- Amount
- Merchant
- Category
- Note
- Transaction Type
- Reference Number

The exact column order should remain stable.

---

# 21. Export Modes

When the user selects Export, show:

### Export Entire History

Exports all expense records.

### Export Since Last Export

Exports only expenses that have not previously been included in an incremental export.

This is intended for sending updates to the user's father.

---

# 22. Export Tracking

Luma must track export state independently for each expense.

An expense should contain export metadata.

Example:

exportedAt = null

After an incremental export:

exportedAt = timestamp

An expense should only be considered exported after the export file has successfully been generated.

The user should not lose export state merely because they opened the export screen.

---

# 23. Important Export Behaviour

Example:

Day 1:

Expenses A, B, C

User exports incremental history.

A, B, C become exported.

Day 2:

Expenses D, E

User exports incremental history.

The resulting spreadsheet contains:

D, E

It must NOT contain:

A, B, C

unless the user explicitly selects Full History.

---

# 24. Sharing / Email

Luma should use the Android share mechanism for exported files.

Luma should NOT implement its own email server.

The user can choose Gmail or another compatible application.

Example:

Generate XLSX
→ Android Share Sheet
→ Gmail
→ User selects recipient
→ User sends

Luma does not need to know the recipient.

---

# 25. Export Safety

The application must clearly distinguish:

"Generate export"

from

"Send email"

Luma cannot guarantee that Gmail actually sent the email.

Therefore the application must NOT mark an export as permanently delivered merely because the Android share sheet opened.

Export tracking should represent:

"Included in an export generated by Luma"

not:

"Successfully received by recipient."

---

# 26. Corrections

The user must be able to edit:

- Amount
- Merchant
- Category
- Note
- Date/time

for manually created and SMS-derived expenses.

Editing an expense after it was exported should be allowed.

The next incremental export should include the modified expense if the implementation tracks modifications after export.

The exact modification strategy must be implemented consistently.

---

# 27. No Unnecessary Features

Version 1 should NOT contain:

- Bank account integration
- Automatic UPI API integration
- Cloud synchronization
- User accounts
- Social features
- Shared budgets
- Investment tracking
- Credit score tracking
- Advertising
- Subscription system
- Cryptocurrency tracking
- Financial recommendations
- Financial advice
- AI chatbot
- Server-side machine learning

The app is deliberately narrow.

---

# 28. UX Philosophy

Luma should feel:

- Fast
- Personal
- Modern
- Minimal
- Calm
- Responsive
- Private

It should NOT feel like:

- An accounting ERP
- A banking app
- A spreadsheet editor
- A generic budgeting template

The primary optimization target is:

> Minimum number of taps required to record an expense correctly.

## Visual Identity

Luma's visual identity is based on a dark, restrained interface using:

- #121212 background
- #1E1E1E surfaces
- #2C2C2C elevated surfaces
- #542A52 plum primary accent
- #FFB39A peach high-emphasis accent
- #F0F0F0 primary text
- #A0A0A0 secondary text

The interface should feel modern and personal rather than like a conventional banking application.

The color palette must remain consistent throughout all screens, notifications where Android permits customization, dialogs, buttons, cards, forms, and empty states.
---

# 29. Success Criteria

The app is successful if:

1. A transaction SMS produces a pending expense automatically.
2. The user receives a reminder immediately.
3. The user can categorize it within a few seconds.
4. Repeated merchants receive useful category suggestions.
5. Expenses remain available offline.
6. No financial data is uploaded automatically.
7. Full Excel exports work.
8. Incremental exports work without duplicates.
9. The user can share the generated spreadsheet through Gmail.
10. The user does not need to reconstruct transactions manually from UPI history.