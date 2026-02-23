---
title: "Known Issues and Tech Debt"
last_updated: 2026-02-21 # YYYY-MM-DD
tags: [reference, app, operations, known-issues, tech-debt, architecture]
---

# Known Issues and Tech Debt

Brief summary: Consolidated tracker of known architectural issues, resolved decisions, and unresolved tech debt. Each entry preserves original problem analysis, proposals, and status from legacy migration records.

## When to use this doc

Use this doc to check the status of known architectural issues before starting related work. If you are working on DI, routing, screen patterns, provider dependencies, or domain layering, check here first for context on past decisions and open items.

## Domain Source File Repository: IO and DTO Leak

**Status:** Open | **Severity:** Architecture violation (layering); low runtime risk, high architectural debt | **Owners:** Platform/Domain

### Problem

The domain-layer repository interface for source files imports `dart:io` and uses DTOs, violating the architecture rules that the Domain layer must be framework-agnostic and DTO-free.

- Violating file: `lib/core/domain/contracts/i_source_file_repository.dart`
  - Imports `dart:io` and returns `io.File` from a domain contract.
  - Uses DTOs (`NewSourceFileDto`, `UpdateSourceFileDto`) in method signatures.

All tests are currently green, but this creates long-term coupling that makes the domain hard to test and port.

> **Canonical rules:** See [Project Structure and Boundaries](/docs/app/reference/architecture/project-structure-and-boundaries.md) — §Layer Boundaries (Domain must not import `dart:io` or DTOs) and §File Abstractions (`FileHandle` only in Domain).

### Impact

- Domain cannot be reused without `dart:io`.
- DTOs leak persistence concerns into Domain contract.
- Harder to mock and reason about boundaries; increases accidental complexity during future refactors.

### Proposal

1. **Remove `dart:io` and DTOs from the domain contract** `ISourceFileRepository`.
   - Replace `Future<io.File> openFile(int sourceFileId)` with storage-layer access via `IFileStorageService` using `FileHandle`.
   - Adjust method signatures to use domain entities/IDs only. Mapping from DTOs happens in the repository implementation (Data layer) or in application services before crossing the boundary.

2. **Move DTO usage** (`NewSourceFileDto`, `UpdateSourceFileDto`) into the repository implementation (`lib/core/repositories/source_file_repository.dart`) and/or application layer services/stores that orchestrate persistence.

3. **Use `FileHandle`** (or primitive IDs) when interacting across layers; do not surface `io.File` outside storage services.

4. **Keep diffs focused and incremental:**
   - Introduce new domain-safe methods first; update call sites.
   - Deprecate old methods (temporary) and remove once call sites are migrated.

### Phased Migration Plan

**Phase A — Introduce domain-safe contract:**
- Edit `lib/core/domain/contracts/i_source_file_repository.dart`:
  - Remove `import 'dart:io' as io;`
  - Replace any method returning `io.File` with a method returning a domain primitive or move the responsibility to `IFileStorageService` (preferred).
  - Replace DTO parameters with primitives/domain types (e.g., fields or a simple domain request object local to domain, not a DTO).

**Phase B — Update Data implementation:**
- Update `lib/core/repositories/source_file_repository.dart` to:
  - Map from DTOs to persistence rows internally; no DTO types cross into the domain contract.
  - Use `IFileStorageService` and `FileHandle` for opening/locating files.

**Phase C — Call site migrations:**
- Stores/services that currently pass DTOs to the domain contract should:
  - Either construct domain request objects/primitive args, or
  - Call the Data implementation directly with DTOs (keeping that usage inside the Data layer), depending on current layering decisions.

**Phase D — Cleanup:**
- Remove deprecated methods from the domain contract after all call sites are updated and tests are green.

### Acceptance Criteria

- `lib/core/domain/contracts/i_source_file_repository.dart` contains no `dart:io` imports.
- The domain contract has no methods that reference DTO types.
- File open/access is done via `IFileStorageService` and `FileHandle` (no `io.File` in domain contracts).
- `dart analyze` reports 0 errors; full test suite passes (green).

### Non-goals

- Changing business rules or UI behavior.
- Altering existing database schema.

### Risks & Mitigations

