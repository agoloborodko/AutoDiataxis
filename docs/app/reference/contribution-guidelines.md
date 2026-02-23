---
title: "Contribution Guidance (Domain-Scoped)"
last_updated: 2026-02-14 # YYYY-MM-DD
tags: [reference, app, contribution, governance]
---

# Contribution Guidance (Domain-Scoped)

Brief summary: Comprehensive guide for contributing code, tests, and architectural components.

## When to use this doc

Use this document as the primary reference for coding standards, testing patterns, and PR requirements.

## Code Organization & Style

- **Folders**: Feature-based (`lib/features/...`).
- **Naming**: `PascalCase` for types, `camelCase` for vars/functions. Prefix interfaces with `I`.
- **Formatting**: `dart format` required (line length ≤ 100).
- **Public APIs**: Document with dartdoc (`///`).
- **No Platform Types in Domain**: Use `FileHandle` instead of `dart:io.File`.

## Test-Driven Development (TDD)

Follow **Red → Green → Refactor** for new features.

### Process
1. **Start with interfaces**: Define method signatures.
2. **Dummy implementation**: Throw `UnimplementedError` to compile.
3. **Write failing tests (Red)**: Cover happy paths and edge cases.
4. **Implement minimal code (Green)**: Make tests pass.
5. **Refactor**: Improve structure while keeping tests green.

### TDD for Persist-First
1. **Test persist-then-process**: Assert that data is saved before processing starts.
2. **Mock Controller**: Verify persistence calls happen before logic execution.

## Testing Guidelines

### Policy
- **Harnesses**: All screen/widget tests **MUST** use `AppTestHarness` or `ScreenHarness`.
- **Fakes**: Use `Fake*` classes for services/stores (happy paths, state).
- **Mocks**: Use mocks only for error injection or interaction verification.
- **Time**: Inject `TestClock` (no `DateTime.now()`).
- **File I/O**: Use `MemoryFileSystem` via `FsScope`.

### Fakes vs Mocks
| Type | Usage |
| :--- | :--- |
| **Fakes** | Provider wiring, realistic state. Must call `notifyListeners()`. |
| **Mocks** | Error scenarios, checking call counts. |

### File Mocking Best Practices
Use `makeMockTempFile()` for receipt/temp-file scenarios:
- Stubs `path` + `existsSync()` (and optional `length()`).
- Perfect for tests that simulate "temp receipt present/absent" behavior.
- Prevents `MissingStubError` and makes intent obvious.

```dart
// Receipt attachment flows
final tempFile = makeMockTempFile(path: '/tmp/receipt.jpg');           // existsSync => true
final missingFile = makeMockTempFile(path: '/gone.jpg', exists: false); // existsSync => false
```

Use `makeMockFile()` for generic file payloads:
- When only path/size matter and you don't care about `existsSync()`.
- For file payloads from stores where you only call `length()`.

```dart
// Generic file payloads
final file = makeMockFile(path: '/dev/null/whatever.bin', size: 42);
```

Specialized helpers for specific file types: `makeMockCsv()`, `makeMockImage()`, `makeMockPdf()`.

### Error Mapping Contract
**Whitelist** user-safe validation errors (e.g., `ArgumentError`, optionally `FormatException`) → surface the original message.

All other exceptions → **map to "Unexpected error"** and log details via `ILoggingService`.

Tests must assert both behaviors (preserved validation message vs. generic message).

### Screen Tests (Mandatory)
```dart
// ✅ Correct
final h = AppTestHarness();
await h.pumpRoute('/screenName', args: {'id': 42});

// ❌ Wrong
await tester.pumpWidget(MaterialApp(...)); // Don't hand-roll harness
```

## Checklists

### Checklist for a New Aggregate
1. **IDs**: Value-objects for FKs and PKs.
2. **Draft**: Primitives only (Presentation layer).
3. **Entity**: Domain aggregate with invariants.
4. **Repository**: Interface in Domain, Implementation in Data.
5. **DTO**: Primitives only (Data layer).
6. **Use Case**: Business logic.
7. **Store**: State management.
8. **Widget**: Wired via Provider/VMHost.
9. **Migration**: Schema change + migration test.

### Code Review Checklist
- ✅ No `dart:io` in Domain.
- ✅ New dependencies injected via constructor.
- ✅ **Route files use Provider**, not GetIt.
- ✅ Route args are primitives → typed `*Args`.
- ✅ No `viewModel` params in screens.
- ✅ Only Stores call `notifyListeners()`.
- ✅ Tests use `AppTestHarness` and `FsScope`.
- ✅ Coverage ≥ 80%.

### Maintenance Checklist
- **New Route**: Add route definition, add route tests, update `receipt_routes_smoke_test`.
- **New Widget Key**: Add to `keys.dart`, add to `keys_uniqueness_test.dart`.
- **New Fake**: Extend `ChangeNotifier` (if applicable), update `provider_integration_with_fakes_test.dart`.

### PR Requirements
- **Tests First**: Write failing tests first.
- **Atomic**: One logical change per PR.
- **Coverage**: ≥ 80% for new code.
- **Messages**: Imperative mood (`feat: add user login`, not `added login`).

## Do's & Don'ts (Quick Reference)

**Do**
* Keep widgets lean; bind UI to VM state.
* Start async work in `onReady(args)`, never in constructors.
* Inject everything via constructors.
* Use ID-based operations (`deleteById`), not index-based.
* Follow the persist-first file handling pattern.

**Don't**
* Call `GetIt` inside ViewModels, Stores, Use Cases.
* Parse `ModalRoute` inside screens.
* Pass full objects across boundaries—use IDs.
* Use `Colors.*` in features (use `AppTokens`).

## Related docs

- [Project Structure and Boundaries](/docs/app/reference/architecture/project-structure-and-boundaries.md)
- [Guardrails and Testing](/docs/app/reference/architecture/guardrails-and-testing.md)
- [Test Support Reference](/docs/app/reference/testing/test-support-reference.md)
