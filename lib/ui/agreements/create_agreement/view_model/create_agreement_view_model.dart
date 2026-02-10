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
      formData: CreateAgreementFormData.empty(type),
    );
  }

  Future<void> resolveRecipientDetails() async {
    final currentState = state.value;
    if (currentState == null) return;
    final formData = state.value!.formData;

    if (currentState.isResolvingRecipientDetails ||
        (formData.recipientResolution?.accountNumber ==
                formData.recipientAccountNumber &&
            formData.recipientResolution?.bankCode ==
                formData.recipientBank?.code)) {
      return;
    }

    state = AsyncValue.data(
      state.value!.copyWith(
        isResolvingRecipientDetails: true,
        formData: formData.copyWith(recipientResolution: null),
      ),
    );

    final result = await ref
        .read(agreementUseCaseProvider.notifier)
        .resolveRecipientDetails(
          accountNumber: formData.recipientAccountNumber,
          bankCode: formData.recipientBank!.code,
        );

    state = AsyncValue.data(
      state.value!.copyWith(
        isResolvingRecipientDetails: false,
        formData: state.value!.formData.copyWith(
          recipientResolution: result.getOrNull(),
        ),
      ),
    );
  }

  Future<void> initiateAgreement() async {
    _log.info('Initiating agreement');
    final currentState = state.value;
    if (currentState == null) return;
    final formData = state.value!.formData;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await ref
          .read(agreementUseCaseProvider.notifier)
          .initiateAgreement(formData);

      return await result.fold(
        (agreement) {
          _log.info('Agreement initiated successfully');
          return state.value!.copyWith(
            agreement: agreement,
            currentStep: CreateAgreementStep.payment,
          );
        },
        (failure) {
          _log.error('Error initiating agreement', failure);
          return state.value!.copyWith(agreement: null);
        },
      );
    });
  }

  void onFormChanged(CreateAgreementFormData formData) {
    if (state.hasValue) {
      _log.debug('Create Agreement form changed: $formData');
      if (state.value!.formData.recipientBank?.code !=
              formData.recipientBank?.code ||
          state.value!.formData.recipientAccountNumber !=
              formData.recipientAccountNumber) {
        state = AsyncValue.data(
          state.value!.copyWith(
            formData: formData.copyWith(recipientResolution: null),
          ),
        );
      } else {
        state = AsyncValue.data(state.value!.copyWith(formData: formData));
      }
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
