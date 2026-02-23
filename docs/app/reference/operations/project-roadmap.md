---
title: "Project Roadmap (Archived Backlog)"
last_updated: 2026-02-21 # YYYY-MM-DD
tags: [reference, app, operations, roadmap, backlog]
---

# Project Roadmap (Archived Backlog)

Brief summary: Historical snapshot of the project backlog and roadmap preserved during legacy migration. This is an archive for context — not active guidance.

## When to use this doc

Use this document for historical reference when reviewing what features were planned, completed, or deferred. This is not active guidance and should not be used to drive current development decisions.

## Completed Items

- Saving files in transactions
- Navigation pop() refreshed the data
- Cross-account transfer
- File persistence
- Refactoring
- Fix ArgumentError (Invalid argument(s): Sum of line totals (1375) must equal transaction amount (1160))
- Transaction matching
  - Receipt parsing should be through ImportSessionController
  - Fix "Another import is already running" error
  - When go to match screen from transaction_form, we should pop to summary screen (previous from transaction_form)
    - Replace the navigation call in TransactionFormViewModel.parseReceipt
    - Introduce DraftId (UUID) to TransactionDraft; expose look-ups in ImportSessionController
    - Refactor commitSingle, discardSingle, updateMatch to use DraftId
    - Add the defensive guard to saveTransaction() and a unit test that verifies the form auto-closes when its draft disappears
    - Update the CONTRIBUTION_GUIDE to forbid passing list indices across view-models or stores (aligns with §4.1 of the architecture doc)
  - Accept All / Reject All buttons behave strange
  - [BUG] When I parse single receipt, and this is a new tx (no matches), MatchTransactionScreen shouldn't be called
  - All amounts in match screen are green (that's wrong)
  - Category is lost in transaction card
  - [BUG] A transaction isn't saved when detached from a match
  - Open transaction from match screen
  - Autoscroll to imported transactions (CANCELLED)
- Color scheme
- Full support of transaction breakdown
  - UnitOfMeasure domain
  - update_sub_tx_dto
  - Decimal amount
- PDF preview

## Pending TODOs

- Category hierarchy: transaction category & item category
- Global settings
- Upload CSV
- Upload bank statement

## Blockers for Public Release

- User account and login, remove OpenAI key from the code

## Should Have (After Release)

- Account management: CRUD and thumbnail
  - Replace account_picker_grid with list
- Collect all time-zone helpers _tz() and move to one utility
- Show multiple files attached & file deletion
- Highlight transaction fields on automatic change
- Export of transactions
- Multi-currency
  - Consider adding tolerance for micro-rounding differences
    - `const int _toleranceCents = 1; // For handling ±1 cent differences`

## Nice to Have

- Limit transaction loading by date, auto-load on scroll (optimisation)
- Multi-platform
- Cross-device sync, tx location, several files in tx, multiple file parsing
- Multi-user
- Disk space growth — consider adding size caps or auto-purge older files in future for files
  - Or, consider centralised storage on server
- iCloud/Google Drive backups — mark receipts with the doNotBackup attribute if needed (platform-specific)
- Create a color theme instead of manually setting colors in each widget

## Related docs

- [Operations Reference Index](/docs/app/reference/operations/index.md)
- [Reference Index](/docs/app/reference/index.md)
