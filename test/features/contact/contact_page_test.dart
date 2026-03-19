import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_portfolio/core/constants/app_strings.dart';
import 'package:my_portfolio/core/theme/app_theme.dart';
import 'package:my_portfolio/core/widgets/section_title.dart';
import 'package:my_portfolio/features/contact/presentation/pages/contact_page.dart';
import 'package:my_portfolio/features/contact/presentation/widgets/contact_link_tile.dart';

void main() {
  group('ContactPage Widget Tests', () {
    Widget createTestWidget({ThemeData? theme}) {
      return MaterialApp(
        theme: theme ?? AppTheme.light,
        home: const ContactPage(),
      );
    }

    void setLogicalSize(WidgetTester tester, double width, double height) {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = Size(width, height);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
    }

    group('Page Rendering', () {
      testWidgets('Contact page renders without error',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(ContactPage), findsOneWidget);
        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('Page has SafeArea', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(SafeArea), findsWidgets);
      });

      testWidgets('Page is scrollable', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(SingleChildScrollView), findsOneWidget);
      });

      testWidgets('Content is constrained to max width 480',
          (WidgetTester tester) async {
        setLogicalSize(tester, 1440, 900);
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Find the ConstrainedBox with maxWidth 480
        final constrainedBoxes = tester.widgetList<ConstrainedBox>(
          find.byType(ConstrainedBox),
        );
        final has480Constraint = constrainedBoxes.any(
          (box) => box.constraints.maxWidth == 480,
        );
        expect(has480Constraint, isTrue);
      });
    });

    group('Content Rendering', () {
      testWidgets('Displays "Contact" section title',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text(AppStrings.sectionContact), findsOneWidget);
        expect(find.byType(SectionTitle), findsOneWidget);
      });

      testWidgets('Displays 3 ContactLinkTile widgets',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(ContactLinkTile), findsNWidgets(3));
      });

      testWidgets('Displays email contact', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text(AppStrings.contactEmail), findsOneWidget);
        expect(find.byIcon(Icons.email), findsOneWidget);
      });

      testWidgets('Displays GitHub contact', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text(AppStrings.contactGitHub), findsOneWidget);
        expect(find.byIcon(Icons.code), findsOneWidget);
      });

      testWidgets('Displays LinkedIn contact', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text(AppStrings.contactLinkedIn), findsOneWidget);
        expect(find.byIcon(Icons.link), findsOneWidget);
      });

      testWidgets('Each tile has a forward arrow trailing icon',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.arrow_forward_ios), findsNWidgets(3));
      });
    });

    group('Contact Link Interaction', () {
      testWidgets('Email tile is tappable', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Tap the email ListTile — should not throw
        await tester.tap(find.text(AppStrings.contactEmail));
        await tester.pumpAndSettle();

        // No crash means the tap handler is wired correctly
        expect(find.byType(ContactPage), findsOneWidget);
      });

      testWidgets('GitHub tile is tappable', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.text(AppStrings.contactGitHub));
        await tester.pumpAndSettle();

        expect(find.byType(ContactPage), findsOneWidget);
      });

      testWidgets('LinkedIn tile is tappable', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.text(AppStrings.contactLinkedIn));
        await tester.pumpAndSettle();

        expect(find.byType(ContactPage), findsOneWidget);
      });
    });

    group('Dark Mode', () {
      testWidgets('Contact page renders correctly in dark mode',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(theme: AppTheme.dark));
        await tester.pumpAndSettle();

        expect(find.text(AppStrings.sectionContact), findsOneWidget);
        expect(find.text(AppStrings.contactEmail), findsOneWidget);
        expect(find.text(AppStrings.contactGitHub), findsOneWidget);
        expect(find.text(AppStrings.contactLinkedIn), findsOneWidget);
      });
    });
  });

  group('ContactLinkTile Widget Tests (Isolated)', () {
    testWidgets('Renders icon, title, and trailing arrow',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContactLinkTile(
              icon: Icons.star,
              title: 'Test Link',
              onTap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.text('Test Link'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_ios), findsOneWidget);
    });

    testWidgets('onTap callback fires when tapped',
        (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContactLinkTile(
              icon: Icons.star,
              title: 'Tap Me',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tap Me'));
      expect(tapped, isTrue);
    });

    testWidgets('Uses ListTile as base widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContactLinkTile(
              icon: Icons.star,
              title: 'Test',
              onTap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ListTile), findsOneWidget);
    });
  });
}
