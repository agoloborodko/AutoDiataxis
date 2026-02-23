---
title: "Guardrails and Testing (Domain-Scoped)"
last_updated: 2026-02-14 # YYYY-MM-DD
tags: [reference, app, architecture, guardrails, testing]
---

# Guardrails and Testing (Domain-Scoped)

Brief summary: Enforcement of architectural patterns, dependency injection rules, and testing strategies.

## When to use this doc

Use this doc to understand **how to implement** screens, routes, and tests correctly. Adherence to these guardrails is mandatory.

## Presentation Patterns (Router / VM / Screen)

### 1. Route Arguments
- Always pass **primitives** in `RouteSettings.arguments` (JSON-safe: `int`, `String`, `bool`).
- The router builds a **typed `*Args`** object (presentation-only) from primitives.
- **Never** pass Domain objects, ViewModels, or Services through route arguments.

```dart
class ParseFileArgs {
  final int sourceFileIdRaw;
  final int accountIdRaw;
  const ParseFileArgs({required this.sourceFileIdRaw, ...});
}
```

### 2. Router (Composition Root)
The router is the **only** place where dependency injection happens for the presentation layer.

- **✅ CORRECT: Provider-based DI**
  ```dart
  // lib/app/routes/app_router.dart
  Route<dynamic> buildParseFileRoute(RouteSettings settings) {
    // 1. Parse primitives
    final args = ParseFileArgs.fromRoute(settings.arguments);
    
    return MaterialPageRoute(
      builder: (ctx) {
        // 2. Resolve dependencies via Provider (context.read)
        final vm = ParseFileViewModel(
          importController: ctx.read<IImportSessionController>(),
          navigationService: ctx.read<INavigationService>(),
        );
        
        // 3. Bind VM to Screen via ViewModelHost
        return ViewModelHost<ParseFileViewModel>(
          vm: vm,
          onReady: (vm) => vm.onReady(args),
          child: const ParseFileScreen(), // Screen is "dumb"
        );
      },
      settings: settings,
    );
  }
  ```

- **❌ WRONG: GetIt in Routes**
  ```dart
  // NEVER DO THIS
  final vm = ParseFileViewModel(
    importController: GetIt.I<IImportSessionController>(), // Creates duplicate instance!
  );
  ```

### 3. Screen Role
- **Pure rendering**: Reads state (`vm.isBusy`, `vm.error`) and wires events (`vm.submit()`).
- **No Logic**: No `ModalRoute.of`, no `GetIt`, no side-effects in constructor.
- **Binding**: Uses `context.watch<TheVm>()`.

## Dependency Injection (DI) Rules

### Critical Rule: No GetIt in Routes or VMs
- **GetIt is Bootstrap-Only**: Only `lib/main.dart` and `lib/core/**/service_locator.dart` may use `GetIt`.
- **Use Provider**: Routes and ViewModels must obtain dependencies via `context.read<T>()`.
- **Why?** Mixing GetIt and Provider creates duplicate service instances, breaking state consistency (e.g., two different Stores).

### DI Guidelines
- **Inject via Constructor**: Classes (VMs, Stores, UseCases) must declare dependencies as `final` fields in the constructor.
- **Register in Setup**: Services/Stores are registered in `setupServiceLocator()` (GetIt) and exposed via `MultiProvider` in `main.dart`.
- **Tests**: Override registrations or pass Fakes directly to constructors.

## Routing Surface Area

Key routes for receipt ingestion and transaction management:

| Route | Purpose | Arguments |
| :--- | :--- | :--- |
| **`/parseFile`** | Entry point for receipt processing | `{sourceFileId, accountId, type}` |
| **`/transactionMatch`** | Handle multiple drafts/matches | `{draftIds: List<int>}` |
| **`/draftEdit`** | Edit individual transaction drafts | `{draftId: int}` |
| **`/transactionUpdate`** | Update existing transactions | `{transactionId: int}` |
| **`/crossAccountTransfer`** | Transfers between accounts | `{fromAccountId, toAccountId}` |

> **Note**: The legacy `/receiptParsing` route has been removed.

## Error Handling & Logging

- **Service**: Use `ILoggingService` for `logInfo`, `logWarning`, `logError`.
- **User-Facing**: ViewModels expose friendly `error` strings (e.g., "Invalid file format").
- **Technical**: Log full details + stack traces via the service. Do not show raw exceptions to users.

## Testing Strategy

### 1. Screen Tests (Pure UI)
- **Goal**: Verify rendering and wiring.
- **Method**: Inject a **Fake VM** using `ChangeNotifierProvider.value`.
- **Do not** spin up real stores or parse routes.
```dart
final vm = FakeParseFileVm()..setBusy(progress: 0.42);
await tester.pumpWidget(
  ChangeNotifierProvider<ParseFileViewModel>.value(
    value: vm,
    child: const MaterialApp(home: ParseFileScreen()),
  ),
);
expect(find.byType(LinearProgressIndicator), findsOneWidget);
```

