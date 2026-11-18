---
title: "Docs Update Review Checklist"
last_updated: 2026-11-16 # YYYY-MM-DD
tags: [maintenance, documentation, checklist, review]
---

# Docs Update Review Checklist

Brief summary: Review checklist for verifying documentation updates without duplicating governance rules.

## When to use this doc

Use this checklist during review of any documentation change set. Copy it into the story file (task plan) and record completion there. Do not check boxes in this canonical file.

## Checklist

Note: This is a read-only template. Keep all boxes unchecked here; the story copy is where completion is recorded.

- [ ] Confirm the doc-impact decision (Yes/No + rationale) is recorded in the task plan per `/docs/governance/doc-impact-detection-guidance.md`.
- [ ] Checklist copied into the story file (task plan) with completion evidence.
- [ ] Verify required doc updates match the triggers in `/docs/governance/update-triggers.md`.
- [ ] Ensure new or updated docs follow `/docs/_templates/doc-template.md` and the checklist in `/docs/_templates/doc-template-checklist.md`.
- [ ] For app docs in Diataxis folders (`/docs/app/tutorials/`, `/docs/app/how-to/`, `/docs/app/reference/`, `/docs/app/explanation/`), confirm a required Diataxis category tag is present and correct (tutorial/how-to/reference/explanation); extra descriptive tags are allowed.
- [ ] For app docs, confirm placement under the correct Diataxis folder in `/docs/app/`.
- [ ] Verify all links are root-relative and parent index updates comply with `/docs/governance/link-and-index-rules.md`. A file under `/docs/updates/` does not get an index line.
- [ ] Confirm a meaningful change has one file under `/docs/updates/` that follows `/docs/maintenance/docs-update-process.md`. Do not require a new dated entry in `/docs/updates.md`.
- [ ] Validate navigation: each new doc outside `/docs/updates/` is reachable from its nearest parent index. A file under `/docs/updates/` is reached from the standing notice on `/docs/updates.md`.
- [ ] **[High]** Verify doc content captures intent, rationale, and invariants rather than transcribing code. See step 4 content quality rules in `/docs/maintenance/docs-update-process.md`.

## Migration verification (legacy migrations)

Use this section when reviewing a legacy migration or sharded transfer.

- [ ] Coverage parity: a source-to-target mapping exists and every source heading is accounted for.
- [ ] Link integrity: all links in migrated docs are root-relative and resolve to existing files.
- [ ] Index reachability: each migrated doc is linked from its nearest parent `index.md`.
- [ ] Updates log: one `/docs/updates/YYYY-MM-DD-<slug>.md` file exists with summary, links, and story key. It is not a new dated entry in `/docs/updates.md`.
- [ ] Template compliance: migrated docs follow `/docs/_templates/doc-template.md` and the checklist in `/docs/_templates/doc-template-checklist.md`.
- [ ] Reuse check: no parallel governance/process rules were created; updates stay within existing docs.
- [ ] Reviewer sign-off is recorded in the migration's `/docs/updates/YYYY-MM-DD-<slug>.md` file and checked here before marking a migration complete or deleting legacy content.

### Legacy deletion gates (when deleting legacy folders)

- [ ] Verification checklist completed and reviewed in `/docs/maintenance/docs-update-review-checklist.md` (Story 4.3).
- [ ] Reviewer sign-off recorded in the deletion's `/docs/updates/YYYY-MM-DD-<slug>.md` file using the required format (e.g., `Sign-off: @reviewer on YYYY-MM-DD`).
- [ ] Migration workflow steps complete and aligned.
- [ ] Migration execution tasks complete, including archive decisions.
- [ ] The deletion's `/docs/updates/YYYY-MM-DD-<slug>.md` file includes the date, story key (or `no-story`), deletion scope/summary, and root-relative links/pointers to migration evidence. It is not a new dated entry in `/docs/updates.md`.

## Related docs

- [Docs Update Process](/docs/maintenance/docs-update-process.md)
- [Doc-Impact Detection Guidance](/docs/governance/doc-impact-detection-guidance.md)
- [Documentation Update Triggers](/docs/governance/update-triggers.md)
- [Link and Index Update Rules](/docs/governance/link-and-index-rules.md)
- [Doc Template Checklist](/docs/_templates/doc-template-checklist.md)
- [Documentation Updates Log](/docs/updates.md)
