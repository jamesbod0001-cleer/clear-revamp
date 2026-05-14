import 'package:cleer_core/models/agreement/agreement.dart';
import 'package:cleer_core/models/agreement/agreement_enums.dart';
import 'package:cleer_core/models/bank/bank.dart';
import 'package:cleer_core/models/payout_destination/payout_destination.dart';
import 'package:cleer_core/models/recipient_resolution/recipient_resolution.dart';
import 'package:cleer/ui/agreements/create_agreement/models/agreement_type.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_agreement_state.freezed.dart';

enum CreateAgreementStep {
  setup, // Maps to AgreementSetupStep
  additionalDetails, // Maps to AdditionalDetailsStep
  review, // Maps to AgreementReviewStep
  payment,
  fundsSecured,
  agreementCreated, // For request payment type
}

@freezed
abstract class CreateAgreementState with _$CreateAgreementState {
  const factory CreateAgreementState({
    @Default(AgreementType.send) AgreementType type,
    @Default(CreateAgreementStep.setup) CreateAgreementStep currentStep,
    required CreateAgreementFormData formData,
    Agreement? agreement,
  }) = _CreateAgreementState;
}

@freezed
abstract class CreateAgreementFormData with _$CreateAgreementFormData {
  const factory CreateAgreementFormData({
    required InitiatorRole initiatorRole,
    @Default('') String amount,

    // For when initiator is sender
    Bank? recipientBank,
    @Default('') String recipientAccountNumber,
    RecipientResolution? recipientResolution,

    // For when initiator is recipient
    PayoutDestination? payoutDestination,

    DisbursementType? disbursementType,
    List<MilestoneDraft>? milestones,
    AgreementCategory? category,
    DateTime? releaseDate,
    @Default('') String description,
  }) = _CreateAgreementFormData;

  factory CreateAgreementFormData.empty(AgreementType type) =>
      CreateAgreementFormData(initiatorRole: type.initiatorRole);
}

@freezed
abstract class MilestoneDraft with _$MilestoneDraft {
  const factory MilestoneDraft({
    required String id,
    @Default('') String name,
    @Default(0.0) double amount,
    DateTime? releaseDate,
  }) = _MilestoneDraft;
}
