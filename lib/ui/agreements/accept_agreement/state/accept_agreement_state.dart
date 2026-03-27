import 'package:cleer/domain/models/agreement/agreement_preview.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'accept_agreement_state.freezed.dart';

enum AcceptAgreementStep {
  agreementDetails, // Maps to AgreementDetailsStep
}

@freezed
abstract class AcceptAgreementState with _$AcceptAgreementState {
  const factory AcceptAgreementState({
    @Default(AcceptAgreementStep.agreementDetails) AcceptAgreementStep currentStep,
    required AgreementPreview agreementPreview,
  }) = _AcceptAgreementState;
}
