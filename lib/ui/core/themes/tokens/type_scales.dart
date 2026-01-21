part of '../theme.dart';

TextStyle _getBaseTextStyle(
  double fontSize,
  FontWeight fontWeight,
  double lineHeight,
  double letterSpacing, {
  TextDecoration decoration = TextDecoration.none,
  bool inPercentages = true,
}) => TextStyle(
  color: _Palette.grey1000,
  fontFamily: _AppFontConstants.rethinkSans,
  fontWeight: fontWeight,
  fontSize: fontSize,
  height: inPercentages ? lineHeight / 100 : lineHeight,
  letterSpacing: inPercentages
      ? fontSize * (letterSpacing / 100)
      : letterSpacing,
  decoration: decoration,
);

// Display
TextStyle get _displayMedium =>
    _getBaseTextStyle(_AppFontSizes.s64, AppFontWeights.semiBold, 120, -2);

// Headlines
TextStyle get _headlineMedium =>
    _getBaseTextStyle(_AppFontSizes.s32, AppFontWeights.semiBold, 120, -2);
TextStyle get _headlineSmall =>
    _getBaseTextStyle(_AppFontSizes.s24, AppFontWeights.semiBold, 140, 0);

// Titles
TextStyle get _titleLarge =>
    _getBaseTextStyle(_AppFontSizes.s20, AppFontWeights.medium, 130, 1);
TextStyle get _titleMedium =>
    _getBaseTextStyle(_AppFontSizes.s16, AppFontWeights.semiBold, 120, 1);
TextStyle get _titleSmall =>
    _getBaseTextStyle(_AppFontSizes.s14, AppFontWeights.semiBold, 100, 0);

// Labels
TextStyle get _labelMedium =>
    _getBaseTextStyle(_AppFontSizes.s16, AppFontWeights.semiBold, 100, 1.5);
TextStyle get _labelSmall =>
    _getBaseTextStyle(_AppFontSizes.s14, AppFontWeights.regular, 150, 0);

// Body
TextStyle get _bodyLarge =>
    _getBaseTextStyle(_AppFontSizes.s16, AppFontWeights.medium, 150, 0);
TextStyle get _bodyMedium =>
    _getBaseTextStyle(_AppFontSizes.s14, AppFontWeights.medium, 150, 0);
TextStyle get _bodySmall => _getBaseTextStyle(
  _AppFontSizes.s12,
  AppFontWeights.medium,
  16 / 12,
  0.25,
  inPercentages: false,
);

TextStyle get _bodyLink => _bodyMedium.copyWith(
  color: _Palette.blue600,
  decoration: TextDecoration.underline,
  decorationStyle: TextDecorationStyle.dotted,
  decorationColor: _Palette.blue600,
);
