enum ApiSubscriptionStatus {
  connected,
  connecting,
  disconnected,
  pendingDisconnected,
  failed,
  unknown;

  bool get isConnected => this == ApiSubscriptionStatus.connected;
  bool get isConnecting => this == ApiSubscriptionStatus.connecting;
}
