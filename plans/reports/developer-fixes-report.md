# Developer Fixes Report

## Summary

All critical and minor code review fixes have been applied. `flutter analyze` reports 0 issues and all 56 tests pass.

---

## Critical Fixes

### FIX-1: Guarded `launchUrl` calls in `project_detail_page.dart`
- Extracted a `_launch(BuildContext context, String uriString)` method matching the exact pattern from `contact_page.dart`
- Both `githubUrl` and `liveUrl` launch calls now wrapped in try/catch with a SnackBar error message
- Uses `AppStrings.contactErrorMessage` for the error text
- Uses `LaunchMode.externalApplication`

### FIX-2: Removed duplicate file-level constants in `home_page.dart`
- Removed `_kName`, `_kTitle`, `_kTagline` file-level constants
- Added import of `AppStrings`
- All 4 usages (2 in `_MobileLayout`, 2 in `_DesktopLayout`) updated to `AppStrings.name`, `AppStrings.title`, `AppStrings.tagline`

### FIX-3: Magic strings moved to `AppStrings`
- Added to `lib/core/constants/app_strings.dart`:
  - `static const techStack = 'Tech Stack';`
  - `static const viewOnGitHub = 'View on GitHub';`
  - `static const liveDemo = 'Live Demo';`
  - `static const whatIValue = 'What I value:';`
- `project_detail_page.dart`: replaced `'Tech Stack'`, `'View on GitHub'`, `'Live Demo'` with `AppStrings.*`
- `about_page.dart`: replaced `'What I value:'` with `AppStrings.whatIValue`

---

## Minor Fixes

### MINOR-1: `const` constructors for `_MobileAbout` and `_DesktopAbout`
- Added `const _MobileAbout();` and `const _DesktopAbout();` constructors
- Since all children are const-compatible, the build methods were also made fully `const`
- Updated `_AboutPageState.build` to pass `const` instances to `ResponsiveLayout`

### MINOR-2: Breakpoint constant unified
- `responsive_layout.dart` already defines `abstract final class Breakpoints` with `static const double tablet = 1024;`
- `app_shell.dart`: removed local `_kDesktopBreakpoint = 1024.0`, imported `responsive_layout.dart`, and replaced usage with `Breakpoints.tablet`

### MINOR-3: `BottomNavigationBar` → `NavigationBar` (Material 3)
- `_MobileShell` in `app_shell.dart` now uses `NavigationBar` with `NavigationDestination` children
- `selectedIndex` and `onDestinationSelected` used (Material 3 API)
- Updated `test/integration/navigation_flow_test.dart` to find `NavigationBar` instead of `BottomNavigationBar`

### MINOR-4: `imageAsset` field made nullable
- `lib/core/models/project.dart`: changed `final String imageAsset` → `final String? imageAsset`, made parameter optional
- `lib/features/projects/data/projects_data.dart`: removed all `imageAsset: ''` arguments (3 entries)

### MINOR-5: Removed dead `AppRoutes.projectDetail` constant
- `lib/router/app_router.dart`: removed `static const String projectDetail = '/projects/:id';`
- Confirmed via grep: constant was declared but never referenced anywhere in the codebase

---

## Files Modified

| File | Change |
|------|--------|
| `lib/core/constants/app_strings.dart` | Added 4 new string constants |
| `lib/features/projects/presentation/pages/project_detail_page.dart` | FIX-1, FIX-3: guarded launches + AppStrings |
| `lib/features/home/presentation/pages/home_page.dart` | FIX-2: removed local constants, use AppStrings |
| `lib/features/about/presentation/pages/about_page.dart` | FIX-3, MINOR-1: AppStrings.whatIValue + const constructors |
| `lib/core/widgets/app_shell.dart` | MINOR-2, MINOR-3: Breakpoints.tablet + NavigationBar |
| `lib/core/models/project.dart` | MINOR-4: nullable imageAsset |
| `lib/features/projects/data/projects_data.dart` | MINOR-4: removed empty imageAsset args |
| `lib/router/app_router.dart` | MINOR-5: removed dead projectDetail constant |
| `test/integration/navigation_flow_test.dart` | Updated BottomNavigationBar → NavigationBar assertion |

---

## Quality Results

- `flutter analyze`: **0 issues**
- `flutter test`: **56/56 passed**
