import 'package:cleer_ui/themes/dimensions.dart';
import 'package:cleer_ui/themes/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class AppEmptyState extends StatelessWidget {
  final Widget icon;
  final String title;
  final Widget? subtitle;
  final double iconBottomSpacing;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconBottomSpacing = 32.0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          Gap(iconBottomSpacing),
          Text(
            title,
            textAlign: TextAlign.center,
            style: context.typo.bodyMedium.copyWith(
              color: context.color.grey800,
            ),
          ),
          if (subtitle != null) ...[Gap(Dimens.spacing.sp6), subtitle!],
        ],
      ),
    );
  }
}
