---
title: "Store Patterns and Testing"
last_updated: 2026-01-26 # YYYY-MM-DD
tags: [reference, app, stores, state-management]
---

# Store Patterns and Testing

Brief summary: State management conventions and provider wiring rules for store and ViewModel tests.

## When to use this doc

Use this reference when implementing stores, ViewModels, or provider wiring in tests.

## State Management Rules

### 1. Stable Identifiers Only
**Never pass list positions across components.** Always use stable IDs.

| ✅ Do | ❌ Don’t |
| :--- | :--- |
| `store.deleteTransaction(transactionId)` | `store.deleteTransactionAt(index)` |
| `viewModel.selectItem(itemId)` | `viewModel.selectItemAt(position)` |

*Rationale:* Indices change with filtering/paging; IDs don’t.

### 2. Three-Type Pattern
See [Project Structure](/docs/app/reference/architecture/project-structure-and-boundaries.md) for details on Draft vs Entity vs DTO.
- **Stores** consume **Drafts** and produce **Entities**.
- **Stores** are the **only** classes that call `notifyListeners()`.
- **ViewModels** expose UI-friendly state (often derived from Stores).

## Provider wiring in tests

- `ListenableProvider.value` / `ChangeNotifierProvider.value` for `ChangeNotifier` fakes.
- `Provider.value` for non-listenables.
- Reset GetIt in test setup/teardown if used.

## Related docs

- [UI/UX Guardrails](/docs/app/reference/ui-ux/ui-ux-guardrails.md)
- [General Contribution and Process](/docs/app/reference/general/contribution-and-process.md)
- [App Reference Index](/docs/app/reference/index.md)