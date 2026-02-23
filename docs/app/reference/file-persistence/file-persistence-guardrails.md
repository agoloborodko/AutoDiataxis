---
title: "File Persistence Guardrails"
last_updated: 2026-02-14 # YYYY-MM-DD
tags: [reference, app, file-persistence, storage]
---

# File Persistence Guardrails

Brief summary: Required file persistence flow, FileHandle usage, architecture layers, and test setup expectations.

## When to use this doc

Use this reference when implementing file storage, drafts, imports/exports, or file I/O tests. The goal is **portable, testable, bullet-proof** file storage that survives app reinstalls, device changes, and simulator UUID resets.

## Storing binary files (images, PDFs, ...)

We never persist absolute paths.
Instead, the infrastructure layer copies bytes into `<app-support>/receipts/<uuid>.<ext>` and returns a **FileHandle**.

**Flow summary:**

- UI → Draft → Store/Use-case → Entity/Repo/DTO → Drift; save first, process later.
- DB stores only the UUID+ext filename; absolute paths are rebuilt per platform via `FileHandle`.
- Avoid platform `File` types in domain; use `FileHandle`.
- Do not persist absolute paths.

## Layered Architecture

| Layer | Class / API | Responsibilities | Test strategy |
|-------|-------------|------------------|---------------|
| **Infrastructure** | **`FileStorageService`** | • Move picked temp files into the app's application support directory under `receipts/`.<br>• Generate a UUID + extension.<br>• Return a `FileHandle`.<br>• Provide `open()` and `delete()` helpers. | Inject a `MemoryFileSystem`, fixed `Uuid` factory, and stubbed `getApplicationSupportDirectory()` in unit tests. |
| **Repository** | **`SourceFileRepository`** | • CRUD on the `source_files` table.<br>• On delete: retrieves `FileHandle` then calls `FileStorageService.delete()` before removing the row.<br>• `openFile(id)` → uses storage to get a real `File`. | Use in‑memory Drift DB and mocked `IFileStorageService`. |
| **Store / ViewModel** | **`SourceFileStore`** | • Orchestrates multi‑step flows:<br>  1. save temp file → `FileHandle`.<br>  2. insert row → `SourceFile`.<br>  3. attach to transaction (optional).<br>• Exposes immutable `List<SourceFile>` for UI. | Mock repo + storage; inject deterministic `Clock`. |
| **UI** | Widgets | • Call store methods.<br>• Display thumbnail via `FutureBuilder` → `Image.file(await store.openFile(id))`. | Widget tests inject a `FakeSourceFileStore`. |

### Repository code snippet

```dart
// inside SourceFileRepository.openFile()
@override
Future<io.File> openFile(int sourceFileId) async {
  final sourceFile = await getSourceFileById(sourceFileId);
  if (sourceFile == null) {
    throw StateError('Source file not found: $sourceFileId');
  }
  final file = await _storage.open(_toHandle(sourceFile.fileName));
  return io.File(file.path);
}

/// Converts a domain StoredFileName to infrastructure FileHandle
FileHandle _toHandle(StoredFileName name) => FileHandle(
      name.value,
      fs: _fs,
      docsDir: _docsDir,
    );
```

## Path Storage Rationale

Why we don't store full paths in the DB: User directories differ per OS; unit tests run on `MemoryFileSystem`; therefore we persist only the UUID filename and rebuild the absolute path at runtime via `FileHandle.absolutePath()`.

## FileHandle Reference

```dart
// ✓ Domain-safe file reference
final handle = FileHandle(
  'a1b2c3d4.png',
  fs: const LocalFileSystem(),
  docsDir: () async => getApplicationSupportDirectory()
      .then((d) => const LocalFileSystem().directory(d.path)),
);
```

## File Lifecycle

```
UI (XFile) ──► FileStorageService.saveToPermanentLocation()
               │  (copy & returns FileHandle)
               ▼
       SourceFileRepository.insertSourceFile()
               │  (stores handle.fileName in DB)
               ▼
         SourceFileStore / widgets
               │  (later)
               ▼
       SourceFileRepository.openFile() ──► dart:io.File
```

## Best Practices

| Do | Don't |
| -- | ----- |
| `SourceFile(fileName: StoredFileName('11ff6a21.png'), ...)` | `SourceFile(path: '/tmp/foo.jpg')` |
| Inject `FileSystem` / `DocsDirProvider` | Call `File()` directly in domain code |

## Testing expectations (file I/O)

- File I/O tests must wrap in `FsScope`.
- Use `TestClock` for deterministic time.
- Receipt/import flows should use `FakeImportSessionController` / `FakeRootStore`.
- Integration flows should cover `/parseFile` → draft edit → commit when applicable.
- In unit tests use `MemoryFileSystem`; inject it into FileHandle / FileStorageService so no real I/O happens.

```dart
final fs = MemoryFileSystem();
final handle = FileHandle('test.png', fs: fs, docsDir: () async => fs.directory('/docs'));
```

## Migration Checklist

For contributors touching legacy code:

* Replace `File` field with `FileHandle` in any file under `lib/core/models`.
* Adapt constructor/factory.
* Update tests with the new helper from `test/fakes/fixtures/source_file_fixtures.dart`.

## FAQ

**Q: What about the `originalName` column for user-friendly display?**
A: Consider adding this in future migrations when user experience requires showing the original filename alongside the UUID-based storage name.

## Related docs

- [File Persistence How-To](/docs/app/how-to/file-persistence.md)
- [Store Patterns and Testing](/docs/app/reference/stores/store-patterns-and-testing.md)
- [Repository Contracts and Naming](/docs/app/reference/repositories/repository-contracts-and-naming.md)
- [Database Guardrails and Migrations](/docs/app/reference/database/database-guardrails-and-migrations.md)
- [UI/UX Guardrails](/docs/app/reference/ui-ux/ui-ux-guardrails.md)
- [App Reference Index](/docs/app/reference/index.md)
