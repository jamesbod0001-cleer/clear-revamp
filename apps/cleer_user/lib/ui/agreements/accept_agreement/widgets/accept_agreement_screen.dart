import 'package:cleer/routing/routes.dart';
import 'package:cleer/ui/agreements/accept_agreement/state/accept_agreement_state.dart';
import 'package:cleer/ui/agreements/accept_agreement/view_model/accept_agreement_view_model.dart';
import 'package:cleer/ui/agreements/accept_agreement/widgets/steps/agreement_details_step.dart';
import 'package:cleer/ui/agreements/accept_agreement/widgets/steps/success_step.dart';
import 'package:cleer/ui/payment_orchestrator/widgets/payment_orchestrator_view.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AcceptAgreementScreen extends ConsumerWidget {
  const AcceptAgreementScreen({
    super.key,
    required this.shortCode,
    this.action,
  });

  final String shortCode;
  final String? action;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(acceptAgreementViewModelProvider((shortCode)));

    ref.listen(acceptAgreementViewModelProvider((shortCode)), (previous, next) {
      if (previous?.value?.agreement?.status != next.value?.agreement?.status) {
        if (next.value?.agreement?.status == .rejected) {
          HomeRoute().go(context);
        }
      }
    });

    final currentStep =
        state.value?.currentStep ?? AcceptAgreementStep.agreementDetails;

    Widget getCurrentStepWidget() {
      return switch (currentStep) {
        AcceptAgreementStep.agreementDetails => AgreementDetailsStep(
          key: ValueKey(currentStep),
          shortCode: shortCode,
          action: action,
        ),
        AcceptAgreementStep.payment => PaymentOrchestratorView(
          key: ValueKey(currentStep),
          agreement: state.value!.agreement!,
        ),
        AcceptAgreementStep.success => SuccessStep(
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
