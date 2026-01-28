import 'package:flutter/material.dart';
import 'package:cleer/ui/core/themes/tokens/color_extension.dart';
import 'package:cleer/ui/core/themes/tokens/typography_extensions.dart';

extension AppThemeContext on BuildContext {
  ThemeData get theme => Theme.of(this);

  /// Access custom color ramps: context.color.green500
  AppColorExtension get color => theme.extension<AppColorExtension>()!;

  /// Access BOTH standard and custom typography: context.typo.bodyLarge or context.typo.bodyLink
  AppTypography get typo => AppTypography(
    theme.textTheme,
    theme.extension<AppTypographyExtension>()!,
  );
}

class AppTypography {
  final TextTheme _textTheme;
  final AppTypographyExtension _extension;

  AppTypography(this._textTheme, this._extension);

  // --- Material 3 Standard Styles ---
  TextStyle get displayMedium => _textTheme.displayMedium!;
  TextStyle get headlineLarge => _textTheme.headlineLarge!;
  TextStyle get headlineMedium => _textTheme.headlineMedium!;
  TextStyle get headlineSmall => _textTheme.headlineSmall!;
  TextStyle get titleLarge => _textTheme.titleLarge!;
  TextStyle get titleMedium => _textTheme.titleMedium!;
  TextStyle get titleSmall => _textTheme.titleSmall!;
  TextStyle get bodyLarge => _textTheme.bodyLarge!;
  TextStyle get bodyMedium => _textTheme.bodyMedium!;
  TextStyle get bodySmall => _textTheme.bodySmall!;
  TextStyle get labelMedium => _textTheme.labelMedium!;
  TextStyle get labelSmall => _textTheme.labelSmall!;

  // --- Cleer Custom Styles ---
  TextStyle get bodyLink => _extension.bodyLink;
}
