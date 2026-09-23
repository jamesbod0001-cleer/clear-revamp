import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer_api/src/models/ModelProvider.dart' as amplify_model;
import 'package:cleer_api/src/mappers/milestone_preview_mappers.dart';
import 'package:cleer_api/src/mappers/user_preview_mappers.dart';
import 'package:cleer_core/models/agreement/agreement_preview.dart' as domain;
import 'package:cleer_core/models/agreement/agreement_enums.dart';
import 'package:intl/intl.dart';

/// Extensions on the Amplify AgreementPreview custom type to convert it to the Domain Task entity.
extension AgreementPreviewToDomainMapper on amplify_model.AgreementPreview {
  domain.AgreementPreview toDomain() {
    return domain.AgreementPreview(
      shortCode: shortCode,
      amount: amount,
      currency: currency,
      disbursementType: _mapDisbursementTypeToDomain(disbursementType!),
      category: AgreementCategory.fromId(category),
      expectedReleaseDate: expectedReleaseDate?.getDateTime(),
      description: description,
      initiatorRole: _mapInitiatorRoleToDomain(initiatorRole!),
      status: _mapAgreementStatusToDomain(status!),
      recipientBankName: recipientBankName,
      recipientAccountName: recipientAccountName,
      recipientAccountNumber: recipientAccountNumber,
      milestones: milestones?.map((milestone) => milestone.toDomain()).toList(),
      initiator: initiator?.toDomain(),
      sender: sender?.toDomain(),
      recipient: recipient?.toDomain(),
    );
  }
}

/// Extensions on the Domain AgreementPreview entity to convert it back to the Amplify custom type for mutations.
extension AgreementPreviewToAmplifyMapper on domain.AgreementPreview {
  amplify_model.AgreementPreview toAmplify() {
    return amplify_model.AgreementPreview(
      shortCode: shortCode,
      amount: amount,
      currency: currency,
      disbursementType: _mapDisbursementTypeToAmplify(disbursementType).name,
      category: category.id,
      expectedReleaseDate: expectedReleaseDate != null
          ? TemporalDate.fromString(
              DateFormat('yyyy-MM-dd').format(expectedReleaseDate!),
            )
          : null,
      description: description,
      initiatorRole: _mapInitiatorRoleToAmplify(initiatorRole).name,
      status: _mapAgreementStatusToAmplify(status).name,
      recipientBankName: recipientBankName,
      recipientAccountName: recipientAccountName,
      recipientAccountNumber: recipientAccountNumber,
      milestones: milestones
          ?.map((milestone) => milestone.toAmplify())
          .toList(),
      initiator: initiator?.toAmplify(),
      sender: sender?.toAmplify(),
      recipient: recipient?.toAmplify(),
    );
  }
}

DisbursementType _mapDisbursementTypeToDomain(String p) {
  switch (p) {
    case 'ONE_TIME':
      return DisbursementType.oneTime;
    case 'MILESTONES':
      return DisbursementType.milestones;
    default:
      throw ArgumentError('Unknown DisbursementType: $p');
  }
}

amplify_model.AgreementDisbursementType _mapDisbursementTypeToAmplify(
  DisbursementType p,
) {
  switch (p) {
    case DisbursementType.oneTime:
      return amplify_model.AgreementDisbursementType.ONE_TIME;
    case DisbursementType.milestones:
      return amplify_model.AgreementDisbursementType.MILESTONES;
  }
}

InitiatorRole _mapInitiatorRoleToDomain(String p) {
  switch (p) {
    case 'SENDER':
      return InitiatorRole.sender;
    case 'RECIPIENT':
      return InitiatorRole.recipient;
    default:
      throw ArgumentError('Unknown InitiatorRole: $p');
  }
}

amplify_model.AgreementInitiatorRole _mapInitiatorRoleToAmplify(
  InitiatorRole p,
) {
  switch (p) {
    case InitiatorRole.sender:
      return amplify_model.AgreementInitiatorRole.SENDER;
    case InitiatorRole.recipient:
      return amplify_model.AgreementInitiatorRole.RECIPIENT;
  }
}

AgreementStatus _mapAgreementStatusToDomain(String p) {
  switch (p) {
    // case 'DRAFT':
    //   return AgreementStatus.draft;
    case 'AWAITING_RECIPIENT':
      return AgreementStatus.awaitingRecipient;
    case 'AWAITING_FUNDING':
      return AgreementStatus.awaitingFunding;
    // case 'FUNDED':
    //   return AgreementStatus.funded;
    // case 'IN_PROGRESS':
    //   return AgreementStatus.inProgress;
    // case 'CANCELLED':
    //   return AgreementStatus.cancelled;
    // case 'RELEASED':
    //   return AgreementStatus.released;
    default:
      throw ArgumentError('Unknown AgreementStatus (within preview): $p');
  }
}

amplify_model.AgreementStatus _mapAgreementStatusToAmplify(AgreementStatus p) {
  switch (p) {
    case AgreementStatus.draft:
      return amplify_model.AgreementStatus.DRAFT;
    case AgreementStatus.awaitingRecipient:
      return amplify_model.AgreementStatus.AWAITING_RECIPIENT;
    case AgreementStatus.awaitingFunding:
      return amplify_model.AgreementStatus.AWAITING_FUNDING;
    case AgreementStatus.funded:
      return amplify_model.AgreementStatus.FUNDED;
    case AgreementStatus.inProgress:
      return amplify_model.AgreementStatus.IN_PROGRESS;
    case AgreementStatus.readyForRelease:
      return amplify_model.AgreementStatus.READY_FOR_RELEASE;
    case AgreementStatus.processingRelease:
      return amplify_model.AgreementStatus.PROCESSING_RELEASE;
    case AgreementStatus.rejected:
      return amplify_model.AgreementStatus.REJECTED;
    case AgreementStatus.cancelled:
      return amplify_model.AgreementStatus.CANCELLED;
    case AgreementStatus.released:
      return amplify_model.AgreementStatus.RELEASED;
    case AgreementStatus.disputed:
      return amplify_model.AgreementStatus.DISPUTED;
  }
}
