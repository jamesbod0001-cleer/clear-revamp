import 'package:cleer_api/src/repositories/push/amplify_push_notification_repository_impl.dart';
import 'package:cleer_api/src/services/push/amplify_push_notification_service_client.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'push_notification_repository_provider.g.dart';

@Riverpod(keepAlive: true)
PushNotificationRepository pushNotificationRepository(Ref ref) {
  return AmplifyPushNotificationRepositoryImpl(
    serviceClient: ref.watch(amplifyPushNotificationServiceClientProvider),
  );
}
