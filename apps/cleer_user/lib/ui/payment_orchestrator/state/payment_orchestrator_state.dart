import 'package:cleer_core/models/agreement/agreement.dart';
import 'package:cleer_core/models/bank/bank.dart';
import 'package:cleer_core/models/charge/charge.dart';
import 'package:cleer_core/models/virtual_account/virtual_account.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_orchestrator_state.freezed.dart';

enum PaymentOrchestratorStep {
  choosePaymentMethod,
  continueWithOpay,
  payWithUSSD,
  payWithBankTransfer,
  enterCardDetails,
  enterCardPin,
  enterCardOtp,
  waitingForConfirmation,
  securingYourPayment,
  redirecting,
  authorizing,
  // paymentSecuredSuccessfully,
  paymentNotSecured,
}

@freezed
abstract class PaymentOrchestratorState with _$PaymentOrchestratorState {
  const factory PaymentOrchestratorState({
    @Default(PaymentOrchestratorStep.choosePaymentMethod)
    PaymentOrchestratorStep currentStep,
    required Agreement agreement,
    Charge? ongoingCharge,
    VirtualAccount? ongoingVirtualAccount,
    Bank? selectedUSSDBank,
  }) = _PaymentOrchestratorState;
}
