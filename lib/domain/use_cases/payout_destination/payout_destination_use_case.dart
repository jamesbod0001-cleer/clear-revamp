import 'package:amplify_flutter/amplify_flutter.dart' hide SignedOutException;
import 'package:cleer/data/repositories/api/payout_destination/payout_destination_repository.dart';
import 'package:cleer/domain/failures/data_failures.dart';
import 'package:cleer/domain/models/payout_destination/payout_destination.dart';
import 'package:result_dart/result_dart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'payout_destination_use_case.g.dart';

@Riverpod(keepAlive: true)
class PayoutDestinationUseCase extends _$PayoutDestinationUseCase {
  late final PayoutDestinationRepository _payoutDestinationRepository;

  final _log = AmplifyLogger("PayoutDestinationUseCase");

  @override
  void build() {
    _payoutDestinationRepository = ref.watch(
      payoutDestinationRepositoryProvider,
    );
    return;
  }

  Future<ResultDart<PayoutDestination, DataFailure>> createPayoutDestination(
    PayoutDestination payoutDestination,
  ) async {
    _log.info('Create payout destination: $payoutDestination');
    final result = await _payoutDestinationRepository.createPayoutDestination(
      payoutDestination,
    );
    result.fold(
      (payoutDestination) {
        _log.info('Payout destination created: $payoutDestination');
      },
      (failure) {
        _log.error('Error creating payout destination', failure);
        throw failure;
      },
    );
    return result;
  }

  Future<ResultDart<PayoutDestination, DataFailure>> deletePayoutDestination(
    PayoutDestination payoutDestination,
  ) async {
    _log.info('Delete payout destination: $payoutDestination');
    final result = await _payoutDestinationRepository.deletePayoutDestination(
      payoutDestination,
    );
    result.fold(
      (payoutDestination) {
        _log.info('Payout destination deleted');
      },
      (failure) {
        _log.error('Error deleting payout destination', failure);
        throw failure;
      },
    );
    return result;
  }
}
