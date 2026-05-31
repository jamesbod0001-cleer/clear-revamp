import 'package:cleer_ui/cleer_ui.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class NavigationConfig {
  static List<NavigationDestination> getDestinations(BuildContext context) {
    final commonDestinations = [
      NavigationDestination(
        icon: PhosphorIcon(PhosphorIcons.house()),
        selectedIcon:
            PhosphorIcon(PhosphorIcons.house(PhosphorIconsStyle.fill)),
        label: 'Home',
      ),
      NavigationDestination(
        icon: PhosphorIcon(PhosphorIcons.handshake()),
        selectedIcon: PhosphorIcon(
          PhosphorIcons.handshake(PhosphorIconsStyle.fill),
        ),
        label: 'Agreements',
      ),
    ];

    if (context.isMobile) {
      return [
        ...commonDestinations,
        NavigationDestination(
          icon: PhosphorIcon(PhosphorIcons.userCircle()),
          selectedIcon: PhosphorIcon(
            PhosphorIcons.userCircle(PhosphorIconsStyle.fill),
          ),
          label: 'Profile',
        ),
      ];
    } else {
      return [
        ...commonDestinations,
        NavigationDestination(
          icon: PhosphorIcon(PhosphorIcons.clockCounterClockwise()),
          selectedIcon: PhosphorIcon(
            PhosphorIcons.clockCounterClockwise(PhosphorIconsStyle.fill),
          ),
          label: 'Activity',
        ),
      ];
    }
  }
}
