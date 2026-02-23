---
title: "Test Support Reference"
last_updated: 2026-02-14 # YYYY-MM-DD
tags: [reference, app, testing, test-support, harness]
---

# Test Support Reference

Brief summary: Comprehensive reference for the `test_support/` folder — deterministic time, hermetic file I/O, app/screen harnesses, mock helpers, keys contract, fakes inventory, conventions, troubleshooting, and migration tips. This folder centralizes testing infrastructure so tests are stable and easy to write.

## When to use this doc

Use this reference when writing, debugging, or extending tests that use the test_support infrastructure (harnesses, fakes, helpers, TestClock, FsScope). For testing **policy** (what you MUST do), see [Contribution Guidance](/docs/app/reference/contribution-guidelines.md). For testing **strategy** (screen tests, VM tests, router tests), see [Guardrails and Testing](/docs/app/reference/architecture/guardrails-and-testing.md).

## Folder Structure

```
test_support/
  fs/
    fs_scope.dart              # per-test MemoryFileSystem + docsDir provider
    fs_scope_test.dart         # guardrail tests
  harness/
    app_test_harness.dart      # full app providers + real navigation + helpers
    app_test_harness_test.dart # guardrail tests
    csv_import_e2e_test.dart   # example e2e using only fakes
    screen_harness.dart        # lightweight screen harness
    screen_harness_test.dart   # guardrail tests
  ids/
    system_ids.dart            # canonical IDs for readability in tests
  time/
    test_clock.dart            # deterministic time for fixtures/builders
```

## TestClock Usage

Use a fixed "now" for any fixture that needs a timestamp.

```dart
import 'test/test_support/time/test_clock.dart';

setUpAll(() {
  TestClock.setNow(() => DateTime.utc(2025, 01, 01));
});
```

> **Rule:** no `DateTime.now()` in fixtures/builders—use `TestClock.now()`.

## FsScope Usage

Each test gets its own in-memory FS and docs dir provider.

```dart
import 'test/test_support/fs/fs_scope.dart';

test('persist & open uses isolated FS', () async {
  await FsScope.run((s) async {
    // Example with our FakeFileStorageService
    final storage = FakeFileStorageService(
      logging: FakeLoggingService(),
      fs: s.fs,
      docsDir: s.docsDir,
    );

    final tmp = s.fs.file('/tmp/receipt.jpg')..createSync(recursive: true);
    final handle = await storage.saveToPermanentLocation(tmp);
    final file = await storage.open(handle);

    expect(await file.exists(), isTrue);
  });
});
```

> **Rule:** any test that touches files runs inside `FsScope`.

## AppTestHarness Usage

Providers, real navigation, and helpers in one place.

```dart
import 'test/test_support/harness/app_test_harness.dart';

testWidgets('transfer flow navigates and saves', (tester) async {
  final h = AppTestHarness();
  h.seedAllBasicData();

  final observer = RecordingNavigatorObserver();
  await h.pumpRoute(
    tester,
    routeName: '/crossAccountTransfer',
    observer: observer,
  );

  // Interact via semantic keys (must exist in prod code)
  await h.tapByKey(Keys.transferSubmit, tester);

  // Verify navigation happened
  expect(observer.lastPushedRouteName, isNotNull);
});
```

**Highlights**

* Real navigation via a `Navigator` + `NavigatorObserver`.
* Provider tree that mirrors `main.dart` (but with fakes).
* Seeding helpers: `seedTwoAccounts()`, `seedBasicCategories()`, `seedSimpleTransaction()`, `seedAllBasicData()`.
* Interaction helpers: `tapByKey`, `enterTextByKey`, `waitForSnackBar`.

> **Rule:** use `AppTestHarness` for any screen or flow that depends on multiple providers or navigation.

## ScreenHarness Usage

Use for focused tests when you don't need the full app.

```dart
final h = ScreenHarness(
  providers: [
    // add the minimal providers your screen needs
  ],
  onGenerateRoute: (settings) {
    if (settings.name == '/test') {
      return MaterialPageRoute(builder: (_) => const MyScreen());
    }
    return null;
  },
);

await h.pumpRoute(tester, routeName: '/test', routeArgs: {'id': 42});
```

## Route Args in Tests

