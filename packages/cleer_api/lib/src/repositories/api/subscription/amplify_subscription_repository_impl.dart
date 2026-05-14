import 'dart:async';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer_api/src/services/api/api_subscription_service_client.dart';
import 'package:cleer_core/cleer_core.dart';

class AmplifySubscriptionRepositoryImpl implements SubscriptionRepository {
  final ApiSubscriptionServiceClient _apiSubscriptionServiceClient;

  AmplifySubscriptionRepositoryImpl({
    required ApiSubscriptionServiceClient apiSubscriptionServiceClient,
  }) : _apiSubscriptionServiceClient = apiSubscriptionServiceClient;

  @override
  Stream<ApiSubscriptionStatus> observeConnectionState() {
    return _apiSubscriptionServiceClient
        .observeHubEvents()
        .where((event) => event is SubscriptionHubEvent)
        .cast<SubscriptionHubEvent>()
        .map((event) => _mapStatus(event.status));
  }

  ApiSubscriptionStatus _mapStatus(SubscriptionStatus status) {
    return switch (status) {
      SubscriptionStatus.connected => ApiSubscriptionStatus.connected,
      SubscriptionStatus.connecting => ApiSubscriptionStatus.connecting,
      SubscriptionStatus.disconnected => ApiSubscriptionStatus.disconnected,
      SubscriptionStatus.pendingDisconnected =>
        ApiSubscriptionStatus.pendingDisconnected,
      SubscriptionStatus.failed => ApiSubscriptionStatus.failed,
    };
  }
}
