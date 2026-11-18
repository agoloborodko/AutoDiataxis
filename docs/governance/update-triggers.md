---
title: "Documentation Update Triggers"
last_updated: 2026-11-16 # YYYY-MM-DD
tags: [governance, documentation, updates]
---

# Documentation Update Triggers

Brief summary: Explicit, enforceable rules that require documentation updates and a "no doc impact" decision rule.

## When to use this doc

Use this document when planning, implementing, or reviewing changes to determine whether documentation updates are required.

## Related docs

- [Governance Index](/docs/governance/index.md)
- [Link and Index Update Rules](/docs/governance/link-and-index-rules.md)
- [Documentation Updates](/docs/updates/)
- [Documentation Index](/docs/index.md)

## Doc-update triggers (MUST)

Documentation MUST be updated when any of the following apply:

1. **Behavior changes**: MUST update docs when changing how a documented task is performed or modifying required steps in a workflow.
2. **New features/workflows**: MUST update docs when introducing a new feature, workflow, or process that requires guidance.
3. **API/contract changes**: MUST update docs when changing documented interface expectations (for example, required frontmatter fields).
4. **Data/model changes**: MUST update docs when changing required metadata or schema for documentation entries (for example, updates log format).
5. **Migrations/schema changes**: MUST update docs when modifying migration steps, checklists, or requirements for moving legacy docs.
6. **Tooling/process changes**: MUST update docs when changing review gates, doc impact rules, or documentation processes.
7. **Structure/category changes**: MUST update docs when changing documentation structure rules, Diataxis placement, or category/tag requirements.

## No doc impact rule

"No doc impact" is allowed only when **none** of the triggers above apply and the change does not alter documented behavior, workflows, interfaces, data/model expectations, migrations, or tooling/processes. The decision MUST include a brief justification.

## Trigger examples (doc-only)

- **Behavior changes:** Adjusting required steps for a documentation workflow.
- **New features/workflows:** Adding a new documentation workflow that needs guidance.
- **API/contract changes:** Requiring a new frontmatter field across docs.
- **Data/model changes:** Changing the required fields of a `/docs/updates/YYYY-MM-DD-<slug>.md` record.
- **Migrations/schema changes:** Updating migration checklists for legacy doc moves.
- **Tooling/process changes:** Changing review gates for documentation updates.
- **Structure/category changes:** Introducing new structure rules, renaming Diataxis folders, or changing required category tags.

## Index and navigation reminder

When adding or updating documentation to satisfy these triggers, follow the link and index update rules in `/docs/governance/link-and-index-rules.md`.
