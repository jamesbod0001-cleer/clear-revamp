import 'package:cleer_api/src/models/ModelProvider.dart' as amplify_model;
import 'package:cleer_core/models/status_history/status_history.dart' as domain;

/// Extensions on the Amplify StatusHistory model to convert it to the Domain Task entity.
extension StatusHistoryToDomainMapper on amplify_model.StatusHistory {
  domain.StatusHistory toDomain() {
    return domain.StatusHistory(
      entityId: entityId,
      entityType: entityType,
      oldStatus: oldStatus,
      newStatus: newStatus,
      changedBy: changedBy,
      createdAt: createdAt?.getDateTimeInUtc().toLocal(),
    );
  }
}

/// Extensions on the Domain StatusHistory entity to convert it back to the Amplify model for mutations.
extension StatusHistoryToAmplifyMapper on domain.StatusHistory {
  amplify_model.StatusHistory toAmplify() {
    return amplify_model.StatusHistory(
      entityId: entityId,
      entityType: entityType,
      oldStatus: oldStatus,
      newStatus: newStatus,
      changedBy: changedBy,
    );
  }
}
