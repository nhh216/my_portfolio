import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:my_portfolio/core/theme/app_theme.dart';
import 'package:my_portfolio/features/projects/data/projects_data.dart';
import 'package:my_portfolio/features/projects/presentation/pages/projects_page.dart';
import 'package:my_portfolio/features/projects/presentation/widgets/project_card.dart';

void main() {
  group('ProjectsPage Widget Tests', () {
    late GoRouter router;

    setUp(() {
      router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const ProjectsPage(),
          ),
          GoRoute(
            path: '/projects/:id',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Project Detail Page')),
            ),
          ),
        ],
      );
    });

    Widget createTestWidget() {
      return MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: router,
      );
    }

    /// Sets logical viewport size (devicePixelRatio = 1 so physical == logical).
    void setLogicalSize(WidgetTester tester, double width, double height) {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = Size(width, height);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
    }

    group('ProjectCard Widget (Isolated)', () {
      testWidgets('Project card renders with title',
          (WidgetTester tester) async {
        setLogicalSize(tester, 400, 300);

        final testProject = projectsData[0];

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: SingleChildScrollView(
                child: SizedBox(
                  width: 380,
                  height: 280,
                  child: ProjectCard(
                    project: testProject,
                    onTap: () {},
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify project title renders
        expect(find.text(testProject.title), findsOneWidget);
      });

      testWidgets('Project card shows tech stack chips',
          (WidgetTester tester) async {
        setLogicalSize(tester, 400, 300);

        final testProject = projectsData[0]; // Flutter Portfolio

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: SingleChildScrollView(
                child: SizedBox(
                  width: 380,
                  height: 280,
                  child: ProjectCard(
                    project: testProject,
                    onTap: () {},
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify tech stack chips render
        for (final tech in testProject.techStack) {
          expect(find.text(tech), findsOneWidget);
        }

        // Verify Chip widgets are present
        expect(find.byType(Chip), findsWidgets);
      });

      testWidgets('All 4 projects have correct titles',
          (WidgetTester tester) async {
        setLogicalSize(tester, 400, 300);

        final expectedTitles = [
          'Flutter Portfolio',
          'Shopping App',
          'Real-Time Chat App',
          'Expense Tracker',
        ];

        for (int i = 0; i < projectsData.length; i++) {
          final project = projectsData[i];

          await tester.pumpWidget(
            MaterialApp(
              theme: AppTheme.light,
              home: Scaffold(
                body: SingleChildScrollView(
                  child: SizedBox(
                    width: 380,
                    height: 280,
                    child: ProjectCard(
                      project: project,
                      onTap: () {},
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          // Verify project title
          expect(find.text(expectedTitles[i]), findsOneWidget);
        }
      });
    });

    group('Project Card Interaction', () {
      testWidgets('Project card tap callback fires',
          (WidgetTester tester) async {
        setLogicalSize(tester, 400, 300);

        bool tapped = false;
        final testProject = projectsData[0];

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: SingleChildScrollView(
                child: SizedBox(
                  width: 380,
                  height: 280,
                  child: ProjectCard(
                    project: testProject,
                    onTap: () {
                      tapped = true;
                    },
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap the card using GestureDetector
        await tester.tap(find.byType(Card));
        await tester.pumpAndSettle();

        // Verify callback was triggered
        expect(tapped, isTrue);
      });

      testWidgets('Project card has interactive tap zone',
          (WidgetTester tester) async {
        setLogicalSize(tester, 400, 300);

        final testProject = projectsData[0];

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: SingleChildScrollView(
                child: SizedBox(
                  width: 380,
                  height: 280,
                  child: ProjectCard(
                    project: testProject,
                    onTap: () {},
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify Card and InkWell widgets are present for tap interaction
        expect(find.byType(Card), findsOneWidget);
        expect(find.byType(InkWell), findsWidgets);
      });

      testWidgets('Card widget wraps project content',
          (WidgetTester tester) async {
        setLogicalSize(tester, 400, 300);

        final testProject = projectsData[0];

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: SingleChildScrollView(
                child: SizedBox(
                  width: 380,
                  height: 280,
                  child: ProjectCard(
                    project: testProject,
                    onTap: () {},
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify Card widget is present
        expect(find.byType(Card), findsOneWidget);
      });
    });

    group('Projects Page Structure', () {
      testWidgets('Page renders without error',
          (WidgetTester tester) async {
        setLogicalSize(tester, 1440, 900);
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(ProjectsPage), findsOneWidget);
        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('Displays Projects heading',
          (WidgetTester tester) async {
        setLogicalSize(tester, 800, 600);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Projects'), findsOneWidget);
      });

      testWidgets('Contains GridView for responsive layout',
          (WidgetTester tester) async {
        setLogicalSize(tester, 800, 600);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(GridView), findsOneWidget);
      });

      testWidgets('Has SafeArea for padding',
          (WidgetTester tester) async {
        setLogicalSize(tester, 800, 600);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(SafeArea), findsOneWidget);
      });
    });

    group('Tech Stack Coverage', () {
      testWidgets('Flutter Portfolio has all expected tech stack',
          (WidgetTester tester) async {
        setLogicalSize(tester, 400, 300);

        final project = projectsData[0];

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: SingleChildScrollView(
                child: SizedBox(
                  width: 380,
                  height: 280,
                  child: ProjectCard(
                    project: project,
                    onTap: () {},
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Flutter'), findsOneWidget);
        expect(find.text('Dart'), findsOneWidget);
        expect(find.text('go_router'), findsOneWidget);
        expect(find.text('Material 3'), findsOneWidget);
      });

      testWidgets('Shopping App has all expected tech stack',
          (WidgetTester tester) async {
        setLogicalSize(tester, 400, 300);

        final project = projectsData[1];

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: SingleChildScrollView(
                child: SizedBox(
                  width: 380,
                  height: 280,
                  child: ProjectCard(
                    project: project,
                    onTap: () {},
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Flutter'), findsOneWidget);
        expect(find.text('Riverpod'), findsOneWidget);
        expect(find.text('Node.js'), findsOneWidget);
        expect(find.text('Stripe'), findsOneWidget);
        expect(find.text('REST API'), findsOneWidget);
      });

      testWidgets('Chat App has all expected tech stack',
          (WidgetTester tester) async {
        setLogicalSize(tester, 400, 300);

        final project = projectsData[2];

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: SingleChildScrollView(
                child: SizedBox(
                  width: 380,
                  height: 280,
                  child: ProjectCard(
                    project: project,
                    onTap: () {},
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Flutter'), findsOneWidget);
        expect(find.text('Firebase'), findsOneWidget);
        expect(find.text('Firestore'), findsOneWidget);
        expect(find.text('FCM'), findsOneWidget);
        expect(find.text('BLoC'), findsOneWidget);
      });
    });
  });
}
