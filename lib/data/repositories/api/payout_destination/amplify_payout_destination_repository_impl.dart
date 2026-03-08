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
import 'package:cleer/data/amplify_models/ModelProvider.dart' as amplify_model;

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

  @override
  Future<ResultDart<PayoutDestination, DataFailure>> deletePayoutDestination(
    PayoutDestination payoutDestination,
  ) async {
    return await performDataOperation<PayoutDestination>(
      operation: () async {
        final response = await _amplifyPayoutDestinationServiceClient
            .deletePayoutDestination(payoutDestination.toAmplify());
        return response.toDomain();
      },
      operationName: 'DeletePayoutDestination',
      targetId: payoutDestination.accountNumber,
    );
  }

  @override
  Future<ResultDart<List<PayoutDestination>, DataFailure>>
  getPayoutDestinationsByUser(String userId) async {
    return await performDataOperation<List<PayoutDestination>>(
      operation: () async {
        final response = await _amplifyPayoutDestinationServiceClient
            .queryPayoutDestinationsByUser(userId);
        log.info('Payout destinations retrieved: ${response.items.length}');
        return response.items
            .whereType<amplify_model.PayoutDestination>()
            .map((e) => e.toDomain())
            .toList();
      },
      operationName: 'GetUserPayoutDestinations',
    );
  }

  @override
  Stream<PayoutDestination> observeUserPayoutDestinationsCreates(
    String userId,
  ) {
    return _amplifyPayoutDestinationServiceClient
        .observeUserPayoutDestinationsCreates(userId)
        .handleError(
          (error) => log.error('Stream error for payout destination', error),
        )
        .where((event) => event.data != null)
        .map((event) {
          log.info('New event: Payout destination created: ${event.data}');
          return event.data!.toDomain();
        });
  }

  @override
  Stream<PayoutDestination> observeUserPayoutDestinationsDeletes(
    String userId,
  ) {
    return _amplifyPayoutDestinationServiceClient
        .observeUserPayoutDestinationsDeletes(userId)
        .handleError((error) => log.error('Stream error for user', error))
        .where((event) => event.data != null)
        .map((event) => event.data!.toDomain());
  }
}
