import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_portfolio/core/theme/app_theme.dart';
import 'package:my_portfolio/features/home/presentation/pages/home_page.dart';

void main() {
  group('HomePage Widget Tests', () {
    Widget createTestWidget() {
      return MaterialApp(
        theme: AppTheme.light,
        home: const HomePage(),
      );
    }

    /// Sets logical viewport size (devicePixelRatio = 1 so physical == logical).
    void setLogicalSize(WidgetTester tester, double width, double height) {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = Size(width, height);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
    }

    group('Mobile Layout (width < 600px)', () {
      testWidgets('Renders name text "Hi, I\'m Hung" on mobile viewport',
          (WidgetTester tester) async {
        setLogicalSize(tester, 500, 900);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Hi, I\'m Hung'), findsWidgets);
        expect(find.text('Flutter Developer'), findsOneWidget);
        expect(
            find.text(
                'Crafting performant cross-platform apps for iOS, Android & Web.'),
            findsOneWidget);
      });

      testWidgets('Mobile layout does not render NavigationRail from HomePage',
          (WidgetTester tester) async {
        setLogicalSize(tester, 400, 900);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Mobile layout should NOT have NavigationRail (nav is in AppShell)
        expect(find.byType(NavigationRail), findsNothing);
        expect(find.byType(Scaffold), findsOneWidget);
      });
    });

    group('Desktop Layout (width >= 1024px)', () {
      testWidgets('Renders name text "Hi, I\'m Hung" on desktop viewport',
          (WidgetTester tester) async {
        setLogicalSize(tester, 1440, 900);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Hi, I\'m Hung'), findsWidgets);
        expect(find.text('Flutter Developer'), findsOneWidget);
        expect(
            find.text(
                'Crafting performant cross-platform apps for iOS, Android & Web.'),
            findsOneWidget);
      });

      testWidgets(
          'Desktop layout does not render NavigationRail (handled by AppShell)',
          (WidgetTester tester) async {
        setLogicalSize(tester, 1440, 900);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // NavigationRail is now in AppShell, not in HomePage directly
        expect(find.byType(NavigationRail), findsNothing);
      });
    });

    group('Text Content Rendering', () {
      testWidgets('All required text is present on mobile',
          (WidgetTester tester) async {
        setLogicalSize(tester, 500, 900);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Hi, I\'m Hung'), findsWidgets);
        expect(find.text('Flutter Developer'), findsOneWidget);
        expect(
            find.text(
                'Crafting performant cross-platform apps for iOS, Android & Web.'),
            findsOneWidget);
      });

      testWidgets('All required text is present on desktop',
          (WidgetTester tester) async {
        setLogicalSize(tester, 1440, 900);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Hi, I\'m Hung'), findsWidgets);
        expect(find.text('Flutter Developer'), findsOneWidget);
        expect(
            find.text(
                'Crafting performant cross-platform apps for iOS, Android & Web.'),
            findsOneWidget);
      });
    });

    group('Responsive Behavior', () {
      testWidgets('HomePage renders without error',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(HomePage), findsOneWidget);
        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('Mobile layout has no NavigationRail',
          (WidgetTester tester) async {
        setLogicalSize(tester, 500, 900);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(NavigationRail), findsNothing);
        expect(find.byType(SafeArea), findsWidgets);
      });

      testWidgets('Desktop layout has no NavigationRail in HomePage',
          (WidgetTester tester) async {
        setLogicalSize(tester, 1440, 900);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // NavigationRail moved to AppShell — not present in HomePage standalone
        expect(find.byType(NavigationRail), findsNothing);
        expect(find.byType(SafeArea), findsWidgets);
      });
    });
  });
}
