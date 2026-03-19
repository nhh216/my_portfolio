# Developer Day 2 Report

## Phase Implementation Report

### Executed Phase
- Phase: Day 2 — Home cleanup, About page, Projects feature
- Plan: /Users/hung/Desktop/Project/my_portfolio
- Status: completed

---

### Files Modified

| File | Change |
|---|---|
| `lib/features/home/presentation/pages/home_page.dart` | Removed `NavigationRail` from `_DesktopLayout`; added `mainAxisSize: MainAxisSize.min` to mobile Column |
| `lib/core/constants/app_strings.dart` | Added `aboutHeading`, `aboutBio`, `aboutValues`, `projectsHeading` |
| `lib/router/app_router.dart` | Wired `AboutPage`, `ProjectsPage`; added `/projects/:id` sub-route |
| `test/features/home/home_page_test.dart` | Updated tests: removed NavigationRail desktop assertions, switched from deprecated `window` API to `tester.view`, added `devicePixelRatio = 1.0` helper |

### Files Created

| File | Purpose |
|---|---|
| `lib/features/about/presentation/pages/about_page.dart` | About feature page with AnimatedOpacity, ResponsiveLayout, SectionTitle |
| `lib/core/models/project.dart` | `Project` data model |
| `lib/features/projects/data/projects_data.dart` | Static list of 3 sample projects |
| `lib/features/projects/presentation/widgets/project_card.dart` | Tappable card widget showing title, description (2 lines), tech chips |
| `lib/features/projects/presentation/pages/projects_page.dart` | Grid (3-col desktop, 1-col mobile) using `GridView.builder` |
| `lib/features/projects/presentation/pages/project_detail_page.dart` | Detail page with GitHub/Live URL buttons via `url_launcher` |

---

### Tasks Completed

- [x] TASK-FIX: Removed `NavigationRail` from `_DesktopLayout` in `home_page.dart`
- [x] TASK-FIX: Desktop layout is now content-only; nav chrome is exclusively in `AppShell`
- [x] TASK-D02: Created `about_page.dart` with `AnimatedOpacity` fade-in (600ms), `ResponsiveLayout` (stacked mobile / side-by-side desktop), `SectionTitle`, `AppStrings`
- [x] TASK-D03: Created `Project` model
- [x] TASK-D03: Created `projects_data.dart` with 3 realistic projects
- [x] TASK-D03: Created `project_card.dart` (Card + InkWell, 2-line description, tech chips)
- [x] TASK-D03: Created `projects_page.dart` (GridView, 3-col desktop / 1-col mobile)
- [x] TASK-D03: Created `project_detail_page.dart` (full description, tech chips, url_launcher buttons, back navigation)
- [x] Updated `app_router.dart` to add `/projects/:id` sub-route under projects branch
- [x] Updated existing tests to use `tester.view` (non-deprecated) with `devicePixelRatio = 1.0`

---

### Tests Status

- `flutter analyze`: **No issues found** (0 errors, 0 warnings, 0 infos)
- `flutter test`: **10/10 passed**
  - widget_test.dart: App renders without error (1 test, passes in multiple runner iterations)
  - home_page_test.dart: All 9 widget tests pass

---

### Issues Encountered

1. **Pre-existing test deprecations**: `tester.binding.window` was deprecated. Migrated all usages to `tester.view.physicalSize` / `tester.view.resetPhysicalSize`.
2. **Layout overflow in tests**: Physical viewport sizes without `devicePixelRatio = 1.0` produced tiny logical viewports (~125px wide) causing overflow. Fixed by introducing `setLogicalSize()` helper that sets both `physicalSize` and `devicePixelRatio = 1.0`.
3. **NavigationRail test assertions**: Old tests expected `NavigationRail` in desktop `HomePage`. Updated assertions to reflect that nav is now exclusively in `AppShell`.

---

### Architecture Notes

- `AboutPage` and `ProjectsPage` each include their own `Scaffold` — consistent with `HomePage` pattern. `AppShell`'s `Scaffold` wraps the `navigationShell` which renders the branch's page tree (each page has its own Scaffold body).
- Project detail route uses `path: ':id'` as a child route under `/projects` within the same `StatefulShellBranch`, so back navigation via `context.pop()` stays within the branch.

---

### Next Steps

- Day 3: Skills page, Contact page with form
- Consider adding `Hero` animations on project card → detail transition
- `ProjectDetailPage` `imageAsset` field unused — can be wired to asset images later
