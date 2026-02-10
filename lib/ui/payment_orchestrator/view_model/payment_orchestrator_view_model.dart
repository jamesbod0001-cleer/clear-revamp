import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer/domain/models/enums/payment_method_type.dart';
import 'package:cleer/domain/providers/flutterwave/flutterwave_provider.dart';
import 'package:cleer/domain/use_cases/flutterwave/flutterwave_use_case.dart';
import 'package:cleer/domain/use_cases/flutterwave/params/create_payment_method_params.dart';
import 'package:cleer/ui/payment_orchestrator/state/payment_orchestrator_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'payment_orchestrator_view_model.g.dart';

@riverpod
class PaymentOrchestratorViewModel extends _$PaymentOrchestratorViewModel {
  final _log = AmplifyLogger("PaymentOrchestratorViewModel");

  @override
  FutureOr<PaymentOrchestratorState> build() {
    return PaymentOrchestratorState();
  }

  Future<void> payWithOpay() async {
    state = AsyncData(state.value!.copyWith(currentStep: .continueWithOpay));
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final savedMethods =
          ref.read(flutterwaveSavedPaymentMethodsProvider).value ?? [];
      final hasOpay = savedMethods.any((m) => m.type == PaymentMethodType.opay);
      if (hasOpay) {
        return state.value!;
      } else {
        final result = await ref
            .read(flutterwaveUseCaseProvider.notifier)
            .createPaymentMethod(CreatePaymentMethodParams.opay());
        return await result.fold(
          (success) {
            _log.info('Payment method created successfully');
            return state.value!;
          },
          (failure) {
            _log.error('Error creating payment method', failure);
            throw failure;
          },
        );
      }
    });
  }

  void moveToNextStep() {
    final paymentOrchestratorState = state.value;
    if (paymentOrchestratorState == null) return;

    final currentStep = paymentOrchestratorState.currentStep;
    final nextStep = PaymentOrchestratorStep.values[currentStep.index + 1];
    state = AsyncValue.data(
      paymentOrchestratorState.copyWith(currentStep: nextStep),
    );
  }

  void moveStepBack() {
    final paymentOrchestratorState = state.value;
    if (paymentOrchestratorState == null) return;

    final currentStep = paymentOrchestratorState.currentStep;

    if (currentStep != PaymentOrchestratorStep.choosePaymentMethod) {
      if (currentStep == PaymentOrchestratorStep.continueWithOpay) {
        state = AsyncData(
          state.value!.copyWith(currentStep: .choosePaymentMethod),
        );
        return;
      }
      // final previousStep =
      //     PaymentOrchestratorStep.values[currentStep.index - 1];
      // state = AsyncValue.data(
      //   paymentOrchestratorState.copyWith(currentStep: previousStep),
      // );
    }
  }

  void changePaymentMethod() {
    final paymentOrchestratorState = state.value;
    if (paymentOrchestratorState == null) return;
    state = AsyncData(
      paymentOrchestratorState.copyWith(currentStep: .choosePaymentMethod),
    );
  }
}
