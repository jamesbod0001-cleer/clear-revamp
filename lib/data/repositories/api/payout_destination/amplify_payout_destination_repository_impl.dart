import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer/data/mappers/payout_destination_mappers.dart';
import 'package:cleer/data/repositories/api/payout_destination/payout_destination_repository.dart';
import 'package:cleer/data/services/api/amplify_payout_destination_service_client.dart';
import 'package:cleer/domain/models/payout_destination/payout_destination.dart';
import 'package:cleer/domain/use_cases/payout_destination/params/get_payout_destination_params.dart';
import 'package:fpdart/fpdart.dart';
import 'package:result_dart/result_dart.dart';
import 'package:cleer/data/repositories/api/mixins/amplify_api_repository_mixin.dart';
import 'package:cleer/domain/failures/data_failures.dart';

class AmplifyPayoutDestinationRepositoryImpl
    with AmplifyApiRepositoryMixin
    implements PayoutDestinationRepository {
  final AmplifyPayoutDestinationServiceClient
  _amplifyPayoutDestinationServiceClient;

  AmplifyPayoutDestinationRepositoryImpl({
    required AmplifyPayoutDestinationServiceClient
    amplifyPayoutDestinationServiceClient,
  }) : _amplifyPayoutDestinationServiceClient =
           amplifyPayoutDestinationServiceClient;

  @override
  AmplifyLogger get log =>
      AmplifyLogger('AmplifyPayoutDestinationRepositoryImpl');

  @override
  Future<ResultDart<Option<PayoutDestination>, DataFailure>>
  getPayoutDestination(GetPayoutDestinationParams params) async {
    return await performDataOperation<Option<PayoutDestination>>(
      operation: () async {
        final response = await _amplifyPayoutDestinationServiceClient
            .queryPayoutDestination(params.accountNumber, params.bankCode);
        return Option.fromNullable(response?.toDomain());
      },
      operationName: 'GetPayoutDestination',
      targetId: params.accountNumber,
    );
  }

  @override
  Future<ResultDart<PayoutDestination, DataFailure>> createPayoutDestination(
    PayoutDestination payoutDestination,
  ) async {
    return await performDataOperation<PayoutDestination>(
      operation: () async {
        final response = await _amplifyPayoutDestinationServiceClient
            .createPayoutDestination(payoutDestination.toAmplify());
        return response.toDomain();
      },
      operationName: 'CreatePayoutDestination',
      targetId: payoutDestination.accountNumber,
    );
  }
}
