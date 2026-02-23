---
title: "Completed Story Archive: Transaction Breakdown Issues"
last_updated: 2026-02-15 # YYYY-MM-DD
tags: [reference, app, operations, archive, transaction-breakdown, ux]
---

# Completed Story Archive: Transaction Breakdown Issues

Brief summary: Historical issue-definition archive for transaction breakdown behavior, capturing expected edit lifecycle, mismatch handling, sync behavior, and validation rules for breakdown items.

## When to use this doc

Use this archive to understand the historical problem framing and acceptance intent for transaction breakdown UX defects. For current rules and implementation standards, use canonical architecture docs.

## Archived issue scope

The story captured recurring UX and consistency issues in the transaction form breakdown flow, including:
- editing limitations for existing breakdown items,
- unclear/blocked edit-mode exit behavior,
- user expectation mismatch for `Sync items`,
- brittle total/price/quantity interactions for non-unit quantities.

## Archived expected behavior model

### Editability and read-only parity

- Editable transactions: all breakdown items (new and existing) should support full inline edit lifecycle.
- Read-only/blocked transactions: breakdown section should be fully read-only (no add/edit/delete/sync actions).

### Item edit lifecycle

- Enter edit mode via existing swipe-right interaction.
- New item should start in edit mode.
- Exit edit mode only when line data is valid; invalid fields must block exit with clear field-level feedback.

### Deletion behavior

- Delete via existing swipe-left with confirmation.
- Recalculate mismatch after deletion.
- If list becomes empty, mismatch warning should not persist solely due to missing items.

### Amount mismatch and tolerance behavior

- Compare transaction amount vs breakdown sum continuously.
- Tolerance rule: ±1 smallest currency fraction.
- If outside tolerance: show warning banner and block save until resolved.
- If inside tolerance: hide warning and allow save.

### Sync actions intent

- `Sync amount`: update transaction amount to breakdown total.
- `Sync items`: add an adjustment line item to reconcile breakdown sum to transaction amount.
- Repeated `Sync items` actions intentionally create additional adjustment rows.

### Numeric editing rules intent

- Price/Total accept valid monetary input up to 2 decimals.
- “Last edit wins” behavior between editable Price and Total.
- For non-unit quantity edits, total entry should remain usable and predictable.
- Invalid quantity blocks exit from edit mode.

## Historical acceptance envelope

The archived acceptance covered editability, read-only consistency, edit-mode transitions, deletion semantics, tolerance and banner behavior, sync actions, numeric rules, and testability expectations.

## Intentional de-duplication notes

Detailed active implementation constraints are maintained in canonical docs and are not duplicated here:
- [Data Persistence](/docs/app/reference/architecture/data-persistence.md)
- [Guardrails and Testing](/docs/app/reference/architecture/guardrails-and-testing.md)

## Related docs

- [Operations Reference](/docs/app/reference/operations/index.md)
- [Completed Story Archive: Transaction Breakdown](/docs/app/reference/operations/completed-story-transaction-breakdown.md)
- [Data Persistence](/docs/app/reference/architecture/data-persistence.md)
- [Guardrails and Testing](/docs/app/reference/architecture/guardrails-and-testing.md)
- [Documentation Updates Log](/docs/updates.md)
