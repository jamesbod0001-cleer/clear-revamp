import 'package:cleer/ui/agreements/create_agreement/models/agreement_type.dart';
import 'package:cleer/ui/agreements/create_agreement/state/create_agreement_state.dart';
import 'package:cleer/ui/agreements/create_agreement/view_model/create_agreement_view_model.dart';
import 'package:cleer/ui/agreements/create_agreement/widgets/steps/agreement_setup_step.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:cleer/ui/core/ui/buttons/app_back_button.dart';
import 'package:cleer/ui/core/ui/step_progress_indicator.dart';
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
        CreateAgreementStep.additionalDetails => Placeholder(
          key: ValueKey(currentStep),
        ),
        CreateAgreementStep.review => Placeholder(key: ValueKey(currentStep)),
      };
    }

    void handleBack() {
      if (isFirstStep) {
        context.pop();
      } else {
        viewModel.moveStepBack();
      }
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
          child: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    child: Padding(
                      padding: Dimens.mobile.edgeInsetsScreenHorizontal,
                      child: Column(
                        crossAxisAlignment: .start,
                        children: [
                          Gap(Dimens.spacing.sp16),
                          Row(
                            mainAxisAlignment: .spaceBetween,
                            children: [
                              AppBackButton(onPressed: () => handleBack()),
                              StepProgressIndicator(),
                            ],
                          ),
                          Gap(Dimens.spacing.sp24),
                          Text(
                            type.isSend ? l10n.sendFunds : l10n.requestFunds,
                            style: context.typo.headlineSmall,
                          ),
                          Gap(Dimens.spacing.sp24),
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 150),
                              child: getCurrentStepWidget(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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
