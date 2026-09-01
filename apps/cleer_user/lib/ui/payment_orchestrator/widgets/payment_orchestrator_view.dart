import 'package:cleer/config/assets.gen.dart';
import 'package:cleer_ui/generated/assets.gen.dart' as ui_assets;
import 'package:cleer_core/models/agreement/agreement.dart';
import 'package:cleer_core/models/charge/charge.dart';
import 'package:cleer/routing/routes.dart';
import 'package:cleer/ui/agreements/accept_agreement/view_model/accept_agreement_view_model.dart';
import 'package:cleer/ui/agreements/create_agreement/view_model/create_agreement_view_model.dart';
import 'package:cleer/ui/core/extensions/string_extensions.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer_ui/themes/dimensions.dart';
import 'package:cleer_ui/themes/theme.dart';
import 'package:cleer_ui/themes/theme_utils.dart';
import 'package:cleer_ui/widgets/buttons/primary_button.dart';
import 'package:cleer/ui/payment_orchestrator/state/payment_orchestrator_state.dart';
import 'package:cleer/ui/payment_orchestrator/view_model/payment_orchestrator_view_model.dart';
import 'package:cleer/ui/payment_orchestrator/widgets/buttons.dart';
import 'package:cleer/ui/payment_orchestrator/widgets/agreement_rejection_bottom_sheet.dart';
import 'package:cleer/ui/payment_orchestrator/widgets/steps/choose_payment_method_step.dart';
import 'package:cleer/ui/payment_orchestrator/widgets/steps/continue_with_opay_step.dart';
import 'package:cleer/ui/payment_orchestrator/widgets/steps/enter_card_details_step.dart';
import 'package:cleer/ui/payment_orchestrator/widgets/steps/loading_step.dart';
import 'package:cleer/ui/payment_orchestrator/widgets/steps/authorizing_web_view.dart';
import 'package:cleer/ui/payment_orchestrator/widgets/steps/pay_with_bank_transfer_step.dart';
import 'package:cleer/ui/payment_orchestrator/widgets/steps/pay_with_ussd_step.dart';
import 'package:cleer/ui/payment_orchestrator/widgets/steps/payment_not_secured_step.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class PaymentOrchestratorView extends ConsumerWidget {
  const PaymentOrchestratorView({super.key, required this.agreement});

  final Agreement agreement;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(paymentOrchestratorViewModelProvider(agreement.id!), (
      previous,
      next,
    ) {
      if (previous?.value?.agreement.status != next.value?.agreement.status) {
        if (next.value?.agreement.status == .cancelled ||
            next.value?.agreement.status == .rejected) {
          /// TODO: It might not go home if the user is on the web
          HomeRoute().go(context);
        }
        if (next.value?.agreement.initiatorRole == .sender &&
            next.value?.agreement.status == .awaitingRecipient) {
          ref
              .read(createAgreementViewModelProvider(.send).notifier)
              .updateAgreement(next.value!.agreement);
          ref
              .read(createAgreementViewModelProvider(.send).notifier)
              .goTo(.fundsSecured);
        } else if (next.value?.agreement.initiatorRole == .recipient &&
            next.value?.agreement.status == .inProgress) {
          final shortCode = next.value!.agreement.shortCode;
          ref
              .read(acceptAgreementViewModelProvider(shortCode).notifier)
              .goToSuccessStep(next.value!.agreement);
        }
      }
    });
    final state = ref.watch(
      paymentOrchestratorViewModelProvider(agreement.id!),
    );
    final currentStep =
        state.value?.currentStep ?? PaymentOrchestratorStep.choosePaymentMethod;

    if (currentStep == PaymentOrchestratorStep.authorizing) {
      return AuthorizingWebView(
        key: const ValueKey('authorizing'),
        agreementId: agreement.id!,
        url:
            state.value!.ongoingCharge!.action.mapOrNull(
              redirect: (r) => r.url,
            ) ??
            '',
      );
    }

    if (state.isLoading &&
        currentStep == PaymentOrchestratorStep.paymentNotSecured) {
      return PopScope(
        canPop: false,
        child: Material(
          color: context.color.background,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            _OrchestratorHeader(agreement: agreement),

            SliverPadding(
              padding: Dimens.mobile.edgeInsetsScreenHorizontal.copyWith(
                bottom: Dimens.spacing.sp54,
              ),
              sliver: SliverToBoxAdapter(
                child: _StepSwitcher(
                  step: currentStep,
                  agreementId: agreement.id!,
                ),
              ),
            ),

            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: Dimens.mobile.edgeInsetsScreenHorizontal.copyWith(
                  bottom:
                      MediaQuery.of(context).padding.bottom +
                      Dimens.padding.p20,
                ),
                child: _OrchestratorFooter(
                  step: currentStep,
                  agreementId: agreement.id!,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrchestratorHeader extends StatelessWidget {
  const _OrchestratorHeader({required this.agreement});
  final Agreement agreement;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SliverToBoxAdapter(
      child: Padding(
        padding: Dimens.mobile.edgeInsetsScreenHorizontal,
        child: Column(
          children: [
            Gap(Dimens.spacing.sp32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    child: Assets.icons.cleerIcon.svg(fit: BoxFit.fill),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
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
                          NumberFormat('#,###.##').format(agreement.amount),
                          style: context.typo.titleLarge.copyWith(
                            color: context.color.grey800,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      agreement.sender?.email?.maskEmail ??
                          agreement.sender?.phoneNumber ??
                          '',
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
          ],
        ),
      ),
    );
  }
}

class _StepSwitcher extends StatelessWidget {
  const _StepSwitcher({required this.step, required this.agreementId});
  final PaymentOrchestratorStep step;
  final String agreementId;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 100),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      child: switch (step) {
        PaymentOrchestratorStep.choosePaymentMethod => ChoosePaymentMethodStep(
          key: const ValueKey('choose'),
          agreementId: agreementId,
        ),
        PaymentOrchestratorStep.continueWithOpay => ContinueWithOpayStep(
          key: const ValueKey('opay'),
          agreementId: agreementId,
        ),
        PaymentOrchestratorStep.payWithBankTransfer => PayWithBankTransferStep(
          key: const ValueKey('payWithBankTransfer'),
          agreementId: agreementId,
        ),
        PaymentOrchestratorStep.payWithUSSD => PayWithUSSDStep(
          key: const ValueKey('ussd'),
          agreementId: agreementId,
        ),
        PaymentOrchestratorStep.enterCardDetails => EnterCardDetailsStep(
          key: const ValueKey('card'),
          agreementId: agreementId,
        ),
        // Note: Authorizing is handled at the top level to fill the screen
        PaymentOrchestratorStep.redirecting => LoadingStep(
          key: const ValueKey('redirecting'),
          title: l10n.redirecting,
          loadingMessage: l10n.pleaseDontCloseThisScreenWeAreRedirectingYou,
        ),
        PaymentOrchestratorStep.securingYourPayment => LoadingStep(
          key: const ValueKey('securing'),
          title: l10n.securingYourPayment,
          loadingMessage:
              l10n.pleaseDontCloseThisScreenWeAreSafelyLockingYourFunds,
        ),
        PaymentOrchestratorStep.waitingForConfirmation => LoadingStep(
          key: const ValueKey('waiting'),
          title: l10n.waitingForConfirmation,
          loadingMessage:
              l10n.weWillUpdateThisScreenOnceYourBankConfirmsThePayment,
        ),
        PaymentOrchestratorStep.paymentNotSecured => PaymentNotSecuredStep(
          key: const ValueKey('failed'),
          agreementId: agreementId,
        ),
        _ => const SizedBox.shrink(),
      },
    );
  }
}

class _OrchestratorFooter extends ConsumerWidget {
  const _OrchestratorFooter({required this.step, required this.agreementId});
  final PaymentOrchestratorStep step;
  final String agreementId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final state = ref.watch(paymentOrchestratorViewModelProvider(agreementId));
    final viewModel = ref.read(
      paymentOrchestratorViewModelProvider(agreementId).notifier,
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (step == PaymentOrchestratorStep.paymentNotSecured) ...[
          Text(
            l10n.ifAnyAmountWasDebitedItWillBeAutomaticallyReversedByYourBank,
            textAlign: .center,
            style: context.typo.bodyMedium.copyWith(
              color: context.color.grey600,
            ),
          ),
          Gap(Dimens.spacing.sp32),
          PrimaryButton(
            onPressed: () => viewModel.retryPayment(),
            child: Text(l10n.retryPayment),
          ),
          Gap(Dimens.spacing.sp12),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: context.color.error),
            onPressed: () => viewModel.handleRejectionFromPaymentFlow(),
            child: Text(l10n.cancelAgreement),
          ),
        ] else ...[
          if (!(step == PaymentOrchestratorStep.choosePaymentMethod ||
              step == .securingYourPayment ||
              step == .waitingForConfirmation ||
              step == .redirecting)) ...[
            Column(
              mainAxisSize: .min,
              children: [
                ChangePaymentMethodButton(
                  onPressed: () => viewModel.changePaymentMethod(),
                ),
                Gap(Dimens.spacing.sp16),
                CancelPaymentButton(
                  onPressed: () => AgreementRejectionBottomSheet.show(
                    context,
                    agreement: state.value!.agreement,
                    onConfirm: () => viewModel.handleRejectionFromPaymentFlow(),
                  ),
                ),
              ],
            ),
            Gap(Dimens.spacing.sp54),
          ],
          Material(
            borderRadius: BorderRadius.circular(Dimens.radius.r8),
            color: context.color.infoLight,
            child: Padding(
              padding: EdgeInsets.all(Dimens.padding.p12),
              child: Row(
                children: [
                  ui_assets.Assets.images.shield.image(width: Dimens.size.s17),
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
        ],
      ],
    );
  }
}
