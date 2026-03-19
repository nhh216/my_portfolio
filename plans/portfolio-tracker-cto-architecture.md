---
title: "Portfolio Tracker — CTO Architecture & Task Assignments"
role: Chief Technology Officer
date: 2026-03-16
version: v1 MVP
status: active
---

# Portfolio Tracker — CTO Architecture & Task Assignments

## CEO Plan Review

**Product:** Portfolio Tracker — Flutter mobile app (iOS + Android)
**Target Users:** Individual retail investors in Vietnam / Southeast Asia
**MVP Scope (v1):** Mock data only · Home screen · Asset list · Asset detail
**Out of Scope v1:** Auth, real API, charts, multi-portfolio, push notifications

**CEO Plan Assessment:** Well-scoped MVP. Risks identified:
- `StatefulShellRoute` needed if we want tab state preserved during navigation
- Hive needs schema versioning from day 1 — migrations are painful to retrofit
- Riverpod `StateNotifierProvider` is deprecated in Riverpod 2.x — use `NotifierProvider` instead

---

## System Architecture

### Pattern: Clean Architecture + Feature-Sliced Folders

```
lib/
├── main.dart
├── app/
│   ├── app.dart              # MaterialApp + theme setup
│   └── router.dart           # GoRouter with ShellRoute
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_text_styles.dart
│   │   └── app_spacing.dart
│   ├── errors/
│   │   └── failures.dart     # Sealed Failure classes
│   └── utils/
│       ├── currency_formatter.dart
│       └── percent_formatter.dart
├── features/
│   └── portfolio/
│       ├── data/
│       │   ├── models/
│       │   │   ├── asset.dart         # Freezed + JsonSerializable
│       │   │   └── portfolio.dart     # Freezed + JsonSerializable
│       │   └── repositories/
│       │       └── asset_repository.dart   # Interface + mock impl
│       ├── domain/
│       │   └── providers/
│       │       ├── asset_provider.dart     # NotifierProvider
│       │       └── portfolio_provider.dart # Computed provider
│       └── presentation/
│           ├── screens/
│           │   ├── home_screen.dart
│           │   └── asset_detail_screen.dart
│           └── widgets/
│               ├── portfolio_summary_card.dart
│               ├── asset_list_tile.dart
│               └── pnl_badge.dart
└── shared/
    └── widgets/
        ├── loading_indicator.dart
        └── error_view.dart
```

### State Management Architecture

```
CEO Plan → NotifierProvider (async) reads from AssetRepository
         ↓
AssetRepository (interface)
         ↓
MockAssetRepository (v1) ──→ returns hardcoded List<Asset>
         ↓
AssetNotifier (NotifierProvider<List<Asset>>)
         ↓
PortfolioProvider (Provider<Portfolio>) — derived/computed
         ↓
HomeScreen / AssetDetailScreen (ConsumerWidget)
```

**Rule:** Use `NotifierProvider` (Riverpod 2.x), NOT the deprecated `StateNotifierProvider`.

### Navigation Architecture

```
GoRouter
└── StatefulShellRoute (preserves tab scroll state)
    └── ShellRoute branch:
        ├── /           → HomeScreen
        └── /asset/:id  → AssetDetailScreen
```

Single-branch shell for v1. Multi-branch when v2 adds tabs.

### Data Models

```dart
// asset.dart — Freezed
@freezed
class Asset with _$Asset {
  const factory Asset({
    required String id,
    required String name,
    required String symbol,
    required double quantity,
    required double buyPrice,
    required double currentPrice,
  }) = _Asset;

  // Computed getters (in extension or const factory)
  factory Asset.fromJson(Map<String, dynamic> json) => _$AssetFromJson(json);
}

// Computed values (extension on Asset)
extension AssetComputed on Asset {
  double get totalValue => quantity * currentPrice;
  double get pnl => totalValue - (quantity * buyPrice);
  double get pnlPercent => (pnl / (quantity * buyPrice)) * 100;
}

// portfolio.dart — Freezed
@freezed
class Portfolio with _$Portfolio {
  const factory Portfolio({
    required List<Asset> assets,
    required double totalValue,
    required double totalPnl,
    required double totalPnlPercent,
  }) = _Portfolio;
}
```

---

## Approved Dependencies (v1)

```yaml
dependencies:
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  dio: ^5.4.3               # HTTP client (stubbed v1, used v2+)
  hive_flutter: ^1.1.0      # Local persistence (future)
  go_router: ^13.2.0
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1

dev_dependencies:
  build_runner: ^2.4.9
  freezed: ^2.4.7
  json_serializable: ^6.7.1
  flutter_lints: ^3.0.2
```

