import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:my_portfolio/core/constants/app_strings.dart';
import 'package:my_portfolio/core/theme/app_theme.dart';
import 'package:my_portfolio/features/projects/data/projects_data.dart';
import 'package:my_portfolio/features/projects/presentation/pages/project_detail_page.dart';

void main() {
  group('ProjectDetailPage Widget Tests', () {
    late GoRouter router;

    Widget createTestWidget({
      required String projectId,
      ThemeData? theme,
    }) {
      router = GoRouter(
        initialLocation: '/projects/$projectId',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('Home'))),
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
        theme: theme ?? AppTheme.light,
        routerConfig: router,
      );
    }

    void setLogicalSize(WidgetTester tester, double width, double height) {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = Size(width, height);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
    }

    group('Valid Project — Flutter Portfolio', () {
      testWidgets('Page renders without error', (WidgetTester tester) async {
        setLogicalSize(tester, 500, 900);
        await tester.pumpWidget(
            createTestWidget(projectId: 'flutter-portfolio'));
        await tester.pumpAndSettle();

        expect(find.byType(ProjectDetailPage), findsOneWidget);
        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('Displays project title in body and AppBar',
          (WidgetTester tester) async {
        setLogicalSize(tester, 500, 900);
        await tester.pumpWidget(
            createTestWidget(projectId: 'flutter-portfolio'));
        await tester.pumpAndSettle();

        // Title appears in both AppBar and body
        expect(find.text('Flutter Portfolio'), findsNWidgets(2));
      });

      testWidgets('Displays project description',
          (WidgetTester tester) async {
        setLogicalSize(tester, 500, 900);
        final project = projectsData[0];

        await tester.pumpWidget(
            createTestWidget(projectId: 'flutter-portfolio'));
        await tester.pumpAndSettle();

        expect(find.text(project.description), findsOneWidget);
      });

      testWidgets('Displays "Tech Stack" heading',
          (WidgetTester tester) async {
        setLogicalSize(tester, 500, 900);
        await tester.pumpWidget(
            createTestWidget(projectId: 'flutter-portfolio'));
        await tester.pumpAndSettle();

        expect(find.text(AppStrings.techStack), findsOneWidget);
      });

      testWidgets('Displays all tech stack chips',
          (WidgetTester tester) async {
        setLogicalSize(tester, 500, 900);
        final project = projectsData[0];

        await tester.pumpWidget(
            createTestWidget(projectId: 'flutter-portfolio'));
        await tester.pumpAndSettle();

        for (final tech in project.techStack) {
          expect(find.text(tech), findsOneWidget);
        }
        expect(find.byType(Chip), findsNWidgets(project.techStack.length));
      });

      testWidgets('No action buttons when githubUrl and liveUrl are null',
          (WidgetTester tester) async {
        setLogicalSize(tester, 500, 900);
        await tester.pumpWidget(
            createTestWidget(projectId: 'flutter-portfolio'));
        await tester.pumpAndSettle();

        // Flutter Portfolio has no githubUrl or liveUrl
        expect(find.text(AppStrings.viewOnGitHub), findsNothing);
        expect(find.text(AppStrings.liveDemo), findsNothing);
        expect(find.byType(FilledButton), findsNothing);
        expect(find.byType(OutlinedButton), findsNothing);
      });

      testWidgets('Has a back button in AppBar', (WidgetTester tester) async {
        setLogicalSize(tester, 500, 900);
        await tester.pumpWidget(
            createTestWidget(projectId: 'flutter-portfolio'));
        await tester.pumpAndSettle();

        expect(find.byType(BackButton), findsOneWidget);
      });

      testWidgets('Page is scrollable', (WidgetTester tester) async {
        setLogicalSize(tester, 500, 900);
        await tester.pumpWidget(
            createTestWidget(projectId: 'flutter-portfolio'));
        await tester.pumpAndSettle();

        expect(find.byType(SingleChildScrollView), findsOneWidget);
      });
    });

    group('Valid Project — Shopping App', () {
      testWidgets('No action buttons when URLs are null',
          (WidgetTester tester) async {
        setLogicalSize(tester, 500, 900);
        await tester.pumpWidget(
            createTestWidget(projectId: 'shopping-app'));
        await tester.pumpAndSettle();

        // Shopping App has no githubUrl or liveUrl
        expect(find.text(AppStrings.viewOnGitHub), findsNothing);
        expect(find.text(AppStrings.liveDemo), findsNothing);
      });

      testWidgets('Displays correct title', (WidgetTester tester) async {
        setLogicalSize(tester, 500, 900);
        await tester.pumpWidget(
            createTestWidget(projectId: 'shopping-app'));
        await tester.pumpAndSettle();

        expect(find.text('Shopping App'), findsNWidgets(2));
      });

      testWidgets('Displays correct tech stack',
          (WidgetTester tester) async {
        setLogicalSize(tester, 500, 900);
        final project = projectsData[1];

        await tester.pumpWidget(
            createTestWidget(projectId: 'shopping-app'));
        await tester.pumpAndSettle();

        for (final tech in project.techStack) {
          expect(find.text(tech), findsOneWidget);
        }
      });
    });

    group('Invalid Project ID', () {
      testWidgets('Shows "Project not found" for invalid ID',
          (WidgetTester tester) async {
        setLogicalSize(tester, 500, 900);
        await tester.pumpWidget(
            createTestWidget(projectId: 'nonexistent-project'));
        await tester.pumpAndSettle();

        expect(find.text('Project not found'), findsOneWidget);
      });

      testWidgets('Shows AppBar with back button for invalid project',
          (WidgetTester tester) async {
        setLogicalSize(tester, 500, 900);
        await tester.pumpWidget(
            createTestWidget(projectId: 'nonexistent-project'));
        await tester.pumpAndSettle();

        expect(find.byType(AppBar), findsOneWidget);
      });
    });

    group('All Projects Render Correctly', () {
      for (final project in projectsData) {
        testWidgets('Project "${project.title}" renders without error',
            (WidgetTester tester) async {
          setLogicalSize(tester, 500, 900);
          await tester.pumpWidget(createTestWidget(projectId: project.id));
          await tester.pumpAndSettle();

          expect(find.text(project.title), findsNWidgets(2));
          expect(find.text(project.description), findsOneWidget);
          expect(find.text(AppStrings.techStack), findsOneWidget);
        });
      }
    });

    group('Dark Mode', () {
      testWidgets('Project detail renders in dark mode',
          (WidgetTester tester) async {
        setLogicalSize(tester, 500, 900);
        await tester.pumpWidget(createTestWidget(
          projectId: 'flutter-portfolio',
          theme: AppTheme.dark,
        ));
        await tester.pumpAndSettle();

        expect(find.text('Flutter Portfolio'), findsNWidgets(2));
        expect(find.text(AppStrings.techStack), findsOneWidget);
      });
    });
  });
}
