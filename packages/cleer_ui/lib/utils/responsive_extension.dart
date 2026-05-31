import 'package:cleer_ui/themes/dimensions.dart';
import 'package:flutter/material.dart';

extension ResponsiveExtension on BuildContext {
  /// Returns true if the screen width is less than the tablet breakpoint.
  bool get isMobile => MediaQuery.sizeOf(this).width < Breakpoints.tablet;

  /// Returns true if the screen width is between tablet and desktop breakpoints.
  bool get isTablet {
    final width = MediaQuery.sizeOf(this).width;
    return width >= Breakpoints.tablet && width < Breakpoints.desktop;
  }

  /// Returns true if the screen width is greater than or equal to the desktop breakpoint.
  bool get isDesktop => MediaQuery.sizeOf(this).width >= Breakpoints.desktop;

  /// Returns true if the screen width is greater than or equal to the tablet breakpoint.
  bool get isAtLeastTablet => MediaQuery.sizeOf(this).width >= Breakpoints.tablet;
}
