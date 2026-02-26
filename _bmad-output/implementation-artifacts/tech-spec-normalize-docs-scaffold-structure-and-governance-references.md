---
title: 'Normalize Documentation Scaffold Structure and Governance References'
slug: 'normalize-docs-scaffold-structure-and-governance-references'
created: '2026-02-25T21:53:07Z'
status: 'Completed'
stepsCompleted: [1, 2, 3, 4]
tech_stack:
  - 'Markdown (.md)'
  - 'YAML frontmatter'
  - 'Diataxis/Divio documentation structure conventions'
  - 'Repository-root-relative documentation links (/docs/...)'
files_to_modify:
  - 'docs/app/index.md'
  - 'docs/app/overview/index.md (remove)'
  - 'docs/app/overview/project-overview.md (move/rename or remove after relocation)'
  - 'docs/app/explanation/index.md'
  - 'docs/app/explanation/project-overview.md (create via move from docs/app/overview/project-overview.md)'
  - 'docs/app/explanation/architecture-overview.md'
  - 'docs/app/reference/index.md'
  - 'docs/app/reference/architecture/index.md'
  - 'docs/governance/diataxis-structure.md'
  - 'docs/governance/link-and-index-rules.md'
  - 'docs/maintenance/docs-update-process.md'
  - 'docs/maintenance/docs-update-review-checklist.md'
  - 'docs/updates.md'
  - 'docs/app/tutorials/index.md (create)'
code_patterns:
  - 'Docs use YAML frontmatter with title/last_updated/tags and standard sections'
  - 'Indexes are parent navigation hubs and should be updated when adding/moving/removing docs'
  - 'Links are root-relative from repository root (/docs/...)'
  - 'App docs use Diataxis category tags in frontmatter tags'
  - 'Scaffold placeholders use Brief summary / When to use / Related docs sections'
test_patterns:
  - 'Manual docs validation via docs/maintenance/docs-update-review-checklist.md'
  - 'Link integrity verification for root-relative links (current baseline scan shows no broken /docs links)'
  - 'Index reachability checks for moved/renamed docs'
  - 'Documentation change logging in docs/updates.md'
---

# Tech-Spec: Normalize Documentation Scaffold Structure and Governance References

**Created:** 2026-02-25T21:53:07Z

## Overview

### Problem Statement

The docs scaffold and governance guidance are inconsistent, which makes the documentation structure harder to understand and maintain. Current issues include an extra `docs/app/overview/` section that conflicts with strict Diataxis organization, overlapping architecture content between Explanation and Reference without clear role boundaries, and governance guidance (`docs/governance/diataxis-structure.md`) referencing folders/files that do not exist in the current scaffold.

### Solution

Review all `/docs` content for scaffold and governance drift, define a strict Diataxis-aligned target structure (removing `docs/app/overview/`), clarify naming and role boundaries for architecture docs across Explanation vs Reference, and produce an implementation-ready spec (including checklist) that will be executed in the dev stage to apply file moves/renames/edits and update links/indexes/governance docs.

### Scope

**In Scope:**
- Review all `/docs` for structure/governance drift and logical inconsistencies
- Remove `docs/app/overview/` from the app scaffold and align indexes/navigation accordingly
- Keep both architecture Explanation and architecture Reference docs, but clarify naming and responsibilities
- Specify exact file moves/renames/edits and index/link updates needed
- Specify governance updates, especially `docs/governance/diataxis-structure.md`
- Provide an implementation checklist for the dev execution stage
- Execute the documentation restructure in the dev stage

**Out of Scope:**
- Unrelated application/source-code changes outside documentation/governance
- Deep authoring of project-specific documentation content beyond scaffold normalization and structural placeholders

## Context for Development

### Codebase Patterns

