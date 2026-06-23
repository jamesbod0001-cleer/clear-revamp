import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/foundation.dart'; 

/// Top-level function for background notification handling.
/// This must be a top-level function and cannot be a method of a class.
/// Note: We still use PushNotificationMessage from Amplify here
/// because it is the raw type received by the SDK handler.
@pragma('vm:entry-point')
Future<void> backgroundNotificationHandler(
    PushNotificationMessage notification,
    ) async {
  // Handle background notification here.
  // For now, we just log it.
  safePrint('Background notification received: ${notification.title}');
}

/// Registers the background notification handler.
/// This should be called before Amplify.configure().
void registerBackgroundNotificationHandler() {
  // 🛑 WEB GUARD: Skip background handler registration entirely if on Web
  if (kIsWeb) {
    safePrint('Web environment detected: Skipping background push notification handler.');
    return;
  }

  try {
    Amplify.Notifications.Push.onNotificationReceivedInBackground(
      backgroundNotificationHandler,
    );
  } catch (e) {
    safePrint('Failed to register background handler: $e');
  }
}