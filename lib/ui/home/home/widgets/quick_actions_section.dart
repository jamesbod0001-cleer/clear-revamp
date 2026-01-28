import 'package:cleer/routing/routes.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:cleer/ui/core/themes/theme.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
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
          style: context.typo.titleSmall.copyWith(color: context.color.grey800),
        ),
        Gap(Dimens.spacing.sp12),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                title: l10n.sendFunds,
                subtitle: l10n.yourMoneyIsHeldSafelyUntilYouConfirm,
                backgroundColor: context.color.green400,
                contentColor: context.color.green1000,
                subtitleColor: context.color.green850,
                icon: PhosphorIcons.arrowUpRight(),
                onTap: () => _handleSendFunds(context),
              ),
            ),
            Gap(Dimens.spacing.sp8),
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
          horizontal: Dimens.padding.p8,
          vertical: Dimens.padding.p12,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(Dimens.radius.r8),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Gap(Dimens.spacing.sp40), // Space for the floating icon
                Text(
                  title.replaceAll(' ', '\n'),
                  style: context.typo.titleLarge.copyWith(
                    color: contentColor
                  ),
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
              top: 0,
              right: 0,
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
