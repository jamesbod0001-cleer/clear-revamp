import 'package:cleer/domain/providers/push/foreground_message_provider.dart';
import 'package:cleer_ui/utils/snack_bar_helper.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class GlobalNotificationListener extends ConsumerWidget {
  final Widget child;

  const GlobalNotificationListener({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen for foreground notifications globally
    ref.listen(foregroundMessageProvider, (previous, next) {
      if (next != null) {
        final title = next.title ?? 'New Notification';

        SnackBarHelper.showNotification(title);

        // Clear the state
        ref.read(foregroundMessageProvider.notifier).consume();
      }
    });

    return child;
  }
}
