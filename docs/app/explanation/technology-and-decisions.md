---
title: "Technology Stack and Decisions"
last_updated: 2026-01-02 # YYYY-MM-DD
tags: [explanation, app, architecture, decisions, stack]
---

# Technology Stack and Decisions

Brief summary: Core technology choices and decision priorities for the Home Accounting app.

## When to use this doc

Use this doc to understand the app's technology stack, decision priorities, and known deferred decisions.

## Technology stack

- Flutter 3.35 (Dart >= 3.9), Provider/ChangeNotifier, GetIt (bootstrap only), Drift + sqflite, Freezed/JSON serializable (marked legacy to phase out), build_runner, http/pretty_http_logger, path_provider, file_picker/image_picker, syncfusion_flutter_pdfviewer.

## Starter template evaluation

### Primary technology domain

Flutter mobile application (existing codebase) based on project requirements.

### Starter options considered

- Retain existing Flutter project with current architecture guardrails (Provider + ViewModelHost routing, GetIt at composition root, Drift persistence, AppTokens theming, harnessed tests).
- Declined generating a new starter template: project is already initialized and structured; re-templating would add risk and churn without benefit.

### Selected starter: Keep existing Flutter project structure

**Rationale for selection:**
- Codebase already aligned to documented architecture (DI, routing, theming, persist-first ingestion).
- Migration to a new starter would disrupt established patterns/tests with no clear upside.
- Existing tooling (FVM pinned Flutter 3.35, custom lint, harnesses, Drift migrations) already provides a solid foundation.

**Initialization command:**

_Not applicable (existing repository). Standard setup remains:_

```bash
fvm flutter pub get
cd tools/arch_guard_lints && flutter pub get && cd -
```

**Architectural decisions provided by existing setup:**
- **Language & Runtime:** Dart/Flutter 3.35 with FVM pin.
- **Styling Solution:** AppTokens + component themes; no `Colors.*` in features/shared.
- **Build Tooling:** Flutter toolchain, build_runner for codegen (Freezed/JSON serializable - marked legacy to phase out, Drift).
- **Testing Framework:** Flutter test with AppTestHarness/ScreenHarness; coverage target >= 80%; custom_lint for DI/color/ModalRoute guardrails.
- **Code Organization:** Feature-first UI, ViewModelHost pattern, Provider-based DI, Drift data layer, domain/application/data separation.
- **Development Experience:** Hot reload, deterministic time (TestClock), hermetic FS (FsScope), semantic keys for accessibility/tests.

## Decision priority analysis

**Critical decisions**
- Keep Flutter 3.35 + Provider/ChangeNotifier + ViewModelHost; GetIt only at composition root; routes use Provider (no GetIt) and typed args (no ModalRoute).
- Persist-first ingestion with ID-based draft ops; receipts/files stored once and linked on commit; domain uses `FileHandle`, DTOs are primitives.
- Drift as the sole DB; FK enforcement on; every schema change bumps `schemaVersion` with JSON dumps and migration tests; tolerance/rehydration rules enforced via use cases/identity maps.
- Theming via AppTokens/component themes; no `Colors.*` in features/shared; `Color.withValues` only.
- Testing guardrails: AppTestHarness/ScreenHarness; semantic keys required; >= 80% coverage; custom_lint for DI/colors/ModalRoute bans.

**Important decisions**
- Offline-first for core flows; network/auth only for LLM features; guard LLM calls via navigation/feature flags.
- Logging and error mapping: all logs through `ILoggingService`; surface validation messages, map others to generic user-safe text.
- Navigation consistency: shallow stacks, replace for match/peer hops; all interactive widgets keyed; localization via `l10n`.
- LLM integration remains direct to OpenAI (temporary); plan to proxy through backend when available.

**Deferred decisions**
- Production auth model and token handling for LLM features.
- Backend proxy for LLM calls (replace direct OpenAI).
- Push/notification strategy and store compliance guidance.
- Caching strategy (none required now; revisit if perf signals emerge).

## Related docs

- [Architecture Overview](/docs/app/explanation/architecture-overview.md)
- [Data Persistence](/docs/app/reference/architecture/data-persistence.md)
- [API Integration](/docs/app/reference/architecture/api-integration.md)
- [Validation and Readiness](/docs/app/explanation/validation-and-readiness.md)
