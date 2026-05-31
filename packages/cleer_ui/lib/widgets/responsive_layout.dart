import 'package:cleer_ui/themes/dimensions.dart';
import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveLayout({
    required this.mobile,
    required this.desktop,
    this.tablet,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width >= Breakpoints.desktop) {
      return desktop;
    } else if (width >= Breakpoints.tablet) {
      return tablet ?? desktop;
    } else {
      return mobile;
    }
  }
}
