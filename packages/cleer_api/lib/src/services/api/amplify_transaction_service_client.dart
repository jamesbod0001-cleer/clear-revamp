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
    final request = ModelQueries.list(
      Transaction.classType,
      where: Transaction.FLUTTERWAVEID.eq(flutterwaveId),
    );

    final response = await _amplifyAPI.query(request: request).response;
    final result = validateResponse(response);

    if (result == null || result.items.isEmpty) {
      return null;
    }

    // Return the first match (there should only be one)
    return result.items.first;
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
