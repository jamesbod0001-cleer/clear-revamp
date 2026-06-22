import 'package:cleer_core/models/push/push_notification_message.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'foreground_message_provider.g.dart';

@Riverpod(keepAlive: true)
class ForegroundMessage extends _$ForegroundMessage {
  @override
  PushNotificationMessage? build() => null;

  void notify(PushNotificationMessage message) => state = message;
  void consume() => state = null;
}