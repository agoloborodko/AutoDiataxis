---
title: "Prompts Folder Archive Decision"
last_updated: 2026-02-21 # YYYY-MM-DD
tags: [reference, operations, archive, prompts]
---

# Prompts Folder Archive Decision

Brief summary: Records the decision to archive the legacy `documents/prompts/` folder without migrating its content into canonical docs.

## When to use this doc

Use this document to understand why legacy prompt files were not migrated and where they remain in the repository.

## Archive decision

The `documents/prompts/` folder is **archived in place** without migration into the canonical `/docs/` tree. These files contain legacy AI prompt templates that were used during early project development. They are not canonical governance, architecture, or implementation guidance.

**Rationale for no migration:**

- The prompt files are project-specific AI interaction templates, not reusable documentation or enforceable rules.
- Migrating them would add non-canonical material to `/docs/`, creating confusion about which docs are authoritative.
- The content is superseded by the BMAD workflow system (`_bmad/`) which provides structured, versioned prompt and workflow management.
- Preserving the files in their original location maintains historical context without polluting the canonical docs tree.

## Not canonical for implementation

These prompt files are **not canonical for implementation**. AI agents and developers must not treat content in `documents/prompts/` as active governance, architecture guidance, or enforceable rules. The canonical sources for project guidance are:

- `/docs/governance/` for documentation governance rules
- `/docs/app/` for app-specific reference, how-to, and explanation docs
- `/docs/maintenance/` for documentation maintenance processes
- `/_bmad/` for AI workflow and prompt management

## Archive scope

**Folder:** `/documents/prompts/` (including `/documents/prompts/archive/`)

**Archived files (12 total):**

| File | Description |
|------|-------------|
| `/documents/prompts/architecture_review.md` | Reviews implementation plans against architecture and domain/data-model rules |
| `/documents/prompts/business_analyst.md` | Refines story files to be ready for implementation planning |
| `/documents/prompts/create_implementation_plan.md` | Orchestrator prompt that coordinates subagents to produce an atomic-commit implementation plan from a story |
| `/documents/prompts/execute_implementation_plan.md` | Orchestrator prompt that drives subagents through review-feedback-fix cycles for each plan step |
| `/documents/prompts/execute_implementation_plan_continue.md` | Continuation variant of execution orchestrator for resuming incomplete implementations |
| `/documents/prompts/flutter_fix.md` | Flutter developer prompt for addressing reviewer feedback via TDD |
| `/documents/prompts/flutter_initial.md` | Flutter developer prompt for implementing a single atomic step via TDD |
| `/documents/prompts/plan_reviewer.md` | Reviews implementation plans for completeness, scope compliance, and quality |
| `/documents/prompts/planner_fix.md` | Updates an existing implementation plan based on reviewer feedback |
| `/documents/prompts/planner_initial.md` | Creates a rigorous implementation plan with meta-analysis from a story |
| `/documents/prompts/review_code.md` | Senior reviewer prompt for validating diffs against implementation plan steps |
| `/documents/prompts/archive/prompts.md` | Earlier collected prompts (planner, reviewer, orchestrator) predating the per-file split |

## Related docs

- [Operations Reference](/docs/app/reference/operations/index.md)
- [Documentation Updates Log](/docs/updates.md)
