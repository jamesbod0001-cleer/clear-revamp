import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer/domain/models/agreement/agreement.dart';
import 'package:cleer/domain/models/recipient_resolution/recipient_resolution.dart';
import 'package:cleer/domain/use_cases/agreement/agreement_use_case.dart';
import 'package:cleer/ui/agreements/create_agreement/models/agreement_type.dart';
import 'package:cleer/ui/agreements/create_agreement/state/create_agreement_state.dart';
import 'package:command_it/command_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'create_agreement_view_model.g.dart';

@riverpod
class CreateAgreementViewModel extends _$CreateAgreementViewModel {
  final _log = AmplifyLogger("CreateAgreementViewModel");

  @override
  FutureOr<CreateAgreementState> build(AgreementType type) {
    resolveRecipientDetailsCommand =
        Command.createAsyncNoParam<RecipientResolution?>(
          _resolveRecipientDetails,
          errorFilter: const LocalErrorFilter(),
          initialValue: null,
        );
    return CreateAgreementState(
      type: type,
      formData: CreateAgreementFormData.empty(type),
    );
  }

  late Command<void, RecipientResolution?> resolveRecipientDetailsCommand;

  Future<RecipientResolution?> _resolveRecipientDetails() async {
    // A continuous loop inside the locked command!
    while (true) {
      final currentState = state.value;
      if (currentState == null) return null;
      final formData = currentState.formData;

      // 1. Capture the targets
      final targetAccountNumber = formData.recipientAccountNumber;
      final targetBankCode = formData.recipientBank?.code;

      if (targetBankCode == null || targetAccountNumber.length != 10) {
        return null; // Safety exit
      }

      if (formData.recipientResolution?.accountNumber == targetAccountNumber &&
          formData.recipientResolution?.bankCode == targetBankCode) {
        return formData.recipientResolution;
      }

      // ---------------------------------------------------------
      // THE NEW DEBOUNCE:
      // Wait 500ms BEFORE hitting the API. Because we are already inside
      // the command, the UI is already showing a beautiful loading spinner!
      await Future.delayed(const Duration(milliseconds: 500));

      // Check if the user typed something else while we were waiting
      final postDelayFormData = state.value?.formData;
      if (postDelayFormData?.recipientAccountNumber != targetAccountNumber ||
          postDelayFormData?.recipientBank?.code != targetBankCode) {
        _log.info(
          'Input changed during debounce delay. Looping to catch new input.',
        );
        continue;
      }
      // ---------------------------------------------------------

      // 2. Make the API Call
      final result = await ref
          .read(agreementUseCaseProvider.notifier)
          .resolveRecipientDetails(
            accountNumber: targetAccountNumber,
            bankCode: targetBankCode,
          );

      // 3. THE MAGIC CHECK: Did the user change the text field during the API call?
      final latestFormData = state.value?.formData;
      if (latestFormData?.recipientAccountNumber != targetAccountNumber ||
          latestFormData?.recipientBank?.code != targetBankCode) {
        _log.info('Input changed during API call. Silently looping.');
        continue;
      }

      // 4. It matches! Safely update the state and return to the UI.
      return await result.fold(
        (recipientResolution) {
          state = AsyncValue.data(
            state.value!.copyWith(
              formData: state.value!.formData.copyWith(
                recipientResolution: recipientResolution,
              ),
            ),
          );
          return recipientResolution;
        },
        (failure) {
          state = AsyncValue.data(
            state.value!.copyWith(
              formData: state.value!.formData.copyWith(
                recipientResolution: null,
              ),
            ),
          );
          throw failure;
        },
      );
    }
  }

  // Future<RecipientResolution?> _resolveRecipientDetails() async {
  //   final currentState = state.value;
  //   if (currentState == null) return null;
  //   final formData = state.value!.formData;
  //
  //   if (formData.recipientResolution?.accountNumber ==
  //           formData.recipientAccountNumber &&
  //       formData.recipientResolution?.bankCode ==
  //           formData.recipientBank?.code) {
  //     return formData.recipientResolution;
  //   }
  //
  //   state = AsyncValue.data(
  //     state.value!.copyWith(
  //       formData: formData.copyWith(recipientResolution: null),
  //     ),
  //   );
  //
  //   final result = await ref
  //       .read(agreementUseCaseProvider.notifier)
  //       .resolveRecipientDetails(
  //         accountNumber: formData.recipientAccountNumber,
  //         bankCode: formData.recipientBank!.code,
  //       );
  //
  //   return await result.fold(
  //     (recipientResolution) {
  //       state = AsyncValue.data(
  //         state.value!.copyWith(
  //           formData: state.value!.formData.copyWith(
  //             recipientResolution: recipientResolution,
  //           ),
  //         ),
  //       );
  //       return recipientResolution;
  //     },
  //     (failure) {
  //       state = AsyncValue.data(
  //         state.value!.copyWith(
  //           formData: state.value!.formData.copyWith(recipientResolution: null),
  //         ),
  //       );
  //       throw failure;
  //     },
  //   );
  // }

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
            currentStep: formData.initiatorRole == .sender
                ? CreateAgreementStep.payment
                : CreateAgreementStep.agreementCreated,
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

  void updateAgreement(Agreement agreement) {
    if (state.value == null) return;
    state = AsyncValue.data(state.value!.copyWith(agreement: agreement));
  }

  void goTo(CreateAgreementStep step) {
    final createAgreementState = state.value;
    if (createAgreementState == null) return;

    state = AsyncValue.data(state.value!.copyWith(currentStep: step));
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
