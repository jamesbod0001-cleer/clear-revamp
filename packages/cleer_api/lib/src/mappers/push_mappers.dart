import 'package:amplify_flutter/amplify_flutter.dart' as amplify;
import 'package:cleer_core/cleer_core.dart' as domain;

extension PushNotificationMapper on amplify.PushNotificationMessage {
  domain.PushNotificationMessage toDomain() {
    return domain.PushNotificationMessage(
      title: title,
      body: body,
      data: data,
    );
  }
}

extension PushPermissionStatusMapper on amplify.PushNotificationPermissionStatus {
  domain.PushNotificationPermissionStatus toDomain() {
    switch (this) {
      case amplify.PushNotificationPermissionStatus.shouldRequest:
        return domain.PushNotificationPermissionStatus.shouldRequest;
      case amplify.PushNotificationPermissionStatus.shouldExplainThenRequest:
        return domain.PushNotificationPermissionStatus.shouldExplainThenRequest;
      case amplify.PushNotificationPermissionStatus.granted:
        return domain.PushNotificationPermissionStatus.granted;
      case amplify.PushNotificationPermissionStatus.denied:
        return domain.PushNotificationPermissionStatus.denied;
    }
  }
}
