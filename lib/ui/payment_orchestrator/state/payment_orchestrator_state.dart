import 'package:cleer/domain/models/agreement/agreement.dart';
import 'package:cleer/domain/models/charge/charge.dart';
import 'package:cleer/domain/models/virtual_account/virtual_account.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_orchestrator_state.freezed.dart';

enum PaymentOrchestratorStep {
  choosePaymentMethod,
  continueWithOpay,
  payWithUSSD,
  payWithBankTransfer,
  enterCardDetails,
  waitingForConfirmation,
  securingYourPayment,
  redirecting,
  authorizing,
  paymentSecuredSuccessfully,
}

@freezed
abstract class PaymentOrchestratorState with _$PaymentOrchestratorState {
  const factory PaymentOrchestratorState({
    @Default(PaymentOrchestratorStep.choosePaymentMethod)
    PaymentOrchestratorStep currentStep,
    required Agreement agreement,
    Charge? ongoingCharge,
    VirtualAccount? ongoingVirtualAccount,
  }) = _PaymentOrchestratorState;
}
