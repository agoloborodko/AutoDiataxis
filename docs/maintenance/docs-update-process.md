---
title: "Docs Update Process"
last_updated: 2026-02-25 # YYYY-MM-DD
tags: [maintenance, documentation, process]
---

# Docs Update Process

Brief summary: Step-by-step process for maintaining and updating documentation with required checks and reviewer verification.

## When to use this doc

Use this process whenever you add, update, move, or delete documentation so changes are consistent, reviewable, and compliant.

## Step-by-step process

1. **Confirm doc impact**
   - Evaluate planned changes against `/docs/governance/update-triggers.md`.
   - Record the doc-impact decision (Yes/No + rationale) in the task plan per `/docs/governance/doc-impact-detection-guidance.md`.
   - If Doc impact = No, include a short justification listing which trigger categories were evaluated and why none apply (per `/docs/governance/doc-impact-detection-guidance.md`).
2. **Classify and place docs (Diataxis)**
   - For app docs under Diataxis folders (`/docs/app/tutorials/`, `/docs/app/how-to/`, `/docs/app/reference/`, `/docs/app/explanation/`), choose the Diataxis category (tutorial, how-to, reference, explanation).
   - Optional descriptive tags (for example, `overview`) may be added in frontmatter, but they do not replace the required Diataxis category tag.
   - Place the doc under the correct folder in `/docs/app/` per `/docs/governance/link-and-index-rules.md`.
   - Treat `/docs/app/index.md` as a navigation index, not a Diataxis category document.
3. **Select targets and create drafts**
   - Identify the specific docs to update or create.
   - For new docs, start from `/docs/_templates/doc-template.md`.
4. **Author or update content**
   - Make the content changes required by the task or workflow.
   - Keep guidance concise, explicit, and enforceable.
5. **Verify template compliance**
   - Check required frontmatter and sections using `/docs/_templates/doc-template-checklist.md`.
   - Ensure `last_updated` uses `YYYY-MM-DD` and `tags` is a list.
6. **Update navigation and indexes**
   - Update the nearest parent index for every new doc (and when moving or removing docs).
   - Update `/docs/index.md` only if a top-level navigation section changes.
   - For app docs, update `/docs/app/index.md` and the relevant Diataxis sub-index if applicable.
   - Follow `/docs/governance/link-and-index-rules.md` for link format and index rules.
7. **Log the update**
   - Add a dated entry with summary, links, and a story key in `/docs/updates.md` (use `no-story` when no story applies).
8. **Run reviewer verification**
   - Use the reviewer checklist: `/docs/maintenance/docs-update-review-checklist.md`.
   - Copy the reviewer checklist into the story file (task plan) and record completion there.
   - Verify doc-impact declarations are recorded in the task plan per `/docs/governance/doc-impact-detection-guidance.md`.
   - Confirm root-relative links, index coverage, and template compliance.

## Migration execution steps (docs transfer)

Use these steps to migrate or transfer documentation content into the canonical `docs/` tree, regardless of source location. If the transfer requires sharding, follow the "Sharding workflow for legacy migrations" section below instead of re-stating it here.

1. **Select the source**
   - Choose one source file (or a clearly scoped section if the file is large).
2. **Identify target locations**
   - Determine the destination folder(s) in `/docs/`.
   - Ensure the nearest parent sub-index exists (create or update it as needed).
3. **Migrate the content**
   - Create or update doc(s) using `/docs/_templates/doc-template.md`, required frontmatter, and required sections.
   - Preserve meaning and coverage; if content is split, add explicit cross-links between the new docs.
   - Ensure all links in migrated or updated docs are root-relative from repository root.
4. **Update navigation and logs**
   - Update the relevant sub-index with root-relative links (from repository root).
   - Append a dated entry in `/docs/updates.md` with a short summary, links, and a story key (use `no-story` when no story applies).
5. **Verify the transfer**
   - Confirm template compliance, link integrity, and index reachability.
   - Validate coverage parity with the legacy source (no meaning loss).
6. **Record reviewer sign-off (required before completion)**
   - Before marking a migration complete or deleting legacy content, record reviewer sign-off in `/docs/updates.md` (e.g., "Sign-off: @reviewer on YYYY-MM-DD").
   - Ensure the same sign-off is checked in `/docs/maintenance/docs-update-review-checklist.md`.

## Legacy deletion criteria (post-migration)

Use these criteria before deleting any legacy folder (e.g., `docs-legacy/`, `documents/`). Deletion is **blocked** unless all gates pass.

1. **Verification checklist complete**
   - The migration verification checklist in `/docs/maintenance/docs-update-review-checklist.md` is fully completed and reviewed (Story 4.3).
2. **Reviewer sign-off recorded**
   - Sign-off is recorded in `/docs/updates.md` using the required format (e.g., `Sign-off: @reviewer on YYYY-MM-DD`).
3. **Epic prerequisites met**
   - All migration workflow steps are complete and aligned.
   - All migration execution tasks are complete, including archive decisions.
4. **Legacy scope fully resolved**
   - All legacy content is either migrated into `/docs/` or explicitly archived with documented rationale.
5. **Deletion entry logged**
   - Add a dated `/docs/updates.md` entry **for each deletion** with:
     - A concise summary of what was deleted (folder path/scope) and the story key (use `no-story` when none applies).
     - Root-relative links/pointers to the migration evidence (target docs, verification checklist results, and any archive decision records).
     - The reviewer sign-off line in the required format (e.g., `Sign-off: @reviewer on YYYY-MM-DD`).

## Sharding workflow for legacy migrations

Use this workflow when splitting a legacy document into smaller, maintainable files.

1. **Shard one legacy file at a time**
   - Migrate a single legacy file per change.
   - If the file is large, split it **by sections**, but still treat it as one file’s migration.
2. **Preserve meaning and coverage**
   - Ensure the sharded set covers the original content without loss.
3. **Update navigation and the updates log on every shard**
   - Update the nearest parent index for any new sharded doc.
   - Add a dated entry to `/docs/updates.md` for each shard/migration step, including a short summary, links, and a story key (use `no-story` when no story applies).
4. **Handle oversized legacy files**
   - If sharding one legacy file would exceed the per-PR maximum, split the file’s sections across multiple PRs.
   - Treat the migration as in-progress until all sections are completed.

## Per-PR sharding scope guidance

- Typical scope: **1–3 docs** per PR.
- Maximum scope: **4–8 docs** per PR.

## Related docs

- [Doc Template](/docs/_templates/doc-template.md)
- [Doc Template Checklist](/docs/_templates/doc-template-checklist.md)
- [Documentation Update Triggers](/docs/governance/update-triggers.md)
- [Doc-Impact Detection Guidance](/docs/governance/doc-impact-detection-guidance.md)
- [Link and Index Update Rules](/docs/governance/link-and-index-rules.md)
- [Documentation Updates Log](/docs/updates.md)
- [Docs Update Review Checklist](/docs/maintenance/docs-update-review-checklist.md)
