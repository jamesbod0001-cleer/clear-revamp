import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cleer/data/services/amplify_providers.dart';
import 'package:cleer/data/services/api/mixins/api_error_checker.dart';

part 'amplify_user_service_client.g.dart';

@riverpod
AmplifyUserServiceClient amplifyUserServiceClient(Ref ref) =>
    AmplifyUserServiceClient(amplifyAPI: ref.watch(amplifyAPIProvider));

class AmplifyUserServiceClient with ApiErrorChecker {
  final APICategory _amplifyAPI;

  AmplifyUserServiceClient({required APICategory amplifyAPI})
    : _amplifyAPI = amplifyAPI;
}
