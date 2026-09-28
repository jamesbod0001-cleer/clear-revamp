import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer_api/src/models/ModelProvider.dart' as amplify_model;
import 'package:cleer_core/models/activity/activity.dart' as domain;
import 'package:cleer_core/models/activity/activity_enums.dart';

/// Extensions on the Amplify Activity model to convert it to the Domain Task entity.
extension ActivityToDomainMapper on amplify_model.Activity {
  domain.Activity toDomain() {
    return domain.Activity(
      id: id,
      userId: userId,
      type: _mapActivityTypeToDomain(type!),
      heading: heading,
      supportingText: supportingText,
      formattedAmount: formattedAmount,
      description: description,
      isRead: isRead,
      entityId: entityId,
      createdAt: createdAt?.getDateTimeInUtc().toLocal(),
    );
  }
}

/// Extensions on the Domain Activity entity to convert it back to the Amplify model for mutations.
extension ActivityToAmplifyMapper on domain.Activity {
  amplify_model.Activity toAmplify() {
    return amplify_model.Activity(
      id: id,
      userId: userId,
      type: _mapActivityTypeToAmplify(type),
      heading: heading,
      supportingText: supportingText,
      formattedAmount: formattedAmount,
      description: description,
      isRead: isRead,
      entityId: entityId,
      createdAt: createdAt != null
          ? TemporalDateTime(createdAt!.toUtc())
          : null,
    );
  }
}

ActivityType _mapActivityTypeToDomain(amplify_model.ActivityType p) {
  switch (p) {
    case amplify_model.ActivityType.AGREEMENT:
      return ActivityType.agreement;
    case amplify_model.ActivityType.PAYMENT:
      return ActivityType.payment;
    case amplify_model.ActivityType.DELIVERY:
      return ActivityType.delivery;
    case amplify_model.ActivityType.DISPUTE:
      return ActivityType.dispute;
  }
}

amplify_model.ActivityType _mapActivityTypeToAmplify(ActivityType p) {
  switch (p) {
    case ActivityType.agreement:
      return amplify_model.ActivityType.AGREEMENT;
    case ActivityType.payment:
      return amplify_model.ActivityType.PAYMENT;
    case ActivityType.delivery:
      return amplify_model.ActivityType.DELIVERY;
    case ActivityType.dispute:
      return amplify_model.ActivityType.DISPUTE;
  }
}
