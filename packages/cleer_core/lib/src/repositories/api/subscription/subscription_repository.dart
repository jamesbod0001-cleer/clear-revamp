import 'package:cleer_core/cleer_core.dart';

abstract class SubscriptionRepository {
  Stream<ApiSubscriptionStatus> observeConnectionState();
}
