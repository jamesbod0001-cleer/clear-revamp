import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart' as amplify;
import 'package:cleer_core/cleer_core.dart' as domain;
import 'package:flutter/cupertino.dart';

extension PushNotificationMapper on amplify.PushNotificationMessage {
  domain.PushNotificationMessage toDomain() {
    final cleanedData = Map<String, dynamic>.from(data);

    final jsonBody = cleanedData['pinpoint.jsonBody'];

    if (jsonBody is String) {
      try {
        final parsedData = jsonDecode(jsonBody) as Map<String, dynamic>;
        cleanedData.addAll(parsedData);
      } catch (e) {
        debugPrint('Failed to parse pinpoint.jsonBody: $e');
      }
    }

    return domain.PushNotificationMessage(
      title: title,
      body: body,
      data: cleanedData,
    );
  }
}

extension PushPermissionStatusMapper
    on amplify.PushNotificationPermissionStatus {
  domain.PushNotificationPermissionStatus toDomain() {
    switch (this) {
      case amplify.PushNotificationPermissionStatus.shouldRequest:
        return domain.PushNotificationPermissionStatus.shouldRequest;
      case amplify.PushNotificationPermissionStatus.shouldExplainThenRequest:
        return domain.PushNotificationPermissionStatus.shouldExplainThenRequest;
      case amplify.PushNotificationPermissionStatus.granted:
        return domain.PushNotificationPermissionStatus.granted;
      case amplify.PushNotificationPermissionStatus.denied:
        return domain.PushNotificationPermissionStatus.denied;
    }
  }
}
