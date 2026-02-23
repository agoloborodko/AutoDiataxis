---
title: "Repository Contracts and Naming"
last_updated: 2026-01-08 # YYYY-MM-DD
tags: [reference, app, repositories, api]
---

# Repository Contracts and Naming

Brief summary: Repository boundary rules, API naming conventions, and response format expectations.

## When to use this doc

Use this reference when designing repository contracts, DTO boundaries, or API integrations.

## Repository boundaries

- Presentation must not import Domain entities/DTOs/repos.
- Route args are primitives/POJOs; do not pass domain objects or IDs through routes (see UI/UX guardrails).
- DTOs stay primitive; domain uses typed value objects.

## API naming and response formats

- REST-ish: plural paths (`/files`, `/transactions`); IDs as `{id}`; query params camelCase.
- JSON field naming uses camelCase for network payloads.
- Headers: prefer standard; custom `X-` only when unavoidable.
- Error payload target: `{ error: { code: "<kebab>", message, details? } }`.
- Prefer `{ data, error? }`; omit `error` on success.
- Status codes: 2xx success, 4xx validation, 5xx server; map to localized user-safe messages.

## Related docs

- [General Contribution and Process](/docs/app/reference/general/contribution-and-process.md)
- [UI/UX Guardrails](/docs/app/reference/ui-ux/ui-ux-guardrails.md)
- [Database Guardrails and Migrations](/docs/app/reference/database/database-guardrails-and-migrations.md)
- [App Reference Index](/docs/app/reference/index.md)