**Rule:** `routeArgs` must be primitives (`int`, `String`, `bool`, `double`) or a `Map<String, dynamic>` containing only primitives. Never pass typed Args objects or domain objects—routes will convert primitives to typed Args internally.

## Route Args Examples

**Example 1: Parse File Route**
```dart
testWidgets('parseFile route builds VM with typed args and renders', (tester) async {
  final h = AppTestHarness();

  await h.pumpRoute(
    tester,
    routeName: '/parseFile',
    routeArgs: {
      'sourceFileId': 42,
      'accountId': 7,
      'transactionType': 'decrease', // or 'increase'
    }, // primitives only
  );

  // Assert: screen is rendered via VM state; no ModalRoute used in widget code.
  expect(find.text('Parse file'), findsOneWidget);
});
```

**Example 2: Add Transaction Route**
```dart
testWidgets('addTransaction route builds VM with typed args and renders', (tester) async {
  final h = AppTestHarness();
  h.seedTwoAccounts(); // Ensure accounts exist

  await h.pumpRoute(
    tester,
    routeName: '/addTransaction',
    routeArgs: {
      'accountId': 1,
      'transactionType': 'increase', // or 'decrease'
    }, // primitives only
  );

  // Assert: screen is rendered via VM state; no ModalRoute used in widget code.
  expect(find.byKey(Keys.addTransactionSubmit), findsOneWidget);
});
```

**Example 3: Account Detail Route**
```dart
testWidgets('accountDetail route shows account details', (tester) async {
  final h = AppTestHarness();
  h.seedTwoAccounts();

  await h.pumpRoute(
    tester,
    routeName: '/accountDetail',
    routeArgs: {
      'accountId': 1,
    }, // single primitive
  );

  expect(find.byKey(Keys.accountDetail), findsOneWidget);
});
```

**Example 4: Routes with No Arguments**
```dart
testWidgets('home route renders without args', (tester) async {
  final h = AppTestHarness();

  await h.pumpRoute(
    tester,
    routeName: '/home',
    // routeArgs can be omitted or null
  );

  expect(find.byKey(Keys.homeScreen), findsOneWidget);
});
```

**Example 5: ScreenHarness with Primitives (Single-Screen Test)**
```dart
testWidgets('receipt intake screen shows progress', (tester) async {
  final vm = FakeReceiptIntakeVm();
  final h = ScreenHarness(
    providers: [
      ChangeNotifierProvider<ReceiptIntakeViewModel>.value(value: vm),
      Provider<ILoggingService>.value(value: FakeLoggingService()),
    ],
    onGenerateRoute: (settings) => MaterialPageRoute(
      builder: (_) => const ReceiptIntakeScreen(),
    ),
  );

  await h.pumpRoute(
    tester,
    routeName: '/parseFile',
    routeArgs: {
      'sourceFileId': 42,
      'accountId': 7,
      'transactionType': 'decrease',
    }, // primitives only - route doesn't build VM in ScreenHarness tests
  );

  expect(find.byType(LinearProgressIndicator), findsOneWidget);
});
```

## Localization in Tests

When a test renders widgets that use `AppLocalizations.of(context)`, add localization delegates and supported locales to the test `MaterialApp` to avoid null lookups:

```dart
MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  // ...
)
```

## Common Mistakes

**❌ DON'T pass typed Args objects:**
```dart
// WRONG
routeArgs: ReceiptIntakeArgs(
  sourceFileIdRaw: 42,
  accountIdRaw: 7,
  transactionType: TransactionType.decrease,
),
```

**✅ DO pass primitives:**
```dart
// CORRECT
routeArgs: {
  'sourceFileId': 42,
  'accountId': 7,
  'transactionType': 'decrease',
},
```

**Why:** Routes are responsible for parsing primitives and building typed Args. Tests should exercise the same code path as production.

## ScreenHarness vs AppTestHarness

**ScreenHarness:** For single-screen tests; inject fake VMs directly via `ChangeNotifierProvider.value`
- Route generator should not build VMs
- Use when testing UI behavior with injected state
- Example: Testing a screen's rendering based on VM state

