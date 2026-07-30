import 'package:cleer/domain/providers/flutterwave/flutterwave_provider.dart';
import 'package:cleer/domain/providers/payout_destination/payout_destination_provider.dart';
import 'package:cleer/domain/providers/user/user_provider.dart';
import 'package:cleer/ui/agreements/create_agreement/models/agreement_type.dart';
import 'package:cleer/ui/agreements/create_agreement/state/create_agreement_state.dart';
import 'package:cleer/ui/agreements/create_agreement/view_model/create_agreement_view_model.dart';
import 'package:cleer/ui/agreements/create_agreement/widgets/steps/additional_details_step.dart';
import 'package:cleer/ui/agreements/create_agreement/widgets/steps/agreement_created_step.dart';
import 'package:cleer/ui/agreements/create_agreement/widgets/steps/agreement_review_step.dart';
import 'package:cleer/ui/agreements/create_agreement/widgets/steps/agreement_setup_step.dart';
import 'package:cleer/ui/agreements/create_agreement/widgets/steps/funds_secured_step.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/widgets/app_offline_banner_wrapper.dart';
import 'package:cleer/ui/core/widgets/user_profile_pill.dart';
import 'package:cleer_ui/cleer_ui.dart';
import 'package:cleer_ui/widgets/buttons/app_back_button.dart';
import 'package:cleer_ui/widgets/step_progress_indicator.dart';
import 'package:cleer/ui/payment_orchestrator/widgets/payment_orchestrator_view.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CreateAgreementScreen extends ConsumerWidget {
  const CreateAgreementScreen({super.key, required this.type});

  final AgreementType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final user = ref.watch(userProfileProvider).value;
    ref.watch(getBanksProvider(.NG));
    ref.watch(userPayoutDestinationsProvider);
    final state = ref.watch(createAgreementViewModelProvider(type));
    final viewModel = ref.read(createAgreementViewModelProvider(type).notifier);

    final currentStep = state.value?.currentStep ?? CreateAgreementStep.setup;
    final bool isFirstStep = currentStep == CreateAgreementStep.setup;

    Widget getCurrentStepWidget() {
      final CreateAgreementStep currentStep = state.value!.currentStep;
      return switch (currentStep) {
        CreateAgreementStep.setup => AgreementSetupStep(
          key: ValueKey(currentStep),
          type: type,
        ),
        CreateAgreementStep.additionalDetails => AdditionalDetailsStep(
          key: ValueKey(currentStep),
          type: type,
        ),
        CreateAgreementStep.review => AgreementReviewStep(
          key: ValueKey(currentStep),
          type: type,
        ),
        CreateAgreementStep.payment => PaymentOrchestratorView(
          key: ValueKey(currentStep),
          agreement: state.value!.agreement!,
        ),
        CreateAgreementStep.fundsSecured => FundsSecuredStep(
          key: ValueKey(currentStep),
          type: type,
        ),
        CreateAgreementStep.agreementCreated => AgreementCreatedStep(
          key: ValueKey(currentStep),
          type: type,
        ),
      };
    }

    void handleBack() {
      if (isFirstStep) {
        context.pop();
      } else {
        viewModel.moveStepBack();
      }
    }

    return AppOfflineBannerWrapper(
      child: Scaffold(
      backgroundColor: currentStep == .agreementCreated
          ? context.color.green900
          : null,
      appBar:
          state.isLoading ||
              currentStep == .payment ||
              currentStep == .fundsSecured ||
              currentStep == .agreementCreated
          ? null
          : AppBar(
              titleSpacing: context.isMobile
                  ? Dimens.of(context).paddingScreenHorizontal
                  : Dimens.size.s0,
              titleTextStyle: context.typo.headlineSmall,
              automaticallyImplyLeading: false,
              title: context.isMobile
                  ? Column(
                      crossAxisAlignment: .start,
                      children: [
                        Gap(Dimens.spacing.sp4),
                        Row(
                          mainAxisAlignment: .spaceBetween,
                          children: [
                            AppBackButton(onPressed: () => handleBack()),
                            StepProgressIndicator(
                              currentStep: state.value!.currentStep.index + 1,
                            ),
                          ],
                        ),
                        Gap(Dimens.spacing.sp24),
                        Text(
                          type.isSend
                              ? (currentStep == .review
                                    ? l10n.reviewDetails
                                    : l10n.sendFunds)
                              : l10n.requestFunds,
                          style: context.typo.headlineSmall,
                        ),
                      ],
                    )
                  : Container(
                      width: double.infinity,
                      height: Dimens.size.s72,
                      padding: Dimens.of(context).edgeInsetsScreenHorizontal,
                      alignment: .centerLeft,
                      decoration: BoxDecoration(
                        border: .all(color: context.color.outline),
                      ),
                      child: Row(
                        mainAxisAlignment: .spaceBetween,
                        children: [
                          Text(l10n.agreements),
                          UserProfilePill(
                            profile: user,
                            // onTap: () => ProfileRoute().go(context),
                          ),
                        ],
                      ),
                    ),
              toolbarHeight: context.isMobile ? 110 : Dimens.size.s72,
            ),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            getCurrentStepWidget(),
            if (state.isLoading)
              Positioned.fill(
                child: Material(
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
}
