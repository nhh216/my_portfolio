import 'package:flutter_test/flutter_test.dart';
import 'package:my_portfolio/core/models/project.dart';
import 'package:my_portfolio/core/models/skill.dart';
import 'package:my_portfolio/features/projects/data/projects_data.dart';
import 'package:my_portfolio/features/skills/data/skills_data.dart';

void main() {
  group('Project Model Tests', () {
    test('Project constructor sets all required fields', () {
      const project = Project(
        id: 'test-id',
        title: 'Test Project',
        description: 'A test project',
        techStack: ['Dart', 'Flutter'],
      );

      expect(project.id, equals('test-id'));
      expect(project.title, equals('Test Project'));
      expect(project.description, equals('A test project'));
      expect(project.techStack, equals(['Dart', 'Flutter']));
      expect(project.imageAsset, isNull);
      expect(project.githubUrl, isNull);
      expect(project.liveUrl, isNull);
    });

    test('Project optional fields can be set', () {
      const project = Project(
        id: 'test-id',
        title: 'Test',
        description: 'Desc',
        techStack: ['Dart'],
        imageAsset: 'assets/test.png',
        githubUrl: 'https://github.com/test',
        liveUrl: 'https://test.com',
      );

      expect(project.imageAsset, equals('assets/test.png'));
      expect(project.githubUrl, equals('https://github.com/test'));
      expect(project.liveUrl, equals('https://test.com'));
    });

    test('Project techStack can be empty list', () {
      const project = Project(
        id: 'test',
        title: 'Test',
        description: 'Desc',
        techStack: [],
      );

      expect(project.techStack, isEmpty);
    });
  });

  group('Projects Data Tests', () {
    test('projectsData has exactly 4 projects', () {
      expect(projectsData.length, equals(4));
    });

    test('All projects have unique IDs', () {
      final ids = projectsData.map((p) => p.id).toSet();
      expect(ids.length, equals(projectsData.length));
    });

    test('All projects have non-empty titles', () {
      for (final project in projectsData) {
        expect(project.title.isNotEmpty, isTrue);
      }
    });

    test('All projects have non-empty descriptions', () {
      for (final project in projectsData) {
        expect(project.description.isNotEmpty, isTrue);
      }
    });

    test('All projects have at least one tech stack item', () {
      for (final project in projectsData) {
        expect(project.techStack.isNotEmpty, isTrue);
      }
    });

    test('No projects have a liveUrl in current data', () {
      for (final project in projectsData) {
        expect(project.liveUrl, isNull);
      }
    });

    test('No projects have a githubUrl in current data', () {
      for (final project in projectsData) {
        expect(project.githubUrl, isNull);
      }
    });

    test('Project IDs match expected values', () {
      final ids = projectsData.map((p) => p.id).toList();
      expect(ids, contains('flutter-portfolio'));
      expect(ids, contains('shopping-app'));
      expect(ids, contains('chat-app'));
      expect(ids, contains('expense-tracker'));
    });
  });

  group('Skill Model Tests', () {
    test('Skill constructor sets all fields', () {
      const skill = Skill(
        name: 'Dart',
        level: SkillLevel.expert,
        category: 'Languages',
      );

      expect(skill.name, equals('Dart'));
      expect(skill.level, equals(SkillLevel.expert));
      expect(skill.category, equals('Languages'));
    });

    test('SkillLevel enum has 4 values', () {
      expect(SkillLevel.values.length, equals(4));
      expect(SkillLevel.values, contains(SkillLevel.beginner));
      expect(SkillLevel.values, contains(SkillLevel.intermediate));
      expect(SkillLevel.values, contains(SkillLevel.advanced));
      expect(SkillLevel.values, contains(SkillLevel.expert));
    });
  });

  group('Skills Data Tests', () {
    test('SkillsData.all has exactly 18 skills', () {
      expect(SkillsData.all.length, equals(18));
    });

    test('All skills have non-empty names', () {
      for (final skill in SkillsData.all) {
        expect(skill.name.isNotEmpty, isTrue);
      }
    });

    test('All skills have non-empty categories', () {
      for (final skill in SkillsData.all) {
        expect(skill.category.isNotEmpty, isTrue);
      }
    });

    test('There are exactly 4 categories', () {
      expect(SkillsData.categories.length, equals(4));
    });

    test('Categories include Languages, Frameworks, Backend & Cloud, Tools',
        () {
      final categories = SkillsData.categories;
      expect(categories, contains('Languages'));
      expect(categories, contains('Frameworks'));
      expect(categories, contains('Backend & Cloud'));
      expect(categories, contains('Tools'));
    });

    test('byCategory returns correct count for Languages', () {
      expect(SkillsData.byCategory('Languages').length, equals(5));
    });

    test('byCategory returns correct count for Frameworks', () {
      expect(SkillsData.byCategory('Frameworks').length, equals(5));
    });

    test('byCategory returns correct count for Backend & Cloud', () {
      expect(SkillsData.byCategory('Backend & Cloud').length, equals(4));
    });

    test('byCategory returns correct count for Tools', () {
      expect(SkillsData.byCategory('Tools').length, equals(4));
    });

    test('byCategory returns empty for unknown category', () {
      expect(SkillsData.byCategory('Unknown').length, equals(0));
    });

    test('Dart skill is expert level', () {
      final dart = SkillsData.all.firstWhere((s) => s.name == 'Dart');
      expect(dart.level, equals(SkillLevel.expert));
    });

    test('Flutter skill is expert level', () {
      final flutter = SkillsData.all.firstWhere((s) => s.name == 'Flutter');
      expect(flutter.level, equals(SkillLevel.expert));
    });

    test('Riverpod skill is expert level', () {
      final riverpod =
          SkillsData.all.firstWhere((s) => s.name == 'Riverpod');
      expect(riverpod.level, equals(SkillLevel.expert));
    });

    test('Kotlin skill is advanced level', () {
      final kotlin = SkillsData.all.firstWhere((s) => s.name == 'Kotlin');
      expect(kotlin.level, equals(SkillLevel.advanced));
    });

    test('Git & GitHub skill is advanced level', () {
      final git =
          SkillsData.all.firstWhere((s) => s.name == 'Git & GitHub');
      expect(git.level, equals(SkillLevel.advanced));
    });
  });
}
