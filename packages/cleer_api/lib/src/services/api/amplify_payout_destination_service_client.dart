import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer_api/src/models/ModelProvider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cleer_api/src/services/amplify_providers.dart';
import 'package:cleer_api/src/services/api/mixins/api_error_checker.dart';

part 'amplify_payout_destination_service_client.g.dart';

@Riverpod(keepAlive: true)
AmplifyPayoutDestinationServiceClient amplifyPayoutDestinationServiceClient(
  Ref ref,
) => AmplifyPayoutDestinationServiceClient(
  amplifyAPI: ref.watch(amplifyAPIProvider),
);

class AmplifyPayoutDestinationServiceClient with ApiErrorChecker {
  final APICategory _amplifyAPI;

  AmplifyPayoutDestinationServiceClient({required APICategory amplifyAPI})
    : _amplifyAPI = amplifyAPI;

  Future<PayoutDestination?> queryPayoutDestination(
    String accountNumber,
    String bankCode,
  ) async {
    final request = ModelQueries.get(
      PayoutDestination.classType,
      PayoutDestinationModelIdentifier(
        accountNumber: accountNumber,
        bankCode: bankCode,
      ),
    );
    final response = await _amplifyAPI.query(request: request).response;
    return validateResponse(response);
  }

  Future<PayoutDestination> createPayoutDestination(
    PayoutDestination payoutDestination,
  ) async {
    final request = ModelMutations.create(
      payoutDestination,
      authorizationMode: APIAuthorizationType.userPools,
    );
    final response = await _amplifyAPI.mutate(request: request).response;
    return validateRequiredResponse(response);
  }

  Future<PayoutDestination> deletePayoutDestination(
    PayoutDestination payoutDestination,
  ) async {
    final request = ModelMutations.delete(
      payoutDestination,
      authorizationMode: APIAuthorizationType.userPools,
    );
    final response = await _amplifyAPI.mutate(request: request).response;
    return validateRequiredResponse(response);
  }

  Future<PaginatedResult<PayoutDestination>> queryPayoutDestinationsByUser(
    String userId,
  ) async {
    const String document = '''
      query ListPayoutDestinationsByUser(\$userId: ID!, \$limit: Int) {
        listPayoutDestinations(filter: { userId: { eq: \$userId } }, limit: \$limit) {
          items {
            accountNumber
            bankCode
            currency
            userId
            bankName
            accountName
            createdAt
            updatedAt
            user {
              id
              identityId
              firstName
              lastName
              phoneNumber
              profilePicture {
                key
                blurHash
                width
                height
                altText
              }
              flutterwaveCustomerId
              isEmailVerified
              email
              deviceToken
              createdAt
              updatedAt
            }
          }
          nextToken
        }
      }
    ''';

    final request = GraphQLRequest<PaginatedResult<PayoutDestination>>(
      document: document,
      variables: {
        'userId': userId,
        'limit': 100,
      },
      authorizationMode: APIAuthorizationType.userPools,
      modelType: const PaginatedModelType(PayoutDestination.classType),
      decodePath: 'listPayoutDestinations',
    );

    final response = await _amplifyAPI.query(request: request).response;
    return validateRequiredResponse(response);
  }

  Stream<GraphQLResponse<PayoutDestination>>
  observeUserPayoutDestinationsCreates(String userId) {
    final subscriptionRequest = ModelSubscriptions.onCreate(
      PayoutDestination.classType,
      where: PayoutDestination.USER.eq(userId),
    );
    return _amplifyAPI.subscribe(subscriptionRequest);
  }

  Stream<GraphQLResponse<PayoutDestination>>
  observeUserPayoutDestinationsDeletes(String userId) {
    final subscriptionRequest = ModelSubscriptions.onDelete(
      PayoutDestination.classType,
      where: PayoutDestination.USER.eq(userId),
    );
    return _amplifyAPI.subscribe(subscriptionRequest);
  }
}
