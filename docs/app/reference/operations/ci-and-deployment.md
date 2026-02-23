---
title: "CI and Deployment"
last_updated: 2026-01-26 # YYYY-MM-DD
tags: [reference, app, operations, ci, deployment]
---

# CI and Deployment

Brief summary: Reference details for the current CI pipeline and release expectations.

## When to use this doc

Use this doc when updating CI workflows, validating pipeline behavior, or preparing a release.

## CI pipeline (GitHub Actions)

- Workflow: `/.github/workflows/flutter_ci.yaml`
- Triggers: push and pull requests to `main`
- Steps:
  1. Checkout repository
  2. Install Flutter
  3. Cache pub packages
  4. `flutter pub get`
  5. `dart run custom_lint` (architecture guardrails)
  6. `dart analyze .`
  7. `flutter test --coverage --reporter expanded`

## Release and Deployment Expectations

- **Release Tagging**: Tag/build/release from `main` only.
- **Approvals**: Require ≥1 approved review before merging to main.
- **Dependency Scanning**: Scan dependencies for vulnerabilities; track performance regressions.
- **Manual Runs**: Use FVM (`fvm flutter run`) for local verification.

## Related docs

- [General Contribution and Process](/docs/app/reference/general/contribution-and-process.md)
- [Run Local Checks](/docs/app/how-to/run-local-checks.md)