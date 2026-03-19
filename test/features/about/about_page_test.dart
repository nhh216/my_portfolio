import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_portfolio/core/constants/app_strings.dart';
import 'package:my_portfolio/core/theme/app_theme.dart';
import 'package:my_portfolio/core/widgets/section_title.dart';
import 'package:my_portfolio/features/about/presentation/pages/about_page.dart';

void main() {
  group('AboutPage Widget Tests', () {
    Widget createTestWidget({ThemeData? theme}) {
      return MaterialApp(
        theme: theme ?? AppTheme.light,
        home: const AboutPage(),
      );
    }

    void setLogicalSize(WidgetTester tester, double width, double height) {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = Size(width, height);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
    }

    group('Page Rendering', () {
      testWidgets('About page renders without error',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(AboutPage), findsOneWidget);
        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('Page has SafeArea on mobile', (WidgetTester tester) async {
        setLogicalSize(tester, 500, 900);
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(SafeArea), findsOneWidget);
      });

      testWidgets('Page has SafeArea on desktop', (WidgetTester tester) async {
        setLogicalSize(tester, 1440, 900);
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

    group('Content Rendering', () {
      testWidgets('Displays "About Me" heading', (WidgetTester tester) async {
        setLogicalSize(tester, 500, 900);
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text(AppStrings.aboutHeading), findsOneWidget);
      });

      testWidgets('Displays SectionTitle widget', (WidgetTester tester) async {
        setLogicalSize(tester, 500, 900);
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(SectionTitle), findsOneWidget);
      });

      testWidgets('Displays bio text', (WidgetTester tester) async {
        setLogicalSize(tester, 500, 900);
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text(AppStrings.aboutBio), findsOneWidget);
      });

      testWidgets('Displays "What I value:" heading',
          (WidgetTester tester) async {
        setLogicalSize(tester, 500, 900);
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text(AppStrings.whatIValue), findsOneWidget);
      });

      testWidgets('Displays all 5 core values', (WidgetTester tester) async {
        setLogicalSize(tester, 500, 900);
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        for (final value in AppStrings.aboutValues) {
          expect(find.text(value), findsOneWidget);
        }
      });

      testWidgets('Each value has a check_circle_outline icon',
          (WidgetTester tester) async {
        setLogicalSize(tester, 500, 900);
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(
          find.byIcon(Icons.check_circle_outline),
          findsNWidgets(AppStrings.aboutValues.length),
        );
      });
    });

    group('Responsive Layout', () {
      testWidgets('Mobile layout renders single column',
          (WidgetTester tester) async {
        setLogicalSize(tester, 500, 900);
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Mobile layout uses Column, not Row for bio + values
        expect(find.byType(Column), findsWidgets);
        // No Row with two Expanded children in mobile
        final rows = tester.widgetList<Row>(find.byType(Row));
        final expandedRows = rows.where((row) {
          final expandedCount =
              row.children.whereType<Expanded>().length;
          return expandedCount == 2;
        });
        expect(expandedRows.isEmpty, isTrue);
      });

      testWidgets('Desktop layout renders two-column Row',
          (WidgetTester tester) async {
        setLogicalSize(tester, 1440, 900);
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Desktop layout should have a Row with 2 Expanded children
        final rows = tester.widgetList<Row>(find.byType(Row));
        final twoColumnRow = rows.where((row) {
          final expandedCount =
              row.children.whereType<Expanded>().length;
          return expandedCount == 2;
        });
        expect(twoColumnRow.isNotEmpty, isTrue);
      });
    });

    group('Animation', () {
      testWidgets('Page uses AnimatedOpacity for fade-in',
          (WidgetTester tester) async {
        setLogicalSize(tester, 500, 900);
        await tester.pumpWidget(createTestWidget());

        // Before pumpAndSettle, opacity should be animating
        expect(find.byType(AnimatedOpacity), findsOneWidget);

        await tester.pumpAndSettle();

        // After animation completes, widget should still be present
        final animatedOpacity = tester.widget<AnimatedOpacity>(
          find.byType(AnimatedOpacity),
        );
        expect(animatedOpacity.opacity, equals(1.0));
      });

      testWidgets('Animation duration is 600ms', (WidgetTester tester) async {
        setLogicalSize(tester, 500, 900);
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        final animatedOpacity = tester.widget<AnimatedOpacity>(
          find.byType(AnimatedOpacity),
        );
        expect(
          animatedOpacity.duration,
          equals(const Duration(milliseconds: 600)),
        );
      });
    });

    group('Dark Mode', () {
      testWidgets('About page renders correctly in dark mode',
          (WidgetTester tester) async {
        setLogicalSize(tester, 500, 900);
        await tester.pumpWidget(createTestWidget(theme: AppTheme.dark));
        await tester.pumpAndSettle();

        // All content should still be visible
        expect(find.text(AppStrings.aboutHeading), findsOneWidget);
        expect(find.text(AppStrings.aboutBio), findsOneWidget);
        expect(find.text(AppStrings.whatIValue), findsOneWidget);
      });
    });
  });
}
