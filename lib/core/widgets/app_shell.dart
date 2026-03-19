import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'responsive_layout.dart';

const _destinations = [
  (icon: Icons.home_outlined, selectedIcon: Icons.home, label: 'Home', path: '/'),
  (icon: Icons.person_outline, selectedIcon: Icons.person, label: 'About', path: '/about'),
  (icon: Icons.work_outline, selectedIcon: Icons.work, label: 'Projects', path: '/projects'),
  (icon: Icons.code, selectedIcon: Icons.code, label: 'Skills', path: '/skills'),
  (icon: Icons.mail_outline, selectedIcon: Icons.mail, label: 'Contact', path: '/contact'),
];

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= Breakpoints.tablet;

    if (isDesktop) {
      return _DesktopShell(
        currentIndex: navigationShell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
        body: navigationShell,
      );
    }

    return _MobileShell(
      currentIndex: navigationShell.currentIndex,
      onDestinationSelected: _onDestinationSelected,
      body: navigationShell,
    );
  }
}

class _DesktopShell extends StatelessWidget {
  const _DesktopShell({
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.body,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: currentIndex,
            onDestinationSelected: onDestinationSelected,
            labelType: NavigationRailLabelType.all,
            destinations: _destinations
                .map(
                  (d) => NavigationRailDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: Text(d.label),
                  ),
                )
                .toList(),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: body),
        ],
      ),
    );
  }
}

class _MobileShell extends StatelessWidget {
  const _MobileShell({
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.body,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: _destinations
            .map(
              (d) => NavigationDestination(
                icon: Icon(d.icon),
                selectedIcon: Icon(d.selectedIcon),
                label: d.label,
              ),
            )
            .toList(),
      ),
    );
  }
}