- Documentation is organized under `/docs` with governance docs in `docs/governance/` and app scaffold docs in `docs/app/`.
- `docs/app/index.md` currently exposes `overview`, `explanation`, `reference`, and `how-to`, where `overview` acts like a fifth category outside strict Diataxis.
- `docs/app/explanation/architecture-overview.md` and `docs/app/reference/architecture/index.md` intentionally coexist today but need clearer naming/role boundaries.
- `docs/governance/diataxis-structure.md` currently describes a richer/example scaffold (e.g., `tutorials`, `reference/runtime|data|api|ui`, several explanation docs) that does not match the actual starter scaffold.
- `overview` is also codified as an allowed/required app-doc category in governance and maintenance docs, so removing it requires cross-document rule updates.
- `docs/governance/diataxis-structure.md` includes product-specific/stale example hints (e.g., "receipt parsing, backend proxy") that are inconsistent with a reusable starter scaffold.
- Docs navigation is index-first across `/docs`, and current root-relative `/docs/...` link targets resolve (baseline broken-link scan returned no missing targets).
- There is no automated docs test suite; validation is checklist/process-driven plus link/index verification.

### Files to Reference

| File | Purpose |
| ---- | ------- |
| `docs/app/index.md` | Root app docs index that currently links to `overview`, `explanation`, `reference`, and `how-to` |
| `docs/app/overview/index.md` | Current non-Diataxis overview index slated for removal/redistribution |
| `docs/app/overview/project-overview.md` | Current overview content placeholder to be relocated or replaced |
| `docs/app/explanation/index.md` | Explanation index; likely target for conceptual overview placement |
| `docs/app/explanation/architecture-overview.md` | Architecture explanation placeholder (concepts/rationale) |
| `docs/app/reference/index.md` | Reference index for code-structured docs |
| `docs/app/reference/architecture/index.md` | Architecture reference index (factual/code-aligned architecture docs) |
| `docs/governance/link-and-index-rules.md` | Normative link/index + app-doc placement/tagging rules, currently including `overview` |
| `docs/governance/diataxis-structure.md` | Canonical structure guidance currently drifting from scaffold reality |
| `docs/maintenance/docs-update-process.md` | Maintenance process that currently treats `overview` as a Diataxis category |
| `docs/maintenance/docs-update-review-checklist.md` | Review checklist that currently validates `overview` as an allowed app-doc category |
| `docs/updates.md` | Required docs-change log file and entry format used by docs workflows |
| `docs/_templates/doc-template.md` | Canonical template for any new/recreated docs during restructure |
| `docs/_templates/doc-template-checklist.md` | Template compliance checklist referenced by governance/maintenance docs |

### Technical Decisions

- Enforce strict Diataxis for app scaffold structure (remove `docs/app/overview/` as a category).
- Treat Diataxis as the folder/category taxonomy, while frontmatter `tags` may include additional descriptive metadata (e.g., `overview`) as long as a required Diataxis category tag is present.
- Preserve both architecture Explanation and architecture Reference documentation, but distinguish them by purpose and naming.
- Review scope is all `/docs`, not just `docs/app`, to catch similar governance/scaffold inconsistencies.
- This quick spec must be implementation-ready and include a checklist; the actual edits will be executed in the dev stage.
- Doc impact is **Yes** (structure/category + governance/process changes), so the dev stage must update governance/maintenance rules, app indexes, and add a `/docs/updates.md` entry.
- Any move/rename plan must preserve index-first navigation and root-relative links; the current docs tree provides a clean link baseline to re-check after edits.

## Implementation Plan

### Tasks

- [x] Task 1: Create the strict Diataxis app scaffold target (move overview content into Explanation and add Tutorials index)
  - File: `docs/app/overview/project-overview.md`
  - Action: Move this file to `docs/app/explanation/project-overview.md` and ensure frontmatter includes the required Diataxis category tag `explanation`.
  - Notes: `overview` may remain as an additional descriptive tag if governance is updated to distinguish required Diataxis category tags from optional metadata tags.
  - File: `docs/app/tutorials/index.md`
  - Action: Create a starter Tutorials index using `/docs/_templates/doc-template.md` conventions and root-relative links.
  - Notes: This can remain an empty placeholder index (no tutorial docs yet) but must be reachable from `docs/app/index.md`.

