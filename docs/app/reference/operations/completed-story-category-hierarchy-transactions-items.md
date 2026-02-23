---
title: "Completed Story Archive: Category Hierarchy for Transactions and Items"
last_updated: 2026-02-15 # YYYY-MM-DD
tags: [reference, app, operations, archive, categories, transaction-breakdown]
---

# Completed Story Archive: Category Hierarchy for Transactions and Items

Brief summary: Historical archive of the completed story that introduced category scope separation (`transaction` vs `item`) across domain, data, UI, pickers, migration behavior, and testing expectations.

## When to use this doc

Use this archive when you need the original implementation intent, acceptance envelope, and migration rationale for category-scope separation. For current canonical rules, use the architecture and guardrails references linked below.

## Historical context and rationale

The archived story addressed a product-model mismatch where one shared category pool was used for both:
- transaction-level classification (for whole transactions), and
- item-level classification (for breakdown/sub-transaction lines).

The story introduced a scope dimension so category selection and management could reflect these two different analytical purposes without relying on user memory or manual filtering.

## Archived scope and intended behavior

### Domain and persistence decisions

- Introduce `CategoryScope` with `transaction` and `item` values.
- Persist `scope` in categories with backfill default to `transaction`.
- Clear legacy breakdown category links during migration so item-level classification can be rebuilt intentionally.

### Category management UX decisions

- Split management into two tabs: transaction categories and item categories.
- Keep existing management interactions (create/edit/delete, emoji behavior) while scoping visible data per tab.
- Infer category scope from active tab at creation time.

### Picker behavior decisions

- Transaction forms (`AddTransaction` and `TransactionForm`) must show transaction-scoped categories only.
- Breakdown item pickers must show item-scoped categories only (bottom-sheet picker flow).
- Scope mismatch is prevented by picker filtering; mismatches from non-UI paths should emit warnings.

### Seed and migration expectations

- Preserve existing transaction category behavior for existing users.
- Seed examples for both scopes (transaction-focused income/expense and item-focused expense categories).
- Keep migration idempotent and backward-compatible for existing transaction records.

### Quality and accessibility expectations

- Coverage targets included unit/repository/migration/viewmodel/widget/integration levels.
- Localization required for all new scope-related labels and warnings.
- Semantic keys, tooltips, and keyboard navigation were part of expected UX quality gates.

## Key acceptance envelope (archived)

The story’s acceptance intent covered:
- scoped category model and persistence,
- tabbed management UX,
- scope-filtered pickers in transaction and item flows,
- migration + seed behavior,
- warning behavior for mismatches,
- testability and accessibility completeness.

## Archived dependencies and future considerations

### Dependencies

- Category entity and category store behavior updates
- Category picker filtering integration in transaction and breakdown flows
- Category management screen/tab redesign
- Drift schema/migration updates for category scope
- Localization updates for scope labels and warnings

### Open questions / future considerations

1. Should a future `CategoryScope.both` mode be supported?
2. Should parent-child category hierarchy enforce same-scope constraints?
3. Should bulk migration helpers be added to re-categorize cleared item links?

## Archived definition-of-done envelope

- Acceptance criteria validated end-to-end
- Coverage expectations across unit, widget, integration, and migration tests
- Localization and semantic key completeness
- Analyzer/tests passing and UX alignment with the designed flow
- Migration behavior validated for backward compatibility

## Intentional de-duplication notes

This archive preserves historical intent and scope while avoiding duplication of active canonical rules already maintained in:
- [Guardrails and Testing](/docs/app/reference/architecture/guardrails-and-testing.md)
- [Data Persistence](/docs/app/reference/architecture/data-persistence.md)

Use those canonical docs for current implementation requirements.

## Related docs

- [Operations Reference](/docs/app/reference/operations/index.md)
- [Guardrails and Testing](/docs/app/reference/architecture/guardrails-and-testing.md)
- [Project Structure and Boundaries](/docs/app/reference/architecture/project-structure-and-boundaries.md)
- [Data Persistence](/docs/app/reference/architecture/data-persistence.md)
- [Documentation Updates Log](/docs/updates.md)
