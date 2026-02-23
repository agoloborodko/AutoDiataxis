---
title: "Lean Tests Initiative (Archived)"
last_updated: 2026-02-14 # YYYY-MM-DD
tags: [reference, app, operations, testing, lean-tests]
---

# Lean Tests Initiative (Archived)

Brief summary: Historical snapshot of test suite performance issues and proposed improvements. This is an archived decision record, not active guidance.

## When to use this doc

Use this doc for historical context on test suite performance concerns. This is not active guidance — it records issues and proposals identified during development.

## Issues Identified

1. Full test suite is ~10 minutes long
2. Tests output 1500+ lines of code

Both issues result in slower development and higher LLM cost due to tokens overspending.

## Proposed Improvements

1. Hide unnecessary logs in tests in case when test is successful
2. Rethink the whole test suite to make it leaner

## Related docs

- [Operations Reference Index](/docs/app/reference/operations/index.md)
- [Test Support Reference](/docs/app/reference/testing/test-support-reference.md)
- [Contribution Guidance](/docs/app/reference/contribution-guidelines.md)
