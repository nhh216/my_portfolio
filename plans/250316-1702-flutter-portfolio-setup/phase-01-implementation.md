# Phase 1: Full Implementation

## Overview
- **Priority:** P1
- **Status:** complete
- **Effort:** 2h

## Files to Modify
- `pubspec.yaml` -- add go_router dependency
- `lib/main.dart` -- rewrite to use router + theme

## Files to Create
- `lib/core/theme/app_colors.dart`
- `lib/core/theme/app_theme.dart`
- `lib/core/widgets/responsive_layout.dart`
- `lib/router/app_router.dart`
- `lib/features/home/presentation/pages/home_page.dart`

## Implementation Steps

### Step 1: Update pubspec.yaml
- [x] Add `go_router: ^14.0.0` under dependencies
- [x] Run `flutter pub get`

### Step 2: Create app_colors.dart
- [x] Define `AppColors` class with static seed color + any brand colors
- [x] Keep minimal -- only colors not derivable from `ColorScheme`

### Step 3: Create app_theme.dart
- [x] `AppTheme` class with static `lightTheme` and `darkTheme` getters
- [x] Use `ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: ...))`
- [x] Set `useMaterial3: true`
- [x] Configure text theme defaults (bodyMedium, titleLarge, etc.)

### Step 4: Create responsive_layout.dart
- [x] `ResponsiveLayout` widget using `LayoutBuilder`
- [x] Breakpoints: mobile (<600), tablet (600-1024), desktop (>1024)
- [x] Accept `mobile`, `tablet`, `desktop` builder params
- [x] Tablet falls back to mobile if not provided

### Step 5: Create app_router.dart
- [x] Define `GoRouter` instance with initial route `/`
- [x] Route `/` -> `HomePage`
- [x] Add placeholder routes: `/about`, `/projects`, `/contact` (redirect to `/` for now)

### Step 6: Create home_page.dart
- [x] Scaffold with centered "Welcome" text using theme styles
- [x] Wrap body in `ResponsiveLayout` to verify it works
- [x] Show different layouts per breakpoint as proof-of-concept

### Step 7: Update main.dart
- [x] Import `AppTheme` and `AppRouter`
- [x] Replace `MaterialApp` with `MaterialApp.router`
- [x] Wire `routerConfig`, `theme`, `darkTheme`, `themeMode`
- [x] Remove all counter demo code

### Step 8: Verify
- [x] Run `flutter analyze` -- zero issues
- [x] Run `flutter run -d chrome` -- app loads with themed home page
- [x] Test window resize triggers responsive breakpoints

## Success Criteria
- App compiles and runs without errors
- Light/dark themes switch correctly
- Responsive layout responds to viewport changes
- Router navigates to home page on `/`
- Clean architecture folders in place for future features

## Risk Assessment
- **go_router version mismatch**: Pin to ^14.0.0, check compatibility with SDK 3.11
- **M3 color overrides**: Stick to `fromSeed()` defaults initially, customize later
