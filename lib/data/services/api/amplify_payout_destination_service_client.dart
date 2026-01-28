import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer/data/amplify_models/ModelProvider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cleer/data/services/amplify_providers.dart';
import 'package:cleer/data/services/api/mixins/api_error_checker.dart';

part 'amplify_payout_destination_service_client.g.dart';

@riverpod
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
}
