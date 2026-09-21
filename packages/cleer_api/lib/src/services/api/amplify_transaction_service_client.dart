import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer_api/src/models/Transaction.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cleer_api/src/services/amplify_providers.dart';
import 'package:cleer_api/src/services/api/mixins/api_error_checker.dart';

part 'amplify_transaction_service_client.g.dart';

@Riverpod(keepAlive: true)
AmplifyTransactionServiceClient amplifyTransactionServiceClient(Ref ref) =>
    AmplifyTransactionServiceClient(amplifyAPI: ref.watch(amplifyAPIProvider));

class AmplifyTransactionServiceClient with ApiErrorChecker {
  final APICategory _amplifyAPI;

  AmplifyTransactionServiceClient({required APICategory amplifyAPI})
    : _amplifyAPI = amplifyAPI;

  Future<Transaction> createTransaction(Transaction transaction) async {
    final request = ModelMutations.create(
      transaction,
      authorizationMode: APIAuthorizationType.userPools,
    );
    final response = await _amplifyAPI.mutate(request: request).response;
    return validateRequiredResponse(response);
  }

  Future<Transaction?> getTransactionByFlutterwaveId(
    String flutterwaveId,
  ) async {
    const String document = '''
      query ListTransactionsByFlutterwaveId(\$flutterwaveId: String!, \$limit: Int) {
        listTransactions(filter: { flutterwaveId: { eq: \$flutterwaveId } }, limit: \$limit) {
          items {
            id
            agreementId
            paymentMethodType
            reference
            flutterwaveId
            amount
            cleerFee
            gatewayFee
            currency
            status
            flutterwavePaymentMethodId
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

    final request = GraphQLRequest<PaginatedResult<Transaction>>(
      document: document,
      variables: {
        'flutterwaveId': flutterwaveId,
        'limit': 1,
      },
      modelType: const PaginatedModelType(Transaction.classType),
      decodePath: 'listTransactions',
    );

    final response = await _amplifyAPI.query(request: request).response;
    final result = validateResponse(response);

    if (result == null || result.items.isEmpty) {
      return null;
    }

    return result.items.whereType<Transaction>().firstOrNull;
  }

  Future<Transaction> updateTransaction(Transaction transaction) async {
    final request = ModelMutations.update(
      transaction,
      authorizationMode: APIAuthorizationType.userPools,
    );
    final response = await _amplifyAPI.mutate(request: request).response;
    return validateRequiredResponse(response);
  }
}
