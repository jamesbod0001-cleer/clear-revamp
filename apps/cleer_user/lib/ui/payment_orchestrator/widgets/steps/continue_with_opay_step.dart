import 'package:cleer/config/assets.gen.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer_ui/themes/dimensions.dart';
import 'package:cleer_ui/themes/theme_utils.dart';
import 'package:cleer_ui/widgets/buttons/primary_button.dart';
import 'package:cleer/ui/payment_orchestrator/view_model/payment_orchestrator_view_model.dart';
import 'package:cleer/ui/payment_orchestrator/widgets/step_header.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ContinueWithOpayStep extends ConsumerWidget {
  const ContinueWithOpayStep({super.key, required this.agreementId});
  final String agreementId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(paymentOrchestratorViewModelProvider(agreementId));
    final viewModel = ref.read(
      paymentOrchestratorViewModelProvider(agreementId).notifier,
    );
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        // If didPop is true, the screen is already closing.
        if (didPop) return;
        viewModel.changePaymentMethod(); // Going back to change payment method
      },
      child: Column(
        children: [
          StepHeader(title: l10n.continueWithOpay),
          Gap(Dimens.spacing.sp84),
          Column(
            mainAxisSize: .min,
            children: [
              Assets.icons.opayLogoWordmark.svg(height: Dimens.size.s32),
              Gap(Dimens.spacing.sp24),
              Text(
                l10n.youllBeRedirectedToAuthorizeThisPayment,
                style: context.typo.bodyLarge.copyWith(
                  color: context.color.grey600,
                ),
                textAlign: .center,
              ),
              Gap(Dimens.spacing.sp24),
              PrimaryButton(
                onPressed: state.isLoading
                    ? null
                    : () => viewModel.continueToOpay(),
                child: Text(l10n.continueWithOpay),
              ),
            ],
          ),
          Gap(Dimens.spacing.sp103),
        ],
      ),
    );
  }
}
