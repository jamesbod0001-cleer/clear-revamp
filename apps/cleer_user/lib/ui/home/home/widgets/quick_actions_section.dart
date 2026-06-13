import 'package:cleer/routing/routes.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer_ui/cleer_ui.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.startATransaction,
          style:
              (context.isMobile
                      ? context.typo.titleSmall
                      : context.typo.titleMedium)
                  .copyWith(color: context.color.grey800),
        ),
        Gap(context.isMobile ? Dimens.spacing.sp12 : Dimens.spacing.sp8),
        IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: _QuickActionCard(
                  title: l10n.sendFunds,
                  subtitle: l10n.yourMoneyIsHeldSafelyUntilYouConfirm,
                  backgroundColor: context.color.green400,
                  contentColor: context.color.green1000,
                  subtitleColor: context.color.green900,
                  icon: PhosphorIcons.arrowUpRight(),
                  onTap: () => _handleSendFunds(context),
                ),
              ),
              Gap(context.isMobile ? Dimens.spacing.sp8 : Dimens.spacing.sp20),
              Expanded(
                child: _QuickActionCard(
                  title: l10n.requestPayment,
                  subtitle: l10n.fundsAreSecuredUntilTheDealIsComplete,
                  backgroundColor: context.color.primaryBlueLight,
                  contentColor: context.color.secondary,
                  subtitleColor: context.color.secondary,
                  icon: PhosphorIcons.arrowDownLeft(),
                  onTap: () => _handleRequestPayment(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleSendFunds(BuildContext context) =>
      CreateAgreementRoute(type: .send).push(context);
  void _handleRequestPayment(BuildContext context) =>
      CreateAgreementRoute(type: .request).push(context);
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.contentColor,
    required this.subtitleColor,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final Color backgroundColor;
  final Color contentColor;
  final Color subtitleColor;
  final PhosphorIconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimens.radius.r8),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.isMobile ? Dimens.padding.p8 : Dimens.padding.p16,
          vertical: context.isMobile ? Dimens.padding.p12 : Dimens.padding.p16,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(
            context.isMobile ? Dimens.radius.r8 : Dimens.radius.r12,
          ),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Gap(context.isMobile ? Dimens.spacing.sp44 : Dimens.spacing.sp45), // Space for the floating icon
                Text(
                  context.isMobile ? title.replaceAll(' ', '\n') : title,
                  style:
                      (context.isMobile
                              ? context.typo.titleLarge
                              : context.typo.headlineSmall)
                          .copyWith(color: contentColor),
                ),
                Gap(Dimens.spacing.sp8),
                Text(
                  subtitle,
                  style: context.typo.bodyMedium.copyWith(
                    color: subtitleColor,
                    fontWeight: AppFontWeights.regular,
                  ),
                ),
              ],
            ),
            Positioned(
              top: context.isMobile ? 0 : -4,
              right: context.isMobile ? 4 : -4,
              child: PhosphorIcon(
                icon,
                color: context.color.secondary,
                size: Dimens.size.s44,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
