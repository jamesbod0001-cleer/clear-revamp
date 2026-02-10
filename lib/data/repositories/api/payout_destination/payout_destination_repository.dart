import 'package:cleer/data/repositories/api/payout_destination/amplify_payout_destination_repository_impl.dart';
import 'package:cleer/data/services/api/amplify_payout_destination_service_client.dart';
import 'package:cleer/domain/models/payout_destination/payout_destination.dart';
import 'package:cleer/domain/use_cases/payout_destination/params/get_payout_destination_params.dart';
import 'package:fpdart/fpdart.dart';
import 'package:result_dart/result_dart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cleer/domain/failures/data_failures.dart';

part 'payout_destination_repository.g.dart';

@riverpod
PayoutDestinationRepository payoutDestinationRepository(Ref ref) =>
    AmplifyPayoutDestinationRepositoryImpl(
      amplifyPayoutDestinationServiceClient: ref.watch(
        amplifyPayoutDestinationServiceClientProvider,
      ),
    );

abstract class PayoutDestinationRepository {
  Future<ResultDart<Option<PayoutDestination>, DataFailure>>
  getPayoutDestination(GetPayoutDestinationParams params);

  Future<ResultDart<PayoutDestination, DataFailure>> createPayoutDestination(
    PayoutDestination payoutDestination,
  );
}
