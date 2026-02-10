import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer/data/amplify_models/ModelProvider.dart' as amplify_model;
import 'package:cleer/data/mappers/payout_destination_mappers.dart';
import 'package:cleer/data/mappers/user_mappers.dart';
import 'package:cleer/domain/models/agreement/agreement.dart' as domain;
import 'package:cleer/domain/models/agreement/agreement_enums.dart';

/// Extensions on the Amplify Agreement model to convert it to the Domain Task entity.
extension AgreementToDomainMapper on amplify_model.Agreement {
  domain.Agreement toDomain() {
    return domain.Agreement(
      id: id,
      amount: amount,
      currency: currency,
      disbursementType: _mapDisbursementTypeToDomain(disbursementType!),
      category: category,
      expectedReleaseDate: expectedReleaseDate.getDateTime(),
      description: description,
      payoutDestination: payoutDestination!.toDomain(),
      initiatorRole: _mapInitiatorRoleToDomain(initiatorRole!),
      status: _mapAgreementStatusToDomain(status!),
      initiator: initiator!.toDomain(),
      createdAt: createdAt?.getDateTimeInUtc(),
    );
  }
}

/// Extensions on the Domain Agreement entity to convert it back to the Amplify model for mutations.
extension AgreementToAmplifyMapper on domain.Agreement {
  amplify_model.Agreement toAmplify() {
    return amplify_model.Agreement(
      id: id,
      amount: amount,
      currency: currency,
      disbursementType: _mapDisbursementTypeToAmplify(disbursementType),
      category: category,
      expectedReleaseDate: TemporalDate(expectedReleaseDate),
      description: description,
      payoutDestination: payoutDestination.toAmplify(),
      initiatorRole: _mapInitiatorRoleToAmplify(initiatorRole),
      status: _mapAgreementStatusToAmplify(status),
      initiator: initiator?.toAmplify(),
    );
  }
}

DisbursementType _mapDisbursementTypeToDomain(
  amplify_model.AgreementDisbursementType p,
) {
  switch (p) {
    case amplify_model.AgreementDisbursementType.ONE_TIME:
      return DisbursementType.oneTime;
    case amplify_model.AgreementDisbursementType.MILESTONES:
      return DisbursementType.milestones;
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

InitiatorRole _mapInitiatorRoleToDomain(
  amplify_model.AgreementInitiatorRole p,
) {
  switch (p) {
    case amplify_model.AgreementInitiatorRole.SENDER:
      return InitiatorRole.sender;
    case amplify_model.AgreementInitiatorRole.RECIPIENT:
      return InitiatorRole.recipient;
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

AgreementStatus _mapAgreementStatusToDomain(amplify_model.AgreementStatus p) {
  switch (p) {
    case amplify_model.AgreementStatus.DRAFT:
      return AgreementStatus.draft;
    case amplify_model.AgreementStatus.AWAITING_RECIPIENT:
      return AgreementStatus.awaitingRecipient;
    case amplify_model.AgreementStatus.AWAITING_FUNDING:
      return AgreementStatus.awaitingFunding;
    case amplify_model.AgreementStatus.FUNDED:
      return AgreementStatus.funded;
    case amplify_model.AgreementStatus.IN_PROGRESS:
      return AgreementStatus.inProgress;
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
  }
}