**AppTestHarness:** For route/flow tests; router builds VMs from primitives via `ViewModelHost<T>`
- Router builds VMs from primitives and calls `vm.onReady(args)`
- Use when testing full Router → ViewModelHost → Screen composition
- Example: Testing navigation flows and route argument parsing

See the Testing Guidelines section in [Contribution Guidance](/docs/app/reference/contribution-guidelines.md) for the distinction.

## Keys Contract

* All interactive controls must use keys from `lib/shared/widgets/keys.dart`.
* **Field name:** `Keys.transactionSubmit`
  **String value:** `'transaction_submit'`
* Attach keys **directly** to `ElevatedButton`, `IconButton`, `TextField`, etc.
  For composites, wrap with a stable semantic key and give the inner child a `ValueKey` derived from the dynamic state.
* **Global uniqueness test:** Run `test/shared/keys_uniqueness_test.dart` to ensure no duplicate key string values exist across the app.

Example:

```dart
ElevatedButton(
  key: Keys.transactionSubmit,
  onPressed: vm.isSaving ? null : vm.saveTransaction,
  child: const Text('Save'),
);

KeyedSubtree(
  key: Keys.categoryPickerGrid,
  child: CategoryPickerGrid(
    key: ValueKey('type_${vm.model.transactionType}_cat_${vm.model.selectedCategoryId ?? 'none'}'),
  ),
);
```

> Tests **must prefer** `find.byKey(Keys.*)` over text/icon finders.

## Folder Deep-Dive

### TestClock

`/time/test_clock.dart`

* `TestClock.now()` → deterministic timestamp for fixtures.
* Set once per run in `setUpAll()` (or a bootstrap file).
* Use in builders/fixtures to avoid flakiness.

### FsScope

`/fs/fs_scope.dart`

* `FsScope.run((s) async { ... })` for one-off isolated FS.
* `s.fs` is a `MemoryFileSystem`; `s.docsDir` matches the app's `docsDir` signature.
* Works seamlessly with `FileHandle` and file-persistence services.

### Mock File Helpers

`/helpers/mock_file.dart`

* **`makeMockTempFile()`** for receipt/temp-file scenarios that need `existsSync()` behavior:
  ```dart
  final f = makeMockTempFile(path: '/tmp/receipt.jpg');           // existsSync => true
  final g = makeMockTempFile(path: '/gone.jpg', exists: false);   // existsSync => false
  ```
* **`makeMockFile()`** for generic file payloads where only path/size matter:
  ```dart
  final f = makeMockFile(path: '/dev/null/whatever.bin', size: 42);
  ```
* **Specialized helpers:** `makeMockCsv()`, `makeMockImage()`, `makeMockPdf()` for specific file types.

### Test Tokens

`/helpers/test_tokens.dart`

* **`makeTestTokens()`** creates complete `AppTokens` instances with custom money colors for testing:
  ```dart
  final testTokens = makeTestTokens(
    income: const Color(0xFFAA0000),
    expense: const Color(0xFF0000AA),
    transfer: const Color(0xFF00AA00),
  );
  ```
* Use this when verifying widgets use token colors instead of ColorScheme colors.
* Provides all 38 required AppTokens fields with sensible defaults for non-money tokens.

### AppTestHarness Details

`/harness/app_test_harness.dart`

* Composes **fakes** for stores/services/controllers, including:

  * **Core Services:** `FakeLoggingService`, `FakeFileStorageService`, `FakeCsvImportService`, `FakeReceiptParseService`
  * **Stores:** `FakeRootStore` (includes all sub-stores: `FakeAccountStore`, `FakeCategoryStore`, `FakeTransactionStore`, `FakeSourceFileStore`, `FakeCurrencyStore`, `FakeUnitStore`)
  * **Controllers:** `FakeImportSessionController(testMode: true)`
  * **ViewModels:** `FakeTransactionFormViewModel`, `FakeTransactionMatchScreenViewModel`, `FakeAccountCardViewModel`
  * **Additional Services:** `FakeLlmService`, `TestNavigationService`
  * **Database:** `FakeDatabase`
* **Navigation:** `HarnessNavigationService` + `RecordingNavigatorObserver`.
* **API:**

  * `pumpRoute(tester, routeName: '/x', routeArgs: {...}, observer: ...)`
  * `tapByKey`, `enterTextByKey`, `waitForSnackBar`
  * `seedTwoAccounts()`, `seedBasicCategories()`, `seedSimpleTransaction()`, `seedAllBasicData()`
  * `resetAllStores()`, `getCurrentState()`

