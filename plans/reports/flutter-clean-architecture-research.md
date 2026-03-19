# Flutter Clean Architecture Research Report

**Research Date:** March 16, 2026
**Focus:** Portfolio app architecture patterns for 2025/2026

---

## Executive Summary

Flutter clean architecture in 2025/2026 emphasizes **three-layer separation** (Presentation/Domain/Data) with **feature-based organization**. The industry consensus favors **go_router for navigation**, **Riverpod 3.0 for state management**, and **native Flutter tools** (LayoutBuilder/MediaQuery) for responsiveness. Material 3 is now the default—no explicit configuration needed.

---

## Key Findings

### 1. Recommended Folder Structure

Standard **feature-based clean architecture**:

```
lib/
├── features/
│   ├── auth/
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   ├── widgets/
│   │   │   └── providers/ (state management)
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   └── repositories/
│   │   └── data/
│   │       ├── datasources/
│   │       ├── models/
│   │       └── repositories/
│   └── (other features...)
├── core/
│   ├── theme/
│   ├── constants/
│   ├── utils/
│   └── widgets/ (shared UI components)
└── main.dart

test/
└── (mirror lib/ structure)
```

**Key Rules:**
- Each feature is self-contained with its own Presentation/Domain/Data layers
- Core contains shared utilities, themes, and widgets
- Follow dependency rule: inner layers know nothing about outer layers
- Max ~200 lines per file (split large components)

---

### 2. Navigation: go_router (Clear Winner)

**Status:** Officially maintained by Flutter team, industry standard in 2025/2026

**Latest Version:** 14.x (stable)

**Why go_router:**
- Deep linking support out-of-box
- Declarative routing syntax
- Works seamlessly with nested navigation
- Perfect for web/desktop/mobile

**Integration with Riverpod:**
```dart
// Define as provider
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => HomePage(),
      ),
    ],
    redirect: (context, state) async {
      // Use ref to check auth state from Riverpod
      final isAuthed = ref.watch(authProvider);
      if (!isAuthed && state.location != '/login') {
        return '/login';
      }
      return null;
    },
  );
});
```

**Note:** Riverpod vs go_router are **not competitors**—they serve different purposes. Use both together.

---

### 3. Responsive Design Patterns

