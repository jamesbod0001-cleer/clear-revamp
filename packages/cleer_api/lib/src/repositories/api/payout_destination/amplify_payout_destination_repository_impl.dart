import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer_api/src/mappers/payout_destination_mappers.dart';
import 'package:cleer_api/src/services/api/amplify_payout_destination_service_client.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:fpdart/fpdart.dart';
import 'package:result_dart/result_dart.dart';
import 'package:cleer_api/src/repositories/api/mixins/amplify_api_repository_mixin.dart';
import 'package:cleer_api/src/models/ModelProvider.dart' as amplify_model;

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
      operationName: 'GetPayoutDestination',
      targetId: params.accountNumber,
      timeoutDuration: const Duration(seconds: 45), // 🔴 45s Timeout
      operation: () async {
        final response = await _amplifyPayoutDestinationServiceClient
            .queryPayoutDestination(params.accountNumber, params.bankCode);
        return Option.fromNullable(response?.toDomain());
      },
    );
  }

  @override
  Future<ResultDart<PayoutDestination, DataFailure>> createPayoutDestination(
      PayoutDestination payoutDestination,
      ) async {
    return await performDataOperation<PayoutDestination>(
      operationName: 'CreatePayoutDestination',
      targetId: payoutDestination.accountNumber,
      timeoutDuration: const Duration(seconds: 45), // 🔴 45s Timeout
      operation: () async {
        final response = await _amplifyPayoutDestinationServiceClient
            .createPayoutDestination(payoutDestination.toAmplify());
        return response.toDomain();
      },
    );
  }

  @override
  Future<ResultDart<PayoutDestination, DataFailure>> deletePayoutDestination(
      PayoutDestination payoutDestination,
      ) async {
    return await performDataOperation<PayoutDestination>(
      operationName: 'DeletePayoutDestination',
      targetId: payoutDestination.accountNumber,
      timeoutDuration: const Duration(seconds: 45), // 🔴 45s Timeout
      operation: () async {
        final response = await _amplifyPayoutDestinationServiceClient
            .deletePayoutDestination(payoutDestination.toAmplify());
        return response.toDomain();
      },
    );
  }

  @override
  Future<ResultDart<List<PayoutDestination>, DataFailure>>
  getPayoutDestinationsByUser(String userId) async {
    return await performDataOperation<List<PayoutDestination>>(
      operationName: 'GetUserPayoutDestinations',
      timeoutDuration: const Duration(seconds: 45), // 🔴 45s Timeout
      operation: () async {
        final response = await _amplifyPayoutDestinationServiceClient
            .queryPayoutDestinationsByUser(userId);
        log.info('Payout destinations retrieved: ${response.items.length}');
        return response.items
            .whereType<amplify_model.PayoutDestination>()
            .map((e) => e.toDomain())
            .toList();
      },
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
        .handleError(
          (error) => log.error('Stream error for payout destination', error),
    )
        .where((event) => event.data != null)
        .map((event) => event.data!.toDomain());
  }
}