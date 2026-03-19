import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_portfolio/core/theme/app_theme.dart';
import 'package:my_portfolio/router/app_router.dart';

/// Tests AppShell's responsive nav behavior: NavigationBar on mobile,
/// NavigationRail on desktop (width >= 1024).
void main() {
  group('AppShell Responsive Navigation Tests', () {
    Widget createApp() => MaterialApp.router(
          theme: AppTheme.light,
          routerConfig: appRouter,
        );

    void setLogicalSize(WidgetTester tester, double width, double height) {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = Size(width, height);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
    }

    group('Mobile layout (width < 1024)', () {
      testWidgets('Shows NavigationBar, not NavigationRail at 500px',
          (WidgetTester tester) async {
        setLogicalSize(tester, 500, 900);
        await tester.pumpWidget(createApp());
        await tester.pumpAndSettle();

        expect(find.byType(NavigationBar), findsOneWidget);
        expect(find.byType(NavigationRail), findsNothing);
      });

      testWidgets('Shows NavigationBar at 1023px (just below desktop breakpoint)',
          (WidgetTester tester) async {
        setLogicalSize(tester, 1023, 900);
        await tester.pumpWidget(createApp());
        await tester.pumpAndSettle();

        expect(find.byType(NavigationBar), findsOneWidget);
        expect(find.byType(NavigationRail), findsNothing);
      });

      testWidgets('NavigationBar has exactly 5 destinations on mobile',
          (WidgetTester tester) async {
        setLogicalSize(tester, 500, 900);
        await tester.pumpWidget(createApp());
        await tester.pumpAndSettle();

        final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
        expect(navBar.destinations.length, equals(5));
      });

      testWidgets('NavigationBar shows all 5 nav labels on mobile',
          (WidgetTester tester) async {
        setLogicalSize(tester, 500, 900);
        await tester.pumpWidget(createApp());
        await tester.pumpAndSettle();

        expect(find.text('Home'), findsWidgets);
        expect(find.text('About'), findsWidgets);
        expect(find.text('Projects'), findsWidgets);
        expect(find.text('Skills'), findsWidgets);
        expect(find.text('Contact'), findsWidgets);
      });
    });

    group('Desktop layout (width >= 1024)', () {
      testWidgets('Shows NavigationRail, not NavigationBar at 1440px',
          (WidgetTester tester) async {
        setLogicalSize(tester, 1440, 900);
        await tester.pumpWidget(createApp());
        await tester.pumpAndSettle();

        expect(find.byType(NavigationRail), findsOneWidget);
        expect(find.byType(NavigationBar), findsNothing);
      });

      testWidgets('Shows NavigationRail at exactly 1024px (desktop breakpoint)',
          (WidgetTester tester) async {
        setLogicalSize(tester, 1024, 900);
        await tester.pumpWidget(createApp());
        await tester.pumpAndSettle();

        expect(find.byType(NavigationRail), findsOneWidget);
        expect(find.byType(NavigationBar), findsNothing);
      });

      testWidgets('NavigationRail has exactly 5 destinations on desktop',
          (WidgetTester tester) async {
        setLogicalSize(tester, 1440, 900);
        await tester.pumpWidget(createApp());
        await tester.pumpAndSettle();

        final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
        expect(rail.destinations.length, equals(5));
      });

      testWidgets('NavigationRail shows all 5 nav labels on desktop',
          (WidgetTester tester) async {
        setLogicalSize(tester, 1440, 900);
        await tester.pumpWidget(createApp());
        await tester.pumpAndSettle();

        expect(find.text('Home'), findsWidgets);
        expect(find.text('About'), findsWidgets);
        expect(find.text('Projects'), findsWidgets);
        expect(find.text('Skills'), findsWidgets);
        expect(find.text('Contact'), findsWidgets);
      });

      testWidgets('Desktop layout uses VerticalDivider between rail and body',
          (WidgetTester tester) async {
        setLogicalSize(tester, 1440, 900);
        await tester.pumpWidget(createApp());
        await tester.pumpAndSettle();

        expect(find.byType(VerticalDivider), findsOneWidget);
      });
    });

    group('Navigation via NavigationRail (desktop)', () {
      testWidgets('Tapping About destination on desktop shows About page',
          (WidgetTester tester) async {
        setLogicalSize(tester, 1440, 900);
        await tester.pumpWidget(createApp());
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.person_outline).first);
        await tester.pumpAndSettle();

        expect(find.text('About Me'), findsWidgets);
      });

      testWidgets('Tapping Contact destination on desktop shows Contact page',
          (WidgetTester tester) async {
        setLogicalSize(tester, 1440, 900);
        await tester.pumpWidget(createApp());
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.mail_outline).first);
        await tester.pumpAndSettle();

        expect(find.text('Contact'), findsWidgets);
      });
    });
  });
}
