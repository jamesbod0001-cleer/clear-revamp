import 'package:cleer_api/cleer_api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cleer_core/cleer_core.dart';

part 'api_subscription_status_provider.g.dart';

@Riverpod(keepAlive: true)
Stream<ApiSubscriptionStatus> apiSubscriptionStatus(Ref ref) {
  final repository = ref.watch(subscriptionRepositoryProvider);
  return repository.observeConnectionState();
}
