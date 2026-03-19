---
title: "Flutter Portfolio Project Setup"
description: "Set up clean architecture, theming, routing, and responsive layout for portfolio app"
status: complete
priority: P1
effort: 2h
branch: main
tags: [flutter, setup, architecture]
created: 2026-03-16
---

# Flutter Portfolio Project Setup

## Goal
Transform bare Flutter template into a structured portfolio app with Material 3 theming, go_router navigation, and responsive layout scaffolding.

## Current State
- Default counter demo app (single `main.dart`)
- Dart SDK ^3.11.1, no extra dependencies

## Architecture
```
lib/
├── core/
│   ├── theme/
│   │   ├── app_colors.dart      # Color constants
│   │   └── app_theme.dart       # Light/dark ThemeData
│   └── widgets/
│       └── responsive_layout.dart  # Breakpoint-aware wrapper
├── features/
│   └── home/
│       └── presentation/
│           ├── pages/
│           │   └── home_page.dart
│           └── widgets/          # Feature-specific widgets
├── router/
│   └── app_router.dart          # go_router config
└── main.dart                    # App entry point
```

## Phases

| # | Phase | Status | Effort |
|---|-------|--------|--------|
| 1 | [Full Implementation](./phase-01-implementation.md) | complete | 2h |

## Dependencies
- go_router ^14.0.0 (pub.dev)

## Key Decisions
- Feature-based folders under `lib/features/` for scalability
- `ColorScheme.fromSeed()` for M3 theming (no manual color mapping)
- `LayoutBuilder` for responsive breakpoints (no external package needed)
- Single phase since all tasks are tightly coupled