### 2. ViewModel Tests (Business Flow)
- **Goal**: Verify logic, navigation, and state changes.
- **Method**: Instantiate VM with **Fakes/Mocks** for services. Call `vm.onReady(args)`.
- **Assert**: State changes (`isBusy`), method calls on mocks.

### 3. Router Tests (Composition)
- **Goal**: Verify argument parsing and DI wiring.
- **Method**: Pump the route with `navigator.pushNamed`.
- **Assert**: Correct `args` are parsed; VM is constructed with dependencies.

## Category Management & Pickers

Category pickers and management screens follow the same Router → ViewModelHost → Screen pattern.

### Scope Filtering
- Category pickers accept an optional **scope filter** (`CategoryScope.transaction` or `CategoryScope.item`).
- Bottom sheets used in breakdown item editing must filter by `CategoryScope.item` so only item-scoped categories appear.
- Presentation may import shared enums under `lib/core/enums/**` (e.g., `CategoryScope`), but must not import Domain entities/DTOs/repositories.

### Deleted Category Display
- Lists exclude deleted categories by construction (repository-owned filtering).
- For historical display (existing records referencing deleted categories), widgets resolve a per-ID presentation projection (e.g., `CategoryDisplay` via `categoryStore.getDisplayById`) that can surface `deleted: true` for a read-only label.
- Do not pass Domain entities into widgets for this purpose.

### Auto-Dismiss Behavior
- Item-level category picker bottom sheets close immediately after selection; the row updates via the selection callback and displays the chosen category (or a deleted label when applicable).

### Example Route
```dart
// lib/app/routes/category_management_route.dart
final class CategoryManagementArgs {
  final String initialScopeName; // 'transaction' | 'item' (primitive)
  const CategoryManagementArgs({required this.initialScopeName});
  static CategoryManagementArgs parse(Object? raw) { /* validate primitives */ }
}

Route<dynamic> buildCategoryManagementRoute(RouteSettings settings) {
  final args = CategoryManagementArgs.parse(settings.arguments);
  return MaterialPageRoute(
    settings: settings,
    builder: (ctx) {
      final vm = CategoryManagementScreenViewModel(rootStore: ctx.read<IRootStore>());
      return ViewModelHost(vm: vm, onReady: (vm) => vm.onReady(args), child: const CategoryManagementScreen());
    },
  );
}
```

## NavigationTarget & Match-Aware Stack Replacement

### NavigationTarget Record
Navigation intents are centralised in the `NavigationTarget` record:

```dart
// lib/core/navigation/navigation_target.dart
typedef NavigationTarget = ({
  String route,
  Map<String, Object?> args,
  bool replace,
});
```

### Match Awareness
- `TransactionMatchItemViewModel.navigationTarget(fromMatch: bool)` derives the route and primitive arguments for every card on `TransactionMatchScreen`.
- The method never sends models across the wire—only IDs such as `transactionId`, `accountId`, or `draftId`.
- `fromMatch` indicates whether navigation originates from an existing match. The screen passes `false`, so cards opened from the match grid push onto the stack. When a form jumps to its peer, it sets `replace: true` to prevent the stack from growing.

### Form-Level Match Awareness
`TransactionFormViewModel` owns match awareness for both `/transactionUpdate` and `/draftEdit`. On `onReady` it queries `ImportSessionController.idMatches` to expose:
- `isMatched` / `matchedSide` — whether the current draft or transaction has a partner.
- `peerNavigationTarget()` — the `NavigationTarget` for the opposite side, always with `replace: true` to keep the navigation stack flat.

### MatchedLinkBanner
- Lives entirely in the form screens (`TransactionFormScreen` and `CrossAccountTransferScreen`).
- Rendered from VM state; no banner-specific route arguments are passed.
- When tapped, the VM calls `INavigationService.navigateTo(peer.route, ... replace: true)`. Both sides stay in sync without additional route data.

## File Lifecycle (Persist-First)

```
Temp File → persistTempFile() → Permanent Storage → Link on Commit
                ↓
        Thumbnails in /draftEdit via pendingFileIdForDraft + openFile
```

**One-Copy Rule:** Files are stored once and linked to transactions upon commit. No duplicate storage or complex cleanup logic.

## Related docs

- [Architecture Overview](/docs/app/explanation/architecture-overview.md)
- [Project Structure and Boundaries](/docs/app/reference/architecture/project-structure-and-boundaries.md)
- [Contribution Guidelines](/docs/app/reference/contribution-guidelines.md)
- [Test Support Reference](/docs/app/reference/testing/test-support-reference.md)