---

## Developer Task Assignments

---

### TASK-D01: Project Setup & Dependencies

**Priority:** P0 — blocks everything

## Technical Spec — TASK-D01: Project Setup & Dependencies

### Objective
Bootstrap the Flutter project with correct folder structure, pubspec dependencies, and linting config.

### Files to create / modify
- `pubspec.yaml` — add approved dependencies
- `analysis_options.yaml` — configure flutter_lints
- `lib/app/app.dart` — MaterialApp + AppTheme wiring
- `lib/app/router.dart` — GoRouter scaffold (no routes yet, just shell)
- `lib/core/constants/app_colors.dart` — brand colors
- `lib/core/constants/app_text_styles.dart` — heading/body styles
- `lib/core/constants/app_spacing.dart` — named spacing constants (8, 16, 24, 32)

### Implementation notes
- Run `flutter pub get` then `dart run build_runner build --delete-conflicting-outputs`
- Use `ThemeData.from(colorScheme: ...)` with Material 3
- No magic numbers anywhere — every padding/margin must reference `AppSpacing`
- Do NOT use `StateNotifierProvider` — use `NotifierProvider` (Riverpod 2.x)

### Acceptance criteria
- [ ] `flutter pub get` exits 0
- [ ] `dart run build_runner build` exits 0 (no generated file conflicts)
- [ ] `flutter analyze` zero issues
- [ ] App launches to a blank screen without crash
- [ ] All spacing uses `AppSpacing` constants
- [ ] No magic numbers in any file

---

### TASK-D02: Asset & Portfolio Data Models

**Priority:** P1 — blocks D03, D04, D05

## Technical Spec — TASK-D02: Asset & Portfolio Data Models

### Objective
Create `Asset` and `Portfolio` Freezed models with computed P&L properties.

### Files to create / modify
- `lib/features/portfolio/data/models/asset.dart` — Freezed + JsonSerializable
- `lib/features/portfolio/data/models/portfolio.dart` — Freezed aggregate
- `lib/core/errors/failures.dart` — sealed Failure class (DataFailure, NetworkFailure)
- Run `build_runner` to generate `.freezed.dart` and `.g.dart` files

### Implementation notes
- Computed values (`totalValue`, `pnl`, `pnlPercent`) go in an `extension` on `Asset`, NOT inside the Freezed factory — Freezed const factories can't have computed logic
- `Portfolio` computed fields (`totalValue`, `totalPnl`, `totalPnlPercent`) are calculated at provider level, not inside the model
- `pnlPercent` guard: if `buyPrice * quantity == 0` return `0.0` to avoid division by zero

### Acceptance criteria
- [ ] `Asset.fromJson` / `toJson` round-trips correctly (unit test)
- [ ] `asset.pnl` returns correct value for positive and negative cases
- [ ] `asset.pnlPercent` returns 0.0 when `buyPrice == 0` (no crash)
- [ ] `flutter analyze` zero issues on generated files
- [ ] No `!` operator usage without justifying comment

---

### TASK-D03: Mock Asset Repository

**Priority:** P1 — blocks D04

## Technical Spec — TASK-D03: Mock Asset Repository

### Objective
Define the `AssetRepository` interface and a `MockAssetRepository` with 5 hardcoded assets.

### Files to create / modify
- `lib/features/portfolio/data/repositories/asset_repository.dart` — abstract interface
- `lib/features/portfolio/data/repositories/mock_asset_repository.dart` — mock implementation

### Implementation notes
- Interface method: `Future<List<Asset>> getAssets()`
- Mock returns `Future.delayed(const Duration(milliseconds: 300), () => _mockAssets)` — simulates network latency
- Mock data: include at least 5 assets covering positive P&L, negative P&L, and zero-gain cases
- Example assets: AAPL, TSLA, VNM, BTC, ETH with varied quantities/prices
- Repository is injected via Riverpod — define a `assetRepositoryProvider` in the same file

### Acceptance criteria
- [ ] `getAssets()` returns a non-empty list after 300ms delay
- [ ] Mock covers positive P&L, negative P&L, and breakeven cases
- [ ] Repository is accessible via `assetRepositoryProvider` (Riverpod)
- [ ] No hardcoded data in provider or screen files — only in mock repository

---

### TASK-D04: Riverpod Providers (State Layer)

**Priority:** P2 — blocks D05, D06

## Technical Spec — TASK-D04: Riverpod Providers

### Objective
Wire `AssetNotifier` and `portfolioProvider` using Riverpod 2.x `NotifierProvider`.

