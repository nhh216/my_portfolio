import '../../../core/models/project.dart';

const List<Project> projectsData = [
  Project(
    id: 'flutter-portfolio',
    title: 'Flutter Portfolio',
    description:
        'A responsive personal portfolio built with Flutter, showcasing '
        'projects and skills across web, iOS, and Android from a single '
        'codebase. Features adaptive navigation, go_router-based routing, '
        'and a Material 3 dark theme.',
    techStack: ['Flutter', 'Dart', 'go_router', 'Material 3'],
  ),
  Project(
    id: 'shopping-app',
    title: 'Shopping App',
    description:
        'A cross-platform e-commerce app featuring product browsing, a '
        'persistent cart, Stripe checkout, and order history. Built with '
        'Riverpod for state management and a Node.js REST backend.',
    techStack: ['Flutter', 'Riverpod', 'Node.js', 'Stripe', 'REST API'],
  ),
  Project(
    id: 'chat-app',
    title: 'Real-Time Chat App',
    description:
        'A real-time messaging app with Firebase Authentication, Firestore '
        'live queries, and push notifications via FCM. Supports one-on-one '
        'and group chats with image sharing and read receipts.',
    techStack: ['Flutter', 'Firebase', 'Firestore', 'FCM', 'BLoC'],
  ),
  Project(
    id: 'expense-tracker',
    title: 'Expense Tracker',
    description:
        'A personal finance tracker with local SQLite persistence, category '
        'budgets, and monthly chart summaries. Supports CSV export and '
        'offline-first operation with a clean Material 3 UI.',
    techStack: ['Flutter', 'Drift (SQLite)', 'fl_chart', 'Material 3'],
  ),
];
