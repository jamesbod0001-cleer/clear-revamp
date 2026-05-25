import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer_ui/themes/dimensions.dart';
import 'package:cleer_ui/themes/theme_utils.dart';
import 'package:cleer_ui/widgets/trust_score_badge.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

class EscrowSummaryCard extends StatelessWidget {
  final double currentlyProtectedAmount;
  final int trustScore;
  final int needsActionCount;
  final int awaitingOtherPartyCount;
  final bool isLoading;

  const EscrowSummaryCard({
    super.key,
    required this.currentlyProtectedAmount,
    required this.trustScore,
    required this.needsActionCount,
    required this.awaitingOtherPartyCount,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Skeletonizer(
      enabled: isLoading,
      child: Container(
        decoration: BoxDecoration(
          color: context.color.blue100,
          border: .all(
            color: context.color.blue300,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
          borderRadius: .circular(Dimens.radius.r8),
        ),
        padding: .all(Dimens.padding.p12),
        child: Column(
          mainAxisSize: .min,
          children: [
            Row(
              mainAxisAlignment: .spaceBetween,
              crossAxisAlignment: .start,
              children: [
                Column(
                  mainAxisSize: .min,
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      l10n.currentlyProtected,
                      style: context.typo.bodySmall.copyWith(
                        color: context.color.grey800,
                      ),
                    ),
                    Text(
                      '${l10n.nairaSign}${NumberFormat('#,###.##').format(currentlyProtectedAmount)}',
                      style: context.typo.headlineSmall.copyWith(
                        color: context.color.grey800,
                      ),
                    ),
                  ],
                ),
                TrustScoreBadge(score: trustScore),
              ],
            ),
            Gap(Dimens.spacing.sp20),
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: context.color.background,
                    border: .all(
                      color: context.color.blue200,
                      strokeAlign: BorderSide.strokeAlignInside,
                    ),
                    borderRadius: .circular(Dimens.radius.r80),
                  ),
                  padding: .symmetric(
                    vertical: Dimens.padding.p2,
                    horizontal: Dimens.padding.p8,
                  ),
                  child: Row(
                    children: [
                      Text(
                        needsActionCount.toString(),
                        style: context.typo.bodySmall.copyWith(
                          color: context.color.blue700,
                        ),
                      ),
                      Gap(Dimens.spacing.sp4),
                      Text(
                        l10n.needsYourAction,
                        style: context.typo.bodySmall.copyWith(
                          color: context.color.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
                Gap(Dimens.spacing.sp12),
                Container(
                  decoration: BoxDecoration(
                    color: context.color.background,
                    border: .all(
                      color: context.color.blue200,
                      strokeAlign: BorderSide.strokeAlignInside,
                    ),
                    borderRadius: .circular(Dimens.radius.r80),
                  ),
                  padding: .symmetric(
                    vertical: Dimens.padding.p2,
                    horizontal: Dimens.padding.p8,
                  ),
                  child: Row(
                    children: [
                      Text(
                        awaitingOtherPartyCount.toString(),
                        style: context.typo.bodySmall.copyWith(
                          color: context.color.blue700,
                        ),
                      ),
                      Gap(Dimens.spacing.sp4),
                      Text(
                        l10n.awaitingOtherParty,
                        style: context.typo.bodySmall.copyWith(
                          color: context.color.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
