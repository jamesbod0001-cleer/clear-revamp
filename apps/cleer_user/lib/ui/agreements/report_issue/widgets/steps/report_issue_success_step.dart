import 'package:cleer/domain/providers/agreement/agreement_provider.dart';
import 'package:cleer/routing/routes.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer_ui/cleer_ui.dart';
import 'package:cleer_ui/widgets/buttons/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ReportIssueSuccessStep extends ConsumerWidget {
  const ReportIssueSuccessStep({super.key, required this.agreementId});

  final String agreementId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final agreementState = ref.watch(agreementDetailsProvider(agreementId));
    final agreement = agreementState.value;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (agreement != null) {
          AgreementDetailsRoute(
            id: agreement.id!,
            $extra: agreement,
          ).go(context);
        } else {
          AgreementDetailsRoute(id: agreementId).go(context);
        }
      },
      child: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: Dimens.mobile.edgeInsetsScreenHorizontal.copyWith(
                bottom: MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                children: [
                  const Spacer(flex: 148),
                  Gap(Dimens.spacing.sp48),
                  StatusCircleIcon(type: .successSecondary),
                  Gap(Dimens.spacing.sp48),
                  Text(
                    l10n.yourReportHasBeenSubmitted,
                    style: context.typo.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  Gap(Dimens.spacing.sp12),
                  Text(
                    l10n.weHaveReceivedYourSubmissionAndTemporarilySecuredTheFundsWhileWeReviewTheDispute,
                    style: context.typo.bodyMedium.copyWith(
                      color: context.color.grey600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(flex: 231),
                  Gap(Dimens.spacing.sp20),
                  PrimaryButton(
                    onPressed: () {
                      if (agreement != null) {
                        AgreementDetailsRoute(
                          id: agreement.id!,
                          $extra: agreement,
                        ).go(context);
                      } else {
                        AgreementDetailsRoute(id: agreementId).go(context);
                      }
                    },
                    child: Text(l10n.viewAgreement),
                  ),
                  Gap(Dimens.spacing.sp20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
