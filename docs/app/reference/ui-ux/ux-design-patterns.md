---
title: "UX Design Patterns"
last_updated: 2026-01-17 # YYYY-MM-DD
tags: [reference, app, ui-ux]
---

# UX Design Patterns

Brief summary: Reference patterns for navigation, decision branching, and feedback in the home accounting UX.

## When to use this doc

Use this reference when implementing or reviewing ingest, match, edit, and feedback flows to keep behavior consistent with the UX intent.

## Navigation patterns

- Keep navigation stacks shallow; use replace when hopping between matched peers to avoid back-stack confusion.
- Home-first entry with a prominent resume/import banner for ingest flows.
- Routes should parse primitives into typed args and launch view models via Provider (guardrails in UI/UX Guardrails).

## Decision patterns

- Branch on ingest results: multiple drafts/matches route to match; a single clean draft routes to edit.
- Scope-aware category selection: tabs/pickers default to the active scope (transaction vs item) with clear labels/tooltips.

## Feedback patterns

- Persistent, numeric progress for ingest/parse with cancel/retry actions.
- Mismatch banners with one-tap sync actions for breakdown vs amount conflicts.
- Guarded destructive actions with rationale and options to cancel/undo; use semantic snackbars for confirms/warnings.

## Related docs

- [UI/UX Guardrails](/docs/app/reference/ui-ux/ui-ux-guardrails.md)
- [UI Component Inventory](/docs/app/reference/ui-ux/ui-component-inventory.md)
- [UX Design Specification](/docs/app/explanation/ux-design-specification.md)
- [UX Design Directions Summary](/docs/app/explanation/ux-design-directions-summary.md)
- [UI/UX Reference](/docs/app/reference/ui-ux/index.md)