- **Risk:** Widespread churn at call sites. **Mitigation:** staged migration with temporary overloads/deprecations.
- **Risk:** Test breakages while signatures change. **Mitigation:** refactor by small patches; use fakes that return `FileHandle`.

### Testing Notes

- Update unit tests for repository implementation to verify DTO→row mapping remains correct.
- Ensure tests that interact with files use `FsScope` and `FileHandle` (per [Test Support Reference](/docs/app/reference/testing/test-support-reference.md)).

### Source File References

- `lib/core/domain/contracts/i_source_file_repository.dart`
- `lib/core/repositories/source_file_repository.dart`
- `lib/core/services/storage/file_handle.dart`

---

## Screen Constructor Patterns (Resolved)

**Status:** RESOLVED (2025, T0-T8) | **Priority:** HIGH | **Category:** Architecture / Code Standards | **Impact (historical):** 3-4 hours per screen test, maintenance burden, onboarding friction

### Problem Summary

Screens in the codebase followed **three different patterns** for ViewModel injection and route argument handling, with no clear documentation about which pattern applied to which screen:

- **Pattern A (Direct ViewModel Injection):** ViewModel passed as constructor parameter. Older pattern used by `HomeScreen`, `TransactionMatchScreen` (initially).
- **Pattern B (Provider-Only Injection):** No ViewModel constructor parameter; VM obtained via `context.read<T>()`. Used by `TransactionFormScreen` and most newer screens.
- **Pattern C (Route Arguments with Raw Values):** Screen expects route arguments cast from `settings.arguments`. Used by `AddTransactionScreen`, `CrossAccountTransferScreen`.

This inconsistency caused compilation errors when the wrong pattern was used, trial-and-error to discover correct patterns, and breaking changes when patterns were migrated (e.g., `TransactionMatchScreen` changed from Pattern A to B mid-development with no documentation).

> **Canonical pattern:** See [Guardrails and Testing](/docs/app/reference/architecture/guardrails-and-testing.md) — §Presentation Patterns for the standardized Provider-only pattern now enforced across all screens.

### Decision

Evaluated 3 solutions:

1. **Standardize on Single Pattern (Provider-Only)** — 8-19 hours, HIGH priority. Adopt Pattern B for ALL screens.
2. **Document Route Argument Patterns** — 2.5 hours, HIGH priority. Immediate documentation value.
3. **Type-Safe Route Builders** — 20-30 hours, MEDIUM priority. Long-term architectural improvement, deferred.

**Chose Solution 1** (standardize on Pattern B) with Solution 2 as supporting documentation. Solution 3 deferred for future evaluation.

**Estimated ROI:** 30-50 hours saved per quarter after standardization. Break-even: 1-2 quarters.

### Resolution (T0-T8)

All screens now follow a **single canonical pattern**:

1. **Screens are lean widgets** — No `viewModel` constructor parameter
2. **ViewModels provided via Provider** — Screens use `context.watch<VM>()` or `context.read<VM>()`
3. **Routes compose VMs** — Routes create VM separately, then pass to `ViewModelHost<T>` with `vm: vm` pattern
4. **Route args are primitives** — Routes parse primitives and build typed `*Args` DTOs
5. **GetIt is bootstrap-only** — Only `main.dart` and `service_locator.dart` use GetIt

### Migration Status

All screens have been migrated to the canonical pattern (verified against story.md T3-T7):

| Task | Screen | Verification | Status |
| :--- | :--- | :--- | :--- |
| **T3 - Summary Module** | `HomeScreen` | Uses `context.watch<HomeScreenViewModel>()` | Migrated |
| **T3 - Summary Module** | `AccountDetailScreen` | Uses `context.watch<AccountDetailScreenViewModel>()` | Migrated |
| **T4 - Transaction Management** | `AddTransactionScreen` | Uses `context.watch<AddTransactionScreenViewModel>()` | Migrated |
| **T4 - Transaction Management** | `CrossAccountTransferScreen` | Uses `context.watch<CrossAccountTransferScreenViewModel>()` | Migrated |
| **T5 - Category Management** | `CategoryManagementScreen` | Uses `context.watch<CategoryManagementViewModel>()` | Migrated |
| **T6 - Transaction Match** | `TransactionMatchScreen` | Uses `context.watch<TransactionMatchScreenViewModel>()` | Migrated |
| **T2 - Receipt Intake** | `ReceiptIntakeScreen` | Uses `context.watch<ReceiptIntakeViewModel>()` | Migrated |