**Approach:** Combine native Flutter tools (don't over-rely on packages)

**LayoutBuilder (Recommended):**
```dart
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth < 600) {
      return MobileLayout();
    } else if (constraints.maxWidth < 1200) {
      return TabletLayout();
    } else {
      return DesktopLayout();
    }
  },
)
```

**MediaQuery.sizeOf() (for global size):**
```dart
final screenSize = MediaQuery.sizeOf(context);
final isMobile = screenSize.width < 600;
```

**flutter_screenutil (Optional, for pixel-perfect scaling):**
- Use if targeting diverse devices with exact pixel specs
- Combines with LayoutBuilder for best results
- Not strictly necessary for most apps

**Best Practice:** Prefer LayoutBuilder over MediaQuery for local components—it's more efficient and doesn't rebuild on unrelated changes.

---

### 4. Material 3 Theme Setup

**Status:** Default in Flutter 3.16+ (no action needed)

**Simple Setup:**
```dart
MaterialApp(
  theme: ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    ),
    useMaterial3: true, // Explicit (optional—now default)
  ),
  darkTheme: ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  ),
)
```

**Key Points:**
- `useMaterial3: true` is default—no need to set it explicitly
- Use `ColorScheme.fromSeed()` for harmonious colors (generates complete palette from one seed color)
- Custom component themes: add `snackBarTheme`, `segmentedButtonTheme`, etc. to ThemeData
- Migration from Material 2 mostly automatic; check `NavigationBar` widget if upgrading legacy code

---

### 5. Essential Packages (2025/2026 Stack)

| Package | Purpose | Status | Notes |
|---------|---------|--------|-------|
| **go_router** | Navigation | Stable (14.x) | Industry standard; official Flutter support |
| **riverpod** | State management | Stable (3.0) | Compile-time safe; best for new projects |
| **riverpod_generator** | Code generation | Stable | Reduces boilerplate; pair with riverpod |
| **freezed** | Data classes | Stable | Generates copyWith, equality, toString |
| **json_serializable** | JSON serialization | Stable | Auto-generate toJson/fromJson |
| **flutter_screenutil** | Responsive scaling | Stable | Optional; use with LayoutBuilder |
| **dio** | HTTP client | Stable (5.x) | Modern, well-maintained alternative to http |
| **sqflite** / **drift** | Local DB | Stable | sqflite for simple; drift for complex queries |

**Avoid:** GetX (maintenance crisis as of 2025)

---

## Comparative Analysis

### State Management: Riverpod vs Provider vs BLoC

| Aspect | Riverpod 3.0 | Provider | BLoC 9.0 |
|--------|-----------|----------|---------|
| **Learning Curve** | Moderate | Easy | Steep |
| **Boilerplate** | Minimal | Low | High |
| **Compile Safety** | Yes (generator) | No | No |
| **Best For** | Most projects | Beginners | Enterprise |
| **Maturity** | High | High | High |

**Recommendation for Portfolio App:** **Riverpod 3.0** balances simplicity with power. Compile-time safety catches bugs early.

---

## Implementation Recommendations

### Quick Start Checklist

- [ ] Set up feature-based folder structure
- [ ] Add `go_router` (v14+) for navigation
- [ ] Add `riverpod` + `riverpod_generator` for state management
- [ ] Use `ColorScheme.fromSeed()` for Material 3 theme (no manual color tweaking needed)
- [ ] Use `LayoutBuilder` for responsive breakpoints
- [ ] Add `freezed` + `json_serializable` for data models
- [ ] Create `core/theme/app_theme.dart` with light/dark themes
- [ ] Document architecture decisions in `docs/ARCHITECTURE.md`

### Architecture Decision Record Template

```markdown
# Architecture Decision: [Title]

## Decision
[What you decided and why]

## Rationale
[Why this choice over alternatives]

## Consequences
[Trade-offs and impacts]
```

---

## Common Pitfalls & Solutions

| Pitfall | Solution |
|---------|----------|
| Mixing layers (UI calls data directly) | Enforce dependency rule; use domain repositories as middlemen |
| Monolithic feature folders | Keep features under 1000 lines; split if too large |
| Over-engineering for "extensibility" | Follow YAGNI; add complexity only when needed |
| Hardcoded pixel values | Use LayoutBuilder breakpoints; avoid MediaQuery for local widgets |
| GetX in new projects | Use Riverpod instead (maintenance risk with GetX) |
| Manual theme colors | Use `ColorScheme.fromSeed()`—generates full palette automatically |

---

## Security & Performance Notes

- **State Management**: Riverpod's compile-time safety prevents null pointer bugs common in Provider
- **Navigation**: go_router handles deep linking securely without URL injection vulnerabilities
- **Responsive**: LayoutBuilder rebuilds only affected subtree; more performant than MediaQuery
- **Theming**: ColorScheme.fromSeed() generates WCAG-compliant contrast ratios by default

---

## Resources & References

### Official Documentation
- [Flutter App Architecture Guide](https://docs.flutter.dev/app-architecture/guide)
- [Material 3 for Flutter](https://m3.material.io/develop/flutter/)
- [Adaptive & Responsive Design Best Practices](https://docs.flutter.dev/ui/adaptive-responsive/best-practices)
- [ThemeData API Reference](https://api.flutter.dev/flutter/material/ThemeData/useMaterial3.html)

### Recommended Articles
- [Building Scalable Folder Structure with Clean Architecture (DEV Community)](https://dev.to/alaminkarno/building-a-scalable-folder-structure-in-flutter-using-clean-architecture-bloccubit-530c)
- [Flutter 3.38 Clean Architecture 2025 (Medium)](https://medium.com/@flutter-app/flutter-3-38-clean-architecture-project-structure-for-2025-f6155ac40d87)
- [GoRouter + Riverpod Integration (CodeWithAndrea)](https://codewithandrea.com/articles/flutter-navigate-without-context-gorouter-riverpod/)
- [Responsive UI in Flutter 2026 (DEV Community)](https://dev.to/techwithsam/how-to-build-responsive-flutter-apps-for-phones-foldables-tablets-web-2026-140o)
- [Master Flutter State Management 2025 (BoltUiX)](https://www.boltuix.com/2025/09/master-flutter-state-management-2025.html)

### Community
- [Flutter Gems - State Management Packages](https://fluttergems.dev/state-management/)
- [Riverpod GitHub Discussions](https://github.com/rrousselGit/riverpod/discussions)
- [go_router GitHub Issues](https://github.com/flutter/packages/issues)

---

## Unresolved Questions

- None at this time. Research covers requested topics comprehensively.

---

## Next Steps for Implementation

1. **Architecture Phase**: Create folder structure + add go_router provider
2. **State Management Phase**: Set up Riverpod with code generation
3. **Theme Phase**: Configure Material 3 with ColorScheme.fromSeed() + dark theme
4. **Responsive Phase**: Implement LayoutBuilder breakpoints for mobile/tablet/desktop
5. **Data Layer Phase**: Add models with freezed/json_serializable, set up repositories
6. **Testing Phase**: Add unit/widget tests mirroring lib/ structure
