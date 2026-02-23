---
title: "Screen DI & Routing Standardization Plan (Archived)"
last_updated: 2026-02-21 # YYYY-MM-DD
tags: [reference, app, operations, architecture, di, routing, migration, archive]
---

# Screen DI & Routing Standardization Plan (Archived)

Brief summary: Historical implementation plan for task T3 — migrating Summary module screens to the canonical Provider-based DI and ViewModelHost presentation stack. This is an archived record of a completed migration; for the current canonical pattern see [Guardrails and Testing](/docs/app/reference/architecture/guardrails-and-testing.md).

## When to use this doc

Use this doc as a historical reference for how the Summary module screens were migrated to the canonical presentation stack. If you need the current screen/routing/DI rules, use [Guardrails and Testing](/docs/app/reference/architecture/guardrails-and-testing.md) instead.

## Project charter snapshot (archived)

### Project description (legacy charter intent)

This archive captures the historical charter that standardized screen composition around:

`Router (composition root) -> ViewModelHost<T> -> lean screen widget`

The intent was to remove mixed constructor/route patterns, keep DI route-centric, and make test setup deterministic.

### Objectives

1. Enforce one canonical screen/routing pattern.
2. Improve testability by removing screen-constructor VM wiring.
3. Keep dependency resolution Provider-based below bootstrap.
4. Document explicit migration boundaries and acceptance gates.
5. Preserve a repeatable rollout pattern for follow-on tasks.

### Non-goals

- Adopting a new router package.
- Rewriting domain models or stores.
- Expanding VM business logic beyond route wiring (`onReady(args)` contract).

## Scope

**In scope (T3 only):**
- `lib/features/summary/screens/home_screen.dart`
  - Remove `viewModel` constructor parameter
  - Remove `RouteAware`/`ModalRoute.of(context)` usage
  - Bind state via `context.watch<HomeScreenViewModel>()`
- `lib/features/summary/screens/account_detail_screen.dart`
  - Remove `RouteAware`/`ModalRoute.of(context)` usage
  - Keep outer screen lean, bind via `context.watch<AccountDetailScreenViewModel>()`
- Route composition updates to keep screens lean and DI correct
  - `lib/app/routes/home_route.dart` → wrap with `ViewModelHost<HomeScreenViewModel>` and resolve deps via Provider
  - `lib/app/routes/account_detail_route.dart` → keep Provider-based DI; chain an initial `fetchData()` in `onReady` (no `ModalRoute` usage in screen)
- Update Summary screen tests that directly construct the old screen signature
  - `test/features/summary/screens/home_screen_theme_test.dart`

**Out of scope:**
- Any Transaction Management, Category Management, or Match feature migrations (T4–T7)
- Shared widget decoupling (e.g., `active_import_banner.dart` still uses `ModalRoute`; that belongs to T7)
- Router package changes (no `go_router`/`auto_route` adoption)
- Business logic changes to VMs beyond wiring lifecycle as per docs

> **Grounding rules** (Provider-based DI, route args, screen role, ViewModelHost) are documented in the canonical [Guardrails and Testing](/docs/app/reference/architecture/guardrails-and-testing.md) reference and are not repeated here.

## Rollout plan snapshot (archived)

- Milestone 1: establish guardrails and typed route arguments.
- Milestone 2: migrate Summary, Transaction, and Category screen groups.
- Milestone 3: complete verification and test-harness alignment.
- Milestone 4: consolidate docs and close migration traceability.

## Files Changed

- `lib/features/summary/screens/home_screen.dart`
- `lib/app/routes/home_route.dart`
- `lib/features/summary/screens/account_detail_screen.dart`
- `lib/app/routes/account_detail_route.dart` (small onReady enhancement only)
- `test/features/summary/screens/home_screen_theme_test.dart`

## Implementation Steps

1. **HomeScreen migration (widget)** — Convert `HomeScreen` from StatefulWidget with `viewModel` parameter to StatelessWidget with no constructor DI. Remove `RouteAware` mixin, `routeObserverGlobal` subscription, and any `ModalRoute.of(context)` calls. In `build`, read the VM via Provider: `final vm = context.watch<HomeScreenViewModel>();`. Keep the existing body logic, but reference `vm` instead of `widget.viewModel`. Do not trigger side‑effects from the widget; fetching will be orchestrated by the route via `ViewModelHost.onReady`.

