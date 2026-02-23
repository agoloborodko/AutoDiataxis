---
title: "Run Local Checks"
last_updated: 2026-02-21
tags: [how-to, app, checks, testing]
---

# Run Local Checks

Brief summary: Run the standard local verification steps before review.

## When to use this doc

Use this guide before opening a PR or requesting review to ensure linting and tests pass.

## Prerequisites

- Flutter 3.35.0 (use FVM; see `.fvmrc`)
- Dart >= 3.9
- Tooling: `flutter`, `dart`, `fvm` (recommended), Git

## Setup

1) Install Flutter 3.35.0 (or use `fvm install 3.35.0`).
2) Install dependencies:
   - `fvm flutter pub get`
   - `cd tools/arch_guard_lints && fvm flutter pub get && cd -`

## Local commands

1) Run linting:
   - `fvm dart run custom_lint`
2) Run static analysis:
   - `fvm dart analyze .`
3) Run tests:
   - `fvm flutter test --coverage --reporter expanded`
4) Launch the app:
   - `fvm flutter run` (choose device/simulator)
5) Follow DI/Theming/Keys rules (Provider + ViewModelHost, no `Colors.*` in features/shared, semantic keys). See [App Reference - Guardrails and Testing](/docs/app/reference/architecture/guardrails-and-testing.md).
6) If you changed the database schema, run the required migration tests (schemaVersion bump, drift JSON exports, migration tests).

## Notes

- No assets are declared in `pubspec.yaml` yet.
- OpenAI direct calls are temporary; production will proxy via backend—do not ship hardcoded keys. Remove embedded keys before release.
- If you are not using FVM, ensure your `flutter`/`dart` binaries point to the required SDK versions.

## Related docs

- [App Reference - Guardrails and Testing](/docs/app/reference/architecture/guardrails-and-testing.md)
- [App Documentation Index](/docs/app/index.md)
