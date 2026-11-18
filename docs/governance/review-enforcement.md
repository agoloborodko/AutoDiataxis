---
title: "Review Enforcement Rules"
last_updated: 2026-11-16 # YYYY-MM-DD
tags: [governance, review, documentation]
---

# Review Enforcement Rules

Brief summary: Enforce documentation update compliance during review by blocking approval when required doc updates are missing.

## When to use this doc

Use this document during review of any change that may trigger documentation updates.

## Scope and intent

These rules apply to any change that matches the doc-update triggers in `/docs/governance/update-triggers.md`.
If a trigger applies, documentation updates are mandatory and approval is blocked until they are complete.

## Approval-block rule

Block approval when **any** doc-update trigger applies **and** any required documentation updates are missing.
Required updates include:

- The relevant documentation content updates.
- The parent index update for any new doc outside `/docs/updates/` (and explicit confirmation when no index update is expected). A file under `/docs/updates/` does not get its own index line. The documentation indexes link to `/docs/updates/`.
- One new file `/docs/updates/YYYY-MM-DD-<slug>.md` for a meaningful change, with frontmatter, a summary, and links. Do not require `docs/updates.md`.
- A doc-impact declaration in the task plan (story file).
- The docs review checklist copied into the story file (task plan) with completion evidence.

Also block approval if the required doc-impact declaration is missing, regardless of trigger outcome.

## Required reviewer checks

At minimum, reviewers MUST verify:

- **Template compliance:** New/updated docs follow `/docs/_templates/doc-template.md` and required frontmatter.
- **Parent index updates:** New docs outside `/docs/updates/` are linked from their nearest parent index per `/docs/governance/link-and-index-rules.md`. A file under `/docs/updates/` does not get its own index line. If no index update is expected for any other doc, reviewers must verify and document why.
- **Updates log entry:** A meaningful change has one new file under `/docs/updates/` that follows `/docs/maintenance/docs-update-process.md`, including frontmatter, a summary, and links. Approval is not blocked because `docs/updates.md` is absent.
- **Link integrity:** Links are root-relative (e.g., `/docs/...`).

## Doc-impact declaration gate (see [Doc-Impact Detection Guidance](/docs/governance/doc-impact-detection-guidance.md))

The task plan must include a doc-impact decision (Yes/No + rationale) per the guidance above.

- If **Doc impact = Yes**, reviewers must confirm the required doc updates listed above are complete.
- If **Doc impact = No**, reviewers must verify **none** of the triggers apply and document the justification per the guidance.

## Doc-first enforcement

Behavior changes must have documentation updated **before** approval. If docs are missing or lagging the change, approval is blocked.

## Reviewer checklist and completion criteria

Use the following checklist during review:

- [ ] Doc-impact decision recorded (Yes/No + rationale) in the task plan.
- [ ] Docs review checklist copied into the story file (task plan) with completion evidence.
- [ ] Triggers evaluated against `/docs/governance/update-triggers.md`.
- [ ] Required docs updated using the canonical template and required frontmatter.
- [ ] Parent index updated for any new docs outside `/docs/updates/`, or explicit verification recorded when no index update is expected. Files under `/docs/updates/` are exempt.
- [ ] One `/docs/updates/YYYY-MM-DD-<slug>.md` file added per `/docs/maintenance/docs-update-process.md` for a meaningful change, with frontmatter, a summary, and links. No shared `docs/updates.md`.
- [ ] All links are root-relative.
- [ ] Doc-first rule satisfied for behavior changes.

Completion criteria: **All** checklist items are verified. If any item fails, approval is blocked.

## Common failure modes

- Missing parent index update after adding a new doc outside `/docs/updates/`.
- Missing or incomplete `/docs/updates/YYYY-MM-DD-<slug>.md` file for a meaningful change.
- “No doc impact” declared without verifying all trigger categories.
- **[High]** Doc content transcribes code (hex values, token lists, file structure) instead of capturing design rationale, intent, and invariants.

## Related docs

- [Governance Index](/docs/governance/index.md)
- [Documentation Update Triggers](/docs/governance/update-triggers.md)
- [Doc-Impact Detection Guidance](/docs/governance/doc-impact-detection-guidance.md)
- [Link and Index Update Rules](/docs/governance/link-and-index-rules.md)
- [Documentation Updates](/docs/updates/)
- [Docs Update Review Checklist](/docs/maintenance/docs-update-review-checklist.md)
