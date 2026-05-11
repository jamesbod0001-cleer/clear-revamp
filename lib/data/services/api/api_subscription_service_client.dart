import 'dart:async';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer/data/services/amplify_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'api_subscription_service_client.g.dart';

@riverpod
ApiSubscriptionServiceClient apiSubscriptionServiceClient(Ref ref) =>
    ApiSubscriptionServiceClient(amplifyHub: ref.watch(amplifyHubProvider));

class ApiSubscriptionServiceClient {
  final AmplifyHub _amplifyHub;

  ApiSubscriptionServiceClient({required AmplifyHub amplifyHub})
    : _amplifyHub = amplifyHub;

  /// Listens to the global Amplify API Hub channel.
  Stream<ApiHubEvent> observeHubEvents() {
    // We use a StreamController.broadcast so multiple repositories
    // or providers can listen to the connection state simultaneously.
    late StreamSubscription<ApiHubEvent> subscription;
    final controller = StreamController<ApiHubEvent>.broadcast();

    controller.onListen = () {
      subscription = _amplifyHub.listen(HubChannel.Api, (event) {
        if (!controller.isClosed) {
          controller.add(event);
        }
      });
    };

    controller.onCancel = () {
      subscription.cancel();
      controller.close();
    };

    return controller.stream;
  }
}
