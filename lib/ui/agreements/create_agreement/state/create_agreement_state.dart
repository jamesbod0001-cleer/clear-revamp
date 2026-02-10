import 'package:cleer/domain/models/agreement/agreement.dart';
import 'package:cleer/domain/models/agreement/agreement_enums.dart';
import 'package:cleer/domain/models/bank/bank.dart';
import 'package:cleer/domain/models/recipient_resolution/recipient_resolution.dart';
import 'package:cleer/ui/agreements/create_agreement/models/agreement_type.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_agreement_state.freezed.dart';

enum CreateAgreementStep {
  setup, // Maps to AgreementSetupStep
  additionalDetails, // Maps to AdditionalDetailsStep
  review, // Maps to AgreementReviewStep
  payment,
}

@freezed
abstract class CreateAgreementState with _$CreateAgreementState {
  const factory CreateAgreementState({
    @Default(AgreementType.send) AgreementType type,
    @Default(CreateAgreementStep.setup) CreateAgreementStep currentStep,
    required CreateAgreementFormData formData,
    @Default(false) bool isResolvingRecipientDetails,
    Agreement? agreement,
  }) = _CreateAgreementState;
}

@freezed
abstract class CreateAgreementFormData with _$CreateAgreementFormData {
  const factory CreateAgreementFormData({
    required InitiatorRole initiatorRole,
    @Default('') String amount,
    Bank? recipientBank,
    @Default('') String recipientAccountNumber,
    RecipientResolution? recipientResolution,
    DisbursementType? disbursementType,
    AgreementCategory? category,
    DateTime? releaseDate,
    @Default('') String description,
  }) = _CreateAgreementFormData;

  factory CreateAgreementFormData.empty(AgreementType type) =>
      CreateAgreementFormData(initiatorRole: type.initiatorRole);
}
