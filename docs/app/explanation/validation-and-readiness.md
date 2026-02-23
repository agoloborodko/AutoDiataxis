---
title: "Validation and Readiness"
last_updated: 2026-02-21 # YYYY-MM-DD
tags: [explanation, app, architecture, validation]
---

# Validation and Readiness

Brief summary: Architecture validation, readiness assessment, and project success factors.

## When to use this doc

Use this document when validating architecture completeness or preparing for implementation.

## Project context analysis

### Requirements overview

**Functional requirements (app)**
- Receipt/statement ingestion with persist-first flow: store files, parse via LLM, branch to match vs edit, commit transactions; ID-based draft operations.
- Transaction management: add/edit transactions with breakdowns, scoped categories, accounts, FX, custom fields, attachments, and global defaults.
- Category management with scope (transaction vs item), emoji/icons, soft-delete handling, and historical display for deleted categories.
- Navigation surface: `/parseFile`, `/transactionMatch`, `/draftEdit`, `/transactionUpdate`, `/crossAccountTransfer`, summary/home, account/category screens; shallow stacks with replace for peer hops.
- Theming/UI: token-driven theming (AppTokens), semantic banners/snackbars, keys for all interactive widgets, localization via `l10n`.
- Testing/guardrails built in: harnesses for routes/screens, architecture lints (DI, colors, ModalRoute bans), >= 80% coverage for changes.

**Non-functional requirements (app)**
- Offline-first for core flows; network/auth only for LLM-dependent features.
- Reliability: persist-first to avoid data loss; DB FK enforcement; migrations versioned with JSON dumps and tests.
- Maintainability: strict DI rules (Provider in routes, GetIt only at bootstrap); clear layer boundaries (presentation/app/domain/data); drafts vs entities vs DTOs separation; no platform types in domain.
- Security/ops: no plaintext secrets; HTTPS; input validation; remove embedded LLM keys before release.
- Performance/UX: shallow navigation, labeled progress, guarded destructive actions, responsive category/breakdown edits; contrast-accessible tokens.

**Scale & complexity**
- Domain: rich transaction model (breakdowns, FX, attachments, custom fields, defaults).
- Platform: Flutter mobile client; high complexity due to ingestion/match flows, DI/test guardrails, migrations.
- Architectural components: presentation (screens/VMs/widgets), app layer (stores/use cases/controllers), domain (entities/value objects/repo interfaces), data (Drift repos/DTOs), theming/tokens, navigation DI, LLM adapter.

### Technical constraints and dependencies

- DI: GetIt only at composition root (`main.dart`, `service_locator`); routes use Provider + ViewModelHost; no GetIt in routes/methods.
- Routing: primitives -> typed args; no ModalRoute in widgets; every screen has a router entry; replace navigation for match peers.
- Theming: all colors in `app/theme`; no `Colors.*` in features/shared; use `Color.withValues`.
- Data: Drift SQLite with `PRAGMA foreign_keys = ON`; schemaVersion bump + migration tests + JSON dumps required.
- File handling: persist-first; domain uses `FileHandle`; DTOs primitives; one-copy rule for attachments.
- LLM: interim direct OpenAI calls via `HttpService`/`LlmService`; production to proxy backend.
- Testing: AppTestHarness/ScreenHarness only; deterministic time (`TestClock`), hermetic FS (`FsScope`); semantic keys mandatory; route smoke tests.

### Cross-cutting concerns identified

- Persist-first ingestion and ID-based draft operations across all flows.
- Navigation consistency and keying for accessibility/tests.
- Localization coverage; UX patterns for banners/progress/mismatch handling; tolerance/sync rules for breakdowns.
- Security/secret hygiene; logging via `ILoggingService` only; error mapping (validation surfaced, others generic).
- Agent/readiness alignment: architecture doc must reflect DI/theming/routing/test guardrails for review/use.

## Validation results

### Coherence validation

**Decision compatibility:** Flutter 3.35 stack with Provider + ViewModelHost, GetIt bootstrap-only, Drift persistence, token-based theming, and temporary direct OpenAI calls (isolated behind HttpService/LlmService) are compatible; future proxy swap is contained.
**Pattern consistency:** Naming/DI/routing/theming/testing patterns match contribution guide and custom_lint guardrails; receipt `document_datetime` is naive (presentation-only) while system timestamps remain UTC epoch; FileHandle pattern enforced.
**Structure alignment:** Feature-first layout with app/core separation, centralized AppDatabase, shared keys, and harnessed tests aligns with documented structure; legacy codegen noted but contained.

