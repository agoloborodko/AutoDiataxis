---
title: "Diataxis Structure (App Docs)"
last_updated: 2026-02-25 # YYYY-MM-DD
tags: [governance, documentation, structure, diataxis]
---

# Diataxis Structure (App Docs)

Brief summary: Canonical starter documentation structure for app docs using the Diataxis model, with strict category folders and no extra overview category.

## When to use this doc

Use this when adding or reorganizing app documentation so content lands in the correct category.

## Starter scaffold structure

```
docs/app/
  index.md
  tutorials/
    index.md
  how-to/
    index.md
  explanation/
    index.md
    project-overview.md
    architecture-overview.md
  reference/
    index.md
    architecture/
      index.md
    general/
      index.md
```

## Placement rules (Diataxis)

1. **Tutorials** = learning-oriented, step-by-step paths for first-time success.
2. **How-to guides** = task-oriented steps for real, repeatable workflows.
3. **Reference** = code-structured, factual details aligned with source layout.
4. **Explanation** = concepts, rationale, tradeoffs, and architecture reasoning.

If a document mixes multiple purposes, split it and place each part in its own category.

Optional tutorial example (add only when it exists):

`docs/app/tutorials/getting-started.md`

## Required tagging (app docs in Diataxis folders)

App docs under `/docs/app/tutorials/`, `/docs/app/how-to/`, `/docs/app/reference/`, and `/docs/app/explanation/` must include at least one required Diataxis category tag in frontmatter `tags`:

- Required category tag values: `tutorial`, `how-to`, `reference`, `explanation`
- Optional descriptive tags may be added when useful (for example, `overview`)
- Valid example: `tags: [app, explanation, overview]`

## Notes on starter accuracy

- The starter scaffold intentionally includes only placeholder indexes and a small set of explanation/reference starter docs.
- Add deeper subtrees (for example, API or data references) only when real project content exists.
- Keep examples generic and repository-agnostic in governance docs.
