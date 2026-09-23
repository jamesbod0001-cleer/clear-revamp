import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer_api/src/models/Dispute.dart';
import 'package:cleer_api/src/services/amplify_providers.dart';
import 'package:cleer_api/src/services/api/mixins/api_error_checker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'amplify_dispute_service_client.g.dart';

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
}
