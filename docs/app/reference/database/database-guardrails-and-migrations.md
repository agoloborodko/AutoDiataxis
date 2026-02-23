---
title: "Database Guardrails and Migrations"
last_updated: 2026-02-21 # YYYY-MM-DD
tags: [reference, app, database, drift, migrations]
---

# Database Guardrails and Migrations

Brief summary: Required database conventions, migration steps, and persistence format rules.

## When to use this doc

Use this reference when changing Drift schema, adding migrations, or validating DB-related tests.

## Database guardrails

- Bump `schemaVersion` on schema changes and keep `onCreate` in sync.
- Ensure `PRAGMA foreign_keys = ON` in `beforeOpen`.
- Migration sequence: baseline export → schema edits and `onCreate` update → new export → generated stubs → `onUpgrade` + migration tests.
- Include JSON dumps and migration tests in PRs that change schema.

## Naming conventions (Drift)

- Tables in `AppDatabase` use snake_case (e.g., `transaction_breakdowns`).
- Columns snake_case; FKs suffixed `_id`; junctions `<a>_<b>`.
- Indexes `idx_<table>_<cols>`.
- Migration tests named by version (e.g., `migration_vN_test.dart`).

## Persistence and time formats

- System timestamps stored as UTC Unix epoch integers in Drift (e.g., `created_at`, `updated_at`) using injected UTC `Clock`.
- `document_datetime` captures receipt date/time as naive value; store/display as provided (no timezone conversion).
- External/log payloads use ISO-8601 strings with timezone (`toIso8601String()`) for system events/requests.
- Do not rely on SQLite defaults/triggers for created/updated timestamps; use injected `Clock` at repository boundary.

## Testing expectations (DB)

- Migration tests are required for schema changes and must align with schema exports.
- Migration tests rely on drift schema exports; keep exports in sync with `onCreate`.
- Architecture/widget/navigation tests remain required; DB changes add migration coverage on top.

## Examples and anti-patterns

- Good: `integer().named('source_account_id').references(Accounts, #id, onDelete: KeyAction.restrict);`
- Good: `final createdAt = clock.now().toUtc();` then store `createdAt.millisecondsSinceEpoch ~/ 1000`.
- Anti-pattern: adding tables in a new file without `schemaVersion` bump/exports/tests.

## Related docs

- [Database Migrations How-To](/docs/app/how-to/database-migrations.md)

- [File Persistence Guardrails](/docs/app/reference/file-persistence/file-persistence-guardrails.md)
- [Repository Contracts and Naming](/docs/app/reference/repositories/repository-contracts-and-naming.md)
- [Run Local Checks](/docs/app/how-to/run-local-checks.md)
- [App Reference Index](/docs/app/reference/index.md)
