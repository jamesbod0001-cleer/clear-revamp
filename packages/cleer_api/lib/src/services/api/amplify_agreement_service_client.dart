import 'dart:convert';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer_api/src/exceptions/backend_exception.dart';
import 'package:cleer_api/src/models/ModelProvider.dart';
import 'package:cleer_api/src/services/api/models/paginated_request/paginated_request.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cleer_api/src/services/amplify_providers.dart';
import 'package:cleer_api/src/services/api/mixins/api_error_checker.dart';

part 'amplify_agreement_service_client.g.dart';

@Riverpod(keepAlive: true)
AmplifyAgreementServiceClient amplifyAgreementServiceClient(Ref ref) =>
    AmplifyAgreementServiceClient(amplifyAPI: ref.watch(amplifyAPIProvider));

class AmplifyAgreementServiceClient with ApiErrorChecker {
  final APICategory _amplifyAPI;

  AmplifyAgreementServiceClient({required APICategory amplifyAPI})
    : _amplifyAPI = amplifyAPI;

  Future<Agreement> queryAgreement(String id) async {
    final request = ModelQueries.get(
      Agreement.classType,
      AgreementModelIdentifier(id: id),
    );
    final response = await _amplifyAPI.query(request: request).response;
    return validateRequiredResponse(response);
  }

  Future<PaginatedResult<Agreement>?> queryAgreementByShortCode(
    String shortCode,
  ) async {
    final request = ModelQueries.list(
      Agreement.classType,
      where: Agreement.SHORTCODE.eq(shortCode),
    );
    final response = await _amplifyAPI.query(request: request).response;
    return validateResponse(response);
  }

  Future<Agreement> createAgreement(Agreement agreement) async {
    final request = ModelMutations.create(
      agreement,
      authorizationMode: APIAuthorizationType.userPools,
    );
    final response = await _amplifyAPI.mutate(request: request).response;
    return validateRequiredResponse(response);
  }

  Future<Agreement> updateAgreement(Agreement agreement) async {
    final request = ModelMutations.update(
      agreement,
      authorizationMode: APIAuthorizationType.userPools,
    );
    final response = await _amplifyAPI.mutate(request: request).response;
    return validateRequiredResponse(response);
  }

  Future<PaginatedResult<Agreement>> queryUserAgreementsByStatus({
    required AgreementStatus status,
    int limit = 20,
    GraphQLRequest<PaginatedResult<Agreement>>? nextRequest,
  }) async {
    if (nextRequest != null) {
      final response = await _amplifyAPI.query(request: nextRequest).response;
      return validateRequiredResponse(response);
    }

    const graphQLDocument = '''
    query AgreementsByStatus(\$status: AgreementStatus!, \$limit: Int, \$nextToken: String) {
      agreementsByStatus(status: \$status, sortDirection: DESC, limit: \$limit, nextToken: \$nextToken) {
        items {
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
          releaseEligibleAt
          updatedAt
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
        nextToken
      }
    }
  ''';

    final request = GraphQLRequest<PaginatedResult<Agreement>>(
      document: graphQLDocument,
      variables: {'status': status.name, 'limit': limit},
      modelType: const PaginatedModelType(Agreement.classType),
      decodePath: 'agreementsByStatus',
    );
    final response = await _amplifyAPI.query(request: request).response;
    return validateRequiredResponse(response);
  }

  Future<PaginatedResult<Agreement>> queryUserAgreements(
    PaginatedRequest<Agreement> request,
  ) async {
    final amplifyRequest =
        request.nextRequest ??
        ModelQueries.list(
          Agreement.classType,
          limit: request.limit,
          where: request.where,
        );
    final response = await _amplifyAPI.query(request: amplifyRequest).response;
    return validateRequiredResponse(response);
  }

  Stream<GraphQLResponse<Agreement>> observeUserAgreementsUpdates() {
    final subscriptionRequest = ModelSubscriptions.onUpdate(
      Agreement.classType,
    );
    return _amplifyAPI.subscribe(subscriptionRequest);
  }