2. **Home route migration** — Update `lib/app/routes/home_route.dart` to construct the VM via Provider‑resolved deps and wrap the screen with `ViewModelHost<HomeScreenViewModel>`. Provide an `onReady` callback that triggers initial fetches. Return `child: const HomeScreen()`. Ensure all deps come from `ctx.read<...>()`; never use `GetIt` in this file.

3. **AccountDetailScreen cleanup (widget)** — The outer `AccountDetailScreen` already binds `vm = context.watch<AccountDetailScreenViewModel>()` and is StatelessWidget — keep that. Remove `RouteAware` and `ModalRoute` usage from `_AccountDetailScreenContent`. Keep the loading overlay logic driven by `vm.isLoading`. Do not trigger widget‑lifecycle fetches; initial and return‑from‑child refresh will be covered by route/VM methods invoked via `onReady`.

4. **AccountDetail route enhancement** — Keep the existing `AccountDetailArgs.parse(settings.arguments)` and VM composition. Change `onReady` to chain `await vm.onReady(args); await vm.fetchData();` so the first render shows up-to-date data without relying on `ModalRoute` lifecycle in the widget.

5. **Tests update (Summary)** — `test/features/summary/screens/home_screen_theme_test.dart` constructs the screen with `HomeScreen(viewModel: vm)`. Update to provide the VM via Provider, returning the screen with no ctor params. Tests must use project harnesses (`ScreenHarness` or `AppTestHarness`). Do not hand‑roll `MaterialApp` or ad-hoc Provider trees outside these harnesses.

## Command Cheatsheet (local verification)

**Static checks:**
- `dart analyze`
- `dart run custom_lint`
- `rg -n "ModalRoute\.of\(" lib/features/summary lib/shared` → should return no hits in Summary screens after changes
- `rg -n "viewModel:\s*" lib/features/summary/screens` → should return no hits

**Focused tests:**
- `flutter test test/features/summary/screens/home_screen_theme_test.dart`

**Broad regression (optional):**
- `flutter test` (or the subset affected by route/screen changes)

## Definition of Done

- Home screen and Account Detail screen compile and run using the canonical pattern:
  - No `viewModel` parameter on screens
  - No `ModalRoute.of(context)` usage in Summary screens
  - Screens bind state via `context.watch<...ViewModel>()`
- Routes compose VMs and inject via `ViewModelHost<T>` with Provider‑based DI (no `GetIt` in routes):
  - Home route uses `ViewModelHost<HomeScreenViewModel>` and triggers initial data fetch in `onReady`
  - Account Detail route calls `vm.onReady(args)` and then `vm.fetchData()`
- Tests updated for Summary screens; `home_screen_theme_test.dart` passes without relying on screen ctor DI
- Lints/analyzer pass:
  - `dart run custom_lint` reports zero GetIt‑in‑routes and zero ModalRoute‑in‑features violations
  - `dart analyze` passes for changed files
- Route args policy enforced:
  - No domain objects or value objects passed via route arguments (Home has none)
  - `AccountDetailArgs` continues to parse and validate primitives only; no behavior changes beyond wiring
- Screens are dumb: no ctor VM param, no `ModalRoute`
- Routes compose with Provider DI and `ViewModelHost<T>`; no `GetIt` in routes

## Stop Criteria (to avoid scope creep)

- Do not modify Transaction Management or Category Management screens (T4–T5)
- Do not alter shared widgets such as `active_import_banner.dart` (belongs to T7)
- Do not introduce or refactor business logic beyond the route‑level initialization described
- Do not adopt a new router or change navigation API surface
- Do not add or change view model contracts except where already defined (i.e., AccountDetail VM already has `onReady(args)`)

## Risk Notes & Mitigations

