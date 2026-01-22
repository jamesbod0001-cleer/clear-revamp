import 'package:flutter/material.dart';

@immutable
class AppColorExtension extends ThemeExtension<AppColorExtension> {
  // Brand & Functional
  final Color primary;
  final Color primaryBlue;
  final Color secondary;
  final Color background;
  final Color outline;
  final Color grayComponent;
  final Color navbarBg;

  // Base
  final Color white;
  final Color black;
  final Color transparent;

  // Semantic
  final Color error;
  final Color errorLight;
  final Color success;
  final Color successLight;
  final Color warning;
  final Color warningLight;
  final Color info;
  final Color infoLight;

  // Green Ramp (000 - 1000)
  final Color green000;
  final Color green050;
  final Color green100;
  final Color green150;
  final Color green200;
  final Color green300;
  final Color green400;
  final Color green500;
  final Color green600;
  final Color green700;
  final Color green800;
  final Color green850;
  final Color green900;
  final Color green950;
  final Color green1000;

  // Blue Ramp (100 - 1400)
  final Color blue100;
  final Color blue200;
  final Color blue300;
  final Color blue400;
  final Color blue500;
  final Color blue600;
  final Color blue700;
  final Color blue800;
  final Color blue900;
  final Color blue1000;
  final Color blue1100;
  final Color blue1200;
  final Color blue1300;
  final Color blue1400;

  // Grey Ramp (100 - 1000)
  final Color grey100;
  final Color grey200;
  final Color grey300;
  final Color grey400;
  final Color grey500;
  final Color grey600;
  final Color grey700;
  final Color grey800;
  final Color grey900;
  final Color grey1000;

  const AppColorExtension({
    required this.primary,
    required this.primaryBlue,
    required this.secondary,
    required this.background,
    required this.outline,
    required this.grayComponent,
    required this.navbarBg,
    required this.white,
    required this.black,
    required this.transparent,
    required this.error,
    required this.errorLight,
    required this.success,
    required this.successLight,
    required this.warning,
    required this.warningLight,
    required this.info,
    required this.infoLight,
    required this.green000,
    required this.green050,
    required this.green100,
    required this.green150,
    required this.green200,
    required this.green300,
    required this.green400,
    required this.green500,
    required this.green600,
    required this.green700,
    required this.green800,
    required this.green850,
    required this.green900,
    required this.green950,
    required this.green1000,
    required this.blue100,
    required this.blue200,
    required this.blue300,
    required this.blue400,
    required this.blue500,
    required this.blue600,
    required this.blue700,
    required this.blue800,
    required this.blue900,
    required this.blue1000,
    required this.blue1100,
    required this.blue1200,
    required this.blue1300,
    required this.blue1400,
    required this.grey100,
    required this.grey200,
    required this.grey300,
    required this.grey400,
    required this.grey500,
    required this.grey600,
    required this.grey700,
    required this.grey800,
    required this.grey900,
    required this.grey1000,
  });

  @override
  AppColorExtension copyWith() => this;

  @override
  AppColorExtension lerp(ThemeExtension<AppColorExtension>? other, double t) {
    if (other is! AppColorExtension) return this;
    return AppColorExtension(
      // Ensure you add the new fields to the lerp method
      primary: Color.lerp(primary, other.primary, t)!,
      primaryBlue: Color.lerp(primaryBlue, other.primaryBlue, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      background: Color.lerp(background, other.background, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      grayComponent: Color.lerp(grayComponent, other.grayComponent, t)!,
      navbarBg: Color.lerp(navbarBg, other.navbarBg, t)!,
      white: Color.lerp(white, other.white, t)!,
      black: Color.lerp(black, other.black, t)!,
      transparent: Color.lerp(transparent, other.transparent, t)!,
      error: Color.lerp(error, other.error, t)!,
      errorLight: Color.lerp(errorLight, other.errorLight, t)!,
      success: Color.lerp(success, other.success, t)!,
      successLight: Color.lerp(successLight, other.successLight, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningLight: Color.lerp(warningLight, other.warningLight, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoLight: Color.lerp(infoLight, other.infoLight, t)!,
      green000: Color.lerp(green000, other.green000, t)!,
      green050: Color.lerp(green050, other.green050, t)!,
      green100: Color.lerp(green100, other.green100, t)!,
      green150: Color.lerp(green150, other.green150, t)!,
      green200: Color.lerp(green200, other.green200, t)!,
      green300: Color.lerp(green300, other.green300, t)!,
      green400: Color.lerp(green400, other.green400, t)!,
      green500: Color.lerp(green500, other.green500, t)!,
      green600: Color.lerp(green600, other.green600, t)!,
      green700: Color.lerp(green700, other.green700, t)!,
      green800: Color.lerp(green800, other.green800, t)!,
      green850: Color.lerp(green850, other.green850, t)!,
      green900: Color.lerp(green900, other.green900, t)!,
      green950: Color.lerp(green950, other.green950, t)!,
      green1000: Color.lerp(green1000, other.green1000, t)!,
      blue100: Color.lerp(blue100, other.blue100, t)!,
      blue200: Color.lerp(blue200, other.blue200, t)!,
      blue300: Color.lerp(blue300, other.blue300, t)!,
      blue400: Color.lerp(blue400, other.blue400, t)!,
      blue500: Color.lerp(blue500, other.blue500, t)!,
      blue600: Color.lerp(blue600, other.blue600, t)!,
      blue700: Color.lerp(blue700, other.blue700, t)!,
      blue800: Color.lerp(blue800, other.blue800, t)!,
      blue900: Color.lerp(blue900, other.blue900, t)!,
      blue1000: Color.lerp(blue1000, other.blue1000, t)!,
      blue1100: Color.lerp(blue1100, other.blue1100, t)!,
      blue1200: Color.lerp(blue1200, other.blue1200, t)!,
      blue1300: Color.lerp(blue1300, other.blue1300, t)!,
      blue1400: Color.lerp(blue1400, other.blue1400, t)!,
      grey100: Color.lerp(grey100, other.grey100, t)!,
      grey200: Color.lerp(grey200, other.grey200, t)!,
      grey300: Color.lerp(grey300, other.grey300, t)!,
      grey400: Color.lerp(grey400, other.grey400, t)!,
      grey500: Color.lerp(grey500, other.grey500, t)!,
      grey600: Color.lerp(grey600, other.grey600, t)!,
      grey700: Color.lerp(grey700, other.grey700, t)!,
      grey800: Color.lerp(grey800, other.grey800, t)!,
      grey900: Color.lerp(grey900, other.grey900, t)!,
      grey1000: Color.lerp(grey1000, other.grey1000, t)!,
    );
  }
}
