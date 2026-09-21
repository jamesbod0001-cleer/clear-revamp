import 'dart:convert';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer_api/src/exceptions/backend_exception.dart';
import 'package:cleer_api/src/models/Milestone.dart';
import 'package:cleer_api/src/models/StatusHistory.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cleer_api/src/services/amplify_providers.dart';
import 'package:cleer_api/src/services/api/mixins/api_error_checker.dart';

part 'amplify_milestone_service_client.g.dart';

@Riverpod(keepAlive: true)
AmplifyMilestoneServiceClient amplifyMilestoneServiceClient(Ref ref) =>
    AmplifyMilestoneServiceClient(amplifyAPI: ref.watch(amplifyAPIProvider));

class AmplifyMilestoneServiceClient with ApiErrorChecker {
  final APICategory _amplifyAPI;

  AmplifyMilestoneServiceClient({required APICategory amplifyAPI})
    : _amplifyAPI = amplifyAPI;

  Future<Milestone> queryMilestone(String id) async {
    final request = ModelQueries.get(
      Milestone.classType,
      MilestoneModelIdentifier(id: id),
    );
    final response = await _amplifyAPI.query(request: request).response;
    return validateRequiredResponse(response);
  }


  Future<PaginatedResult<Milestone>> queryMilestonesByAgreement(
    String agreementId,
  ) async {
    const String document = '''
      query ListMilestonesByAgreement(\$agreementId: ID!, \$limit: Int) {
        listMilestones(filter: { agreementId: { eq: \$agreementId } }, limit: \$limit) {
          items {
            id
            agreementId
            name
            amount
            order
            expectedReleaseDate
            participants
            lastUpdatedBy
            releaseEligibleAt
            status
            createdAt
            updatedAt
            agreement {
              id
              shortCode
              amount
              currency
              category
              description
              status
              createdAt
              disbursementType
              initiatorRole
              expectedReleaseDate
              lastUpdatedBy
              participants
              activeMilestoneId
              activeMilestoneStatus
              activeMilestoneName
              activeMilestoneAmount
              activeMilestoneExpectedReleaseDate
              releaseEligibleAt
              updatedAt
              physicalDeliveryContext {
                status
                packagingPhotos {
                  key
                  blurHash
                  width
                  height
                  altText
                }
                deliveryDetails {
                  driverPhoneNumber
                  additionalDetails
                  photos {
                    key
                    blurHash
                    width
                    height
                    altText
                  }
                  arrangedBy
                }
              }
              initiator {
                id
                identityId
                firstName
                lastName
                phoneNumber
                flutterwaveCustomerId
              }
              sender {
                id
                identityId
                firstName
                lastName
                phoneNumber
                flutterwaveCustomerId
              }
              recipient {
                id
                identityId
                firstName
                lastName
                phoneNumber
                flutterwaveCustomerId
              }
              payoutDestination {
                accountNumber
                bankCode
                bankName
                accountName
                currency
              }
            }
          }
          nextToken
        }
      }
    ''';

    final request = GraphQLRequest<PaginatedResult<Milestone>>(
      document: document,
      variables: {
        'agreementId': agreementId,
        'limit': 100,
      },
      authorizationMode: APIAuthorizationType.userPools,
      modelType: const PaginatedModelType(Milestone.classType),
      decodePath: 'listMilestones',
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
      variables: {
        'entityId': milestoneId,
        'limit': 100,
      },
      authorizationMode: APIAuthorizationType.userPools,
      modelType: const PaginatedModelType(StatusHistory.classType),
      decodePath: 'listByEntity',
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

  /// Fetches the authoritative AWS Server Time
  Future<TemporalDateTime> getServerTime() async {
    const String document = '''
      query GetServerTime {
        getServerTime
      }
    ''';

    final request = GraphQLRequest<String>(document: document);
    final response = await _amplifyAPI.query(request: request).response;

    if (response.hasErrors || response.data == null) {
      throw BackendException('Failed to fetch server time: ${response.errors}');
    }

    final Map<String, dynamic> data = jsonDecode(response.data!);
    return TemporalDateTime.fromString(data['getServerTime']);
  }
}
