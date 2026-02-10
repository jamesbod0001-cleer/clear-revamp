import 'package:cleer/config/assets.gen.dart';
import 'package:cleer/domain/models/agreement/agreement.dart';
import 'package:cleer/domain/providers/flutterwave/flutterwave_provider.dart';
import 'package:cleer/ui/core/extensions/string_extensions.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:cleer/ui/core/themes/theme.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:cleer/ui/payment_orchestrator/state/payment_orchestrator_state.dart';
import 'package:cleer/ui/payment_orchestrator/view_model/payment_orchestrator_view_model.dart';
import 'package:cleer/ui/payment_orchestrator/widgets/steps/choose_payment_method_step.dart';
import 'package:cleer/ui/payment_orchestrator/widgets/steps/continue_with_opay_step.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class PaymentOrchestratorView extends ConsumerWidget {
  const PaymentOrchestratorView({super.key, required this.agreement});

  final Agreement agreement;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final state = ref.watch(paymentOrchestratorViewModelProvider);
    final viewModel = ref.read(paymentOrchestratorViewModelProvider.notifier);
    ref.watch(flutterwaveSavedPaymentMethodsProvider);

    final currentStep =
        state.value?.currentStep ?? PaymentOrchestratorStep.choosePaymentMethod;
    final bool isFirstStep =
        currentStep == PaymentOrchestratorStep.choosePaymentMethod;

    Widget getCurrentStepWidget() {
      final PaymentOrchestratorStep currentStep = state.value!.currentStep;
      return switch (currentStep) {
        PaymentOrchestratorStep.choosePaymentMethod => ChoosePaymentMethodStep(
          key: ValueKey(currentStep),
        ),
        PaymentOrchestratorStep.continueWithOpay => ContinueWithOpayStep(
          key: ValueKey(currentStep),
        ),
      };
    }

    return PopScope(
      canPop: isFirstStep,
      onPopInvokedWithResult: (didPop, result) {
        // If didPop is true, the screen is already closing.
        if (didPop) return;

        // If didPop is false, we are on Step 2 or 3.
        // Just move the internal state back.
        viewModel.moveStepBack();
      },
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: Dimens.mobile.edgeInsetsScreenHorizontal,
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Gap(Dimens.spacing.sp32),
                    Row(
                      mainAxisAlignment: .spaceBetween,
                      children: [
                        CircleAvatar(
                          backgroundColor: context.color.secondary,
                          radius: Dimens.radius.r40,
                          child: Padding(
                            padding: .fromLTRB(
                              Dimens.padding.p20,
                              Dimens.padding.p16,
                              20.27,
                              Dimens.padding.p16,
                            ),
                            child: Assets.icons.cleerIcon.svg(fit: .fill),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: .end,
                          children: [
                            Row(
                              children: [
                                Text(
                                  l10n.ngn,
                                  style: context.typo.labelSmall.copyWith(
                                    color: context.color.grey600,
                                  ),
                                ),
                                Gap(Dimens.spacing.sp4),
                                Text(
                                  NumberFormat(
                                    '#,###.##',
                                  ).format(agreement.amount),
                                  style: context.typo.titleLarge.copyWith(
                                    color: context.color.grey800,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              agreement.sender!.email?.maskEmail ??
                                  agreement.sender!.phoneNumber,
                              style: context.typo.bodyMedium.copyWith(
                                fontWeight: AppFontWeights.regular,
                                color: context.color.grey800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Gap(Dimens.spacing.sp40),
                    getCurrentStepWidget(),
                    Gap(Dimens.spacing.sp54),
                  ]),
                ),
              ),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: Dimens.mobile.edgeInsetsScreenHorizontal.copyWith(
                    bottom: MediaQuery.of(context).padding.bottom,
                  ),
                  child: Column(
                    mainAxisAlignment: .end,
                    children: [
                      Material(
                        borderRadius: .circular(Dimens.radius.r8),
                        color: context.color.infoLight,
                        child: Padding(
                          padding: .all(Dimens.padding.p8),
                          child: Row(
                            children: [
                              Assets.images.shield.image(
                                width: Dimens.size.s17,
                                height: Dimens.size.s24,
                              ),
                              Gap(Dimens.spacing.sp8),
                              Expanded(
                                child: Text(
                                  l10n.fundsAreHeldSecurelyUntilYouConfirmRelease,
                                  style: context.typo.bodyMedium.copyWith(
                                    color: context.color.blue800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Gap(Dimens.spacing.sp24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
