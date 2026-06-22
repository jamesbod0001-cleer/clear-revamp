import 'package:cleer_core/models/push/push_notification_enums.dart';
import 'package:cleer_core/models/push/push_notification_message.dart';

abstract class PushNotificationRepository {
  Stream<String> get onTokenReceived;
  Stream<PushNotificationMessage> get onNotificationReceivedInForeground;
  Stream<PushNotificationMessage> get onNotificationOpened;

  PushNotificationMessage? get launchNotification;

  Future<bool> requestPermissions({
    bool alert = true,
    bool badge = true,
    bool sound = true,
  });

  Future<PushNotificationPermissionStatus> getPermissionStatus();
}
