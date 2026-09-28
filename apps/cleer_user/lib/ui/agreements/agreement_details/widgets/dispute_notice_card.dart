import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer_ui/cleer_ui.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class DisputeNoticeCard extends StatelessWidget {
  const DisputeNoticeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: .all(Dimens.padding.p8),
      decoration: BoxDecoration(
        color: context.color.infoLight,
        borderRadius: .circular(Dimens.radius.r8),
      ),
      child: Row(
        crossAxisAlignment: .center,
        children: [
          PhosphorIcon(
            PhosphorIcons.info(),
            color: context.color.info,
            size: Dimens.size.s24,
          ),
          Gap(Dimens.spacing.sp8),
          Expanded(
            child: Text(
              l10n.fundsAreSecurelyHeldUntilTheIssueIsResolved,
              style: context.typo.bodyMedium.copyWith(
                color: context.color.info,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
