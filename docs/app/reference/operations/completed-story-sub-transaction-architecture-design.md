---
title: "Completed Story Archive: Sub-Transaction Architecture Design"
last_updated: 2026-02-15 # YYYY-MM-DD
tags: [reference, app, operations, archive, transaction-breakdown, architecture]
---

# Completed Story Archive: Sub-Transaction Architecture Design

Brief summary: Historical architecture design archive for sub-transaction line items, focused on identity consistency, aggregate ownership, draft-to-domain mapping, and ID-based operations.

## When to use this doc

Use this archive when reviewing historical architectural decisions behind breakdown item editing, especially around draft identity, persistence mapping, and save/update semantics. For active architecture constraints, use canonical reference docs.

## Core architectural decisions (archived)

### Identity strategy by layer

- Domain identity: `SubTransactionId` value object.
- Presentation identity: one stable draft identifier (`SubTransactionDraftId` / UUID-like value).
- Data identity: DB primary key for `transaction_breakdowns` rows.

The design intentionally removed dual identity in draft models to prevent UI branching on persistence state.

### Aggregate and repository boundaries

- `Transaction` remains aggregate root.
- `SubTransaction` remains a child entity inside `Transaction`.
- Writes remain aggregate-centric through `ITransactionRepository` (no separate write repository for sub-transactions).

### Draft purity and mapping responsibilities

- Drafts stay presentation-only and do not expose persistence flags.
- Application layer owns mapping from draft line identity to persisted sub-transaction identity via an internal identity map.
- New vs persisted line handling is decided in mapping/use-case layers, not in widgets.

### UI/VM operations model

- Breakdown operations are ID-based (`add`, `update`, `remove`, `reorder`) using stable draft line IDs.
- UI deletion/editing paths must not branch on “new vs persisted” in presentation code.

### Data and persistence model

- Breakdown items persisted in dedicated `transaction_breakdowns` table.
- Read path may query rows directly for analytics/reporting.
- Update flow described as diff-based (`toInsert`, `toUpdate`, `toDelete`) against persisted rows.

## Quality and migration intent (archived)

### Testing strategy intent

- Domain tests for entity invariants.
- Application tests for draft-to-domain mapping and identity map behavior.
- ViewModel tests for ID-based operations.
- Widget tests for deletion/editing behavior independent of persistence origin.

### Refactor/migration sequence intent

- Simplify draft model to one stable line ID.
- Refactor VM APIs to ID-based operations.
- Introduce identity map in save command/use case.
- Remove persistence-state conditionals from UI.
- Cover regression paths for mixed new/persisted lines.

## Intentional de-duplication notes

This archive keeps historical design intent while deferring active constraints and canonical rules to:
- [Project Structure and Boundaries](/docs/app/reference/architecture/project-structure-and-boundaries.md)
- [Data Persistence](/docs/app/reference/architecture/data-persistence.md)
- [Guardrails and Testing](/docs/app/reference/architecture/guardrails-and-testing.md)

## Related docs

- [Operations Reference](/docs/app/reference/operations/index.md)
- [Data Persistence](/docs/app/reference/architecture/data-persistence.md)
- [Project Structure and Boundaries](/docs/app/reference/architecture/project-structure-and-boundaries.md)
- [Guardrails and Testing](/docs/app/reference/architecture/guardrails-and-testing.md)
- [Documentation Updates Log](/docs/updates.md)