- [x] Task 2: Clarify Explanation-role boundaries between project overview and architecture explanation
  - File: `docs/app/explanation/index.md`
  - Action: Add a link to `project-overview.md` and update summary text so Explanation explicitly includes project context, architecture rationale, and conceptual documentation.
  - Notes: Keep index-first navigation; do not link directly from unrelated indexes if `docs/app/explanation/index.md` is the nearest parent.
  - File: `docs/app/explanation/architecture-overview.md`
  - Action: Refine placeholder summary/when-to-use/related-doc wording to clearly position this doc as rationale/tradeoffs/design explanation (not factual reference inventory).
  - Notes: Preserve file path unless implementation reveals a strong naming conflict; the boundary clarification is the primary requirement.
  - File: `docs/app/explanation/project-overview.md`
  - Action: Adjust summary/when-to-use/related-doc wording after the move so it is clearly an Explanation doc and not a fifth category.
  - Notes: Cross-link to `architecture-overview.md` and `docs/app/reference/index.md`.

- [x] Task 3: Update app and reference indexes for the new navigation model
  - File: `docs/app/index.md`
  - Action: Remove the `Overview` section/link, add a `Tutorials` section/link (`/docs/app/tutorials/index.md`), and update tags/frontmatter text if they imply `overview` is a category.
  - Notes: Final app index should expose only Diataxis categories (`tutorials`, `how-to`, `reference`, `explanation`) plus related docs.
  - File: `docs/app/reference/index.md`
  - Action: Review wording to reinforce that Reference is factual/code-aligned while Explanation holds conceptual/rationale docs.
  - Notes: Link targets may remain unchanged if already valid.
  - File: `docs/app/reference/architecture/index.md`
  - Action: Update wording/related-doc text to clearly distinguish this index (code-aligned architecture details/contracts) from `docs/app/explanation/architecture-overview.md`.
  - Notes: Keep the cross-link to the Explanation architecture doc, but label it as rationale/conceptual context.

- [x] Task 4: Remove the deprecated `overview` app-doc category scaffolding and residual references
  - File: `docs/app/overview/index.md`
  - Action: Delete the file after all links are updated to the new Explanation location(s).
  - Notes: Delete the `docs/app/overview/` folder only after confirming no remaining references to files inside it.
  - File: `docs/app/index.md`
  - Action: Verify no `/docs/app/overview/...` links remain after Task 3.
  - Notes: If any overview references remain elsewhere in `/docs`, retarget or remove them in the appropriate file-specific tasks below.

- [x] Task 5: Normalize the canonical Diataxis scaffold guidance to match the reusable starter
  - File: `docs/governance/diataxis-structure.md`
  - Action: Replace the current scaffold example with a starter-accurate structure that removes `overview/`, includes `tutorials/` and `how-to/` indexes as applicable, and avoids speculative subtrees not present in the starter.
  - Notes: Remove product-specific examples (e.g., receipt parsing/backend proxy) and keep examples generic/reusable.
  - File: `docs/governance/diataxis-structure.md`
  - Action: Update tagging guidance to require one Diataxis category tag (`tutorial`, `how-to`, `reference`, `explanation`) while allowing optional descriptive tags (including `overview`) where useful.
  - Notes: Keep tutorial/how-to/reference/explanation definitions aligned with Diataxis placement rules and explicitly separate category tags from descriptive metadata tags. Include a concrete valid example such as `tags: [app, explanation, overview]` for an Explanation doc.

