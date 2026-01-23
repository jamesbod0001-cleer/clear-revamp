import 'package:cleer/ui/agreements/create_agreement/models/agreement_type.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_agreement_state.freezed.dart';

enum CreateAgreementStep {
  setup, // Maps to AgreementSetupStep
  additionalDetails, // Maps to AdditionalDetailsStep
  review, // Maps to AgreementReviewStep
}

@freezed
abstract class CreateAgreementState with _$CreateAgreementState {
  const factory CreateAgreementState({
    @Default(AgreementType.send) AgreementType type,
    @Default(CreateAgreementStep.setup) CreateAgreementStep currentStep,
    required CreateAgreementFormData formData,
  }) = _CreateAgreementState;
}

@freezed
abstract class CreateAgreementFormData with _$CreateAgreementFormData {
  const factory CreateAgreementFormData({
    @Default('') String amount,
    @Default('') String recipientBankName,
    @Default('') String recipientAccountNumber,
    @Default('') String recipientAccountName,
    @Default('') String category,
    @Default('') String description,
  }) = _CreateAgreementFormData;

  factory CreateAgreementFormData.empty() => const CreateAgreementFormData();
}
