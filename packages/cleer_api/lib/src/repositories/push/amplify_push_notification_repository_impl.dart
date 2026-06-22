import 'package:cleer_api/src/mappers/push_mappers.dart';
import 'package:cleer_api/src/services/push/amplify_push_notification_service_client.dart';
import 'package:cleer_core/cleer_core.dart';

class AmplifyPushNotificationRepositoryImpl
    implements PushNotificationRepository {
  final AmplifyPushNotificationServiceClient _serviceClient;

  AmplifyPushNotificationRepositoryImpl({
    required AmplifyPushNotificationServiceClient serviceClient,
  }) : _serviceClient = serviceClient;

  @override
  Stream<String> get onTokenReceived => _serviceClient.onTokenReceived;

  @override
  Stream<PushNotificationMessage> get onNotificationReceivedInForeground =>
      _serviceClient.onNotificationReceivedInForeground.map((m) => m.toDomain());

  @override
  Stream<PushNotificationMessage> get onNotificationOpened =>
      _serviceClient.onNotificationOpened.map((m) => m.toDomain());

  @override
  PushNotificationMessage? get launchNotification =>
      _serviceClient.launchNotification?.toDomain();

  @override
  Future<bool> requestPermissions({
    bool alert = true,
    bool badge = true,
    bool sound = true,
  }) {
    return _serviceClient.requestPermissions(
      alert: alert,
      badge: badge,
      sound: sound,
    );
  }

  @override
  Future<PushNotificationPermissionStatus> getPermissionStatus() async {
    final status = await _serviceClient.getPermissionStatus();
    return status.toDomain();
  }
}
