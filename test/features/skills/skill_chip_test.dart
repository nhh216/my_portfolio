import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_portfolio/core/models/skill.dart';
import 'package:my_portfolio/core/theme/app_theme.dart';
import 'package:my_portfolio/features/skills/presentation/widgets/skill_chip.dart';

void main() {
  group('SkillChip Widget Tests', () {
    Widget createTestWidget(Skill skill, {ThemeData? theme}) {
      return MaterialApp(
        theme: theme ?? AppTheme.light,
        home: Scaffold(
          body: SkillChip(skill: skill),
        ),
      );
    }

    group('Rendering', () {
      testWidgets('Renders skill name as label', (WidgetTester tester) async {
        const skill = Skill(name: 'Dart', level: SkillLevel.expert, category: 'Languages');
        await tester.pumpWidget(createTestWidget(skill));
        await tester.pumpAndSettle();

        expect(find.text('Dart'), findsOneWidget);
      });

      testWidgets('Renders as a Chip widget', (WidgetTester tester) async {
        const skill = Skill(name: 'Flutter', level: SkillLevel.expert, category: 'Frameworks');
        await tester.pumpWidget(createTestWidget(skill));
        await tester.pumpAndSettle();

        expect(find.byType(Chip), findsOneWidget);
      });
    });

    group('Level-based Background Colors', () {
      testWidgets('Expert level uses primary background color',
          (WidgetTester tester) async {
        const skill = Skill(name: 'Dart', level: SkillLevel.expert, category: 'Languages');
        await tester.pumpWidget(createTestWidget(skill));
        await tester.pumpAndSettle();

        final chip = tester.widget<Chip>(find.byType(Chip));
        final colorScheme = AppTheme.light.colorScheme;
        expect(chip.backgroundColor, equals(colorScheme.primary));
      });

      testWidgets('Advanced level uses secondary background color',
          (WidgetTester tester) async {
        const skill = Skill(name: 'Kotlin', level: SkillLevel.advanced, category: 'Languages');
        await tester.pumpWidget(createTestWidget(skill));
        await tester.pumpAndSettle();

        final chip = tester.widget<Chip>(find.byType(Chip));
        final colorScheme = AppTheme.light.colorScheme;
        expect(chip.backgroundColor, equals(colorScheme.secondary));
      });

      testWidgets('Intermediate level uses surface background color',
          (WidgetTester tester) async {
        const skill = Skill(name: 'Figma', level: SkillLevel.intermediate, category: 'Tools');
        await tester.pumpWidget(createTestWidget(skill));
        await tester.pumpAndSettle();

        final chip = tester.widget<Chip>(find.byType(Chip));
        final colorScheme = AppTheme.light.colorScheme;
        expect(chip.backgroundColor, equals(colorScheme.surface));
      });

      testWidgets('Beginner level uses outline background color',
          (WidgetTester tester) async {
        const skill = Skill(name: 'Rust', level: SkillLevel.beginner, category: 'Languages');
        await tester.pumpWidget(createTestWidget(skill));
        await tester.pumpAndSettle();

        final chip = tester.widget<Chip>(find.byType(Chip));
        final colorScheme = AppTheme.light.colorScheme;
        expect(chip.backgroundColor, equals(colorScheme.outline));
      });
    });

    group('Level-based Label Colors', () {
      testWidgets('Expert level label uses onPrimary color',
          (WidgetTester tester) async {
        const skill = Skill(name: 'Dart', level: SkillLevel.expert, category: 'Languages');
        await tester.pumpWidget(createTestWidget(skill));
        await tester.pumpAndSettle();

        final chip = tester.widget<Chip>(find.byType(Chip));
        final colorScheme = AppTheme.light.colorScheme;
        final labelText = chip.label as Text;
        expect(labelText.style?.color, equals(colorScheme.onPrimary));
      });

      testWidgets('Advanced level label uses onSecondary color',
          (WidgetTester tester) async {
        const skill = Skill(name: 'Kotlin', level: SkillLevel.advanced, category: 'Languages');
        await tester.pumpWidget(createTestWidget(skill));
        await tester.pumpAndSettle();

        final chip = tester.widget<Chip>(find.byType(Chip));
        final colorScheme = AppTheme.light.colorScheme;
        final labelText = chip.label as Text;
        expect(labelText.style?.color, equals(colorScheme.onSecondary));
      });

      testWidgets('Intermediate level label uses onSurface color',
          (WidgetTester tester) async {
        const skill = Skill(name: 'Figma', level: SkillLevel.intermediate, category: 'Tools');
        await tester.pumpWidget(createTestWidget(skill));
        await tester.pumpAndSettle();

        final chip = tester.widget<Chip>(find.byType(Chip));
        final colorScheme = AppTheme.light.colorScheme;
        final labelText = chip.label as Text;
        expect(labelText.style?.color, equals(colorScheme.onSurface));
      });

      testWidgets('Beginner level label uses onSurface color',
          (WidgetTester tester) async {
        const skill = Skill(name: 'Rust', level: SkillLevel.beginner, category: 'Languages');
        await tester.pumpWidget(createTestWidget(skill));
        await tester.pumpAndSettle();

        final chip = tester.widget<Chip>(find.byType(Chip));
        final colorScheme = AppTheme.light.colorScheme;
        final labelText = chip.label as Text;
        expect(labelText.style?.color, equals(colorScheme.onSurface));
      });
    });

    group('All 4 Levels Produce Distinct Background Colors', () {
      test('Expert, advanced, intermediate, beginner backgrounds are distinct',
          () {
        final colors = AppTheme.light.colorScheme;
        final expertBg = colors.primary;
        final advancedBg = colors.secondary;
        final intermediateBg = colors.surface;
        final beginnerBg = colors.outline;

        expect(expertBg, isNot(equals(advancedBg)));
        expect(expertBg, isNot(equals(intermediateBg)));
        expect(advancedBg, isNot(equals(intermediateBg)));
        expect(beginnerBg, isNot(equals(expertBg)));
      });
    });
  });
}
