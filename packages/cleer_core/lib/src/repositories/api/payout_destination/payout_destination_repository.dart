import 'package:cleer_core/cleer_core.dart';
import 'package:fpdart/fpdart.dart';
import 'package:result_dart/result_dart.dart';

abstract class PayoutDestinationRepository {
  Future<ResultDart<Option<PayoutDestination>, DataFailure>>
  getPayoutDestination(GetPayoutDestinationParams params);

  Future<ResultDart<PayoutDestination, DataFailure>> createPayoutDestination(
    PayoutDestination payoutDestination,
  );
  Future<ResultDart<PayoutDestination, DataFailure>> deletePayoutDestination(
    PayoutDestination payoutDestination,
  );

  Future<ResultDart<List<PayoutDestination>, DataFailure>>
  getPayoutDestinationsByUser(String userId);
  Stream<PayoutDestination> observeUserPayoutDestinationsCreates(String userId);
  Stream<PayoutDestination> observeUserPayoutDestinationsDeletes(String userId);
}
