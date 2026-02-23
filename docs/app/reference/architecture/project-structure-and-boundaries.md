---
title: "Project Structure and Boundaries"
last_updated: 2026-01-26 # YYYY-MM-DD
tags: [reference, app, architecture, structure]
---

# Project Structure and Boundaries

Brief summary: Project structure, boundaries, and integration points for the app.

## When to use this doc

Use this doc when navigating the repo, adding new components, or validating structure decisions. It defines the strict layering rules and type usage across the application.

## Layer Boundaries & Dependency Rule

The application follows a strict dependency rule: each layer may only depend **inward** (left → right in the table).

| Layer | Key Artifacts | May Depend On | Forbidden | Notes |
| :--- | :--- | :--- | :--- | :--- |
| **Presentation** | Widgets, ViewModels, **Draft** classes, **Route Args** | Application | Domain, Data | Drafts carry raw user input (primitives only) and never leave this layer. Route Args are also presentation-only. |
| **Application** | Stores (ChangeNotifier), Use-Cases, Controllers | Domain | Data APIs, Flutter Widgets | Converts **Draft ➜ Domain** and coordinates transactions. *The **only** place that calls `notifyListeners()`.* |
| **Domain** | Entities, Value-Objects, Aggregate Factories, **Repository interfaces** | — | Flutter, sqflite/drift, "Dto" imports | Pure business rules. No framework code, no I/O. |
| **Data (Infrastructure)** | Repository implementations, DTOs, services (Drift, REST, FileSystem) | Domain | Presentation | Maps **Domain ↔ DTO**, performs I/O. DTOs never escape this layer. |

## File Abstractions

Strict rules apply to file handling types to ensure platform independence in the Domain layer.

| Layer | Allowed Types | Rationale |
| :--- | :--- | :--- |
| **Presentation** (`lib/features/...`) | `dart:io.File`, `package:file.File` | Widgets & pickers need platform files. |
| **Application / Stores / Services** (`lib/app/...`) | May convert to/from both sides | Bridge UI ↔ domain/data. |
| **Domain** (`lib/core/domain/...`) | **`FileHandle` only** | Platform-agnostic business logic. **No `dart:io` or `package:file`**. |
| **DTOs** (`lib/core/dtos/...`) | **Primitives only** (e.g., `String fileName`, `Uint8List bytes`) | Storage/wire format. |
| **Infrastructure** | `package:file.File` + `dart:io` as needed | Real I/O; map `FileHandle` ↔ DTO fields. |

> **Rule**: Only repository implementations/services map `FileHandle` to/from DTO primitives; **Domain never references `dart:io` or `package:file`**.

## Data Flow & Modelling (Three-Type Pattern)

We use distinct types for each layer to decouple concerns.

| Type | Lives in | Purpose | `id` field |
| :--- | :--- | :--- | :--- |
| **Draft** | `lib/core/domain/drafts` *(logical presentation model)* | Raw user input before validation. | *absent or nullable* |
| **Entity** | `lib/core/domain/entities` | Validated business object. | **non-nullable** (Value Object) |
| **DTO** | `lib/core/dtos/**` | Persistence / wire format. | primitives only (`int`, `String`) |

```mermaid
Draft --(Use-Case: validate/map)--> Entity --(Repo impl maps)--> DTO --(DB/API)--> ✨
```

**Golden Rules:**
- *No DTO, Map or SQL row may appear above the Data layer.*
- *No Domain type may import Flutter, `dart:io`, or any persistence package.*
- *Drafts disappear **before** the Domain boundary; DTOs appear **after** it.*

## Implementation Blueprints

### 1. Draft (Presentation)
```dart
class NewTransactionDraft {
  final String customerId;           // primitive uuid
  final List<NewLineDraft> lines;    // primitives only
  // ...
}
```

### 2. Domain Aggregate
```dart
class Transaction {
  final TransactionId id;
  final CustomerId    customerId;
  final DateTime      placedAt;

  // Factory converts Draft -> Validated Aggregate
  static Transaction create(NewTransactionDraft draft, { ... }) { ... }
}
```

### 3. Repository Interface (Domain)
```dart
abstract class ITransactionRepository {
  Future<void> add(Transaction entity);
  Future<Transaction?> findById(TransactionId id);
}
```

### 4. Repository Implementation (Data)
```dart
class TransactionRepositoryImpl implements ITransactionRepository {
  @override
  Future<void> add(Transaction entity) async {
    final row = TransactionRowDto.fromDomain(entity); // Mapping happens here
    await _db.into(_db.transactions).insert(row.toCompanion());
  }
}
```

### 5. Use Case (Application)
```dart
class SaveTransactionUseCase {
  final ITransactionRepository _repo;
  final Clock _clock;

  Future<SaveTransactionResult> call(SaveTransactionCommand cmd) async {
    final entity = Transaction.create(cmd.draft, ...);
    await _repo.add(entity);
    return SaveTransactionSuccess(entity);
  }
}
```

### 6. Store (Application)
```dart
class TransactionStore extends ChangeNotifier {
  final SaveTransactionUseCase _saveTx;

  Future<void> create(NewTransactionDraft draft) async {
    final result = await _saveTx(SaveTransactionCommand(draft: draft));
    if (result is SaveTransactionSuccess) {
      _cache.add(result.transaction);
      notifyListeners(); // The ONLY place calling notifyListeners
    }
  }
}
```

## Related docs

- [Architecture Overview](/docs/app/explanation/architecture-overview.md)
- [Data Persistence](/docs/app/reference/architecture/data-persistence.md)
- [Guardrails, Testing, and Process Patterns](/docs/app/reference/architecture/guardrails-and-testing.md)