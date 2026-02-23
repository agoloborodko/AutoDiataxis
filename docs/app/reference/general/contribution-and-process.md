---
title: "General Contribution and Process"
last_updated: 2026-01-26 # YYYY-MM-DD
tags: [reference, app, general, contribution, process]
---

# General Contribution and Process

Brief summary: Cross-domain contribution standards, process expectations, and shared guardrails for app changes.

## When to use this doc

Use this reference when preparing a PR, applying cross-domain guardrails, or verifying shared process rules.

## Glossary

| Term | Lives in | Purpose | Typical suffix |
| :--- | :--- | :--- | :--- |
| **Draft** | Presentation | Transient request object created from a form or picker. | `*Draft` (`NewTransactionDraft`) |
| **Entity** | Domain | Aggregate or child object with invariants. | entity name (`Transaction`) |
| **DTO** | Data | Persistence/serialisation shape. | `*Dto` / `*Row` (`TransactionRowDto`) |
| **Route Args** | Presentation | Typed arguments built by router from primitives. | `*Args` (`ParseFileArgs`) |
| **CategoryScope** | Core (Enums) | Shared enum distinguishing selection context (`transaction`/`item`). | `CategoryScope` |

> **Rule of thumb**: *Drafts disappear **before** the Domain boundary; DTOs appear **after** it; Route Args never leave Presentation.*

## PR and commit standards

- Commit messages use the imperative mood (e.g., `feat: add ...`, `fix: ...`).
- PRs must be small/atomic and tests should be written first.
- Coverage target is >= 80% for new/changed code.
- Update relevant docs and document breaking changes or migrations.

## Security Guidelines

- **Secrets**: Never store sensitive data in plaintext; use secure storage.
- **Validation**: Validate and sanitize all inputs and server responses.
- **HTTPS**: Enforce HTTPS; apply OWASP Mobile/API best practices.
- **Rate-limiting**: Rate-limit or debounce requests where appropriate.

## Migration Notes (Legacy to Canonical)

### 1. Draft Operations
Replace index-based operations with stable ID methods:
```dart
// ✅ New (stable)
await controller.replaceDraftById(draftId, updatedDraft);
await controller.commitSingleById(draftId);
```

### 2. Parsing Waits
Move parsing waits from `TransactionFormScreen` to `ReceiptIntakeViewModel` (non-blocking).

### 3. Naming Updates
Rename internal fields for clarity (e.g., `_importStore` -> `_importSessionController`).

## Cross-domain architecture guardrails

- DI: GetIt only in `main.dart`/`service_locator`; routes/widgets use Provider + ViewModelHost.
- Layering: presentation must not import Domain entities/DTOs/repos.
- Constructors stay side-effect free.

## Naming and structure conventions

- Dart files snake_case; classes PascalCase.
- ViewModels suffix `ViewModel`; stores `Store`; services `Service`.

## Related docs

- [App Reference Index](/docs/app/reference/index.md)
- [UI/UX Guardrails](/docs/app/reference/ui-ux/ui-ux-guardrails.md)
- [Store Patterns and Testing](/docs/app/reference/stores/store-patterns-and-testing.md)