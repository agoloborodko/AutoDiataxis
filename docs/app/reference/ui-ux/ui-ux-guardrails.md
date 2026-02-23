---
title: "UI/UX Guardrails"
last_updated: 2026-01-26 # YYYY-MM-DD
tags: [reference, app, ui, ux, guardrails]
---

# UI/UX Guardrails

Brief summary: Screen, routing, theming, and accessibility rules for UI implementation.

## When to use this doc

Use this reference when building screens, routing, theming, or accessibility-critical UI.

## Localization Policy

- **All new user-facing strings must be localized.**
- Add ARB entries in `lib/l10n/app_en.arb`.
- Wire `gen_l10n` for new keys.
- **Testing**: Widget/route tests must include localization setup:
  ```dart
  MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    // ...
  )
  ```
- **Route tests**: Remember to provide localization in both app and tests via `AppLocalizations.localizationsDelegates` and `AppLocalizations.supportedLocales`.

## Category Picker UX

- **Scope Filtering**: Category pickers consume `CategorySnapshot` lists from stores; repositories own filtering (including excluding soft-deleted). Historical displays use per-ID projections (`CategoryDisplay`) that may surface `deleted: true` for read-only contexts.
- **Auto-Dismiss**: The item-level category picker bottom sheet auto-dismisses immediately on selection to reduce taps and accidental double actions.
- **Deleted Category Labels**: Use `deletedCategoryLabel` ARB key for read-only display of deleted categories in historical records.

## Theming and Tokens (MANDATORY)

### Usage Rules
- **Single Source of Truth**: `lib/app/theme/`.
- **Tokens**: Use `AppTokens` for semantic colors (money, status, banners).
- **Themes**: Use Material `ThemeData` components for structural UI.
- **Prohibited**: No `Colors.*` in `lib/features/**` or `lib/shared/**`.
- **Transparency**: Use `Color.withValues(alpha: …)` (deprecated: `withOpacity`).

### Accessing Tokens
```dart
final tokens = Theme.of(context).extension<AppTokens>()!;
final color = tokens.income; // Semantic usage
```

### Manual Verification
```bash
grep -r 'Colors\.' lib/features lib/shared # Should return no results
```

## Screen and routing guardrails

- Screen files stay lean: no `viewModel` params.
- Route args are primitives/POJOs.
- Avoid reading `ModalRoute` inside feature widgets.

## Accessibility
- Every interactive widget needs a semantic key from `shared/widgets/keys.dart`.
- Use `Key('feature.element.action')` dot-delimited keys.

## Related docs

- [General Contribution and Process](/docs/app/reference/general/contribution-and-process.md)
- [App Reference Index](/docs/app/reference/index.md)