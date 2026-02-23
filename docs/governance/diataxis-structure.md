---
title: "Diataxis Structure (App Docs)"
last_updated: 2026-01-02 # YYYY-MM-DD
tags: [governance, documentation, structure, diataxis]
---

# Diataxis Structure (App Docs)

Brief summary: Canonical documentation structure for the app, using the Diataxis/Divio model and avoiding speculative or mixed‑purpose content.

## When to use this doc

Use this when adding or reorganizing app documentation so content lands in the correct category.

## Structure (safer baseline)

```
docs/app/
  index.md
  overview/
    index.md
    project-overview.md
  tutorials/
    index.md
    getting-started.md            # only if an onboarding walkthrough exists
  how-to/
    (empty until real task guides exist)
  reference/
    index.md
    architecture/                 # layers/modules/boundaries (code-structured)
    runtime/                      # routing, state, DI
    data/                         # schema, migrations, persistence
    api/                          # receipt parsing, backend proxy
    ui/                           # theming, widgets
  explanation/
    index.md
    architecture-overview.md
    design-decisions.md
    tradeoffs.md
    constraints.md
    glossary.md
```

## Placement rules (Diataxis)

1) **Tutorials** = learning‑oriented, step‑by‑step paths for first‑time success.  
2) **How‑to guides** = task‑oriented steps for real, repeatable workflows.  
3) **Reference** = code‑structured, factual details aligned with source layout.  
4) **Explanation** = concepts, rationale, tradeoffs, architecture reasoning.  

If a document mixes multiple purposes, split it and place each part in its own category.

## Required tagging (app docs)

App docs must include a Diataxis category tag in frontmatter `tags`:

- `tutorial`, `how-to`, `reference`, `explanation`, or `overview`.

## Feature documentation placement

Use a dual placement approach:

- **Explanation**: `docs/app/explanation/feature-overview.md`  
  High‑level feature catalog and conceptual grouping.
- **Reference**: `docs/app/reference/features/<feature>.md`  
  Concrete details: routes, screens, models, state classes, storage, events.

Only add **How‑to** or **Tutorial** feature docs when there is a real, repeatable task
or an onboarding path that someone new can follow end‑to‑end.

## Current file mapping (minimal changes)

- `docs/app/project-overview.md` → `docs/app/overview/project-overview.md`
- `docs/app/architecture/index.md` → `docs/app/reference/architecture/index.md`
- `docs/app/architecture/overview.md` → `docs/app/explanation/architecture-overview.md`
- `docs/app/index.md` stays as the entry point and Diataxis map

These moves are optional until you want to reorganize the files.
