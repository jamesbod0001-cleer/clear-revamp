import 'package:cleer/data/repositories/api/subscription/amplify_subscription_repository_impl.dart';
import 'package:cleer/data/services/api/api_subscription_service_client.dart';
import 'package:cleer/domain/models/enums/api_subscription_status.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'subscription_repository.g.dart';

@riverpod
SubscriptionRepository subscriptionRepository(Ref ref) =>
    AmplifySubscriptionRepositoryImpl(
      apiSubscriptionServiceClient: ref.watch(
        apiSubscriptionServiceClientProvider,
      ),
    );

abstract class SubscriptionRepository {
  Stream<ApiSubscriptionStatus> observeConnectionState();
}
