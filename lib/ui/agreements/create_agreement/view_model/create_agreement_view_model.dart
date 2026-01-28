import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer/domain/use_cases/agreement/agreement_use_case.dart';
import 'package:cleer/ui/agreements/create_agreement/models/agreement_type.dart';
import 'package:cleer/ui/agreements/create_agreement/state/create_agreement_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'create_agreement_view_model.g.dart';

@riverpod
class CreateAgreementViewModel extends _$CreateAgreementViewModel {
  final _log = AmplifyLogger("CreateAgreementViewModel");

  @override
  FutureOr<CreateAgreementState> build(AgreementType type) {
    return CreateAgreementState(
      type: type,
      formData: CreateAgreementFormData.empty(),
    );
  }

  Future<void> resolveRecipientDetails() async {
    final currentState = state.value;
    if (currentState == null) return;
    final formData = state.value!.formData;

    if (currentState.isResolvingRecipientDetails ||
        (currentState.recipientResolution?.accountNumber ==
                formData.recipientAccountNumber &&
            currentState.recipientResolution?.bankCode ==
                formData.recipientBank?.code)) {
      return;
    }

    final agreementUseCase = ref.read(agreementUseCaseProvider.notifier);

    state = AsyncValue.data(
      state.value!.copyWith(
        isResolvingRecipientDetails: true,
        recipientResolution: null,
      ),
    );

    final result = await agreementUseCase.resolveRecipientDetails(
      accountNumber: formData.recipientAccountNumber,
      bankCode: formData.recipientBank!.code,
    );

    state = AsyncValue.data(
      state.value!.copyWith(
        isResolvingRecipientDetails: false,
        recipientResolution: result.getOrNull(),
      ),
    );
  }

  void onFormChanged(CreateAgreementFormData formData) {
    if (state.hasValue) {
      _log.debug('Create Agreement form changed: $formData');
      if (state.value!.formData.recipientBank?.code !=
              formData.recipientBank?.code ||
          state.value!.formData.recipientAccountNumber !=
              formData.recipientAccountNumber) {
        state = AsyncValue.data(
          state.value!.copyWith(recipientResolution: null),
        );
      }
      state = AsyncValue.data(state.value!.copyWith(formData: formData));
    }
  }

  void moveToNextStep() {
    final createAgreementState = state.value;
    if (createAgreementState == null) return;

    final currentStep = createAgreementState.currentStep;
    final nextStep = CreateAgreementStep.values[currentStep.index + 1];
    state = AsyncValue.data(
      createAgreementState.copyWith(currentStep: nextStep),
    );
  }

  void moveStepBack() {
    final createAgreementState = state.value;
    if (createAgreementState == null) return;

    final currentStep = createAgreementState.currentStep;

    if (currentStep != CreateAgreementStep.setup) {
      final previousStep = CreateAgreementStep.values[currentStep.index - 1];
      state = AsyncValue.data(
        createAgreementState.copyWith(currentStep: previousStep),
      );
    }
  }
}
