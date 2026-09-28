import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer_api/src/models/Dispute.dart';
import 'package:cleer_api/src/models/StatusHistory.dart';
import 'package:cleer_api/src/services/amplify_providers.dart';
import 'package:cleer_api/src/services/api/mixins/api_error_checker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'amplify_dispute_service_client.g.dart';

const String disputesByAgreementIdQuery = '''
query DisputesByAgreementId(\$agreementId: ID!, \$limit: Int) {
  disputesByAgreementId(agreementId: \$agreementId, limit: \$limit) {
    items {
      id
      agreementId
      milestoneId
      raisedById
      reason
      description
      evidenceKeys
      status
      participants
      lastUpdatedBy
      createdAt
      updatedAt
      agreement {
        id
        shortCode
        amount
        currency
        disbursementType
        category
        description
        initiatorRole
        status
        createdAt
        updatedAt
      }
      milestone {
        id
        agreementId
        name
        amount
        order
        expectedReleaseDate
        status
        lastUpdatedBy
        releaseEligibleAt
        createdAt
        updatedAt
      }
      raisedBy {
        id
        identityId
        firstName
        lastName
        phoneNumber
        email
        isEmailVerified
        flutterwaveCustomerId
        flutterwavePaymentMethodIds
        deviceToken
        createdAt
        updatedAt
        profilePicture {
          key
          blurHash
          width
          height
          altText
        }
      }
    }
  }
}
''';

@Riverpod(keepAlive: true)
AmplifyDisputeServiceClient amplifyDisputeServiceClient(Ref ref) =>
    AmplifyDisputeServiceClient(amplifyAPI: ref.watch(amplifyAPIProvider));

class AmplifyDisputeServiceClient with ApiErrorChecker {
  final APICategory _amplifyAPI;

  AmplifyDisputeServiceClient({required APICategory amplifyAPI})
    : _amplifyAPI = amplifyAPI;

  Future<Dispute> createDispute(Dispute dispute) async {
    final request = ModelMutations.create(dispute);
    final response = await _amplifyAPI.mutate(request: request).response;
    return validateRequiredResponse(response);
  }

  Future<Dispute> queryDispute(String id) async {
    final request = ModelQueries.get(
      Dispute.classType,
      DisputeModelIdentifier(id: id),
    );
    final response = await _amplifyAPI.query(request: request).response;
    return validateRequiredResponse(response);
  }

  Future<PaginatedResult<Dispute>> queryDisputesByAgreement(
    String agreementId,
  ) async {
    final request = GraphQLRequest<PaginatedResult<Dispute>>(
      document: disputesByAgreementIdQuery,
      variables: {'agreementId': agreementId},
      authorizationMode: APIAuthorizationType.userPools,
      modelType: const PaginatedModelType(Dispute.classType),
      decodePath: 'disputesByAgreementId',
    );

    final response = await _amplifyAPI.query(request: request).response;
    return validateRequiredResponse(response);
  }

  Stream<GraphQLResponse<Dispute>> observeAgreementDisputeUpdates(
    String agreementId,
  ) {
    final subscriptionRequest = ModelSubscriptions.onUpdate(
      Dispute.classType,
      where: Dispute.AGREEMENT.eq(agreementId),
    );
    return _amplifyAPI.subscribe(subscriptionRequest);
  }

  Future<PaginatedResult<StatusHistory>> queryDisputeStatusHistory(
    String disputeId,
  ) async {
    const String document = '''
      query ListByEntity(\$entityId: ID!, \$limit: Int) {
        listByEntity(entityId: \$entityId, limit: \$limit) {
          items {
            id
            entityId
            entityType
            context
            oldStatus
            newStatus
            changedBy
            createdAt
            updatedAt
          }
          nextToken
        }
      }
    ''';

    final request = GraphQLRequest<PaginatedResult<StatusHistory>>(
      document: document,
      variables: {'entityId': disputeId},
      authorizationMode: APIAuthorizationType.userPools,
      modelType: const PaginatedModelType(StatusHistory.classType),
      decodePath: 'listByEntity',
    );

    final response = await _amplifyAPI.query(request: request).response;
    return validateRequiredResponse(response);
  }

  Stream<GraphQLResponse<StatusHistory>> observeDisputeStatusHistoryCreates(
    String disputeId,
  ) {
    final subscriptionRequest = ModelSubscriptions.onCreate(
      StatusHistory.classType,
      where: StatusHistory.ENTITYID.eq(disputeId),
    );
    return _amplifyAPI.subscribe(subscriptionRequest);
  }
}