### Files to create / modify
- `lib/features/portfolio/domain/providers/asset_provider.dart`
- `lib/features/portfolio/domain/providers/portfolio_provider.dart`

### Implementation notes
- `assetProvider`: Use `AsyncNotifierProvider<AssetNotifier, List<Asset>>` — calls `assetRepositoryProvider.getAssets()` on init
- `portfolioProvider`: Use `Provider<AsyncValue<Portfolio>>` — derives from `assetProvider`, computes aggregate totals
- Portfolio aggregate: sum all asset `totalValue`, sum all `pnl`, compute overall `pnlPercent`
- Loading / error states flow through `AsyncValue` — screens handle `.when(data:, loading:, error:)`
- No `print()` statements — use `debugPrint()` only in debug builds if needed

### Acceptance criteria
- [ ] `assetProvider` exposes `AsyncValue<List<Asset>>`
- [ ] `portfolioProvider` correctly sums all asset values
- [ ] Loading state is visible while mock delay runs
- [ ] Error state from repository propagates to provider
- [ ] Zero `StateNotifierProvider` usage in the codebase

---

### TASK-D05: Home Screen

**Priority:** P3 — depends on D04

## Technical Spec — TASK-D05: Home Screen

### Objective
Build `HomeScreen` with a `PortfolioSummaryCard` at top and scrollable `AssetListTile` list below.

### Files to create / modify
- `lib/features/portfolio/presentation/screens/home_screen.dart`
- `lib/features/portfolio/presentation/widgets/portfolio_summary_card.dart`
- `lib/features/portfolio/presentation/widgets/asset_list_tile.dart`
- `lib/features/portfolio/presentation/widgets/pnl_badge.dart`
- `lib/shared/widgets/loading_indicator.dart`
- `lib/shared/widgets/error_view.dart`

### Implementation notes
- `HomeScreen` is a `ConsumerWidget` — reads `assetProvider` and `portfolioProvider`
- `PortfolioSummaryCard` shows: total portfolio value (formatted as currency), total P&L value + percent
- P&L text color: green if positive, red if negative, grey if zero — use `AppColors` constants
- `AssetListTile`: symbol, name, current price, individual P&L badge
- `PnlBadge`: colored chip with arrow icon + percent — reused on detail screen
- Handle all three `AsyncValue` states: loading → `LoadingIndicator`, error → `ErrorView`, data → list
- `ErrorView` must have a Retry button that calls `ref.invalidate(assetProvider)`

### Acceptance criteria
- [ ] Loading indicator shown during 300ms mock delay
- [ ] Portfolio summary card shows correct aggregate totals
- [ ] All 5 mock assets render in the list
- [ ] P&L values are green (positive) / red (negative) / grey (zero)
- [ ] Tapping an asset tile navigates to `/asset/:id`
- [ ] Error state shows `ErrorView` with working Retry button
- [ ] No `setState()` calls in `HomeScreen`

---

### TASK-D06: Asset Detail Screen

**Priority:** P3 — depends on D04

## Technical Spec — TASK-D06: Asset Detail Screen

### Objective
Build `AssetDetailScreen` that receives an asset `id` via route param and displays full asset stats.

### Files to create / modify
- `lib/features/portfolio/presentation/screens/asset_detail_screen.dart`
- `lib/app/router.dart` — register `/asset/:id` route

### Implementation notes
- Route param `id` is a `String` — look up asset from `assetProvider` list by `id`
- If asset not found (e.g. stale deep link), show `ErrorView` with "Asset not found" message
- Fields to display: name, symbol, quantity, buy price, current price, total value, P&L (value + %), `PnlBadge`
- Add a back button (GoRouter `context.pop()`) — do NOT use `Navigator.pop()`
- Currency formatting via `CurrencyFormatter` in `lib/core/utils/currency_formatter.dart`

### Acceptance criteria
- [ ] All 6 asset fields render correctly
- [ ] P&L badge color matches the sign of P&L
- [ ] Back button returns to Home Screen
- [ ] Deep link `/asset/aapl` loads correct asset
- [ ] Unknown `id` shows error view, not a crash

---

## Tester Task Assignments

---

### TASK-T01: Unit Tests — Models & Computed Properties

**Depends on:** TASK-D02

**File:** `test/features/portfolio/models/asset_test.dart`

