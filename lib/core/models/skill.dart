enum SkillLevel { beginner, intermediate, advanced, expert }

class Skill {
  final String name;
  final SkillLevel level;
  final String category;

  const Skill({
    required this.name,
    required this.level,
    required this.category,
  });
}
