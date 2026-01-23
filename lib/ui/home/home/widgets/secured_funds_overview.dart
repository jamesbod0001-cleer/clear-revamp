import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:cleer/ui/core/themes/theme.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:cleer/ui/core/ui/trust_score_badge.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class SecuredFundsOverview extends StatelessWidget {
  const SecuredFundsOverview({
    super.key,
    required this.totalFunds,
    required this.trustScore,
  });

  final String totalFunds;
  final int trustScore;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.all(Dimens.padding.p12),
      decoration: BoxDecoration(
        color: context.color.grayComponent,
        borderRadius: BorderRadius.circular(Dimens.radius.r8),
        border: Border.all(color: context.color.outline),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.totalFundsSecured,
                  style: context.typo.bodyMedium.copyWith(
                    fontWeight: AppFontWeights.regular,
                    color: context.color.grey800,
                  ),
                ),
                Gap(Dimens.spacing.sp2),
                Text(
                  totalFunds,
                  style: context.typo.headlineSmall.copyWith(
                    fontWeight: AppFontWeights.medium,
                    height: 1.5,
                    letterSpacing: 0.24,
                  ),
                ),
              ],
            ),
          ),
          TrustScoreBadge(score: trustScore),
        ],
      ),
    );
  }
}