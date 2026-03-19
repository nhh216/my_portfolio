import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_portfolio/core/theme/app_theme.dart';
import 'package:my_portfolio/core/widgets/section_title.dart';

void main() {
  group('SectionTitle Widget Tests', () {
    Widget createTestWidget(String title, {ThemeData? theme}) {
      return MaterialApp(
        theme: theme ?? AppTheme.light,
        home: Scaffold(
          body: SectionTitle(title: title),
        ),
      );
    }

    group('Rendering', () {
      testWidgets('Renders provided title text', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget('My Section'));
        await tester.pumpAndSettle();

        expect(find.text('My Section'), findsOneWidget);
      });

      testWidgets('Renders a Divider below the title',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget('Test'));
        await tester.pumpAndSettle();

        expect(find.byType(Divider), findsOneWidget);
      });

      testWidgets('Uses headlineSmall text style for the title',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget('Styled Title'));
        await tester.pumpAndSettle();

        final textWidget = tester.widget<Text>(find.text('Styled Title'));
        expect(
          textWidget.style?.fontSize,
          isNotNull,
        );
      });

      testWidgets('Divider has thickness 2', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget('Check Divider'));
        await tester.pumpAndSettle();

        final divider = tester.widget<Divider>(find.byType(Divider));
        expect(divider.thickness, equals(2));
      });

      testWidgets('Widget uses Column as root layout',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget('Layout Test'));
        await tester.pumpAndSettle();

        expect(find.byType(Column), findsWidgets);
      });
    });

    group('Edge Cases', () {
      testWidgets('Handles empty string title without error',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(''));
        await tester.pumpAndSettle();

        expect(find.byType(SectionTitle), findsOneWidget);
      });

      testWidgets('Handles long title without overflow',
          (WidgetTester tester) async {
        const longTitle =
            'This is a very long section title that might cause overflow';
        await tester.pumpWidget(createTestWidget(longTitle));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });

      testWidgets('Renders correctly with different title strings',
          (WidgetTester tester) async {
        const titles = ['About Me', 'Projects', 'Skills', 'Contact'];

        for (final title in titles) {
          await tester.pumpWidget(createTestWidget(title));
          await tester.pumpAndSettle();

          expect(find.text(title), findsOneWidget);
          expect(find.byType(Divider), findsOneWidget);
        }
      });
    });

    group('Dark Mode', () {
      testWidgets('Renders title correctly in dark mode',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget('Dark Mode', theme: AppTheme.dark));
        await tester.pumpAndSettle();

        expect(find.text('Dark Mode'), findsOneWidget);
        expect(find.byType(Divider), findsOneWidget);
      });
    });
  });
}
