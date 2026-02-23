---
title: "PDF Assets Archive Decision"
last_updated: 2026-02-21 # YYYY-MM-DD
tags: [reference, operations, archive, pdf-assets]
---

# PDF Assets Archive Decision

Brief summary: Records the decision to archive the legacy `documents/screens.pdf` and `documents/screens_compressed.pdf` files without migrating their content into canonical docs.

## When to use this doc

Use this document to understand why legacy PDF screen design assets were not migrated and where they remain in the repository.

## Archive decision

The PDF screen design files in `documents/` are **archived in place** without migration into the canonical `/docs/` tree. These files contain legacy screen/UI design mockups in binary PDF format. They cannot be meaningfully migrated into the Markdown documentation tree.

**Rationale for no migration:**

- The files are binary PDF assets containing visual screen designs and wireframes, not textual documentation.
- PDF content cannot be meaningfully converted to Markdown without losing fidelity.
- Migrating them would add non-canonical binary material to `/docs/`, creating confusion about which docs are authoritative.
- Preserving the files in their original location maintains historical context without polluting the canonical docs tree.
- The compressed version (`screens_compressed.pdf`, ~218KB) provides a lightweight alternative to the original (~20.2MB) for reference purposes.

## Not canonical for implementation

These PDF files are **not canonical for implementation**. AI agents and developers must not treat content in `documents/screens.pdf` or `documents/screens_compressed.pdf` as active governance, architecture guidance, or enforceable rules. The canonical sources for project guidance are:

- `/docs/governance/` for documentation governance rules
- `/docs/app/` for app-specific reference, how-to, and explanation docs
- `/docs/maintenance/` for documentation maintenance processes
- `/_bmad/` for AI workflow and prompt management

## Archive scope

**Files:** `/documents/screens.pdf` and `/documents/screens_compressed.pdf`

**Archived files (2 total):**

| File | Size | Date | Description |
|------|------|------|-------------|
| `/documents/screens.pdf` | ~20.2MB | 2025-02-06 | Original screen design/wireframe PDF with full-resolution mockups |
| `/documents/screens_compressed.pdf` | ~218KB | 2025-02-08 | Compressed version of the same screen designs; more practical for quick reference |

## Related docs

- [Operations Reference](/docs/app/reference/operations/index.md)
- [Documentation Updates Log](/docs/updates.md)
