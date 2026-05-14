import 'package:cleer_ui/l10n/generated/ui_localizations.dart';
import 'package:cleer_ui/themes/dimensions.dart';
import 'package:cleer_ui/themes/theme.dart';
import 'package:cleer_ui/themes/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class TrustScoreBadge extends StatelessWidget {
  const TrustScoreBadge({super.key, required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    final l10n = UiLocalizations.of(context)!;

    return Row(
      children: [
        Text(
          '${l10n.trustScore}:',
          style: context.typo.bodySmall.copyWith(color: context.color.grey600),
        ),
        Gap(Dimens.spacing.sp4),
        Material(
          color: context.color.successLight,
          borderRadius: BorderRadius.circular(Dimens.radius.r20),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Dimens.padding.p8,
              vertical: Dimens.padding.p2,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PhosphorIcon(
                  PhosphorIcons.shootingStar(PhosphorIconsStyle.duotone),
                  color: context.color.success,
                  size: Dimens.size.s16,
                ),
                Gap(Dimens.spacing.sp4),
                Text(
                  '$score',
                  style: context.typo.bodySmall.copyWith(
                    fontWeight: AppFontWeights.regular,
                    letterSpacing: 0,
                    height: 1.5,
                    color: context.color.success,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
