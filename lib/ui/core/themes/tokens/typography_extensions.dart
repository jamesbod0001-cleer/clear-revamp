import 'package:flutter/material.dart';

@immutable
class AppTypographyExtension extends ThemeExtension<AppTypographyExtension> {
  final TextStyle bodyLink;

  const AppTypographyExtension({required this.bodyLink});

  @override
  AppTypographyExtension copyWith({TextStyle? bodyLink}) =>
      AppTypographyExtension(bodyLink: bodyLink ?? this.bodyLink);

  @override
  AppTypographyExtension lerp(
    ThemeExtension<AppTypographyExtension>? other,
    double t,
  ) {
    if (other is! AppTypographyExtension) return this;
    return AppTypographyExtension(
      bodyLink: TextStyle.lerp(bodyLink, other.bodyLink, t)!,
    );
  }
}
