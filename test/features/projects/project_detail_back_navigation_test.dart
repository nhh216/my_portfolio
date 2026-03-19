import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:my_portfolio/core/theme/app_theme.dart';
import 'package:my_portfolio/features/projects/presentation/pages/project_detail_page.dart';

void main() {
  group('ProjectDetailPage Back Navigation Tests', () {
    void setLogicalSize(WidgetTester tester, double width, double height) {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = Size(width, height);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
    }

    Widget createTestWidget(String projectId) {
      final router = GoRouter(
        initialLocation: '/projects/$projectId',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('Projects List'))),
          ),
          GoRoute(
            path: '/projects/:id',
            builder: (context, state) => ProjectDetailPage(
              projectId: state.pathParameters['id']!,
            ),
          ),
        ],
      );

      return MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: router,
      );
    }

    group('BackButton presence', () {
      testWidgets('BackButton is present in AppBar for valid project',
          (WidgetTester tester) async {
        setLogicalSize(tester, 500, 900);
        await tester.pumpWidget(createTestWidget('flutter-portfolio'));
        await tester.pumpAndSettle();

        expect(find.byType(BackButton), findsOneWidget);
      });

      testWidgets('AppBar is present for valid project',
          (WidgetTester tester) async {
        setLogicalSize(tester, 500, 900);
        await tester.pumpWidget(createTestWidget('flutter-portfolio'));
        await tester.pumpAndSettle();

        expect(find.byType(AppBar), findsOneWidget);
      });
    });

    group('Back navigation via BackButton', () {
      testWidgets('Tapping BackButton navigates back to previous route',
          (WidgetTester tester) async {
        setLogicalSize(tester, 500, 900);

        // Start on the projects list page
        final router = GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () => context.push('/projects/flutter-portfolio'),
                    child: const Text('Open Project'),
                  ),
                ),
              ),
            ),
            GoRoute(
              path: '/projects/:id',
              builder: (context, state) => ProjectDetailPage(
                projectId: state.pathParameters['id']!,
              ),
            ),
          ],
        );

        await tester.pumpWidget(MaterialApp.router(
          theme: AppTheme.light,
          routerConfig: router,
        ));
        await tester.pumpAndSettle();

        // Navigate to project detail
        await tester.tap(find.text('Open Project'));
        await tester.pumpAndSettle();

        // Verify we're on the detail page
        expect(find.text('Flutter Portfolio'), findsWidgets);
        expect(find.byType(BackButton), findsOneWidget);

        // Tap back button
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();

        // Verify we're back on the previous page
        expect(find.text('Open Project'), findsOneWidget);
        expect(find.byType(BackButton), findsNothing);
      });
    });

    group('All projects have BackButton', () {
      const projectIds = [
        'flutter-portfolio',
        'shopping-app',
        'chat-app',
        'expense-tracker',
      ];

      for (final id in projectIds) {
        testWidgets('Project "$id" has a BackButton', (WidgetTester tester) async {
          setLogicalSize(tester, 500, 900);
          await tester.pumpWidget(createTestWidget(id));
          await tester.pumpAndSettle();

          expect(find.byType(BackButton), findsOneWidget);
        });
      }
    });

    group('Invalid project still shows AppBar', () {
      testWidgets('Invalid project ID shows AppBar without crashing',
          (WidgetTester tester) async {
        setLogicalSize(tester, 500, 900);
        await tester.pumpWidget(createTestWidget('nonexistent'));
        await tester.pumpAndSettle();

        expect(find.byType(AppBar), findsOneWidget);
        expect(find.text('Project not found'), findsOneWidget);
      });
    });
  });
}