### Requirements coverage validation

**Epic/feature coverage:** Ingestion/parse/match, transaction CRUD with breakdowns/custom fields/attachments, category scope & soft-delete, accounts/balances, summary/home, global settings/localization all mapped to features/app/core layers and routes.
**Functional requirements coverage:** Persist-first ingestion, ID-based draft ops, DI/theming guardrails, navigation surface (/parseFile, /transactionMatch, /draftEdit, /transactionUpdate, /crossAccountTransfer, summary/home, account/category) covered.
**Non-functional requirements coverage:** Offline-first core flows, FK-enforced Drift schema, >= 80% coverage policy, semantic keys, localization, secret hygiene, migration discipline addressed.

### Implementation readiness validation

**Decision completeness:** Critical decisions/versioning documented; direct LLM calls flagged for proxy migration.
**Structure completeness:** Concrete tree defined; all legacy documentation sources migrated to `docs/` (Epic 5, completed 2026-02-21); legacy `lib/widgets` removed; drift schemas and test harness locations explicit.
**Pattern completeness:** Naming/structure/communication/process patterns cover conflict points; file persistence clarified via FileHandle and [File Persistence How-To](/docs/app/how-to/file-persistence.md); tests mandated under `test/**`.

### Gap analysis results

- Critical: none blocking implementation.
- Important: legacy codegen (Freezed/JSON serializable) slated for removal; drift files centralized in `lib/core/database/app_database.dart` (plan split to `lib/data/drift/{tables,daos,migrations}`); assets not yet declared - establish convention on first asset; direct LLM calls need backend proxy; docs migration from legacy folders completed (Epic 5, 2026-02-21).
- Nice-to-have: add explicit receipt datetime display examples; add pubspec asset scaffold when needed.

### Validation issues addressed

- Receipt `document_datetime` clarified as naive presentation-only; system timestamps remain UTC epoch for calculations.
- File storage patterns aligned with [File Persistence How-To](/docs/app/how-to/file-persistence.md) (FileHandle, no absolute paths, FsScope in tests).

### Architecture readiness assessment

**Overall status:** READY FOR IMPLEMENTATION  
**Confidence level:** High (with noted tech debt items tracked above)  
**Key strengths:** Strong DI/theming guardrails; persist-first + Drift discipline; harnessed testing strategy; clear routing/keys/localization rules.  
**Areas for future enhancement:** Migrate LLM calls to backend proxy; retire legacy codegen; modularize Drift files; formalize asset pipeline.

### Implementation handoff

**AI Agent guidelines:** Follow documented DI/routing/theming rules; keep tests under `test/**` using harnesses; respect FileHandle patterns; treat receipt datetime as display-only naive value; run lint/analyze/tests and migration steps per [Database Migrations How-To](/docs/app/how-to/database-migrations.md).
**First implementation priority:** Begin refactoring Drift into modular folders (`lib/data/drift/{tables,daos,migrations}`) while planning LLM proxy replacement; keep migrations/tests green.

### Architecture completion summary

**Workflow completion:** Architecture Decision Workflow completed.  
**Total steps completed:** 8  
**Date completed:** 2025-12-21  
**Document location:** /docs/app/reference/architecture/index.md

**Final architecture deliverables**
- Architectural decisions with versions and guardrails
- Implementation patterns for agent consistency
- Project structure with directories and mappings
- Validation confirming coherence and completeness

**Implementation ready foundation**
- Dozens of documented decisions across 8 steps
- Comprehensive patterns covering naming/structure/communication/process
- Feature-first architecture with clear boundaries and tests layout
- Requirements mapped to features, routes, data, and storage

**AI Agent implementation guide**
- Technology stack pinned (Flutter 3.35; Provider + ViewModelHost; Drift)
- Consistency rules to prevent conflicts (DI, theming, routing, FileHandle)
- Project structure and integration points defined
- File persistence rules (persist-first, FileHandle, no absolute paths)

**Project success factors**
- Clear decision framework and rationale
- Consistency guarantees via guardrails and tests
- Complete coverage of requirements and flows
- Solid foundation for future proxy/asset/codegen cleanups

## Related docs

- [Architecture Overview](/docs/app/explanation/architecture-overview.md)
- [Project Structure and Boundaries](/docs/app/reference/architecture/project-structure-and-boundaries.md)
- [Documentation Updates Log](/docs/updates.md)
