import 'package:cleer/routing/routes.dart' show CreateAgreementRoute;
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:cleer/ui/core/themes/theme.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AgreementsOverviewSection extends StatelessWidget {
  const AgreementsOverviewSection({
    super.key,
    required this.hasAgreements,
    this.waitingCount = 0,
    this.waitingAmount = '₦0',
    this.readyCount = 0,
    this.readyAmount = '₦0',
  });

  final bool hasAgreements;
  final int waitingCount;
  final String waitingAmount;
  final int readyCount;
  final String readyAmount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.activeAgreements,
          style: context.typo.titleSmall.copyWith(color: context.color.grey800),
        ),
        Gap(Dimens.spacing.sp12),
        if (!hasAgreements)
          const _AgreementsEmptyState()
        else
          Row(
            children: [
              Expanded(
                child: _AgreementSummaryCard(
                  label: l10n.waitingForApproval,
                  count: waitingCount,
                  amount: waitingAmount,
                  onTap: () {},
                ),
              ),
              Gap(Dimens.spacing.sp8),
              Expanded(
                child: _AgreementSummaryCard(
                  label: l10n.readyForRelease,
                  count: readyCount,
                  amount: readyAmount,
                  onTap: () {},
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _AgreementSummaryCard extends StatelessWidget {
  const _AgreementSummaryCard({
    required this.label,
    required this.count,
    required this.amount,
    required this.onTap,
  });

  final String label;
  final int count;
  final String amount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimens.radius.r8),
      child: Container(
        decoration: BoxDecoration(
          color: context.color.grayComponent,
          borderRadius: BorderRadius.circular(Dimens.radius.r8),
          border: Border.all(
            color: context.color.outline.withValues(alpha: .30),
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.padding.p12,
          vertical: Dimens.padding.p8,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: context.typo.bodyMedium.copyWith(
                color: context.color.grey800,
                fontWeight: AppFontWeights.regular,
              ),
            ),
            Gap(Dimens.spacing.sp8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: .symmetric(horizontal: Dimens.padding.p6),
                  decoration: BoxDecoration(
                    color: context.color.outline,
                    borderRadius: BorderRadius.circular(Dimens.radius.r80),
                  ),

                  child: Row(
                    children: [
                      Text(
                        l10n.view,
                        style: context.typo.bodySmall.copyWith(
                          color: context.color.grey600,
                        ),
                      ),
                      Gap(Dimens.spacing.sp4),
                      Text(
                        count.toString(),
                        style: context.typo.bodyMedium.copyWith(
                          color: context.color.blue700,
                        ),
                      ),
                      Gap(Dimens.spacing.sp4),
                      Text(
                        l10n.agreements,
                        style: context.typo.bodySmall.copyWith(
                          color: context.color.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
                PhosphorIcon(
                  PhosphorIcons.caretRight(PhosphorIconsStyle.bold),
                  size: Dimens.size.s20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AgreementsEmptyState extends StatelessWidget {
  const _AgreementsEmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Material(
      color: context.color.grayComponent,
      borderRadius: BorderRadius.circular(Dimens.radius.r8),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.padding.p12,
          vertical: 17.5,
        ),
        child: Row(
          children: [
            PhosphorIcon(
              PhosphorIcons.empty(PhosphorIconsStyle.duotone),
              color: context.color.grey800,
            ),
            Gap(Dimens.spacing.sp8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.youHaveNoActiveTransactions,
                    style: context.typo.bodyMedium.copyWith(
                      fontWeight: AppFontWeights.regular,
                      color: context.color.grey800,
                    ),
                  ),
                  Gap(Dimens.spacing.sp2),
                  RichText(
                    text: TextSpan(
                      style: context.typo.bodySmall.copyWith(
                        color: context.color.grey600,
                      ),
                      children: [
                        _linkSpan(
                          context,
                          text: l10n.sendFunds,
                          onTap: () => _handleSendFunds(context),
                        ),
                        const TextSpan(text: ' '),
                        TextSpan(text: l10n.or),
                        const TextSpan(text: ' '),
                        _linkSpan(
                          context,
                          text: l10n.requestPayment,
                          onTap: () => _handleRequestPayment(context),
                        ),
                        const TextSpan(text: ' '),
                        TextSpan(text: l10n.toGetStarted),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Private helper to style the links and avoid repeated code
  TextSpan _linkSpan(
    BuildContext context, {
    required String text,
    required VoidCallback onTap,
  }) {
    return TextSpan(
      text: text,
      style: TextStyle(
        color: context.color.blue700,
        decorationColor: context.color.blue700,
        decoration: TextDecoration.underline,
        decorationStyle: TextDecorationStyle.dotted,
      ),
      recognizer: TapGestureRecognizer()..onTap = onTap,
    );
  }

  void _handleSendFunds(BuildContext context) =>
      CreateAgreementRoute(type: .send).push(context);
  void _handleRequestPayment(BuildContext context) =>
      CreateAgreementRoute(type: .request).push(context);
}
