import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class NavigationConfig {
  static final List<NavigationDestination> destinations = [
    NavigationDestination(
      icon: PhosphorIcon(PhosphorIcons.house()),
      selectedIcon: PhosphorIcon(PhosphorIcons.house(PhosphorIconsStyle.fill)),
      label: 'Home',
    ),
    NavigationDestination(
      icon: PhosphorIcon(PhosphorIcons.handshake()),
      selectedIcon: PhosphorIcon(
        PhosphorIcons.handshake(PhosphorIconsStyle.fill),
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
