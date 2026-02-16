import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:cleer/ui/core/themes/tokens/color_extension.dart';
import 'package:cleer/ui/core/themes/tokens/typography_extensions.dart';
import 'package:cleer/ui/core/ui/shapes/fixed_width_indicator_shape.dart';
import 'package:flutter/material.dart';

part 'tokens/palette.dart';
part 'tokens/typography_constants.dart';
part 'tokens/type_scales.dart';

abstract class AppTheme {
  static final TextTheme _textTheme = TextTheme(
    displayMedium: _displayMedium,
    headlineLarge: _headlineLarge,
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
    primary: _Palette.primary, // #60E491 (functionalLightGreen)
    onPrimary: _Palette
        .secondary, // #030551 (functionalDeepBlue) - High contrast for Cleer

    secondary: _Palette.secondary, // #030551 (functionalDeepBlue)
    onSecondary: _Palette
        .green000, // #EEFDF3 (lightGreen 000) - Lightest green for contrast
    // UI States (Semantic)
    error: _Palette.error, // #9F1B1D (semantic red1000)
    onError: _Palette.errorLight, // #F7E1E7 (semantic red100)
    // Background & Surfaces
    surface: _Palette.background, // #FAFAFA (functional bg color)
    onSurface: _Palette.grey1000, // #1C211C (grey1000)
    // Containers (Cards, Inputs, etc.)
    // Using functional - gray component for surface containers
    surfaceContainerHighest: _Palette.grayComponent, // #F2F3F2
    onSurfaceVariant: _Palette.grey800, // #424742 (grey800)
    // Outline for TextFields and Dividers
    outline: _Palette.outline, // #E2E3E4 (functional outline100)
    // Custom Semantic Mappings
    tertiary: _Palette.info, // #0144CD (semantic blue1000)
    onTertiary: _Palette.infoLight, // #EBF1FC (semantic blue100)
  );

  static final _appColorExtension = AppColorExtension(
    // Brand & Functional
    primary: _Palette.primary,
    primaryBlue: _Palette.primaryBlue,
    primaryBlueLight: _Palette.primaryBlueLight,
    secondary: _Palette.secondary,
    background: _Palette.background,
    outline: _Palette.outline,
    grayComponent: _Palette.grayComponent,
    navbarBg: _Palette.navbarBg,

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
    green000: _Palette.green000,
    green050: _Palette.green050,
    green100: _Palette.green100,
    green150: _Palette.green150,
    green200: _Palette.green200,
    green300: _Palette.green300,
    green400: _Palette.green400,
    green500: _Palette.green500,
    green600: _Palette.green600,
    green700: _Palette.green700,
    green800: _Palette.green800,
    green850: _Palette.green850,
    green900: _Palette.green900,
    green950: _Palette.green950,
    green1000: _Palette.green1000,

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

  static final _appBarTheme = AppBarThemeData(
    centerTitle: false,
    elevation: Dimens.size.s0,
  );

  static final _navigationBarTheme = NavigationBarThemeData(
    elevation: Dimens.size.s0,
    backgroundColor: _Palette.navbarBg,
    indicatorColor: _Palette.primaryBlue,
    indicatorShape: FixedWidthIndicatorShape(
      width: Dimens.size.s56,
      height: Dimens.size.s32,
      borderRadius: Dimens.size.s16,
    ),
    height: Dimens.size.s60,
    labelPadding: EdgeInsets.only(top: Dimens.padding.p4),
    iconTheme: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return IconThemeData(color: _Palette.background, size: Dimens.size.s24);
      }
      return IconThemeData(color: _Palette.grey600, size: Dimens.size.s24);
    }),
    labelTextStyle: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return _bodySmall.copyWith(color: _Palette.secondary);
      }
      return _bodySmall.copyWith(color: _Palette.grey600);
    }),
  );

  static final _inputDecorationTheme = InputDecorationThemeData(
    contentPadding: EdgeInsets.all(Dimens.padding.p12),
    filled: true,
    fillColor: _Palette.grayComponent,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(Dimens.radius.r8),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(Dimens.radius.r8),
      borderSide: BorderSide(
        color: _Palette.outline,
        strokeAlign: BorderSide.strokeAlignInside,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(Dimens.radius.r8),
      borderSide: BorderSide(
        color: _Palette.blue400,
        width: Dimens.size.s2,
        strokeAlign: BorderSide.strokeAlignInside,
      ),
    ),
  );

  static final _iconTheme = IconThemeData(color: _Palette.grey600);

  static final _buttonTheme = ButtonThemeData(
    shape: RoundedRectangleBorder(borderRadius: .circular(Dimens.radius.r8)),
    minWidth: Dimens.mobile.buttonMinimumSize.width,
    height: Dimens.mobile.buttonMinimumSize.height,
    padding: EdgeInsets.symmetric(vertical: Dimens.padding.p16),
  );

  static final _filledButtonTheme = FilledButtonThemeData(
    style: FilledButton.styleFrom(
      foregroundColor: _Palette.grey1000,
      backgroundColor: _Palette.primary,
      minimumSize: Dimens.mobile.buttonMinimumSize,
      disabledBackgroundColor: _Palette.grey200,
      disabledForegroundColor: _Palette.grey500,
      textStyle: _labelMedium,
      padding: EdgeInsets.symmetric(vertical: Dimens.padding.p16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimens.radius.r8),
      ),
    ),
  );

  static final _outlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      backgroundColor: _Palette.transparent,
      minimumSize: Dimens.mobile.buttonMinimumSize,
      textStyle: _labelMedium,
      padding: EdgeInsets.symmetric(vertical: Dimens.padding.p16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimens.radius.r8),
      ),
    ),
  );

  static final _textButtonTheme = TextButtonThemeData(
    style: OutlinedButton.styleFrom(
      backgroundColor: _Palette.transparent,
      foregroundColor: _Palette.blue700,
      minimumSize: Dimens.mobile.buttonMinimumSize,
      textStyle: _labelMedium,
      padding: EdgeInsets.symmetric(vertical: Dimens.padding.p16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimens.radius.r8),
      ),
    ),
  );

  static ThemeData lightTheme = ThemeData(
    fontFamily: _AppFontConstants.rethinkSans,
    brightness: Brightness.light,
    colorScheme: _lightColorScheme,
    textTheme: _textTheme,
    appBarTheme: _appBarTheme,
    inputDecorationTheme: _inputDecorationTheme,
    buttonTheme: _buttonTheme,
    filledButtonTheme: _filledButtonTheme,
    outlinedButtonTheme: _outlinedButtonTheme,
    textButtonTheme: _textButtonTheme,
    iconTheme: _iconTheme,
    navigationBarTheme: _navigationBarTheme,
    useMaterial3: true,
    extensions: [_appColorExtension, _appTypographyExtension],
  );
}
