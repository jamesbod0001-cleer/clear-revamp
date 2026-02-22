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
}