- [x] Task 6: Update governance link/index rules to enforce the new category set
  - File: `docs/governance/link-and-index-rules.md`
  - Action: Remove `Overview -> /docs/app/overview/` from app-doc placement rules and split app-doc tagging guidance into required Diataxis category tag(s) vs optional descriptive tags.
  - Notes: Ensure wording still enforces correct folder-purpose alignment and root-relative/index-first navigation, and does not treat `overview` as a Diataxis category.

- [x] Task 7: Update maintenance process and review checklist to remove `overview` from app-doc classification checks
  - File: `docs/maintenance/docs-update-process.md`
  - Action: Update the Diataxis classification step to list only `tutorial`, `how-to`, `reference`, and `explanation` as categories, while allowing additional descriptive tags in frontmatter.
  - Notes: Preserve the rest of the workflow and existing doc-impact/reviewer verification steps.
  - File: `docs/maintenance/docs-update-review-checklist.md`
  - Action: Update checklist wording so review validates correct Diataxis folder placement and presence of a required Diataxis category tag, without failing on extra descriptive tags such as `overview`.
  - Notes: Keep this file as a read-only canonical template (unchecked boxes only).

- [x] Task 8: Record the documentation restructure in the updates log
  - File: `docs/updates.md`
  - Action: Append a dated entry using the documented format summarizing scaffold normalization, overview removal, and governance alignment, with root-relative links to key affected indexes/governance docs.
  - Notes: Use story key `no-story` unless the dev execution is attached to a BMAD story artifact.

- [x] Task 9: Run docs validation and reviewer checks for a docs-only structural change
  - File: `docs/maintenance/docs-update-review-checklist.md`
  - Action: Use this checklist as the validation standard for the change set (copy into the execution task/story artifact if one exists).
  - Notes: Validation should include root-relative link integrity, index reachability, and confirmation that no app-doc governance doc still allows `overview`.
  - File: `docs/updates.md`
  - Action: Confirm the new log entry format is valid and includes date, summary, links, and story key.
  - Notes: Reviewer sign-off format is only required when applicable to the execution workflow/review gate.

### Acceptance Criteria

- [x] AC 1: Given the docs restructure changes are applied, when a reader opens `docs/app/index.md`, then the app index exposes only Diataxis categories (`Tutorials`, `How-to`, `Reference`, `Explanation`) and contains no `Overview` category link.
- [x] AC 2: Given `project-overview` content is retained, when the app docs are reviewed after the change, then that content exists under `docs/app/explanation/` with the required `explanation` Diataxis category tag (and optional descriptive tags as needed) plus updated wording that positions it as conceptual context.
- [x] AC 3: Given both architecture Explanation and architecture Reference docs remain, when their indexes/placeholders are read, then the Explanation docs describe rationale/tradeoffs and the Reference docs describe code-aligned factual details/contracts without mixed-purpose wording.
- [x] AC 4: Given the starter app docs follow strict Diataxis, when `docs/app/index.md` is used as entry navigation, then `docs/app/tutorials/index.md` exists and is reachable even if no tutorial content pages exist yet.
- [x] AC 5: Given governance and maintenance docs are updated, when app-doc placement/tag rules are reviewed in `docs/governance/link-and-index-rules.md`, `docs/governance/diataxis-structure.md`, `docs/maintenance/docs-update-process.md`, and `docs/maintenance/docs-update-review-checklist.md`, then `overview` is not treated as a Diataxis category and the docs explicitly distinguish required Diataxis category tags from optional descriptive tags.
- [x] AC 6: Given `docs/governance/diataxis-structure.md` is the canonical scaffold reference, when it is compared to the starter docs tree, then its example structure and examples are generic, starter-accurate, and free of stale product-specific/speculative subtrees.
- [x] AC 7: Given `docs/app/overview/` is deprecated, when a repo-wide `/docs` link/reference scan is run after the edits, then no root-relative links or governance/process text still point to `/docs/app/overview/`.
- [x] AC 8: Given the deprecated overview scaffold is removed, when the app docs tree is inspected after implementation, then `docs/app/overview/` no longer exists and its former content/navigation is represented under the appropriate Diataxis locations.
- [x] AC 9: Given the docs-only change set is ready for review, when validation is performed using `docs/maintenance/docs-update-review-checklist.md`, then root-relative links resolve, moved/new docs are reachable from parent indexes, and a correctly formatted `docs/updates.md` entry is present.

