import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_orchestrator_state.freezed.dart';

enum PaymentOrchestratorStep { choosePaymentMethod, continueWithOpay }

@freezed
abstract class PaymentOrchestratorState with _$PaymentOrchestratorState {
  const factory PaymentOrchestratorState({
    @Default(PaymentOrchestratorStep.choosePaymentMethod)
    PaymentOrchestratorStep currentStep,
  }) = _PaymentOrchestratorState;
}
