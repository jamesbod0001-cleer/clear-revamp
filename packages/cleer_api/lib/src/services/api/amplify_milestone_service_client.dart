import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer_api/src/models/Milestone.dart';
import 'package:cleer_api/src/models/StatusHistory.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cleer_api/src/services/amplify_providers.dart';
import 'package:cleer_api/src/services/api/mixins/api_error_checker.dart';

part 'amplify_milestone_service_client.g.dart';

@riverpod
AmplifyMilestoneServiceClient amplifyMilestoneServiceClient(Ref ref) =>
    AmplifyMilestoneServiceClient(amplifyAPI: ref.watch(amplifyAPIProvider));

class AmplifyMilestoneServiceClient with ApiErrorChecker {
  final APICategory _amplifyAPI;

  AmplifyMilestoneServiceClient({required APICategory amplifyAPI})
    : _amplifyAPI = amplifyAPI;

  Future<PaginatedResult<Milestone>> queryMilestonesByAgreement(
    String agreementId,
  ) async {
    final request = ModelQueries.list(
      Milestone.classType,
      where: Milestone.AGREEMENT.eq(agreementId),
    );
    final response = await _amplifyAPI.query(request: request).response;
    return validateRequiredResponse(response);
  }

  Stream<GraphQLResponse<Milestone>> observeAgreementMilestonesUpdates(
    String agreementId,
  ) {
    final subscriptionRequest = ModelSubscriptions.onUpdate(
      Milestone.classType,
      where: Milestone.AGREEMENT.eq(agreementId),
    );
    return _amplifyAPI.subscribe(subscriptionRequest);
  }

  Future<PaginatedResult<StatusHistory>> queryMilestoneStatusHistory(
    String milestoneId,
  ) async {
    final request = ModelQueries.list(
      StatusHistory.classType,
      where: StatusHistory.ENTITYID.eq(milestoneId),
    );
    final response = await _amplifyAPI.query(request: request).response;
    return validateRequiredResponse(response);
  }

  Stream<GraphQLResponse<StatusHistory>> observeMilestoneStatusHistoryCreates(
    String milestoneId,
  ) {
    final subscriptionRequest = ModelSubscriptions.onCreate(
      StatusHistory.classType,
      where: StatusHistory.ENTITYID.eq(milestoneId),
    );
    return _amplifyAPI.subscribe(subscriptionRequest);
  }

  Future<Milestone> createMilestone(Milestone milestone) async {
    final request = ModelMutations.create(
      milestone,
      authorizationMode: APIAuthorizationType.userPools,
    );
    final response = await _amplifyAPI.mutate(request: request).response;
    return validateRequiredResponse(response);
  }

  Future<Milestone> updateMilestone(Milestone milestone) async {
    final request = ModelMutations.update(
      milestone,
      authorizationMode: APIAuthorizationType.userPools,
    );
    final response = await _amplifyAPI.mutate(request: request).response;
    return validateRequiredResponse(response);
  }
}