All routes use Provider-based DI:
- All routes in `lib/app/routes/` use `ctx.read<T>()` for dependency resolution
- All routes create VM separately, then pass to `ViewModelHost<T>` with `vm: vm` pattern
- No GetIt usage in route files
- All routes use `ViewModelHost<T>` for VM lifecycle management

### Enforcement

- **Static Analysis:** `custom_lint` rules ban GetIt outside bootstrap and `ModalRoute.of` in features
- **CI Gates:** Custom lint runs in CI and blocks merges on violations
- **Code Review:** PR checklist enforces pattern compliance (see [Contribution Guidance](/docs/app/reference/contribution-guidelines.md) — §Code Review Checklist)

### Lessons Learned

1. **Single pattern reduces cognitive load** — Developers no longer need to guess which pattern to use
2. **Provider-based DI prevents duplicate instances** — Eliminates state inconsistency bugs
3. **Typed Args improve safety** — Compile-time validation of route arguments
4. **Documentation is critical** — Clear examples prevent regression
5. **Example consistency matters** — Examples must match actual codebase patterns (`vm: vm` not `create:`)

### Related Tasks

- T0: Project Setup & Guardrails (custom_lint rules)
- T1: Bootstrap DI Clarification
- T2: Routing Pattern & Typed Args
- T3: Screen Migration - Summary Module
- T4: Screen Migration - Transaction Management
- T5: Screen Migration - Category Management
- T6: Transaction Match Verification
- T7: Shared Widget Decoupling
- T8: Test Suite Updates
- T9: Documentation Consolidation

### Pattern Detection Quick Reference

**Pattern A (Direct ViewModel) — DEPRECATED:**
```dart
// Look for ViewModel in constructor
class MyScreen extends StatefulWidget {
  final MyScreenViewModel viewModel; // ← Pattern A indicator
  const MyScreen({required this.viewModel});
}
```

**Pattern B (Provider-Only) — CANONICAL:**
```dart
// No ViewModel in constructor
class MyScreen extends StatelessWidget {
  const MyScreen({super.key}); // ← Pattern B indicator (no params)

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MyScreenViewModel>(); // ← Pattern B confirmation
    return const SizedBox.shrink();
  }
}
```

**Pattern C (Route Arguments) — CHECK route_builder.dart:**
```dart
// Check route_builder.dart for argument type
case '/myScreen':
  final arg = settings.arguments as SomeType; // ← Pattern C indicator
```

### Migration Checklist Per Screen

- [ ] Remove `viewModel` parameter from screen constructor
- [ ] Add ViewModel lookup in `initState`: `_vm = context.read<T>()`
- [ ] Add ViewModel listener: `_vm.addListener(_onViewModelChanged)`
- [ ] Remove listener in `dispose`: `_vm.removeListener(_onViewModelChanged)`
- [ ] Update route registration to use `ViewModelHost`
- [ ] Update all tests to provide ViewModel via `Provider`
- [ ] Update test documentation/examples
- [ ] Run tests: `flutter test path/to/screen_test.dart`
- [ ] Run analyzer: `dart analyze`
- [ ] Manual verification: Launch app and test screen

---

## Opaque Provider Dependencies (Unresolved)

**Status:** UNRESOLVED | **Priority:** HIGH | **Category:** Developer Experience / Test Infrastructure | **Impact:** 2-3 hours per complex screen test, affects ALL screen tests

### Problem

Screen widgets have complex provider dependencies that are not documented or discoverable without deep code inspection. Errors when dependencies are missing are often cryptic and appear **sequentially** rather than all at once — each test run reveals only the next missing provider, requiring multiple iterations.

**Real-world impact example:** Setting up `CrossAccountTransferScreen` tests required discovering 6 providers through 6 separate error cycles, plus hidden requirements (minimum 2 seeded accounts with valid currency IDs; if only 1 account exists, screen silently fails or behaves incorrectly). Total setup code: 40+ lines just to provide dependencies.

