import 'package:flutter/material.dart';
import '../../../../core/models/skill.dart';

class SkillChip extends StatelessWidget {
  const SkillChip({super.key, required this.skill});

  final Skill skill;

  Color _backgroundColor(ColorScheme colors) {
    return switch (skill.level) {
      SkillLevel.expert => colors.primary,
      SkillLevel.advanced => colors.secondary,
      SkillLevel.intermediate => colors.surface,
      SkillLevel.beginner => colors.outline,
    };
  }

  Color _labelColor(ColorScheme colors) {
    return switch (skill.level) {
      SkillLevel.expert => colors.onPrimary,
      SkillLevel.advanced => colors.onSecondary,
      SkillLevel.intermediate => colors.onSurface,
      SkillLevel.beginner => colors.onSurface,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Chip(
      label: Text(
        skill.name,
        style: TextStyle(color: _labelColor(colors)),
      ),
      backgroundColor: _backgroundColor(colors),
    );
  }
}
