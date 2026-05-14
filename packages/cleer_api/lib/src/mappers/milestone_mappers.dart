import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer_api/src/models/ModelProvider.dart' as amplify_model;
import 'package:cleer_api/src/mappers/agreement_mappers.dart';
import 'package:cleer_core/models/milestone/milestone.dart' as domain;
import 'package:cleer_core/models/milestone/milestone_enums.dart';
import 'package:intl/intl.dart';

/// Extensions on the Amplify Milestone model to convert it to the Domain Task entity.
extension MilestoneToDomainMapper on amplify_model.Milestone {
  domain.Milestone toDomain() {
    return domain.Milestone(
      id: id,
      order: order,
      name: name,
      amount: amount,
      expectedReleaseDate: expectedReleaseDate.getDateTime(),
      status: _mapMilestoneStatusToDomain(status!),
      agreement: agreement?.toDomain(),
      participants: participants,
      lastUpdatedBy: lastUpdatedBy,
    );
  }
}

/// Extensions on the Domain Milestone entity to convert it back to the Amplify model for mutations.
extension MilestoneToAmplifyMapper on domain.Milestone {
  amplify_model.Milestone toAmplify() {
    return amplify_model.Milestone(
      id: id,
      order: order,
      name: name,
      amount: amount,
      expectedReleaseDate: TemporalDate.fromString(
        DateFormat('yyyy-MM-dd').format(expectedReleaseDate),
      ),
      status: _mapMilestoneStatusToAmplify(status),
      agreement: agreement?.toAmplify(),
      participants: participants,
      lastUpdatedBy: lastUpdatedBy,
    );
  }
}

MilestoneStatus _mapMilestoneStatusToDomain(amplify_model.MilestoneStatus p) {
  switch (p) {
    case amplify_model.MilestoneStatus.PENDING:
      return MilestoneStatus.pending;
    case amplify_model.MilestoneStatus.IN_PROGRESS:
      return MilestoneStatus.inProgress;
    case amplify_model.MilestoneStatus.READY_FOR_RELEASE:
      return MilestoneStatus.readyForRelease;
    case amplify_model.MilestoneStatus.PROCESSING_RELEASE:
      return MilestoneStatus.processingRelease;
    case amplify_model.MilestoneStatus.RELEASED:
      return MilestoneStatus.released;
    case amplify_model.MilestoneStatus.DISPUTED:
      return MilestoneStatus.disputed;
  }
}

amplify_model.MilestoneStatus _mapMilestoneStatusToAmplify(MilestoneStatus p) {
  switch (p) {
    case MilestoneStatus.pending:
      return amplify_model.MilestoneStatus.PENDING;
    case MilestoneStatus.inProgress:
      return amplify_model.MilestoneStatus.IN_PROGRESS;
    case MilestoneStatus.readyForRelease:
      return amplify_model.MilestoneStatus.READY_FOR_RELEASE;
    case MilestoneStatus.processingRelease:
      return amplify_model.MilestoneStatus.PROCESSING_RELEASE;
    case MilestoneStatus.released:
      return amplify_model.MilestoneStatus.RELEASED;
    case MilestoneStatus.disputed:
      return amplify_model.MilestoneStatus.DISPUTED;
  }
}