### ScreenHarness Details

`/harness/screen_harness.dart`

* Lightweight route pump + providers, for focused screen tests.

### System IDs

`/ids/system_ids.dart`

* Canonical IDs for readability (`TestIds.system`, `userA`, `userB`).
* **Do not** bake "system == 1" into test logic—always pass IDs explicitly to helpers/builders.

## Conventions & contracts (copy this into new tests)

* **Routing & DI:** Build VMs in route builders; use `context.read<T>()`. Never call `GetIt` inside routes/VMs.
* **Route args:** primitives only → typed `*Args`. **Never pass typed Args objects or domain entities to `routeArgs`**—routes will convert primitives to typed Args internally. Both `ScreenHarness` and `AppTestHarness` enforce this via runtime validation.
* **Deterministic time:** use `TestClock` in fixtures/builders.
* **Hermetic FS:** run file tests within `FsScope`.
* **Keys:** required for all interactive controls; use `find.byKey()` in tests.
* **Minimal fallbacks:** only value objects/IDs; pass explicit args for business calls.
* **IDs over indices:** all public test helpers accept IDs.
* **Error mapping:** preserve validation messages; map the rest to a generic message and log via `ILoggingService`.

## Examples

### CSV Import E2E

See `harness/csv_import_e2e_test.dart` for:

* Streaming progress + drafts,
* Matching & commit,
* Persist-first receipt scan,
* Continuation imports, overrides precedence, cancel semantics.

### File Persistence

Use `FsScope` + `FakeFileStorageService` to test `FileHandle`-based flows without touching disk.

## Troubleshooting

* **Widget not found by key:** ensure the production widget has the semantic key (and you're not wrapping it in a parent that steals taps).
* **Route didn't push:** add a `RecordingNavigatorObserver` and assert `lastPushedRouteName`. Check your `onGenerateRoute`.
* **File not found:** you likely didn't run in `FsScope` or your path is outside `/docs`—use `FileHandle` and the scope's `docsDir`.
* **Flaky time assertions:** switch fixtures to `TestClock.now()`.
* **MissingStubError on file operations:** use `makeMockTempFile()` for receipt/temp-file scenarios that need `existsSync()` behavior, or `makeMockFile()` for generic file payloads.

## Migration Tips

* Replace **text/icon** finders with **keys**.
* Replace bespoke `MaterialApp` scaffolds with `AppTestHarness`/`ScreenHarness`.
* Replace global `MemoryFileSystem()` usage with `FsScope`.
* Replace index-based draft ops with `*ById` variants.
* Remove heavy Mocktail fallbacks; pass explicit arguments.

## Adding New Helpers/Fakes

* New fakes that expose state must extend `ChangeNotifier` and call `notifyListeners()` on change.
* Put broadly useful helpers in `test_support/` so the whole test suite can reuse them.
* Add compact guardrail tests beside the helper (`*_test.dart`) to prevent regressions.

### Complete Fakes Inventory

**All available fakes are listed above in the `/harness/app_test_harness.dart` section.** When adding new fakes:

1. **Check existing fakes first** - avoid duplication by reusing existing fakes in `test/fakes/`
2. **Update this list** - add new fakes to the inventory above
3. **Follow naming convention** - use `Fake` prefix for fakes, `Mock` prefix for mocks
4. **Add to AppTestHarness** - if broadly needed, include in the harness providers
5. **Update provider integration test** - ensure new fakes work with Provider wiring

**Prevent duplication:** Before creating a new fake, search `test/fakes/` to see if similar functionality already exists.

## Related docs

- [Testing Reference Index](/docs/app/reference/testing/index.md)
- [Guardrails and Testing](/docs/app/reference/architecture/guardrails-and-testing.md)
- [Contribution Guidance](/docs/app/reference/contribution-guidelines.md)
- [Store Patterns and Testing](/docs/app/reference/stores/store-patterns-and-testing.md)
- [ImportSessionController Reference](/docs/app/reference/controllers/import-session-controller.md)
