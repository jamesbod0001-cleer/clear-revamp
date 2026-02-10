import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer/data/amplify_models/Agreement.dart';
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

  Future<Agreement> createAgreement(Agreement agreement) async {
    final request = ModelMutations.create(
      agreement,
      authorizationMode: APIAuthorizationType.userPools,
    );
    final response = await _amplifyAPI.mutate(request: request).response;
    return validateRequiredResponse(response);
  }
}
