import 'package:cleer/ui/agreements/accept_agreement/state/accept_agreement_state.dart';
import 'package:cleer/ui/agreements/accept_agreement/view_model/accept_agreement_view_model.dart';
import 'package:cleer/ui/agreements/accept_agreement/widgets/steps/agreement_details_step.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AcceptAgreementScreen extends ConsumerWidget {
  const AcceptAgreementScreen({super.key, required this.shortCode});

  final String shortCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(acceptAgreementViewModelProvider((shortCode)));
    final viewModel = ref.read(
      acceptAgreementViewModelProvider(shortCode).notifier,
    );

    final currentStep =
        state.value?.currentStep ?? AcceptAgreementStep.agreementDetails;
    // final bool isFirstStep =
    //     currentStep == AcceptAgreementStep.agreementDetails;

    Widget getCurrentStepWidget() {
      return switch (currentStep) {
        AcceptAgreementStep.agreementDetails => AgreementDetailsStep(
          key: ValueKey(currentStep),
          shortCode: shortCode,
        ),
      };
    }

    return Scaffold(
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
    );
  }
}
