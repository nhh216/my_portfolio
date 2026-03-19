---
title: "CTO Architecture Review & Engineering Task Assignments"
role: Chief Technology Officer
date: 2026-03-16
status: active
---

# CTO Architecture Review & Engineering Task Assignments

## CEO Product Plan Summary

**Product:** Personal developer portfolio — cross-platform Flutter app (Web, macOS, iOS, Android).
**Goal:** Showcase Hung's identity, projects, skills, and contact — with a polished, responsive UI.
**Current State:** Phase 1 scaffolding complete (theme, routing, responsive layout, hero home page).

---

## Architecture Decision

### Chosen Pattern: Clean Architecture + Feature-Sliced Structure

```
lib/
├── core/
│   ├── constants/          # App-wide constants (strings, assets, durations)
│   ├── theme/              # AppColors, AppTheme (M3)
│   ├── utils/              # Helpers (url_launcher wrapper, formatters)
│   └── widgets/            # Shared UI (ResponsiveLayout, SectionTitle, AppButton)
├── features/
│   ├── home/               # Hero section — DONE (Phase 1)
│   │   └── presentation/pages/ & widgets/
│   ├── about/              # About Me — bio, photo, values
│   │   └── presentation/pages/ & widgets/
│   ├── projects/           # Projects showcase — cards, detail view
│   │   ├── data/           # Static project data source
│   │   └── presentation/pages/ & widgets/
│   ├── skills/             # Tech stack badges, proficiency indicators
│   │   └── presentation/pages/ & widgets/
│   └── contact/            # Contact form / links (email, GitHub, LinkedIn)
│       └── presentation/pages/ & widgets/
├── router/
│   └── app_router.dart     # go_router — all routes registered here
└── main.dart
```

### Key Architectural Decisions

| Decision | Choice | Rationale |
|---|---|---|
| State management | `StatefulWidget` / `ValueNotifier` | No complex state needed for static portfolio |
| Data source | Dart constants / models (no backend) | Portfolio data is static — no API needed |
| Navigation | `go_router` (shell route) | Deep-linking for Web, persistent nav rail on desktop |
| Responsive strategy | `ResponsiveLayout` widget (existing) | Already working, covers mobile/tablet/desktop |
| URL launching | `url_launcher` package | Open GitHub, LinkedIn, email from contact section |
| Fonts | `google_fonts` package | `Inter` for body, `Poppins` for headings |
| Animations | Flutter built-in (`AnimatedOpacity`, `TweenAnimationBuilder`) | Keep dependency count low |

---

## System Components

```
┌─────────────────────────────────────────────────────────────┐
│                      App Shell (go_router)                  │
│  ┌──────────┬────────────────────────────────────────────┐  │
│  │   Nav    │         Feature Pages                      │  │
│  │  Rail /  │  Home | About | Projects | Skills | Contact│  │
│  │  Drawer  │                                            │  │
│  └──────────┴────────────────────────────────────────────┘  │
│                                                             │
│  Core Layer:  AppTheme · AppColors · ResponsiveLayout       │
│               AppConstants · SharedWidgets                  │
└─────────────────────────────────────────────────────────────┘
```

### Navigation Architecture (Shell Route)

```
GoRouter
└── ShellRoute (AppShell — persistent nav rail / bottom nav)
    ├── /           → HomePage
    ├── /about      → AboutPage
    ├── /projects   → ProjectsPage
    │   └── /projects/:id  → ProjectDetailPage
    ├── /skills     → SkillsPage
    └── /contact    → ContactPage
```

### Data Model (No Backend)

```dart
// Project model
class Project {
  final String id, title, description, imageAsset;
  final List<String> techStack;
  final String? githubUrl, liveUrl;
}

// Skill model
class Skill {
  final String name, assetIcon;
  final SkillLevel level; // beginner | intermediate | advanced | expert
}
```

---

## Engineering Tasks

