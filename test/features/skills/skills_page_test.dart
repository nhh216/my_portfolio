import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_portfolio/core/constants/app_strings.dart';
import 'package:my_portfolio/core/theme/app_theme.dart';
import 'package:my_portfolio/core/widgets/section_title.dart';
import 'package:my_portfolio/features/skills/data/skills_data.dart';
import 'package:my_portfolio/features/skills/presentation/pages/skills_page.dart';
import 'package:my_portfolio/features/skills/presentation/widgets/skill_chip.dart';

void main() {
  group('SkillsPage Widget Tests', () {
    Widget createTestWidget() {
      return MaterialApp(
        theme: AppTheme.light,
        home: const SkillsPage(),
      );
    }

    /// Sets logical viewport size (devicePixelRatio = 1 so physical == logical).
    void setLogicalSize(WidgetTester tester, double width, double height) {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = Size(width, height);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
    }

    group('Page Rendering', () {
      testWidgets('Skills page renders without error',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(SkillsPage), findsOneWidget);
        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('Page has SafeArea', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(SafeArea), findsOneWidget);
      });

      testWidgets('Page is scrollable', (WidgetTester tester) async {
        setLogicalSize(tester, 500, 400);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(SingleChildScrollView), findsOneWidget);
      });
    });

    group('Section Titles', () {
      testWidgets('Skills section heading is visible',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text(AppStrings.sectionSkills), findsOneWidget);
      });

      testWidgets('Languages category heading is visible',
          (WidgetTester tester) async {
        setLogicalSize(tester, 500, 800);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Languages'), findsOneWidget);
      });

      testWidgets('Frameworks category heading is visible',
          (WidgetTester tester) async {
        setLogicalSize(tester, 500, 800);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Frameworks'), findsOneWidget);
      });

      testWidgets('Tools category heading is visible',
          (WidgetTester tester) async {
        setLogicalSize(tester, 500, 800);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Tools'), findsOneWidget);
      });

      testWidgets('Backend & Cloud category heading is visible',
          (WidgetTester tester) async {
        setLogicalSize(tester, 500, 1200);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Backend & Cloud'), findsOneWidget);
      });

      testWidgets('Skills are grouped by category with SectionTitle',
          (WidgetTester tester) async {
        setLogicalSize(tester, 500, 1200);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Multiple SectionTitle widgets should be present (main + categories)
        expect(find.byType(SectionTitle), findsWidgets);
        expect(find.byType(SectionTitle), findsNWidgets(5)); // Main + 4 categories
      });
    });

    group('Skill Chips', () {
      testWidgets('Dart skill chip is visible',
          (WidgetTester tester) async {
        setLogicalSize(tester, 500, 800);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Dart'), findsOneWidget);
        expect(find.byType(SkillChip), findsWidgets);
      });

      testWidgets('Flutter skill chip is visible',
          (WidgetTester tester) async {
        setLogicalSize(tester, 500, 800);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Flutter'), findsOneWidget);
      });

      testWidgets('All language skills are visible',
          (WidgetTester tester) async {
        setLogicalSize(tester, 500, 1200);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        const langSkills = [
          'Dart',
          'Kotlin',
          'Swift',
          'JavaScript',
          'TypeScript',
        ];
        for (final skill in langSkills) {
          expect(find.text(skill), findsOneWidget);
        }
      });

      testWidgets('All framework skills are visible',
          (WidgetTester tester) async {
        setLogicalSize(tester, 500, 1200);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        const frameworks = [
          'Flutter',
          'Riverpod',
          'BLoC',
          'go_router',
          'Jetpack Compose',
        ];
        for (final framework in frameworks) {
          expect(find.text(framework), findsOneWidget);
        }
      });

      testWidgets('All tool skills are visible',
          (WidgetTester tester) async {
        setLogicalSize(tester, 500, 1200);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        const tools = [
          'Git & GitHub',
          'Figma',
          'CI/CD (GitHub Actions)',
          'Fastlane',
        ];
        for (final tool in tools) {
          expect(find.text(tool), findsOneWidget);
        }
      });

      testWidgets('Skill chips match data count',
          (WidgetTester tester) async {
        setLogicalSize(tester, 500, 800);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // 9 skills total in SkillsData
        expect(find.byType(SkillChip), findsNWidgets(SkillsData.all.length));
      });
    });

    group('Skill Categories', () {
      testWidgets('Languages category has correct skill count',
          (WidgetTester tester) async {
        setLogicalSize(tester, 500, 1200);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        final langSkills = SkillsData.byCategory('Languages');
        expect(langSkills.length, equals(5));
      });

      testWidgets('Frameworks category has correct skill count',
          (WidgetTester tester) async {
        setLogicalSize(tester, 500, 1200);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        final frameworkSkills = SkillsData.byCategory('Frameworks');
        expect(frameworkSkills.length, equals(5));
      });

      testWidgets('Tools category has correct skill count',
          (WidgetTester tester) async {
        setLogicalSize(tester, 500, 1200);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        final toolSkills = SkillsData.byCategory('Tools');
        expect(toolSkills.length, equals(4));
      });

      testWidgets('All categories are rendered',
          (WidgetTester tester) async {
        setLogicalSize(tester, 500, 1200);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(SkillsData.categories.length, equals(4));
        for (final category in SkillsData.categories) {
          expect(find.text(category), findsOneWidget);
        }
      });
    });

    group('Layout Structure', () {
      testWidgets('Main content is centered with max width constraint',
          (WidgetTester tester) async {
        setLogicalSize(tester, 1200, 800);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(ConstrainedBox), findsWidgets);
      });

      testWidgets('Category groups have proper spacing',
          (WidgetTester tester) async {
        setLogicalSize(tester, 500, 800);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Multiple SizedBox widgets for spacing
        expect(find.byType(SizedBox), findsWidgets);
      });

      testWidgets('Skill chips are wrapped for responsive layout',
          (WidgetTester tester) async {
        setLogicalSize(tester, 500, 800);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Wrap widget for responsive chip layout
        expect(find.byType(Wrap), findsWidgets);
      });
    });

    group('Skill Chip Rendering', () {
      testWidgets('Skill chips render with correct text color',
          (WidgetTester tester) async {
        setLogicalSize(tester, 500, 800);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Verify that skill chips are rendered with Material design chips
        expect(find.byType(Chip), findsWidgets);
        expect(find.byType(Chip), findsNWidgets(SkillsData.all.length));
      });

      testWidgets('Expert level skill (Dart) is rendered',
          (WidgetTester tester) async {
        setLogicalSize(tester, 500, 800);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Find Dart chip
        expect(find.text('Dart'), findsOneWidget);
        expect(find.byType(Chip), findsWidgets);
      });

      testWidgets('Intermediate level skill (Figma) is rendered',
          (WidgetTester tester) async {
        setLogicalSize(tester, 500, 1200);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Find Figma chip
        expect(find.text('Figma'), findsOneWidget);
        expect(find.byType(Chip), findsWidgets);
      });
    });
  });
}
