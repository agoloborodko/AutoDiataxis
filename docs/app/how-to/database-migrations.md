---
title: "Database Migrations"
last_updated: 2026-02-14 # YYYY-MM-DD
tags: [how-to, app, database, migrations, drift]
---

# Database Migrations

Brief summary: Step-by-step guide for performing database schema migrations using Drift.

## When to use this doc

Use this guide when you need to change the database schema, write a migration, or verify migration tests. Follow these steps **for every breaking change** (add / drop / rename column, constraint, trigger, index).

For data persistence policies and schema rules, see [Data Persistence](/docs/app/reference/architecture/data-persistence.md) reference.

## Step 1: Export the *current* schema (baseline)

```bash
dart run drift_dev schema dump lib/core/database/app_database.dart drift_schemas/home_accounting/
```

The command stores a snapshot named `drift_schema_v#.json`; commit it to version control. ([Exporting schemas - Drift](https://drift.simonbinder.eu/migrations/exports/))

**NB: if current version already exists, it shouldn't change!**

## Step 2: Change the schema & update `onCreate`

* Edit table classes, views, triggers or indices.
* Reflect those changes in the `onCreate` callback so **new installs** get the latest schema immediately. ([The migrator API - Drift](https://drift.simonbinder.eu/migrations/api/))
* Bump `schemaVersion` in `AppDatabase`. ([Testing migrations - Drift](https://drift.simonbinder.eu/migrations/tests/))
* Run `dart run build_runner build --delete-conflicting-outputs` to regenerate code.

## Step 3: Export the *new* schema

```bash
dart run drift_dev schema dump lib/core/database/app_database.dart drift_schemas/home_accounting/
```

This writes `drift_schema_vN+1.json`, giving the migration tools both “before” and “after” states. ([Exporting schemas - Drift](https://drift.simonbinder.eu/migrations/exports/), [Testing migrations - Drift](https://drift.simonbinder.eu/migrations/tests/))

## Step 4: Generate migration-test scaffolding

```bash
dart run drift_dev schema generate \
  --data-classes --companions \
  drift_schemas/home_accounting \
  test/generated_migrations
```

Drift reads the two JSON files and creates:

* `schema_v#.dart` snapshots (old & new)
* `schema.dart` containing `GeneratedHelper`
* Skeleton data classes / companions for legacy versions

These are consumed by `SchemaVerifier` in our test suite. ([Testing migrations - Drift](https://drift.simonbinder.eu/migrations/tests/))

## Step 5: Write the migration in `AppDatabase.onUpgrade`

1. **Three-phase pattern**

   | Step | Purpose                                             | Notes                                                                                                                          |
   | ---- | --------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
   | 1️⃣  | *Easy DDL* – e.g. `ALTER TABLE … ADD COLUMN … NULL` | SQLite allows this without copy. ([The migrator API - Drift](https://drift.simonbinder.eu/migrations/api/))                    |
   | 2️⃣  | Back-fill / data fix-up                             | Use SQL or Dart (`customSelect`, `customStatement`).                                                                           |
   | 3️⃣  | `await m.alterTable(TableMigration(...))`           | Rebuild to add `NOT NULL`, `CHECK`, drop cols, etc. ([The migrator API - Drift](https://drift.simonbinder.eu/migrations/api/)) |

2. Re-create new/changed **indexes and triggers** (they’re dropped by `alterTable`). ([The migrator API - Drift](https://drift.simonbinder.eu/migrations/api/))

3. Finish with integrity checks:

```dart
await customStatement('PRAGMA foreign_key_check;'); // zero rows = OK
await customStatement('PRAGMA optimize;');
```

SQLite recommends these after complex DDL. ([Testing migrations - Drift](https://drift.simonbinder.eu/migrations/tests/))

### Example

```dart
if (from < 7) {
  // 1️⃣  Nullable shell column
  await customStatement('ALTER TABLE foo ADD COLUMN bar TEXT;');

  // 2️⃣  Back-fill
  final rows = await customSelect('SELECT id, path FROM foo').get();
  for (final r in rows) {
    await customStatement(
      'UPDATE foo SET bar = ? WHERE id = ?',
      [extract(r.read<String>('path')), r.read<int>('id')],
    );
  }

  // 3️⃣  Rebuild with NOT NULL + UNIQUE + CHECK
  await m.alterTable(TableMigration(
    foo,
    columnTransformer: {foo.id: foo.id, foo.bar: foo.bar},
  ));

  // Re-add supporting index
  await m.createIndex(Index(
    'idx_foo_bar',
    'CREATE UNIQUE INDEX idx_foo_bar ON foo(bar)',
  ));
}
```

## Step 6: Extend the migration test

Open `test/core/database/migration_test.dart` and cover:

| Aspect                     | How to test                                               | Why                                                                                                         |
| -------------------------- | --------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| **DDL drift**              | `verifier.migrateAndValidate(db, newVersion)`             | Ensures schema matches code. ([Testing migrations - Drift](https://drift.simonbinder.eu/migrations/tests/)) |
| **Data preservation**      | Insert rows under old schema, assert equality afterwards  | Avoids silent data loss.                                                                                    |
| **New constraints**        | Use `customInsert` to insert invalid data; expect failure | Companions can’t create `NULL` for non-null columns.                                                        |
| **Indexes created**        | `PRAGMA index_list('table');` contains new index          | Guards performance. ([Testing migrations - Drift](https://drift.simonbinder.eu/migrations/tests/))          |
| **Dropped columns absent** | `PRAGMA table_info` has no `file_path`                    | Confirms clean table. ([Testing migrations - Drift](https://drift.simonbinder.eu/migrations/tests/))        |
| **Foreign-key integrity**  | `PRAGMA foreign_key_check;` returns 0 rows                | Confirms cascades. ([Testing migrations - Drift](https://drift.simonbinder.eu/migrations/tests/))           |
| **Triggers survive**       | Operation violating trigger throws                        | Protects business rules.                                                                                    |
| **Idempotence**            | Run migration again → no-op                               | Real apps may reopen upgraded DB.                                                                           |

> **Tip:** enable FKs in every helper DB connection
> 
> ```dart
> await db.customStatement('PRAGMA foreign_keys = ON');
> ```
> 
> FK enforcement is connection-local. ([The migrator API - Drift](https://drift.simonbinder.eu/migrations/api/))

## Step 7: Commit & review

* Commit **both** JSON snapshots, generated Dart, migration code, and tests.
* PR reviewers verify this checklist and that CI (unit + migration tests) is green.

## Recovery and Rollback

### Pre-Migration Backups

* Before calling `driftDatabase.open()`, **copy** the existing SQLite file to a backup location if storage permits.
* On migration failure, **restore** this backup before retrying or notifying the user.

### Detecting Partial Migrations

* At app startup, query critical schema elements:

  ```dart
  final cols = await customSelect("PRAGMA table_info('source_files')").get();
  if (!cols.any((c) => c.read<String>('name') == 'file_name')) {
    // Incomplete migration -> rerun onUpgrade logic
  }
  ```
* Ship a **patch release** (version bump) that re-executes missing migration steps.

## Best Practices

### Idempotent DDL Operations

Use PRAGMA guards to prevent duplicate-column or duplicate-trigger failures:

```dart
final cols = await customSelect("PRAGMA table_info('source_files')").get();
final hasFileName = cols.any((r) => r.read<String>('name') == 'file_name');
if (!hasFileName) {
  await customStatement('ALTER TABLE source_files ADD COLUMN file_name TEXT;');
}

final triggers = await customSelect(
  "SELECT name FROM sqlite_master WHERE type='trigger' AND name='prevent_same_source_and_target_account'"
).get();
if (triggers.isEmpty) {
  await customStatement('CREATE TRIGGER prevent_same_source_and_target_account ...');
}
```

### Atomic Migrations

Drift wraps `onUpgrade` in a transaction and savepoint by default. You can also wrap migration logic in:

```dart
await transaction(() async {
  // migration steps...
});
```

This guarantees rollback on failure.

## Key References

* Exporting schemas  ([Exporting schemas - Drift](https://drift.simonbinder.eu/migrations/exports/))
* Testing migrations  ([Testing migrations - Drift](https://drift.simonbinder.eu/migrations/tests/))
* Migrator API & 12-step copy  ([The migrator API - Drift](https://drift.simonbinder.eu/migrations/api/))
* Step-by-step helper  ([Testing migrations - Drift](https://drift.simonbinder.eu/migrations/tests/))
* FK pragma discussion  ([The migrator API - Drift](https://drift.simonbinder.eu/migrations/api/))
* `PRAGMA foreign_key_check`  ([Testing migrations - Drift](https://drift.simonbinder.eu/migrations/tests/))
* `PRAGMA table_info`  ([Testing migrations - Drift](https://drift.simonbinder.eu/migrations/tests/))
* `PRAGMA index_list`  ([Testing migrations - Drift](https://drift.simonbinder.eu/migrations/tests/))
* Community advice on switching to drift-dev tooling  ([Testing migrations - Drift](https://drift.simonbinder.eu/migrations/tests/))
* Complex migrations & triggers  ([The migrator API - Drift](https://drift.simonbinder.eu/migrations/api/))

These updates clarify the correct **order of operations** (baseline export → edit schema → new export → generate stubs → write migration) and emphasise updating `onCreate` before writing `onUpgrade`, ensuring both fresh installs and upgrades share a single, authoritative schema definition.

## Related docs

- [Data Persistence](/docs/app/reference/architecture/data-persistence.md) - Identity rules, timestamp policy, Drift schema rules
- [File Persistence How-To](/docs/app/how-to/file-persistence.md) - Save, attach, display, and delete files
- [File Persistence Guardrails](/docs/app/reference/file-persistence/file-persistence-guardrails.md) - File storage architecture, FileHandle reference, and migration checklist for file-related schema changes
