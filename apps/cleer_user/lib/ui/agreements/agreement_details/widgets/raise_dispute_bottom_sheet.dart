import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer_ui/cleer_ui.dart';
import 'package:cleer_ui/widgets/bottom_sheets/custom_bottom_sheet.dart';
import 'package:cleer_ui/widgets/buttons/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class RaiseDisputeBottomSheet extends StatelessWidget {
  const RaiseDisputeBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return CustomBottomSheet.show(
      context: context,
      child: const RaiseDisputeBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StatusCircleIcon(type: .errorFlag),
        Gap(Dimens.spacing.sp24),
        Text(
          l10n.reportAnIssueWithThisAgreement,
          style: context.typo.headlineSmall,
        ),
        Gap(Dimens.spacing.sp24),
        Text(
          l10n.weWillPauseTheReleaseOfFundsWhileWeReviewWhatHappenedYouWillBeAskedToExplainTheIssueAndUploadAndyPhotosOrEvidenceThatCanHelpUsResolveItFairly,
          style: context.typo.bodyMedium.copyWith(
            fontWeight: AppFontWeights.regular,
            color: context.color.grey600,
          ),
        ),
        Gap(Dimens.spacing.sp24),
        PrimaryButton.error(onPressed: () {}, child: Text(l10n.continueText)),
        Gap(Dimens.spacing.sp12),
        TextButton(
          onPressed: () {
            context.pop();
          },
          child: Text(l10n.cancel),
        ),
        Gap(Dimens.spacing.sp24),
      ],
    );
  }
}
