enum AppConnectionStatus {
  connected,
  disconnected;

  bool get isConnected => this == AppConnectionStatus.connected;
  bool get isDisconnected => this == AppConnectionStatus.disconnected;
}
