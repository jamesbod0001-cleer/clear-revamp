import 'dart:async';
import 'package:hooks_riverpod/hooks_riverpod.dart';

extension CacheExtension on Ref {
  /// Keeps the provider alive for [duration] after the last listener is removed.
  /// If a listener is added back before the timer finishes, the timer is canceled.
  void cacheFor(Duration duration) {
    // Pause disposal
    final keepAliveLink = keepAlive();
    Timer? timer;

    // Cleanup if the provider is finally disposed
    onDispose(() {
      timer?.cancel();
    });

    // Start the timer when the last UI component stops watching
    onCancel(() {
      timer = Timer(duration, () {
        keepAliveLink.close(); // Triggers the actual disposal
      });
    });

    // Cancel the timer if the user comes back quickly
    onResume(() {
      timer?.cancel();
    });
  }
}