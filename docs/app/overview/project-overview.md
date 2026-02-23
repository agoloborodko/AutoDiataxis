---
title: "Project Overview - Home Accounting (mobile)"
last_updated: 2026-02-21 # YYYY-MM-DD
tags: [app, overview, documentation]
---

# Project Overview - Home Accounting (mobile)

Brief summary: Flutter mobile app for home accounting with integration-first receipt/bank ingestion and local persistence via Drift SQLite.

## When to use this doc

Use this overview to understand the app's purpose, tech stack, and primary references before diving into implementation details.

## Summary

- Flutter mobile app for home accounting with integration-first receipt/bank ingestion.
- Local persistence via Drift SQLite; temporary direct OpenAI calls for receipt parsing (to be proxied by backend in production).
- Monolith repo with feature-first UI, Provider state management, GetIt at composition root only.

## Quick reference

- Tech stack: Flutter 3.35.0 (FVM; see `/.fvmrc`), Dart >=3.9.0 <4.0.0 (pubspec constraint), Provider/ChangeNotifier, GetIt (bootstrap), Drift + sqflite, Freezed/JSON serializable, build_runner, http/pretty_http_logger, path_provider, file_picker/image_picker, syncfusion_flutter_pdfviewer.
- Entry point: `lib/main.dart`
- DI/bootstrap: `lib/core/service_locator.dart` + `MultiProvider` in `main.dart`
- Database: `lib/core/database/app_database.dart` (schema via Drift)
- Routing: `lib/app/routes/*.dart` (VMs via Provider + ViewModelHost)
- Theming/tokens: `lib/app/theme/`
- Shared widgets/keys: `lib/shared/widgets/`

## Canonical app documentation

- Architecture overview: `/docs/app/explanation/architecture-overview.md`
- Architecture reference: `/docs/app/reference/architecture/index.md`
- API integration reference: `/docs/app/reference/architecture/api-integration.md`
- Data persistence reference: `/docs/app/reference/architecture/data-persistence.md`
- Validation and readiness: `/docs/app/explanation/validation-and-readiness.md`
- Local checks: `/docs/app/how-to/run-local-checks.md`
- Operations reference: `/docs/app/reference/operations/index.md`
- Contribution guidance: `/docs/app/reference/general/contribution-and-process.md`
- Store patterns and testing: `/docs/app/reference/stores/store-patterns-and-testing.md`
- UI component inventory: `/docs/app/reference/ui-ux/ui-component-inventory.md`

## Migrated guidance (formerly legacy)

All legacy migration sources have been migrated into `/docs/` (Epic 5, completed 2026-02-21). Canonical locations:

- Contribution: [Contribution Guidelines](/docs/app/reference/contribution-guidelines.md)
- Architecture: [Architecture Reference](/docs/app/reference/architecture/index.md)
- Testing: [Test Support Reference](/docs/app/reference/testing/test-support-reference.md)
- Migrations: [Database Migrations](/docs/app/how-to/database-migrations.md)
- File persistence: [File Persistence How-To](/docs/app/how-to/file-persistence.md)
- Known issues: [Known Issues and Tech Debt](/docs/app/reference/operations/known-issues-and-tech-debt.md)

## Notes / follow-ups

- Replace direct OpenAI calls with backend proxy; scrub embedded keys pre-release.
- Add assets to `pubspec.yaml` if media is introduced.
- Keep DI/theming/key rules enforced via custom_lint and harnesses; maintain 80%+ coverage on changes.

## Related docs

- [App Documentation Index](/docs/app/index.md)
- [Architecture Overview](/docs/app/explanation/architecture-overview.md)
- [Documentation Updates Log](/docs/updates.md)
