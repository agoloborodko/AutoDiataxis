---
title: "Link and Index Update Rules"
last_updated: 2026-01-02 # YYYY-MM-DD
tags: [governance, links, index, documentation]
---

# Link and Index Update Rules

Brief summary: Defines the required link format and index update rules to keep documentation navigation consistent.

Guidance: All new or updated docs must follow the canonical template at `/docs/_templates/doc-template.md` and include the required frontmatter above. Use root-relative links (e.g., /docs/area/index.md). Date format for `last_updated` is YYYY-MM-DD.

## When to use this doc

Use this document whenever you add, move, or update documentation content or navigation.

## Rules

1. **Root-relative links only**
   - All links must start at the repository root.
   - Example: `/docs/area/index.md` (never `../docs/area/index.md`).

2. **Parent index updates are required for every new doc**
   - When adding a new doc, update the parent folder index to include the new doc.
   - Example: Adding `/docs/governance/link-and-index-rules.md` requires updating `/docs/governance/index.md`.

3. **Root index updates only for top-level navigation changes**
   - Update `/docs/index.md` only when adding or changing top-level navigation sections.
   - Do not update the root index for every new doc; use the relevant parent index instead.

4. **Index-first navigation**
   - Do not add direct links that bypass indexes unless the doc is referenced by an index.
   - A doc is considered "referenced by an index" when it is linked from its nearest parent index (for example, `/docs/governance/index.md` for `/docs/governance/link-and-index-rules.md`).

5. **Diataxis placement is required for app docs**
   - App documentation MUST live under the correct Diataxis folder:
     - Tutorials → `/docs/app/tutorials/`
     - How-to guides → `/docs/app/how-to/`
     - Reference → `/docs/app/reference/`
     - Explanation → `/docs/app/explanation/`
     - Overview → `/docs/app/overview/`
   - The doc must match its folder’s purpose (no mixed-purpose docs).

6. **Diataxis category tagging is required for app docs**
   - App docs MUST include a Diataxis category tag in frontmatter `tags`.
   - Allowed values: `tutorial`, `how-to`, `reference`, `explanation`, `overview`.

## Related docs

- [Documentation Index](/docs/index.md)
- [Governance Index](/docs/governance/index.md)
- [Documentation Updates Log](/docs/updates.md)
- [Diataxis Structure (App Docs)](/docs/governance/diataxis-structure.md)
