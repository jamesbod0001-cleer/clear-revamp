import 'package:cleer/ui/agreements/agreement_details/view_model/release_funds_view_model.dart';
import 'package:cleer/ui/agreements/agreement_details/widgets/emphasized_action_card.dart';
import 'package:cleer/ui/agreements/agreement_details/widgets/release_funds_bottom_sheet.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:cleer_ui/cleer_ui.dart';
import 'package:cleer_ui/widgets/buttons/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ApproveServicePaymentCard extends ConsumerWidget {
  const ApproveServicePaymentCard({super.key, required this.agreement});
  final Agreement agreement;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isMilestone = agreement.disbursementType == .milestones;

    final state = ref.watch(releaseFundsViewModelProvider(agreement.id!));

    return EmphasizedActionCard(
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Text(
            isMilestone
                ? l10n.approveMilestoneRelease
                : l10n.confirmServiceCompletion,
            style: context.typo.titleSmall.copyWith(color: context.color.white),
          ),
          Gap(Dimens.spacing.sp4),
          Text(
            isMilestone
                ? l10n.theProviderHasMarkedThisMilestoneAsCompleted
                : l10n.theProviderHasMarkedThisServiceAsCompleteConfirmCompletionToReleaseFunds,
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
              onPressed: () =>
                  ReleaseFundsBottomSheet.show(context, agreement: agreement),
              child: Text(l10n.releaseFunds),
            ),
        ],
      ),
    );
  }
}