## Additional Context

### Dependencies

- No external libraries, services, or runtime dependencies (docs-only Markdown/frontmatter changes).
- Depends on existing canonical documentation governance and maintenance rules remaining the source of truth (no parallel replacement docs created).
- Depends on `/docs/_templates/doc-template.md` and `/docs/_templates/doc-template-checklist.md` for any newly created index file (`docs/app/tutorials/index.md`) or rewritten placeholders.
- Depends on file move/delete support in the implementation environment (preserve history when possible via `git mv` during dev stage).

### Testing Strategy

- No unit/integration tests are expected; validation is documentation-structure and link/navigation verification.
- Re-run a root-relative link/reference scan across `/docs` after edits to confirm no references to `/docs/app/overview/` remain and all `/docs/...` targets resolve.
- Example validation commands for the dev stage (command-assisted manual review):
  - `rg -n '/docs/app/overview/' docs`
  - `rg -n 'overview' docs/governance docs/maintenance`
  - `rg -n 'tutorial|how-to|reference|explanation' docs/governance/link-and-index-rules.md docs/governance/diataxis-structure.md docs/maintenance/docs-update-process.md docs/maintenance/docs-update-review-checklist.md`
- Verify index reachability manually:
  - `docs/app/index.md` links to Tutorials/How-to/Reference/Explanation indexes.
  - `docs/app/explanation/index.md` links to both `project-overview.md` and `architecture-overview.md`.
  - `docs/app/reference/architecture/index.md` keeps a clearly labeled link to the Explanation architecture doc.
- Verify folder removal explicitly after link/index updates:
  - `rg --files docs/app | rg '^docs/app/overview/'` returns no results.
- Check frontmatter and template compliance for newly created/moved docs:
  - `last_updated` in `YYYY-MM-DD`
  - `tags` is a list and includes at least one required Diataxis category tag (`tutorial`, `how-to`, `reference`, or `explanation`)
  - required sections remain present (Brief summary, When to use, Related docs)
- Validate governance/maintenance consistency by scanning for stale category mentions:
  - `overview` is removed as a Diataxis category/folder rule and, if mentioned, is clearly described as optional descriptive metadata only
  - wording consistently checks for a required Diataxis category tag (not exclusivity of all frontmatter tags)
  - Diataxis examples in `docs/governance/diataxis-structure.md` match the intended starter scaffold
- Append and review the `docs/updates.md` entry for date/format/links/story key (`no-story` unless a story key exists).
- Use `docs/maintenance/docs-update-review-checklist.md` as the final review gate and record completion evidence in the execution artifact/story copy as required by the docs process.

### Notes

- Highest risk: moving/removing `docs/app/overview/` can leave stale links in governance/process docs even if app indexes are updated; treat repo-wide docs scans as required, not optional.
- Highest risk: category terminology mismatch (`tutorial` frontmatter tag vs `tutorials/` folder name) can cause incomplete rule updates; verify folder names and tag names separately.
- Known limitation: the repository currently has no automated Markdown link checker wired into CI, so validation remains manual/command-assisted.
- Future improvement (out of scope): add an automated docs lint/link-check command and a lightweight governance consistency check for allowed Diataxis categories.
- Future improvement (out of scope): define a maintainer policy for when the starter scaffold in `docs/governance/diataxis-structure.md` should be updated so examples do not drift from the actual template tree again.

## Review Notes

- Adversarial review completed
- Findings: 10 total, 6 fixed, 4 skipped
- Resolution approach: auto-fix
