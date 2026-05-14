import 'package:cleer/routing/routes.dart';
import 'package:cleer/ui/agreements/accept_agreement/view_model/accept_agreement_view_model.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer_ui/themes/dimensions.dart';
import 'package:cleer_ui/themes/theme_utils.dart';
import 'package:cleer_ui/widgets/buttons/primary_button.dart';
import 'package:cleer_ui/widgets/status_circle_icon.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SuccessStep extends ConsumerWidget {
  const SuccessStep({super.key, required this.shortCode});
  final String shortCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final state = ref.watch(acceptAgreementViewModelProvider(shortCode));
    // final viewModel = ref.read(
    //   acceptAgreementViewModelProvider(shortCode).notifier,
    // );

    final agreement = state.value!.agreement!;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        // If didPop is true, the screen is already closing.
        if (didPop) return;
        AgreementsRoute().go(context);
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
                  StatusCircleIcon(type: .successOutlined),
                  Gap(Dimens.spacing.sp48),
                  Text(
                    agreement.initiatorRole == .sender
                        ? l10n.paymentSecuredSuccessfully
                        : l10n.agreementWithAccountIsActive(
                            agreement.recipient?.firstName ?? '',
                          ),
                    style: context.typo.headlineSmall,
                    textAlign: .center,
                  ),
                  Gap(Dimens.spacing.sp12),
                  Text(
                    agreement.initiatorRole == .sender
                        ? l10n.thePaymentIsNowHeldSecurelyYouWillReceiveFundsOnceTheAgreedConditionsAreMet
                        : l10n.yourFundsAreSecurelyHeldYouRemainInControlMoneyIsOnlyReleasedWhenYouApprove,
                    style: context.typo.bodyMedium.copyWith(
                      color: context.color.grey600,
                    ),
                    textAlign: .center,
                  ),
                  const Spacer(flex: 231),
                  Gap(Dimens.spacing.sp20),
                  PrimaryButton(
                    onPressed: () {
                      AgreementDetailsRoute(
                        id: agreement.id!,
                        $extra: agreement,
                      ).go(context);
                    },
                    child: Text(l10n.viewAgreement),
                  ),
                  Gap(Dimens.spacing.sp12),
                  TextButton(
                    onPressed: () {
                      HomeRoute().go(context);
                    },
                    child: Text(l10n.goToDashboard),
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
