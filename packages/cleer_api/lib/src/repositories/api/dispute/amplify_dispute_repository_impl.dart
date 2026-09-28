import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer_api/src/mappers/dispute_mappers.dart';
import 'package:cleer_api/src/mappers/status_history_mappers.dart';
import 'package:cleer_api/src/models/ModelProvider.dart' as amplify_model;
import 'package:cleer_api/src/repositories/api/mixins/amplify_api_repository_mixin.dart';
import 'package:cleer_api/src/services/api/amplify_dispute_service_client.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:result_dart/result_dart.dart';

class AmplifyDisputeRepositoryImpl
    with AmplifyApiRepositoryMixin
    implements DisputeRepository {
  final AmplifyDisputeServiceClient _disputeServiceClient;

  AmplifyDisputeRepositoryImpl({
    required AmplifyDisputeServiceClient disputeServiceClient,
  }) : _disputeServiceClient = disputeServiceClient;

  @override
  AmplifyLogger get log => AmplifyLogger('AmplifyDisputeRepositoryImpl');

  @override
  Future<ResultDart<Dispute, DataFailure>> createDispute(
    Dispute dispute,
  ) async {
    return await performDataOperation<Dispute>(
      operation: () async {
        final amplifyDispute = dispute.toAmplify();
        final response = await _disputeServiceClient.createDispute(
          amplifyDispute,
        );
        return response.toDomain();
      },
      operationName: 'CreateDispute',
      targetId: dispute.id,
    );
  }

  @override
  Future<ResultDart<Dispute, DataFailure>> getDispute(
    String disputeId,
  ) async {
    return await performDataOperation<Dispute>(
      operation: () async {
        final response = await _disputeServiceClient.queryDispute(disputeId);
        return response.toDomain();
      },
      operationName: 'GetDispute',
      targetId: disputeId,
    );
  }

  @override
  Future<ResultDart<List<Dispute>, DataFailure>> getDisputesByAgreement(
    String agreementId,
  ) async {
    return await performDataOperation<List<Dispute>>(
      operation: () async {
        final response = await _disputeServiceClient.queryDisputesByAgreement(
          agreementId,
        );
        return response.items
            .map((d) => d?.toDomain())
            .whereType<Dispute>()
            .toList();
      },
      operationName: 'GetDisputesByAgreement',
      targetId: agreementId,
    );
  }

  @override
  Stream<Dispute> observeAgreementDisputeUpdates(String agreementId) {
    return _disputeServiceClient
        .observeAgreementDisputeUpdates(agreementId)
        .handleError((error) => log.error('Stream error for dispute', error))
        .where((event) => event.data != null)
        .map((event) {
          log.info('New event: Dispute updated: ${event.data}');
          return event.data!.toDomain();
        });
  }

  @override
  Future<ResultDart<List<StatusHistory>, DataFailure>> getDisputeStatusHistory(
    String disputeId,
  ) async {
    return await performDataOperation<List<StatusHistory>>(
      operation: () async {
        final response = await _disputeServiceClient.queryDisputeStatusHistory(
          disputeId,
        );
        return response.items
            .whereType<amplify_model.StatusHistory>()
            .map((item) => item.toDomain())
            .toList();
      },
      operationName: 'GetDisputeStatusHistory',
      targetId: disputeId,
    );
  }

  @override
  Stream<StatusHistory> observeDisputeStatusHistoryCreates(
    String disputeId,
  ) {
    return _disputeServiceClient
        .observeDisputeStatusHistoryCreates(disputeId)
        .handleError(
          (error) => log.error('Stream error for dispute status history', error),
        )
        .where((event) => event.data != null)
        .map((event) => event.data!.toDomain());
  }
}
