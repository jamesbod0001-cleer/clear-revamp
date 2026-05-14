import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer_ui/themes/dimensions.dart';
import 'package:cleer_ui/themes/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class UserPerformanceStatsCard extends StatelessWidget {
  const UserPerformanceStatsCard({
    super.key,
    required this.successfulAgreements,
    required this.disputeFreeAgreements,
    required this.totalValueTransacted,
  });

  final int successfulAgreements;
  final int disputeFreeAgreements;
  final String totalValueTransacted;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Material(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimens.radius.r8),
        side: BorderSide(color: context.color.outline),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: Dimens.padding.p12),
        child: IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatItem(
                value: '$successfulAgreements',
                label: l10n.successfulAgreements,
              ),
              _verticalDivider(context),
              _StatItem(
                value: '$disputeFreeAgreements',
                label: l10n.disputeFreeAgreements,
              ),
              _verticalDivider(context),
              _StatItem(
                value: totalValueTransacted,
                label: l10n.totalValueTransacted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Private helper for the divider to keep the build method clean
  Widget _verticalDivider(BuildContext context) => VerticalDivider(
    color: context.color.outline,
    thickness: Dimens.size.s1,
    width: Dimens.size.s1,
  );
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Dimens.padding.p14),
      child: SizedBox(
        width: Dimens.size.s87,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value, style: context.typo.bodyLarge),
            Gap(Dimens.spacing.sp2),
            Text(
              label,
              style: context.typo.bodySmall.copyWith(
                color: context.color.grey600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
