part of '../theme.dart';

TextStyle _getBaseTextStyle(
  double fontSize,
  FontWeight fontWeight,
  double height,
  double letterSpacingPercentage, {
  TextDecoration decoration = TextDecoration.none,
}) => TextStyle(
  color: _Palette.grey1000,
  fontFamily: _AppFontConstants.rethinkSans,
  fontWeight: fontWeight,
  fontSize: fontSize,
  height: height,
  letterSpacing: fontSize * (letterSpacingPercentage / 100),
  decoration: decoration,
);

// Display
TextStyle get _displayMedium => _getBaseTextStyle(
  _AppFontSizes.s64,
  AppFontWeights.semiBold,
  76.8 / 64,
  -2,
);

// Headlines
TextStyle get _headlineMedium => _getBaseTextStyle(
  _AppFontSizes.s32,
  AppFontWeights.semiBold,
  38.4 / 32,
  -1,
);
TextStyle get _headlineSmall =>
    _getBaseTextStyle(_AppFontSizes.s24, AppFontWeights.bold, 28.8 / 24, 0);

// Titles
TextStyle get _titleLarge =>
    _getBaseTextStyle(_AppFontSizes.s20, AppFontWeights.semiBold, 24 / 20, 1);
TextStyle get _titleMedium =>
    _getBaseTextStyle(_AppFontSizes.s16, AppFontWeights.semiBold, 19.2 / 16, 1);
TextStyle get _titleSmall =>
    _getBaseTextStyle(_AppFontSizes.s14, AppFontWeights.semiBold, 16.8 / 14, 1);

// Labels
TextStyle get _labelMedium =>
    _getBaseTextStyle(_AppFontSizes.s16, AppFontWeights.semiBold, 1.0, 1.5);
TextStyle get _labelSmall =>
    _getBaseTextStyle(_AppFontSizes.s14, AppFontWeights.regular, 21 / 14, 0);

// Body
TextStyle get _bodyLarge =>
    _getBaseTextStyle(_AppFontSizes.s16, AppFontWeights.medium, 24 / 16, 0);
TextStyle get _bodyMedium =>
    _getBaseTextStyle(_AppFontSizes.s14, AppFontWeights.medium, 21 / 14, 0);
TextStyle get _bodySmall =>
    _getBaseTextStyle(_AppFontSizes.s12, AppFontWeights.medium, 16 / 12, 0.5);

TextStyle get _bodyLink => _bodyMedium.copyWith(
  decoration: TextDecoration.underline,
  decorationStyle: TextDecorationStyle.dotted,
  decorationColor: _Palette.green1000,
);
