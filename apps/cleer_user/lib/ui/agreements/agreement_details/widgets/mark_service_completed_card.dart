import 'package:cleer/ui/agreements/agreement_details/view_model/mark_service_completed_view_model.dart';
import 'package:cleer/ui/agreements/agreement_details/widgets/emphasized_action_card.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:cleer_ui/cleer_ui.dart';
import 'package:cleer_ui/widgets/buttons/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MarkServiceCompletedCard extends ConsumerWidget {
  const MarkServiceCompletedCard({
    super.key,
    required this.agreement,
  });

  final Agreement agreement;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isMilestone = agreement.disbursementType == .milestones;

    final state = ref.watch(
      markServiceCompletedViewModelProvider(agreement.id!),
    );
    final viewModel = ref.read(
      markServiceCompletedViewModelProvider(
        agreement.id!,
      ).notifier,
    );

    final String title = isMilestone
        ? l10n.milestoneCompleted
        : l10n.finishedTheService;
    final String subtitle = isMilestone
        ? l10n.youHaveFinishedThisMilestoneNotifyYourClient(
            agreement.activeMilestoneName ?? '',
          )
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

          if (state.isLoading)
            Padding(
              padding: EdgeInsets.symmetric(vertical: Dimens.padding.p20),
              child: const Center(child: CircularProgressIndicator()),
            )
          else
            PrimaryButton(
              onPressed: () => viewModel.markCompleted(),
              child: Text(actionText),
            ),
        ],
      ),
    );
  }
}
