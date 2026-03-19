import 'package:go_router/go_router.dart';
import '../features/portfolio/presentation/screens/home_screen.dart';
import '../features/portfolio/presentation/screens/asset_detail_screen.dart';

abstract final class TrackerRoutes {
  static const String home = '/';
  static const String assetDetail = '/asset/:id';
}

final trackerRouter = GoRouter(
  initialLocation: TrackerRoutes.home,
  routes: [
    GoRoute(
      path: TrackerRoutes.home,
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: 'asset/:id',
          builder: (context, state) => AssetDetailScreen(
            assetId: state.pathParameters['id'] ?? '',
          ),
        ),
      ],
    ),
  ],
);