**Test cases:**
- [ ] `asset.totalValue == quantity * currentPrice`
- [ ] `asset.pnl` is positive when `currentPrice > buyPrice`
- [ ] `asset.pnl` is negative when `currentPrice < buyPrice`
- [ ] `asset.pnlPercent` returns `0.0` when `buyPrice == 0`
- [ ] `Asset.fromJson(asset.toJson()) == asset` (round-trip)

---

### TASK-T02: Unit Tests — Mock Repository

**Depends on:** TASK-D03

**File:** `test/features/portfolio/repositories/mock_asset_repository_test.dart`

**Test cases:**
- [ ] `getAssets()` returns exactly 5 assets
- [ ] Returned list contains at least one positive-P&L and one negative-P&L asset
- [ ] Method completes in under 500ms

---

### TASK-T03: Provider Tests — Asset & Portfolio Providers

**Depends on:** TASK-D04

**File:** `test/features/portfolio/providers/providers_test.dart`

**Test cases:**
- [ ] `assetProvider` starts in `AsyncLoading` state
- [ ] `assetProvider` transitions to `AsyncData` with 5 assets
- [ ] `portfolioProvider` total value equals sum of all `asset.totalValue`
- [ ] `portfolioProvider` total P&L equals sum of all `asset.pnl`
- [ ] Overriding repository with error triggers `AsyncError` state

---

### TASK-T04: Widget Tests — Home Screen

**Depends on:** TASK-D05

**File:** `test/features/portfolio/screens/home_screen_test.dart`

**Test cases:**
- [ ] `LoadingIndicator` visible before data resolves
- [ ] `PortfolioSummaryCard` renders after data loads
- [ ] All 5 `AssetListTile` widgets render (find by key or text)
- [ ] Tapping first tile navigates to detail route
- [ ] Error state renders `ErrorView` with "Retry" button
- [ ] Tapping "Retry" calls `ref.invalidate(assetProvider)`

---

### TASK-T05: Widget Tests — Asset Detail Screen

**Depends on:** TASK-D06

**File:** `test/features/portfolio/screens/asset_detail_screen_test.dart`

**Test cases:**
- [ ] All 6 fields (name, symbol, quantity, buy price, current price, total value) render
- [ ] `PnlBadge` color is green for positive P&L
- [ ] `PnlBadge` color is red for negative P&L
- [ ] Back button triggers `context.pop()`
- [ ] Unknown asset id renders error view

---

### TASK-T06: Integration — Navigation Flow

**Depends on:** All D-tasks complete

**File:** `test/integration/navigation_flow_test.dart`

**Test cases:**
- [ ] App starts on HomeScreen (`/`)
- [ ] Tap first asset → navigates to `/asset/{id}`
- [ ] Back button from detail → returns to HomeScreen
- [ ] Deep link `/asset/aapl` loads AssetDetailScreen directly
- [ ] Deep link to unknown id `/asset/xxx` renders error view, no crash

---

### TASK-T07: Static Analysis Gate

**Run after every D-task**

**Command:** `flutter analyze --no-fatal-infos`

**Acceptance criteria:**
- [ ] Zero errors
- [ ] Zero warnings
- [ ] No `// ignore:` suppressions added

---

## Delivery Sequence

```
Sprint 1 (Day 1)
  D01  Project setup + dependencies
  D02  Asset / Portfolio models
  D03  Mock repository
  T07  Analyze gate (after each D task)

Sprint 1 (Day 2)
  D04  Riverpod providers
  T01  Unit tests — models
  T02  Unit tests — repository
  T03  Provider tests

Sprint 2 (Day 3)
  D05  Home screen
  D06  Asset detail screen
  T04  Widget tests — Home
  T05  Widget tests — Detail

Sprint 2 (Day 4)
  T06  Integration — navigation flow
  T07  Final analyze gate
  Code review — CTO sign-off
```

---

## Quality Gates (mandatory before any task is marked Done)

1. `flutter analyze` — zero issues
2. `flutter test` — all tests in scope pass
3. No `print()` in production code
4. No `!` operator without justifying comment
5. No magic numbers (all constants in `core/constants/`)
6. All files under 200 lines
7. No new dependencies without CTO approval

---

## Risks & Mitigations

| Risk | Mitigation |
|---|---|
| Freezed codegen conflicts during parallel development | Each dev runs their own `build_runner` scope; merge `.g.dart` carefully |
| `NotifierProvider` API newness — team may default to old patterns | CTO code review checks for `StateNotifierProvider` usage and rejects |
| P&L percent division by zero | Guard in `AssetComputed` extension, covered by T01 unit test |
| Riverpod 2.x `ref.invalidate` not available in tests without `ProviderContainer` | Use `ProviderContainer` with `overrides` in all provider tests |
