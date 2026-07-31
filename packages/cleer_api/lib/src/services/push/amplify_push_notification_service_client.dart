import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cleer_api/src/services/amplify_providers.dart';

part 'amplify_push_notification_service_client.g.dart';

@Riverpod(keepAlive: true)
AmplifyPushNotificationServiceClient amplifyPushNotificationServiceClient(
  Ref ref,
) => AmplifyPushNotificationServiceClient(
  pushCategory: ref.watch(amplifyPushNotificationsProvider),
);

class AmplifyPushNotificationServiceClient {
  final PushNotificationsCategory _pushCategory;

  AmplifyPushNotificationServiceClient({
    required PushNotificationsCategory pushCategory,
  }) : _pushCategory = pushCategory;

  Stream<String> get onTokenReceived => _pushCategory.onTokenReceived;

  Stream<PushNotificationMessage> get onNotificationReceivedInForeground =>
      _pushCategory.onNotificationReceivedInForeground;

  Stream<PushNotificationMessage> get onNotificationOpened =>
      _pushCategory.onNotificationOpened;

  PushNotificationMessage? get launchNotification =>
      _pushCategory.launchNotification;

  Future<bool> requestPermissions({
    bool alert = true,
    bool badge = true,
    bool sound = true,
  }) {
    return _pushCategory.requestPermissions(
      alert: alert,
      badge: badge,
      sound: sound,
    );
  }

  Future<PushNotificationPermissionStatus> getPermissionStatus() {
    return _pushCategory.getPermissionStatus();
  }
}
