import 'dart:ui';

import 'package:cleer/domain/providers/api/api_subscription_status_provider.dart';
import 'package:cleer/domain/providers/network/network_provider.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
