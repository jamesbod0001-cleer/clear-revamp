import 'dart:ui';

import 'package:cleer/domain/providers/api/api_subscription_status_provider.dart';
import 'package:cleer/domain/providers/network/network_provider.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

/// Helper to disable Riverpod 3's automatic retry for providers that handle
/// their own recovery logic (Self-Healing).
Duration? noRetry(int retryCount, Object error) => null;

extension ApiSubscriptionReconnection on Ref {
  /// Watches both hardware connectivity and Amplify protocol status
  /// to ensure real-time streams stay active and data stays in sync.
  void listenForSubscriptionRecovery({
    required VoidCallback onSyncRequired,
    required VoidCallback onReconnectRequired,
  }) {
    // We initialize our state by reading the CURRENT values.
    // This is critical for the "Refresh while offline" case, so the new
    // listener knows it is starting in an offline state.
    var prevApiStatus = read(apiSubscriptionStatusProvider).value ??
        ApiSubscriptionStatus.disconnected;
    var wasHardwareOffline =
        read(connectionStatusProvider).value?.isDisconnected ?? false;

    // PROTOCOL WATCHER (Amplify Hub)
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
    listen(connectionStatusProvider, (previous, next) {
      final isOnline = next.value?.isConnected ?? false;

      if (!isOnline) {
        wasHardwareOffline = true;
      } else if (wasHardwareOffline && isOnline) {
        wasHardwareOffline = false;

        // When hardware returns, we always want to restart subscriptions.
        onReconnectRequired();

        // IMPORTANT: If we are currently in an error state, we should also
        // trigger a sync immediately, as we might have missed the protocol
        // handshake or Amplify might not trigger it.
        onSyncRequired();
      }
    });
  }
}
