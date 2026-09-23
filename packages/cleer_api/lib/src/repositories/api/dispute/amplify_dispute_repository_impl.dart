import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer_api/src/mappers/dispute_mappers.dart';
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
}
