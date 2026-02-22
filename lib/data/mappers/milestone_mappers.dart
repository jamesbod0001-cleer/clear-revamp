import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer/data/amplify_models/ModelProvider.dart' as amplify_model;
import 'package:cleer/data/mappers/agreement_mappers.dart';
import 'package:cleer/domain/models/milestone/milestone.dart' as domain;
import 'package:cleer/domain/models/milestone/milestone_enums.dart';

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
      expectedReleaseDate: TemporalDate(expectedReleaseDate),
      status: _mapMilestoneStatusToAmplify(status),
      agreement: agreement?.toAmplify(),
    );
  }
}

MilestoneStatus _mapMilestoneStatusToDomain(amplify_model.MilestoneStatus p) {
  switch (p) {
    case amplify_model.MilestoneStatus.PENDING:
      return MilestoneStatus.pending;
    case amplify_model.MilestoneStatus.IN_PROGRESS:
      return MilestoneStatus.inProgress;
    case amplify_model.MilestoneStatus.COMPLETED:
      return MilestoneStatus.completed;
    case amplify_model.MilestoneStatus.PENDING_RELEASE:
      return MilestoneStatus.pendingRelease;
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
    case MilestoneStatus.completed:
      return amplify_model.MilestoneStatus.COMPLETED;
    case MilestoneStatus.pendingRelease:
      return amplify_model.MilestoneStatus.PENDING_RELEASE;
    case MilestoneStatus.released:
      return amplify_model.MilestoneStatus.RELEASED;
    case MilestoneStatus.disputed:
      return amplify_model.MilestoneStatus.DISPUTED;
  }
}
