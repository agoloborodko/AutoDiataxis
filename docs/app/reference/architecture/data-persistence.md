---
title: "Data Persistence"
last_updated: 2026-02-02 # YYYY-MM-DD
tags: [reference, app, architecture, data, persistence]
---

# Data Persistence

Brief summary: Data architecture, persistence rules, and domain policies for the app.

## When to use this doc

Use this document when working on storage, migrations, or file persistence logic. It defines how data is identified, stored, and managed.

## Identity Rules

All aggregates and references use **Value Objects** for IDs to ensure type safety.

| Context | Type of ID | Example |
| :--- | :--- | :--- |
| **Draft** | **Primitive** (`String`, `int`) | `customerId` (String) |
| **Domain & Persistence** | **Value Object** (`class CustomerId`) | `CustomerId customerId` |
| **Inside Aggregate** | **Value Object** | `AccountId debitAccountId` |

> **Rule**: Use a small value-object even for "foreign" IDs. Never pass full objects across aggregate boundaries; always pass their IDs.

### Category Scope
Categories have a `CategoryScope` (enum) to distinguish context:
- `transaction`: Standard category.
- `item`: For individual breakdown items.
- Persisted as **TEXT** (enum name).

## Drift & Schema Rules

- **Schema Definition**: `lib/core/database/app_database.dart`.
- **Versioning**: Bump `schemaVersion` on every change.
- **Foreign Keys**: Enabled via `PRAGMA foreign_keys = ON` in `beforeOpen`.
- **Migrations**: 
  - Follow the migration workflow (export schema → edit → export new schema → generate stubs → write migration).
  - Every schema change PR must include **JSON dumps + migration tests**.
  - Put all SQL side-effects (backfills, indexes) in `onCreate`/`onUpgrade`.

## Timestamp Policy

Strict separation between **persistence (UTC)** and **display (Local)**.

- **Source of Truth**: Domain + Repository using injected `Clock`.
- **Storage**: **UTC** always. Repository persists exact values from Domain.
- **Database**: Do **not** use SQL defaults (`CURRENT_TIMESTAMP`) or triggers to manage timestamps.
- **Display**: Convert to local timezone **only** in the Presentation layer.
- **Testing**: Inject `TestClock` to control time deterministically.

### Update Logic
- `createdAt`: Set on creation, never changes.
- `updatedAt`: Updated **only** when material fields change (computed in Domain via `Clock`).

## Breakdown Modelling & Decimal Policy

- **Modelling**: `Transaction` aggregate contains `lines` (`SubTransaction`).
- **Decimals**:
  - `quantity` is `Decimal`.
  - `priceCents` and `totalCostCents` are `int` (minor units).
  - **Rounding**: `total = price * quantity` (rounded to nearest cent). Rounding logic lives in **Domain**.

### Tolerance & Sync Policy
- **Tolerance**: ±1 cent (symmetric smallest fraction) mismatch allowed between Transaction Amount and Breakdown Sum.
  - If `|delta| ≤ 1 cent`: Banner hidden, save allowed.
  - If `|delta| > 1 cent`: Banner shown, save blocked until resolved.
- **Sync Actions** (banner buttons):
  - **Sync Amount**: Sets `model.amountCents = breakdownTotalCents` and re-evaluates mismatch; typically hides the banner immediately.
  - **Sync Items**: Appends an `Adjustment` line to reconcile the difference; repeat presses add additional `Adjustment` rows by design.
- **Deletion Policy**: When the last breakdown item is removed, the mismatch banner disappears (no breakdown total to compare) and saving reverts to standard form validation.
- **Editing Policy** (last-edit-wins):
  - Editing **Total** fixes the line total; subsequent quantity changes keep total fixed and recompute unit Price (rounded per domain policy).
  - Editing **Price** and then changing quantity recomputes Total as `price × quantity`.
- **Quantity Validation**: quantity must be > 0. Invalid input blocks exiting the item's edit mode and shows an inline error until corrected.

### DigitalAmountInput Widget
The shared `DigitalAmountInput` renders a digit-only field that formats as monetary text while emitting integer cents via `onChanged(int cents)`.

- **Usage**: Pass `initialAmountCents` and update the model in the handler; the widget manages caret position and formatting.
- **Scope**: Use it for both Price and Total fields in breakdown rows; model methods translate Total edits to Price (and vice versa) per the policy above.

## Tables (Current Snapshot)

- **currencies:** `id`, `code` (unique, 3 chars), `name?`, timestamps.
- **categories:** `id`, `name`, `parent_id?`, `icon?`, `type`, `scope`, soft-delete, timestamps.
- **units:** `id`, `name` (unique), `description?`, timestamps.
- **accounts:** `id`, `name` (unique), `currency`, `balance`, `balance_utc`, timestamps.
- **transactions:** `id`, `document_datetime`, `amount`, `merchant?`, `currency`, `source/target_account`, `rates`, `category`, soft-delete, timestamps.
- **transaction_breakdowns:** `id`, `transaction_id`, `item_name`, `price`, `quantity`, `unit`, `total_cost`, `category`, `note`, timestamps.
- **source_files:** `id`, `file_name`, `uploaded_at`, `metadata?`.
- **transaction_source_files:** `id`, `transaction_id`, `source_file_id`.
- **global_defaults:** `id`, `default_currency`, `default_account`.

## Related docs

- [Database Migrations](/docs/app/how-to/database-migrations.md)
- [File Persistence](/docs/app/how-to/file-persistence.md)
- [Project Structure and Boundaries](/docs/app/reference/architecture/project-structure-and-boundaries.md)
- [Architecture Overview](/docs/app/explanation/architecture-overview.md)
