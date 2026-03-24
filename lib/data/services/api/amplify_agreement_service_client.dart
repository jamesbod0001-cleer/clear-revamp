import 'dart:convert';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer/data/amplify_models/Agreement.dart';
import 'package:cleer/data/amplify_models/AgreementStatus.dart';
import 'package:cleer/data/services/api/models/paginated_request/paginated_request.dart';
import 'package:flutter/cupertino.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cleer/data/services/amplify_providers.dart';
import 'package:cleer/data/services/api/mixins/api_error_checker.dart';

part 'amplify_agreement_service_client.g.dart';

@riverpod
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
    debugPrint(response.data?.toJson().toString());
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

  // Future<PaginatedResult<Agreement>> queryUserAgreements(
  //     PaginatedRequest<Agreement> request,
  //     ) async {
  //
  //   // 1. Update the document to include nextToken for pagination
  //   // and ALL required fields from your schema.
  //   const graphQLDocument = '''
  //   query AgreementsByStatus(\$status: AgreementStatus!, \$nextToken: String) {
  //     agreementsByStatus(status: \$status, sortDirection: ASC, nextToken: \$nextToken) {
  //       items {
  //         id
  //         shortCode
  //         amount
  //         currency
  //         category
  //         description
  //         initiatorId
  //         recipientAccountNumber
  //         recipientBankCode
  //         status
  //         createdAt
  //         disbursementType
  //         initiatorRole
  //       }
  //       nextToken
  //     }
  //   }
  // ''';
  //
  //   final draftReq = GraphQLRequest<String>(
  //     document: graphQLDocument,
  //     variables: {
  //       'status': 'AWAITING_RECIPIENT',
  //       // 'nextToken': request.nextToken, // Pass your token here if paginating
  //     },
  //   );
  //
  //   try {
  //     final response = await _amplifyAPI.query(request: draftReq).response;
  //
  //     // 2. Check for GraphQL errors
  //     if (response.errors.isNotEmpty) {
  //       safePrint('GraphQL Errors: ${response.errors}');
  //       throw Exception('Failed to query agreements');
  //     }
  //
  //     // 3. Parse the JSON string
  //     final String? data = response.data;
  //     List<Agreement> agreements = [];
  //     String? nextToken;
  //
  //     if (data != null) {
  //       final Map<String, dynamic> jsonData = jsonDecode(data);
  //       final agreementsData = jsonData['agreementsByStatus'];
  //
  //       if (agreementsData != null) {
  //         // Extract the raw items list
  //         final List<dynamic> items = agreementsData['items'] ?? [];
  //
  //         // Map each JSON object into your Amplify Agreement model
  //         agreements = items.map((item) {
  //           return Agreement.fromJson(item as Map<String, dynamic>);
  //         }).toList();
  //
  //         // Extract the token for the next page
  //         nextToken = agreementsData['nextToken'];
  //       }
  //     }
  //
  //     // 4. Return your PaginatedResult
  //     // (Assuming PaginatedResult is a custom class in your app)
  //     return PaginatedResult<Agreement>(
  //        agreements,
  //        request.limit,
  //        nextToken,
  //       null,
  //       Agreement.classType,
  //       null
  //     );
  //
  //   } catch (e) {
  //     safePrint('Error parsing agreements: $e');
  //     rethrow;
  //   }
  // }

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
          initiatorId
          recipientAccountNumber
          recipientBankCode
          status
          createdAt
          disbursementType
          initiatorRole
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

  Stream<GraphQLResponse<Agreement>> observeUserAgreementsCreates() {
    final subscriptionRequest = ModelSubscriptions.onCreate(
      Agreement.classType,
    );
    return _amplifyAPI.subscribe(subscriptionRequest);
  }

  Stream<GraphQLResponse<Agreement>> observeUserAgreementsUpdates() {
    final subscriptionRequest = ModelSubscriptions.onUpdate(
      Agreement.classType,
    );
    return _amplifyAPI.subscribe(subscriptionRequest);
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
      throw Exception('Failed to fetch server time: ${response.errors}');
    }

    final Map<String, dynamic> data = jsonDecode(response.data!);
    return TemporalDateTime.fromString(data['getServerTime']);
  }
}
