import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_strings.dart';
import '../../data/projects_data.dart';

class ProjectDetailPage extends StatelessWidget {
  const ProjectDetailPage({super.key, required this.projectId});

  final String projectId;

  Future<void> _launch(BuildContext context, String uriString) async {
    try {
      await launchUrl(
        Uri.parse(uriString),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.contactErrorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final project = projectsData.where((p) => p.id == projectId).firstOrNull;

    if (project == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Project not found')),
      );
    }

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(project.title),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                project.title,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                project.description,
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.7),
              ),
              const SizedBox(height: 24),
              Text(
                AppStrings.techStack,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: project.techStack
                    .map((tech) => Chip(label: Text(tech)))
                    .toList(),
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  if (project.githubUrl != null)
                    FilledButton.icon(
                      onPressed: () => _launch(context, project.githubUrl!),
                      icon: const Icon(Icons.code),
                      label: const Text(AppStrings.viewOnGitHub),
                    ),
                  if (project.liveUrl != null)
                    OutlinedButton.icon(
                      onPressed: () => _launch(context, project.liveUrl!),
                      icon: const Icon(Icons.open_in_new),
                      label: const Text(AppStrings.liveDemo),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
