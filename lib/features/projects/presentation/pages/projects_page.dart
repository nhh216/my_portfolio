import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/section_title.dart';
import '../../data/projects_data.dart';
import '../widgets/project_card.dart';

class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(title: AppStrings.projectsHeading),
              const SizedBox(height: 24),
              Expanded(
                child: ResponsiveLayout(
                  mobile: _ProjectsGrid(crossAxisCount: 1),
                  desktop: _ProjectsGrid(crossAxisCount: 3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProjectsGrid extends StatelessWidget {
  const _ProjectsGrid({required this.crossAxisCount});

  final int crossAxisCount;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: crossAxisCount == 1 ? 2.5 : 1.4,
      ),
      itemCount: projectsData.length,
      itemBuilder: (context, index) {
        final project = projectsData[index];
        return ProjectCard(
          project: project,
          onTap: () => context.go('/projects/${project.id}'),
        );
      },
    );
  }
}
