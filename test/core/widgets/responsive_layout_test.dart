import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_portfolio/core/widgets/responsive_layout.dart';

void main() {
  group('ResponsiveLayout Widget Tests', () {
    void setLogicalSize(WidgetTester tester, double width, double height) {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = Size(width, height);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
    }

    Widget createTestWidget({Widget? tablet}) {
      return MaterialApp(
        home: ResponsiveLayout(
          mobile: const Text('Mobile'),
          tablet: tablet,
          desktop: const Text('Desktop'),
        ),
      );
    }

    group('Breakpoint Behavior', () {
      testWidgets('Shows mobile widget when width < 600',
          (WidgetTester tester) async {
        setLogicalSize(tester, 500, 900);
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Mobile'), findsOneWidget);
        expect(find.text('Desktop'), findsNothing);
      });

      testWidgets('Shows desktop widget when width >= 1024',
          (WidgetTester tester) async {
        setLogicalSize(tester, 1440, 900);
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Desktop'), findsOneWidget);
        expect(find.text('Mobile'), findsNothing);
      });

      testWidgets('Shows mobile fallback when width is tablet and no tablet widget',
          (WidgetTester tester) async {
        setLogicalSize(tester, 800, 900);
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Tablet range (600-1023) without tablet widget falls back to mobile
        expect(find.text('Mobile'), findsOneWidget);
        expect(find.text('Desktop'), findsNothing);
      });

      testWidgets('Shows tablet widget when width is tablet and tablet provided',
          (WidgetTester tester) async {
        setLogicalSize(tester, 800, 900);
        await tester.pumpWidget(
          createTestWidget(tablet: const Text('Tablet')),
        );
        await tester.pumpAndSettle();

        expect(find.text('Tablet'), findsOneWidget);
        expect(find.text('Mobile'), findsNothing);
        expect(find.text('Desktop'), findsNothing);
      });
    });

    group('Boundary Values', () {
      testWidgets('Width 599 shows mobile', (WidgetTester tester) async {
        setLogicalSize(tester, 599, 900);
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Mobile'), findsOneWidget);
      });

      testWidgets('Width 600 shows tablet/mobile fallback',
          (WidgetTester tester) async {
        setLogicalSize(tester, 600, 900);
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // 600 is tablet range, no tablet widget → falls back to mobile
        expect(find.text('Mobile'), findsOneWidget);
      });

      testWidgets('Width 1023 shows tablet/mobile fallback',
          (WidgetTester tester) async {
        setLogicalSize(tester, 1023, 900);
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Mobile'), findsOneWidget);
      });

      testWidgets('Width 1024 shows desktop', (WidgetTester tester) async {
        setLogicalSize(tester, 1024, 900);
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Desktop'), findsOneWidget);
      });
    });

    group('ScreenSize Enum', () {
      test('Breakpoints constants are correct', () {
        expect(Breakpoints.mobile, equals(600));
        expect(Breakpoints.tablet, equals(1024));
      });

      test('ScreenSize enum has 3 values', () {
        expect(ScreenSize.values.length, equals(3));
        expect(ScreenSize.values, contains(ScreenSize.mobile));
        expect(ScreenSize.values, contains(ScreenSize.tablet));
        expect(ScreenSize.values, contains(ScreenSize.desktop));
      });
    });
  });
}