**Representative error cycle** (from `AddTransactionScreen`):
```dart
// Run 1: Error: Could not find Provider<IRootStore>
// Run 2: Error: Could not find Provider<ILoggingService>
// Run 3: Error: Could not find Provider<INavigationService>
// Run 4: Error: Could not find Provider<SaveTransactionUseCase>
// → 4 test runs to discover all 4 missing providers
```

### Impact Summary

- **Time waste**: ~2-3 hours per screen test spent iteratively fixing provider setup
- **Trial-and-error debugging**: Run test, identify missing provider, add it, repeat
- **Code inspection required**: No way to discover requirements without reading screen implementation
- **Maintenance burden**: Future changes to provider requirements break tests silently
- **Onboarding friction**: New developers must learn this pattern through pain

### Proposed Solutions

#### Solution 1: Document Provider Requirements in Screen Documentation

**Effort:** 4.5-5.5 hours | **ROI:** 1-2 sprints | **DX Rating:** Good

Add standardized dartdoc comments to all screens listing required providers, their types (`ChangeNotifierProvider` vs `Provider`), and a minimum test setup example. Zero code changes required — immediate value through documentation alone. Document 5-10 most commonly tested screens first, then backfill incrementally. Add to contribution guide as mandatory for new screens.

#### Solution 2: Screen-Specific Test Harness Builders

**Effort:** 5-6 hours (8-10 with refactoring) | **ROI:** 2-3 sprints | **DX Rating:** Excellent

Create pre-configured test harness builders for complex screens in `test/helpers/screen_harness_builders.dart`. Each builder provides all required providers with sensible defaults, reducing setup from 40+ lines to 3 lines while remaining overridable for specific tests.

#### Solution 3: Enhanced Provider Error Messages

**Effort:** 10-20 hours | **ROI:** 5-10 sprints | **DX Rating:** Great

Improve `ProviderNotFoundException` to list ALL missing providers at once instead of failing on the first one. Three implementation options: custom Provider wrapper, contribute to Provider package, or custom test-only validation helper. Lower ROI than Solutions 1 & 2 due to implementation complexity.

### Comparison

| Solution | Effort | ROI | Maintainability | Developer Experience |
| :--- | :--- | :--- | :--- | :--- |
| **1. Documentation** | 4-5 hours | 1-2 sprints | Easy | ⭐⭐⭐ Good |
| **2. Test Builders** | 5-6 hours | 2-3 sprints | Easy | ⭐⭐⭐⭐⭐ Excellent |
| **3. Enhanced Errors** | 10-20 hours | 5-10 sprints | Complex | ⭐⭐⭐⭐ Great |

### Recommended Implementation Order

1. **Week 1**: Implement Solution 1 (Documentation) — Immediate value, low effort
2. **Week 2-3**: Implement Solution 2 (Test Builders) — High value for complex screens
3. **Future**: Consider Solution 3 (Enhanced Errors) — Only if Solutions 1 & 2 prove insufficient

### Current Workaround

Developers must: run test → see error → identify missing provider → add provider to harness → repeat until all providers added. **Time cost: 1-2 hours per complex screen.**

### Estimated ROI

20-30 hours saved per quarter after initial 10-12 hour investment (Solutions 1 + 2).

## Related docs

- [Guardrails and Testing](/docs/app/reference/architecture/guardrails-and-testing.md) — Canonical DI, routing, and screen patterns
- [Project Structure and Boundaries](/docs/app/reference/architecture/project-structure-and-boundaries.md) — Layer boundaries and file abstractions
- [Repository Contracts and Naming](/docs/app/reference/repositories/repository-contracts-and-naming.md) — Repository and DTO boundary rules
- [Contribution Guidance](/docs/app/reference/contribution-guidelines.md) — Code review checklist
- [Test Support Reference](/docs/app/reference/testing/test-support-reference.md) — Test harnesses and helpers
- [Screen DI & Routing Standardization Plan (Archived)](/docs/app/reference/operations/screen-di-routing-standardization-plan.md) — Historical T3 implementation plan
- [Operations Reference](/docs/app/reference/operations/index.md)
