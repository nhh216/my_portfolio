import 'package:go_router/go_router.dart';
import '../core/widgets/app_shell.dart';
import '../features/about/presentation/pages/about_page.dart';
import '../features/contact/presentation/pages/contact_page.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/projects/presentation/pages/project_detail_page.dart';
import '../features/projects/presentation/pages/projects_page.dart';
import '../features/skills/presentation/pages/skills_page.dart';

abstract final class AppRoutes {
  static const String home = '/';
  static const String about = '/about';
  static const String projects = '/projects';
  static const String skills = '/skills';
  static const String contact = '/contact';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const HomePage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.about,
              builder: (context, state) => const AboutPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.projects,
              builder: (context, state) => const ProjectsPage(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) => ProjectDetailPage(
                    projectId: state.pathParameters['id'] ?? '',
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.skills,
              builder: (context, state) => const SkillsPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.contact,
              builder: (context, state) => const ContactPage(),
            ),
          ],
        ),
      ],
    ),
  ],
);
