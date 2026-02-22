import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer/data/mappers/milestone_mappers.dart';
import 'package:cleer/data/repositories/api/milestone/milestone_repository.dart';
import 'package:cleer/data/services/api/amplify_milestone_service_client.dart';
import 'package:cleer/domain/models/milestone/milestone.dart';
import 'package:result_dart/result_dart.dart';
import 'package:cleer/data/repositories/api/mixins/amplify_api_repository_mixin.dart';
import 'package:cleer/domain/failures/data_failures.dart';
import 'package:cleer/data/amplify_models/ModelProvider.dart' as amplify_model;

class AmplifyMilestoneRepositoryImpl
    with AmplifyApiRepositoryMixin
    implements MilestoneRepository {
  final AmplifyMilestoneServiceClient _amplifyMilestoneServiceClient;

  AmplifyMilestoneRepositoryImpl({
    required AmplifyMilestoneServiceClient amplifyMilestoneServiceClient,
  }) : _amplifyMilestoneServiceClient = amplifyMilestoneServiceClient;

  @override
  AmplifyLogger get log => AmplifyLogger('AmplifyMilestoneRepositoryImpl');

  @override
  Future<ResultDart<List<Milestone>, DataFailure>> getMilestonesByAgreement(
    String agreementId,
  ) async {
    return await performDataOperation(
      operation: () async {
        log.info('Getting milestones for agreement: $agreementId');
        final response = await _amplifyMilestoneServiceClient
            .queryMilestonesByAgreement(agreementId);
        log.info('Milestones retrieved: ${response.items.length}');
        return response.items
            .whereType<amplify_model.Milestone>()
            .map((e) => e.toDomain())
            .toList();
      },
      operationName: 'GetMilestonesByAgreement',
    );
  }

  @override
  Future<ResultDart<Milestone, DataFailure>> createMilestone(
    Milestone milestone,
  ) async {
    return await performDataOperation<Milestone>(
      operation: () async {
        log.info('Creating milestone: $milestone');
        final response = await _amplifyMilestoneServiceClient.createMilestone(
          milestone.toAmplify(),
        );
        log.info('Milestone created: $response');
        return response.toDomain();
      },
      operationName: 'CreateMilestone',
      targetId: milestone.id,
    );
  }

  @override
  Future<ResultDart<Milestone, DataFailure>> updateMilestone(
    Milestone milestone,
  ) async {
    return await performDataOperation<Milestone>(
      operation: () async {
        log.info('Updating milestone: $milestone');
        final response = await _amplifyMilestoneServiceClient.updateMilestone(
          milestone.toAmplify(),
        );
        log.info('Milestone updated: $response');
        return response.toDomain();
      },
      operationName: 'UpdateMilestone',
      targetId: milestone.id,
    );
  }
}