  Future<PaginatedResult<StatusHistory>> queryAgreementStatusHistory(
    String agreementId,
  ) async {
    final request = ModelQueries.list(
      StatusHistory.classType,
      where: StatusHistory.ENTITYID.eq(agreementId),
    );
    final response = await _amplifyAPI.query(request: request).response;
    return validateRequiredResponse(response);
  }

  Stream<GraphQLResponse<StatusHistory>> observeAgreementStatusHistoryCreates(
    String agreementId,
  ) {
    final subscriptionRequest = ModelSubscriptions.onCreate(
      StatusHistory.classType,
      where: StatusHistory.ENTITYID.eq(agreementId),
    );
    return _amplifyAPI.subscribe(subscriptionRequest);
  }

  Future<AgreementPreview> getAgreementPreviewData(String shortCode) async {
    const String document = '''
      query GetAgreementPreview(\$shortCode: String!) {
        getAgreementPreview(shortCode: \$shortCode) {
          shortCode
          amount
          currency
          category
          description
          status
          initiatorRole
          disbursementType
          expectedReleaseDate
          initiator { id firstName lastName }
          sender { id firstName lastName }
          recipient { id firstName lastName }
          recipientBankName
          recipientAccountName
          recipientAccountNumber
          milestones { id name amount order expectedReleaseDate }
        }
      }
    ''';
    final request = GraphQLRequest<String>(
      document: document,
      variables: {'shortCode': shortCode},
      // CRITICAL: Force API Key auth so web links work without login
      authorizationMode: APIAuthorizationType.apiKey,
    );
    final response = await _amplifyAPI.query(request: request).response;

    if (response.hasErrors) {
      throw BackendException(response.errors.first.message);
    }

    if (response.data == null) {
      throw BackendException(
        'No preview data returned from server.',
        code: 'NotFound',
      );
    }

    final Map<String, dynamic> jsonData = jsonDecode(response.data!);
    final dynamic previewData = jsonData['getAgreementPreview'];

    if (previewData == null) {
      throw BackendException('Agreement not found.', code: 'NotFound');
    }

    return AgreementPreview.fromJson(previewData as Map<String, dynamic>);
  }

  /// Calls the custom Admin Lambda function to securely inject the logged-in user
  /// into the Agreement's participants array, bypassing standard @auth rules.
  /// Returns the Agreement ID on success.
  Future<String> joinAgreement(String shortCode) async {
    const String document = '''
      mutation JoinAgreement(\$shortCode: String!) {
        joinAgreement(shortCode: \$shortCode)
      }
    ''';

    final request = GraphQLRequest<String>(
      document: document,
      variables: {'shortCode': shortCode},
      // CRITICAL: We explicitly use userPools because the Lambda needs
      // the caller's secure identity token to verify who they are.
      authorizationMode: APIAuthorizationType.userPools,
    );

    // Note: We use _amplifyAPI.mutate instead of .query here
    final response = await _amplifyAPI.mutate(request: request).response;

    if (response.hasErrors) {
      // If the Lambda throws an error (e.g. "Unauthorized", "Not found"), it bubbles up here
      throw BackendException(response.errors.first.message);
    }

    if (response.data == null) {
      throw BackendException(
        'No data returned from server while joining agreement.',
        code: 'UnknownError',
      );
    }

    // The response data is a JSON string. We decode it to extract our returned string.
    final Map<String, dynamic> jsonData = jsonDecode(response.data!);
    final dynamic joinedAgreementId = jsonData['joinAgreement'];

    if (joinedAgreementId == null) {
      throw BackendException(
        'Failed to parse the joined agreement ID.',
        code: 'ParseError',
      );
    }

    // Return the actual Agreement ID so the UseCase can query it natively!
    return joinedAgreementId as String;
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
