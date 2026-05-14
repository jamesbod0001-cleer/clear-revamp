import 'dart:ui';

import 'package:cleer_ui/themes/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppNavigationShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final List<NavigationDestination> destinations;

  const AppNavigationShell({
    required this.navigationShell,
    required this.destinations,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
          child: NavigationBar(
            backgroundColor: context.color.navbarBg.withValues(alpha: 0.92),
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (int index) {
              navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              );
            },
            destinations: destinations,
          ),
        ),
      ),
    );
  }
}
