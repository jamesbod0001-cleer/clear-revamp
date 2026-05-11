import 'package:cleer/domain/providers/user/user_provider.dart';
import 'package:cleer/ui/action_alerts/models/action_alert.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'action_alerts_view_model.g.dart';

@riverpod
List<ActionAlert> actionAlerts(Ref ref) {
  final user = ref.watch(userProfileProvider).value;
  final alerts = <ActionAlert>[];

  // 1. DISPUTES
  // ... alerts.add(HomeActionAlert(type: AlertActionType.activeDisputes, severity: AlertSeverity.critical, priority: 1));

  if (user != null) {
    // 2. NIN VERIFICATION
    // ... alerts.add(HomeActionAlert(type: AlertActionType.verifyNin, severity: AlertSeverity.warning, priority: 2));

    // 3. EMAIL VERIFICATION
    if (user.email == null || !user.isEmailVerified!) {
      if (user.email == null) {
        alerts.add(AddEmailAlert(severity: AlertSeverity.warning, priority: 3));
      } else {
        alerts.add(
          VerifyEmailAlert(severity: AlertSeverity.warning, priority: 3),
        );
      }
    }
  }

  alerts.sort((a, b) => a.priority.compareTo(b.priority));
  return alerts;
}
