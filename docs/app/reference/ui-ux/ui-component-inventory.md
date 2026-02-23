---
title: "UI Component Inventory"
last_updated: 2026-01-16 # YYYY-MM-DD
tags: [reference, app, ui-ux, inventory]
---

# UI Component Inventory

Brief summary: Reference list of shared widgets, feature widgets, and UI entry points for the Home Accounting app.

## When to use this doc

Use this reference when navigating existing UI components, auditing widget usage, or planning UI updates across features.

## Inventory scope

- Widgets under `lib/shared/widgets`, `lib/widgets`, and feature-specific widget folders.
- Screen entry points under `lib/features/**/screens`.

## Shared widgets

- `shared/widgets/digital_amount_input.dart` – numeric amount entry with custom styling.
- `shared/widgets/transaction_card.dart` – transaction summary card.
- `shared/widgets/themed_dropdown_container.dart` – themed dropdown wrapper.
- `shared/widgets/semantic_snackbar.dart` – standardized snackbar messaging.
- `shared/widgets/active_import_banner.dart` – banner for active import sessions.
- `shared/widgets/keys.dart` – key identifiers for widgets and tests.
- `widgets/view_model_host.dart` – helper to provide view models in widget trees.

## Feature widgets (sampling)

- Transaction management: `widgets/transaction_breakdown_item_card.dart`, `widgets/receipt_capture_menu.dart`, `widgets/date_picker.dart`, `widgets/account_picker.dart`, `widgets/account_picker_grid.dart`, `widgets/category_picker_grid.dart`, `widgets/transaction_match_item.dart`, `widgets/matched_link_banner.dart`, `widgets/brick_row.dart`, `widgets/bulk_actions_bar.dart`, `widgets/match_control_strip.dart`, `widgets/date_header.dart`.
- Summary: `widgets/account_card.dart`, `widgets/transaction_list.dart`, `widgets/transaction_list_item.dart`.
- Category management: `widgets/category_icon_widget.dart`.

## Screen entry points

- Splash: `features/splash/screens/splash_screen.dart`
- Transactions: add / edit / receipt intake / cross-account transfer (`features/transaction_management/screens/*.dart`)
- Accounts: add account (`features/account_management/screens/add_account_screen.dart`)
- Categories: manage categories (`features/category_management/screens/category_management_screen.dart`)
- Summary/home: `features/summary/screens/home_screen.dart`, `account_detail_screen.dart`
- Transaction matching: `features/transaction_match/screens/transaction_match_screen.dart`

## UI guardrails alignment

- UI is driven by ChangeNotifier view models/providers per feature folder.
- Theming uses `app/theme/app_theme.dart`; localization uses `l10n`.
- Use `AppTokens`/component themes; avoid `Colors.*` in `lib/features/**` or `lib/shared/**`.
- Prefer `Color.withValues` over `withOpacity()`.
- Interactive widgets must use semantic keys from `shared/widgets/keys.dart`.
- Maintain semantic key uniqueness tests when updating or adding keys.
- Routes build VMs with `Provider/context.read<T>()` and wrap screens in `ViewModelHost<T>`; GetIt only at composition root.

## Related docs

- [UI/UX Guardrails](/docs/app/reference/ui-ux/ui-ux-guardrails.md)
- [Store Patterns and Testing](/docs/app/reference/stores/store-patterns-and-testing.md)
- [General Contribution and Process](/docs/app/reference/general/contribution-and-process.md)
- [App Reference Index](/docs/app/reference/index.md)
