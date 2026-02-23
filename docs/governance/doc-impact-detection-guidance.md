---
title: "Doc-Impact Detection Guidance"
last_updated: 2026-01-17 # YYYY-MM-DD
tags: [governance, documentation, doc-impact]
---

# Doc-Impact Detection Guidance

Brief summary: How to evaluate planned changes against documentation update triggers and record doc impact (or no doc impact) with justification.

## When to use this doc

Use this guidance before planning or implementing any change to determine whether documentation updates are required and to record a doc impact decision.

## Decision flow

Use trigger categories from `/docs/governance/update-triggers.md`.

1. Identify planned changes across trigger categories: behavior changes, new features/workflows, API/contract changes, data/model changes, migrations/schema changes, tooling/process changes.
2. Identify any **structure/category changes** (Diataxis placement rules, folder structure, required tags).
3. Map each planned change to the trigger categories in `/docs/governance/update-triggers.md`.
4. Decide doc impact:
   - If any trigger applies: Doc impact = Yes.
   - If no triggers apply: Doc impact = No, only with an explicit justification.

## Task planning requirements

Mandatory when any trigger category applies.

- You MUST add documentation update tasks to your task plan (Tasks/Subtasks) before implementation.
- Doc update tasks must name the specific docs to change and include required parent index changes.
- If Diataxis placement or tags are affected, tasks MUST include updates to structure docs and relevant indexes.
- Follow `/docs/governance/link-and-index-rules.md` for any new or updated docs.

## Doc impact declarations

Required for every change.

- Record the doc impact decision (Yes/No + short rationale) in your task plan (Tasks/Subtasks).

## "No Doc Impact" declaration requirements

When no triggers apply.

- Include a short justification that lists which trigger categories were evaluated and why none apply.
- Place the declaration in your task plan (Tasks/Subtasks).

## Related docs

- [Documentation Update Triggers](/docs/governance/update-triggers.md)
- [Link and Index Update Rules](/docs/governance/link-and-index-rules.md)
- [Governance Index](/docs/governance/index.md)
