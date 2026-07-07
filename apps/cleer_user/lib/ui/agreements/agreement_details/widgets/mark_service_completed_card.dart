import 'package:cleer/ui/agreements/agreement_details/widgets/emphasized_action_card.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:cleer_ui/cleer_ui.dart';
import 'package:cleer_ui/widgets/buttons/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class MarkServiceCompletedCard extends StatelessWidget {
  const MarkServiceCompletedCard({super.key, required this.agreement});

  final Agreement agreement;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isMilestone = agreement.disbursementType == .milestones;

    final String title = isMilestone
        ? l10n.milestoneCompleted
        : l10n.finishedTheService;
    final String subtitle = isMilestone
        ? l10n.youHaveFinishedThisMilestoneNotifyYourClientSoTheyCanReleaseThisMilestonePayment
        : l10n.letYourClientKnowTheAgreedWorkHasBeenCompleted;
    final String actionText = isMilestone
        ? l10n.markMilestoneComplete
        : l10n.markAsCompleted;

    return EmphasizedActionCard(
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Text(
            title,
            style: context.typo.titleSmall.copyWith(color: context.color.white),
          ),
          Gap(Dimens.spacing.sp4),
          Text(
            subtitle,
            style: context.typo.bodySmall.copyWith(
              color: context.color.blue200,
            ),
          ),
          Gap(Dimens.spacing.sp12),
          PrimaryButton(onPressed: () {}, child: Text(actionText)),
        ],
      ),
    );
  }
}