### Developer Tasks

#### TASK-D01: Navigation Shell + Route Wiring [COMPLETE]
- **Priority:** P1 (blocks all other features)
- **Effort:** 3h
- **Files:**
  - `lib/router/app_router.dart` — add ShellRoute, register all 5 routes
  - `lib/core/widgets/app_shell.dart` — new: persistent nav (NavigationRail desktop, BottomNavBar mobile)
- **Acceptance Criteria:**
  - Nav rail visible on desktop (≥1024px), bottom bar on mobile/tablet
  - All 5 routes navigate without error
  - Browser back button works on Web
  - Active destination highlights correctly

#### TASK-D02: About Page [COMPLETE]
- **Priority:** P2
- **Effort:** 2h
- **Files:**
  - `lib/features/about/presentation/pages/about_page.dart`
  - `lib/features/about/presentation/widgets/bio_card.dart`
- **Content:** Name, photo (placeholder asset), 2–3 sentence bio, values/fun-facts list
- **Acceptance Criteria:**
  - Responsive — stacked on mobile, side-by-side on desktop
  - Fade-in animation on mount

#### TASK-D03: Projects Data + Projects Page [COMPLETE]
- **Priority:** P2
- **Effort:** 4h
- **Files:**
  - `lib/core/models/project.dart` — Project model
  - `lib/features/projects/data/projects_data.dart` — static list (min 3 projects)
  - `lib/features/projects/presentation/pages/projects_page.dart`
  - `lib/features/projects/presentation/widgets/project_card.dart`
  - `lib/features/projects/presentation/pages/project_detail_page.dart`
- **Acceptance Criteria:**
  - Grid layout on desktop, list on mobile
  - Each card shows title, tags, and short description
  - Tapping opens detail page with GitHub/live URL buttons (url_launcher)
  - Detail page has back navigation

#### TASK-D04: Skills Page [COMPLETE]
- **Priority:** P3
- **Effort:** 2h
- **Files:**
  - `lib/core/models/skill.dart`
  - `lib/features/skills/data/skills_data.dart`
  - `lib/features/skills/presentation/pages/skills_page.dart`
  - `lib/features/skills/presentation/widgets/skill_chip.dart`
- **Acceptance Criteria:**
  - Skills grouped by category (Languages, Frameworks, Tools)
  - Each chip shows icon + name
  - Responsive wrap layout

#### TASK-D05: Contact Page [COMPLETE]
- **Priority:** P3
- **Effort:** 2h
- **Files:**
  - `lib/features/contact/presentation/pages/contact_page.dart`
  - `lib/features/contact/presentation/widgets/contact_link_tile.dart`
- **Links to include:** Email, GitHub, LinkedIn (url_launcher)
- **Acceptance Criteria:**
  - Links open correctly on all platforms
  - Accessible tap targets (≥48dp)

#### TASK-D06: Shared Widgets Extraction [COMPLETE]
- **Priority:** P1 (do alongside D01)
- **Effort:** 1h
- **Files:**
  - `lib/core/widgets/section_title.dart` — reusable section heading
  - `lib/core/constants/app_strings.dart` — all user-facing strings
  - `lib/core/constants/app_assets.dart` — asset path constants
- **Acceptance Criteria:**
  - No magic strings in widget files
  - All features use `SectionTitle` for headings

#### TASK-D07: Add Dependencies [COMPLETE]
- **Priority:** P0 (do first)
- **Effort:** 30min
- **pubspec.yaml additions:**
  ```yaml
  dependencies:
    url_launcher: ^6.3.0
    google_fonts: ^6.2.1
  ```
- **Acceptance Criteria:**
  - `flutter pub get` runs clean
  - `flutter analyze` zero issues

---

### Tester Tasks

