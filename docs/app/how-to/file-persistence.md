---
title: "File Persistence"
last_updated: 2026-02-14 # YYYY-MM-DD
tags: [how-to, app, files, persistence, storage]
---

# File Persistence

Brief summary: Task-oriented guide for handling file storage operations using the FileHandle pattern.

## When to use this doc

Use this guide when implementing file uploads, storage operations, or working with the FileStorageService. For architectural details, layer responsibilities, and FileHandle reference information, see [File Persistence Guardrails](/docs/app/reference/file-persistence/file-persistence-guardrails.md).

## Task: Save File

```dart
final pickerFile = await ImagePicker().pickImage(...);
final handle = await fileStorage.saveToPermanentLocation(File(pickerFile.path));
await repo.insertSourceFile(NewSourceFileDto(
  fileName: StoredFileName(handle.fileName), // value object, not a plain String — enforces domain naming rules
  uploadedAt: clock.now(),
  metadata: '{}',
));
```

## Task: Attach to Transaction

```dart
final sf = await store.attachTempFileToTransaction(txId, File(pickerFile.path));
```
Implementation:
1. `FileStorageService.save…`
2. `SourceFileRepository.insertSourceFile()`
3. `Repository.attachFileToTransaction()`

## Task: Display Image

```dart
FutureBuilder<File>(
  future: store.openFile(sourceFile.id),
  builder: (_, snap) {
    if (!snap.hasData) return const CircularProgressIndicator();
    return Image.file(snap.data!);
  },
)
```

## Task: Delete Files

To delete everything for a transaction:

```dart
await store.deleteFilesForTransaction(txId);
```
The store will:
1. fetch linked files,
2. `Future.wait` of physical delete + DB delete.

## Migration Reminder

When changing path logic or columns in `source_files`, **always**:
1. bump `schemaVersion`,
2. write an `onUpgrade` step (add column, back‑fill, alter table),
3. dump new schema JSON, regenerate helpers, and update migration tests.

## Related docs

- [File Persistence Guardrails](/docs/app/reference/file-persistence/file-persistence-guardrails.md)
- [Data Persistence](/docs/app/reference/architecture/data-persistence.md)
- [Database Migrations](/docs/app/how-to/database-migrations.md)
