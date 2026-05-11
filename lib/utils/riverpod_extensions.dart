import 'dart:async';
import 'package:cleer/domain/models/enums/api_subscription_status.dart';
import 'package:cleer/domain/providers/api/api_subscription_status_provider.dart';
import 'package:cleer/domain/providers/network/network_provider.dart';
import 'package:flutter/cupertino.dart';
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

extension ApiSubscriptionReconnection on Ref {
  /// Watches both hardware connectivity and Amplify protocol status
  /// to ensure real-time streams stay active and data stays in sync.
  void listenForSubscriptionRecovery({
    required VoidCallback onSyncRequired,
    required VoidCallback onReconnectRequired,
  }) {
    var prevApiStatus = ApiSubscriptionStatus.disconnected;
    var wasHardwareOffline = false;

    // PROTOCOL WATCHER (Amplify Hub)
    // When Amplify moves from 'connecting' to 'connected', we know the
    // handshake is done and we likely missed data. Time to re-fetch.
    listen(apiSubscriptionStatusProvider, (previous, next) {
      final currentStatus = next.value ?? ApiSubscriptionStatus.unknown;

      final isHandshakeComplete =
          prevApiStatus.isConnecting && currentStatus.isConnected;

      if (isHandshakeComplete) {
        onSyncRequired();
      }
      prevApiStatus = currentStatus;
    });

    // HARDWARE WATCHER (Internet Connection Checker)
    // When internet returns, Amplify's internal retry might have already
    // died (failed). We manually poke the stream to restart.
    listen(connectionStatusProvider, (previous, next) {
      final isOnline = next.value?.isConnected ?? false;

      if (!isOnline) {
        wasHardwareOffline = true;
      } else if (wasHardwareOffline && isOnline) {
        wasHardwareOffline = false;
        onReconnectRequired();
      }
    });
  }
}
