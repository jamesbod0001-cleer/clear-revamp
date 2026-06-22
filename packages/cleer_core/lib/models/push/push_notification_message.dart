class PushNotificationMessage {
  final String? title;
  final String? body;
  final Map<String, dynamic> data;

  const PushNotificationMessage({
    this.title,
    this.body,
    this.data = const {},
  });
}
