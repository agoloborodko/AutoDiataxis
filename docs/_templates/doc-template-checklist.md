---
title: "Doc Template Checklist"
last_updated: 2026-01-01 # YYYY-MM-DD
tags: [templates, checklist, documentation, governance]
---

# Doc Template Checklist

Brief summary: Checklist for authoring or updating docs using the canonical template without copying guidance text into final docs.

## When to use this doc

Use this checklist before creating or updating any documentation.

## Checklist

- Use `/docs/_templates/doc-template.md` as the base template (do not copy guidance text into the final doc).
- Populate required placeholders: `title`, `last_updated`, `tags`, `summary`, `when_to_use`, `related_docs`, and `sections` (if needed).
- For `sections`, provide one or more items with `title` and `body` for each content section (optional for index docs).
- Ensure `last_updated` uses `YYYY-MM-DD` format and `tags` is a list.
- Keep all links root-relative (e.g., `/docs/area/index.md`).
- Update the nearest parent index to include the new or updated doc.
- Update `/docs/index.md` only for top-level navigation changes.
- Add a dated entry to `/docs/updates.md` that follows the requirements in `/docs/maintenance/docs-update-process.md`.

## Related docs

- [Documentation Index](/docs/index.md)
- [Doc Template](/docs/_templates/doc-template.md)
- [Documentation Updates Log](/docs/updates.md)
