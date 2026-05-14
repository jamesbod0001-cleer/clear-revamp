import 'package:cleer_api/src/repositories/api/subscription/amplify_subscription_repository_impl.dart';
import 'package:cleer_api/src/services/api/api_subscription_service_client.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'subscription_repository_provider.g.dart';

@riverpod
SubscriptionRepository subscriptionRepository(Ref ref) =>
    AmplifySubscriptionRepositoryImpl(
      apiSubscriptionServiceClient: ref.watch(
        apiSubscriptionServiceClientProvider,
      ),
    );
