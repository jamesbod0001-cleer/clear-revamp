import 'package:cleer/ui/core/themes/tokens/color_extension.dart';
import 'package:cleer/ui/core/themes/tokens/typography_extensions.dart';
import 'package:flutter/material.dart';

part 'tokens/palette.dart';
part 'tokens/typography_constants.dart';
part 'tokens/type_scales.dart';

abstract class AppTheme {
  static final TextTheme _textTheme = TextTheme(
    displayMedium: _displayMedium,
    headlineMedium: _headlineMedium,
    headlineSmall: _headlineSmall,
    titleLarge: _titleLarge,
    titleMedium: _titleMedium,
    titleSmall: _titleSmall,
    labelMedium: _labelMedium,
    labelSmall: _labelSmall,
    bodyLarge: _bodyLarge,
    bodyMedium: _bodyMedium,
    bodySmall: _bodySmall,
  );

  static final _lightColorScheme = ColorScheme(
    brightness: Brightness.light,

    // Brand Identity
    primary: _Palette.primary, // #62E393 (functionalPrimary)
    onPrimary:
        _Palette.secondary, // #030551 (functionalSecondary) - high contrast

    secondary: _Palette.secondary, // #030551 (functionalSecondary)
    onSecondary: _Palette.green100, // Lightest green tint for contrast
    // UI States
    error: _Palette.error, // #9F1B1D (semantic - red1000)
    onError:
        _Palette.errorLight, // #F7E1E7 (semantic - red100) - avoids pure white
    // Background & Surfaces
    // Using functional - bgcolor (#FAFAFA) as the base
    surface: _Palette.background,
    onSurface: _Palette.grey1000, // #1C211C (functional - text1000)
    // Containers (Cards, etc.)
    surfaceContainerHighest: _Palette.grayComponent, // #F2F3F2
    onSurfaceVariant: _Palette.grey800, // #424742 (functional - text800)
    // Outline for TextFields and Dividers
    outline: _Palette.outline, // #E2E3E4 (functional - outline100)
    // Custom Semantic Mappings
    tertiary: _Palette.info, // #0144CD (semantic - blue1000)
    onTertiary: _Palette.blue100, // #E0E5EE
  );

  static final _appColorExtension = AppColorExtension(
    // Brand & Functional
    primary: _Palette.primary,
    secondary: _Palette.secondary,
    background: _Palette.background,
    outline: _Palette.outline,
    grayComponent: _Palette.grayComponent,
    navbarGreen: _Palette.navbarGreen,

    // Base
    white: _Palette.white,
    black: _Palette.black,
    transparent: _Palette.transparent,

    // Semantic
    error: _Palette.error,
    errorLight: _Palette.errorLight,
    success: _Palette.success,
    successLight: _Palette.successLight,
    warning: _Palette.warning,
    warningLight: _Palette.warningLight,
    info: _Palette.info,
    infoLight: _Palette.infoLight,

    // Green Ramp
    green100: _Palette.green100,
    green200: _Palette.green200,
    green300: _Palette.green300,
    green400: _Palette.green400,
    green500: _Palette.green500,
    green600: _Palette.green600,
    green700: _Palette.green700,
    green800: _Palette.green800,
    green900: _Palette.green900,
    green1000: _Palette.green1000,
    green1100: _Palette.green1100,
    green1200: _Palette.green1200,
    green1300: _Palette.green1300,
    green1400: _Palette.green1400,
    green1600: _Palette.green1600,
    green1700: _Palette.green1700,
    green1800: _Palette.green1800,
    green1900: _Palette.green1900,

    // Blue Ramp
    blue100: _Palette.blue100,
    blue200: _Palette.blue200,
    blue300: _Palette.blue300,
    blue400: _Palette.blue400,
    blue500: _Palette.blue500,
    blue600: _Palette.blue600,
    blue700: _Palette.blue700,
    blue800: _Palette.blue800,
    blue900: _Palette.blue900,
    blue1000: _Palette.blue1000,
    blue1100: _Palette.blue1100,
    blue1200: _Palette.blue1200,
    blue1300: _Palette.blue1300,
    blue1400: _Palette.blue1400,

    // Grey Ramp
    grey100: _Palette.grey100,
    grey200: _Palette.grey200,
    grey300: _Palette.grey300,
    grey400: _Palette.grey400,
    grey500: _Palette.grey500,
    grey600: _Palette.grey600,
    grey700: _Palette.grey700,
    grey800: _Palette.grey800,
    grey900: _Palette.grey900,
    grey1000: _Palette.grey1000,
  );

  static final _appTypographyExtension = AppTypographyExtension(
    bodyLink: _bodyLink,
  );

  static ThemeData lightTheme = ThemeData(
    fontFamily: _AppFontConstants.rethinkSans,
    brightness: Brightness.light,
    colorScheme: _lightColorScheme,
    textTheme: _textTheme,
    useMaterial3: true,
    extensions: [_appColorExtension, _appTypographyExtension],
  );
}
