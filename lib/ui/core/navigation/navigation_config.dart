import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class NavigationConfig {
  static final List<NavigationDestination> hostDestinations = [
    NavigationDestination(
      icon: PhosphorIcon(PhosphorIcons.house()),
      selectedIcon: PhosphorIcon(PhosphorIcons.house(PhosphorIconsStyle.fill)),
      label: 'Home',
    ),
    NavigationDestination(
      icon: PhosphorIcon(PhosphorIcons.arrowsLeftRight()),
      selectedIcon: PhosphorIcon(
        PhosphorIcons.arrowsLeftRight(PhosphorIconsStyle.fill),
      ),
      label: 'Agreements',
    ),
    NavigationDestination(
      icon: PhosphorIcon(PhosphorIcons.userCircle()),
      selectedIcon: PhosphorIcon(
        PhosphorIcons.userCircle(PhosphorIconsStyle.fill),
      ),
      label: 'Profile',
    ),
  ];
}
