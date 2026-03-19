import '../../../core/models/skill.dart';

abstract final class SkillsData {
  static const List<Skill> all = [
    // Languages
    Skill(name: 'Dart', level: SkillLevel.expert, category: 'Languages'),
    Skill(name: 'Kotlin', level: SkillLevel.advanced, category: 'Languages'),
    Skill(name: 'Swift', level: SkillLevel.intermediate, category: 'Languages'),
    Skill(name: 'JavaScript', level: SkillLevel.intermediate, category: 'Languages'),
    Skill(name: 'TypeScript', level: SkillLevel.intermediate, category: 'Languages'),

    // Frameworks & SDKs
    Skill(name: 'Flutter', level: SkillLevel.expert, category: 'Frameworks'),
    Skill(name: 'Riverpod', level: SkillLevel.expert, category: 'Frameworks'),
    Skill(name: 'BLoC', level: SkillLevel.advanced, category: 'Frameworks'),
    Skill(name: 'go_router', level: SkillLevel.advanced, category: 'Frameworks'),
    Skill(name: 'Jetpack Compose', level: SkillLevel.intermediate, category: 'Frameworks'),

    // Backend & Cloud
    Skill(name: 'Firebase', level: SkillLevel.advanced, category: 'Backend & Cloud'),
    Skill(name: 'Firestore', level: SkillLevel.advanced, category: 'Backend & Cloud'),
    Skill(name: 'Node.js', level: SkillLevel.intermediate, category: 'Backend & Cloud'),
    Skill(name: 'REST APIs', level: SkillLevel.advanced, category: 'Backend & Cloud'),

    // Tools & Workflow
    Skill(name: 'Git & GitHub', level: SkillLevel.advanced, category: 'Tools'),
    Skill(name: 'Figma', level: SkillLevel.intermediate, category: 'Tools'),
    Skill(name: 'CI/CD (GitHub Actions)', level: SkillLevel.intermediate, category: 'Tools'),
    Skill(name: 'Fastlane', level: SkillLevel.intermediate, category: 'Tools'),
  ];

  static List<String> get categories =>
      all.map((s) => s.category).toSet().toList();

  static List<Skill> byCategory(String category) =>
      all.where((s) => s.category == category).toList();
}
