import 'package:cleer/data/repositories/api/subscription/subscription_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cleer/domain/models/enums/api_subscription_status.dart';

part 'api_subscription_status_provider.g.dart';

@Riverpod(keepAlive: true)
Stream<ApiSubscriptionStatus> apiSubscriptionStatus(Ref ref) {
  final repository = ref.watch(subscriptionRepositoryProvider);
  return repository.observeConnectionState();
}