- **Risk:** Removing `RouteAware` could skip refreshes when returning from child screens.
  - **Mitigation:** Account Detail route will eagerly refresh via `fetchData()` in `onReady`; further return‑from‑child refresh policies can be revisited in a future, dedicated task if needed.
- **Risk:** Tests referencing old screen constructors will fail.
  - **Mitigation:** Update the single affected test to use Provider for the VM and keep its theme assertions intact.

## QA strategy snapshot (archived)

- Route smoke checks verify route composition through `ViewModelHost<T>` and typed args handling.
- Screen widget tests provide VM via Provider and avoid any `ModalRoute` dependency.
- Static gates (`custom_lint`, analyzer) enforce no GetIt-in-routes and no ModalRoute-in-features/shared rules.

## Traceability snapshot (archived)

Legacy charter traceability covered:
- Screen targets across Summary, Transaction Management, Category Management, and Transaction Match flows.
- Route targets under `lib/app/routes/**`.
- Shared widget decoupling checks (e.g., `active_import_banner.dart`).
- Harness and feature-test updates under `test/**`.
- Associated documentation updates for architecture, contribution, and test-support guides.

## Story 5.12 archival coverage note

This archived plan was updated in Story `5-12-migrate-documents-stories-completed` to be the canonical destination for the legacy Screen DI and Routing Standardization charter.

Coverage approach:
- Preserved the original project charter intent, objectives, ADR decision, task structure, acceptance/exit criteria, and execution constraints.
- Kept concrete migration guidance (files changed, implementation steps, commands, DoD, stop criteria, risks, and code sketches).
- Avoided duplicating active canonical rules already maintained in:
  - [Guardrails and Testing](/docs/app/reference/architecture/guardrails-and-testing.md)
  - [Project Structure and Boundaries](/docs/app/reference/architecture/project-structure-and-boundaries.md)

Intentional omissions from the raw legacy charter are documented in `/docs/updates.md` with canonical cross-links where active guidance already exists.

## Change Sketches

**home_route.dart** (route DI pattern):
```dart
return MaterialPageRoute(
  settings: settings,
  builder: (ctx) {
    final vm = HomeScreenViewModel(
      rootStore: ctx.read<IRootStore>(),
      navigationService: ctx.read<INavigationService>(),
      loggingService: ctx.read<ILoggingService>(),
    );
    return ViewModelHost<HomeScreenViewModel>(
      vm: vm,
      onReady: (vm) async {
        await vm.fetchAccounts();
        await vm.fetchTransactions();
        await vm.fetchCategories();
      },
      child: const HomeScreen(),
    );
  },
);
```

**account_detail_route.dart** (chain data refresh):
```dart
return ViewModelHost<AccountDetailScreenViewModel>(
  vm: vm,
  onReady: (vm) async {
    await vm.onReady(args);
    await vm.fetchData();
  },
  child: const AccountDetailScreen(),
);
```

**home_screen_theme_test.dart** (provide VM via Provider):
```dart
final vm = HomeScreenViewModel(
  rootStore: fakeRoot,
  loggingService: fakeLogger,
  navigationService: testNav,
);

final harness = ScreenHarness(
  theme: customTheme,
  providers: [
    ChangeNotifierProvider<IRootStore>.value(value: fakeRoot),
    Provider<ILoggingService>.value(value: fakeLogger),
    Provider<INavigationService>.value(value: testNav),
    ChangeNotifierProvider<IImportSessionController>.value(value: fakeImportCtrl),
    ChangeNotifierProvider<HomeScreenViewModel>.value(value: vm),
  ],
  onGenerateRoute: (settings) => MaterialPageRoute(
    builder: (_) => const HomeScreen(),
  ),
);
```

## Related docs

- [Guardrails and Testing](/docs/app/reference/architecture/guardrails-and-testing.md) — Canonical DI, routing, and screen patterns
- [Contribution Guidance](/docs/app/reference/contribution-guidelines.md) — Code review checklist and testing guidelines
- [Known Issues and Tech Debt](/docs/app/reference/operations/known-issues-and-tech-debt.md) — Related screen pattern issues
- [Operations Reference](/docs/app/reference/operations/index.md)