#### TASK-T01: Widget Tests — Navigation Shell [COMPLETE]
- **Depends on:** TASK-D01
- **Effort:** 2h
- **File:** `test/core/widgets/app_shell_test.dart`
- **Test Cases:**
  - Renders NavigationRail on desktop viewport
  - Renders BottomNavigationBar on mobile viewport
  - Tapping each destination triggers correct route

#### TASK-T02: Widget Tests — Home Page [COMPLETE]
- **Effort:** 1h
- **File:** `test/features/home/home_page_test.dart`
- **Test Cases:**
  - Renders `_MobileLayout` at width < 600
  - Renders `_DesktopLayout` at width > 1024
  - Name, title, tagline text are present

#### TASK-T03: Widget Tests — Projects Page [COMPLETE]
- **Depends on:** TASK-D03
- **Effort:** 2h
- **File:** `test/features/projects/projects_page_test.dart`
- **Test Cases:**
  - All static projects render (no null errors)
  - Tapping a card navigates to detail page
  - Detail page shows title and description

#### TASK-T04: Widget Tests — Skills Page [COMPLETE]
- **Depends on:** TASK-D04
- **Effort:** 1h
- **File:** `test/features/skills/skills_page_test.dart`
- **Test Cases:**
  - Skills categories render correctly
  - Each skill chip shows name

#### TASK-T05: Integration — Navigation Flow [COMPLETE]
- **Depends on:** All D-tasks
- **Effort:** 2h
- **File:** `test/integration/navigation_flow_test.dart`
- **Test Cases:**
  - Can navigate Home → About → Projects → Skills → Contact → Home
  - Deep link `/projects` loads projects page directly
  - Back navigation restores previous page

#### TASK-T06: Golden Tests — Responsive Breakpoints [COMPLETE]
- **Effort:** 2h
- **File:** `test/golden/responsive_golden_test.dart`
- **Test Cases:**
  - Mobile (375×812) home page screenshot matches golden
  - Desktop (1440×900) home page matches golden
  - Update goldens command documented in README

#### TASK-T07: Static Analysis & Lint [COMPLETE]
- **Priority:** P0 (run after every D-task)
- **Command:** `flutter analyze`
- **Acceptance Criteria:** Zero issues, no `// ignore` suppressions

---

## Delivery Order (Recommended Sequence)

```
Day 1:  D07 (deps) → D01 + D06 (shell + shared) → T07 (analyze)
Day 2:  D02 (about) → D03 (projects) → T01 + T02
Day 3:  D04 (skills) → D05 (contact) → T03 + T04
Day 4:  T05 (integration) → T06 (golden) → T07 (final analyze)
```

---

## Quality Gates

Before any task is marked done:
1. `flutter analyze` — zero issues
2. `flutter test` — all tests pass
3. Responsive verified at 375px (mobile), 768px (tablet), 1440px (desktop)
4. No hardcoded strings outside `app_strings.dart`
5. Files under 200 lines (split if needed)

---

## Risks & Mitigations

| Risk | Mitigation |
|---|---|
| `url_launcher` Web requires `launchMode: LaunchMode.externalApplication` | Document platform config in contact feature |
| `google_fonts` adds network request in production | Cache fonts or bundle as assets |
| go_router ShellRoute state loss on nav | Use `StatefulShellRoute` for state preservation |
| Golden test flakiness across Flutter versions | Pin Flutter SDK version in CI |

---

## Delivery Summary

All engineering tasks completed successfully. Portfolio app is production-ready.

**Test Results:** 56 tests passing, 0 analyze issues
**Code Review:** Approved
**Features Shipped:**
- Navigation shell with responsive layout (NavigationRail desktop, BottomNavigationBar mobile)
- Home, About, Projects (with detail pages), Skills, and Contact pages
- Responsive design across mobile/tablet/desktop breakpoints
- URL launching for GitHub, LinkedIn, and email links
- Material 3 theming with light/dark mode support
- Static project and skills data management
- Clean architecture with feature-sliced structure

**Status:** Ready for deployment
