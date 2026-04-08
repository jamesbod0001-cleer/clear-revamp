import 'package:cleer/data/amplify_models/ModelProvider.dart' as amplify_model;
import 'package:cleer/data/mappers/agreement_mappers.dart';
import 'package:cleer/data/mappers/milestone_mappers.dart';
import 'package:cleer/domain/models/status_history/status_history.dart'
    as domain;

/// Extensions on the Amplify StatusHistory model to convert it to the Domain Task entity.
extension StatusHistoryToDomainMapper on amplify_model.StatusHistory {
  domain.StatusHistory toDomain() {
    return domain.StatusHistory(
      oldStatus: oldStatus,
      newStatus: newStatus,
      changedBy: changedBy,
      agreement: agreement?.toDomain(),
      milestone: milestone?.toDomain(),
      createdAt: createdAt?.getDateTimeInUtc().toLocal(),
    );
  }
}

/// Extensions on the Domain StatusHistory entity to convert it back to the Amplify model for mutations.
extension StatusHistoryToAmplifyMapper on domain.StatusHistory {
  amplify_model.StatusHistory toAmplify() {
    return amplify_model.StatusHistory(
      oldStatus: oldStatus,
      newStatus: newStatus,
      changedBy: changedBy,
      agreement: agreement?.toAmplify(),
      milestone: milestone?.toAmplify(),
    );
  }
}
