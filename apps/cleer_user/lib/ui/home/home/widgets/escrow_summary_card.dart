import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer_ui/cleer_ui.dart';
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
  final bool hasError;

  const EscrowSummaryCard({
    super.key,
    required this.currentlyProtectedAmount,
    required this.trustScore,
    required this.needsActionCount,
    required this.awaitingOtherPartyCount,
    this.isLoading = false,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Skeletonizer(
      enabled: isLoading && !hasError,
      child: Container(
        decoration: BoxDecoration(
          color: context.color.blue100,
          border: .all(
            color: context.color.blue300,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
          borderRadius: .circular(Dimens.radius.r8),
        ),
        padding: context.isMobile
            ? .all(Dimens.padding.p12)
            : .symmetric(
                horizontal: Dimens.padding.p16,
                vertical: Dimens.padding.p12,
              ),
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
                    if (!hasError)
                      Text(
                        '${l10n.nairaSign}${NumberFormat('#,###.##').format(currentlyProtectedAmount)}',
                        style:
                            (context.isMobile
                                    ? context.typo.headlineSmall
                                    : context.typo.headlineMedium)
                                .copyWith(color: context.color.grey800),
                      )
                    else
                      Container(
                        margin: .only(top: Dimens.padding.p8),
                        padding: .symmetric(
                          horizontal: Dimens.padding.p8,
                          vertical: Dimens.padding.p4,
                        ),
                        constraints: BoxConstraints(maxWidth: 174),
                        decoration: BoxDecoration(
                          borderRadius: .circular(Dimens.radius.r8),
                          color: context.color.background,
                        ),
                        child: Text(
                          l10n.pleaseCheckYourInternetConnectionAndTryAgain,
                          style: context.typo.bodySmall.copyWith(
                            color: context.color.grey600,
                          ),
                        ),
                      ),
                  ],
                ),
                if (!hasError) TrustScoreBadge(score: trustScore),
              ],
            ),
            if (!hasError) ...[
              Gap(context.isMobile ? Dimens.spacing.sp12 : Dimens.spacing.sp32),
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
                  Gap(Dimens.spacing.sp4),
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
          ],
        ),
      ),
    );
  }
}
