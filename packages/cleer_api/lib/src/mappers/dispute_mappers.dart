import 'package:cleer_api/src/mappers/agreement_mappers.dart';
import 'package:cleer_api/src/mappers/milestone_mappers.dart';
import 'package:cleer_api/src/mappers/user_mappers.dart';
import 'package:cleer_api/src/models/ModelProvider.dart' as amplify_model;
import 'package:cleer_core/models/dispute/dispute.dart' as domain;
import 'package:cleer_core/models/dispute/dispute_enums.dart';

extension DisputeToDomainMapper on amplify_model.Dispute {
  domain.Dispute toDomain() {
    return domain.Dispute(
      id: id,
      agreement: agreement?.toDomain(),
      milestone: milestone?.toDomain(),
      raisedBy: raisedBy?.toDomain(),
      reason: DisputeReason.fromId(reason),
      description: description,
      evidenceKeys: evidenceKeys,
      status: _mapDisputeStatusToDomain(status!),
      participants: participants,
      lastUpdatedBy: lastUpdatedBy,
      createdAt: createdAt?.getDateTimeInUtc().toLocal(),
    );
  }
}

extension DisputeToAmplifyMapper on domain.Dispute {
  amplify_model.Dispute toAmplify() {
    return amplify_model.Dispute(
      id: id,
      reason: reason.id,
      description: description,
      evidenceKeys: evidenceKeys,
      status: _mapDisputeStatusToAmplify(status),
      participants: participants,
      lastUpdatedBy: lastUpdatedBy,
      agreement: agreement?.toAmplify(),
      milestone: milestone?.toAmplify(),
      raisedBy: raisedBy?.toAmplify(),
    );
  }
}

DisputeStatus _mapDisputeStatusToDomain(amplify_model.DisputeStatus p) {
  switch (p) {
    case amplify_model.DisputeStatus.OPEN:
      return DisputeStatus.open;
    case amplify_model.DisputeStatus.UNDER_REVIEW:
      return DisputeStatus.underReview;
    case amplify_model.DisputeStatus.RESOLVED:
      return DisputeStatus.resolved;
    case amplify_model.DisputeStatus.DISMISSED:
      return DisputeStatus.dismissed;
  }
}

amplify_model.DisputeStatus _mapDisputeStatusToAmplify(DisputeStatus p) {
  switch (p) {
    case DisputeStatus.open:
      return amplify_model.DisputeStatus.OPEN;
    case DisputeStatus.underReview:
      return amplify_model.DisputeStatus.UNDER_REVIEW;
    case DisputeStatus.resolved:
      return amplify_model.DisputeStatus.RESOLVED;
    case DisputeStatus.dismissed:
      return amplify_model.DisputeStatus.DISMISSED;
  }
}
