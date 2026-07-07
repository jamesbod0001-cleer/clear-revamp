import 'package:cleer/domain/use_cases/push/push_notification_use_case.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_permission_view_model.g.dart';

@riverpod
class NotificationPermissionViewModel
    extends _$NotificationPermissionViewModel {
  @override
  void build() {}

  Future<bool> checkAndShowNudge() async {
    return await ref
        .read(pushNotificationUseCaseProvider.notifier)
        .shouldShowNudge();
  }

  Future<void> requestPermissions() async {
    await ref
        .read(pushNotificationUseCaseProvider.notifier)
        .requestPermissions();
  }

  void skipForNow() =>
      ref.read(pushNotificationUseCaseProvider.notifier).markNudgeShown();
}
