import 'package:amplify_flutter/amplify_flutter.dart';
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
