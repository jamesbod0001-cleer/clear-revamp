import 'package:cleer_api/src/repositories/api/activity/amplify_activity_repository_impl.dart';
import 'package:cleer_api/src/services/api/amplify_activity_service_client.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'activity_repository_provider.g.dart';

@riverpod
ActivityRepository activityRepository(Ref ref) =>
    AmplifyActivityRepositoryImpl(
      amplifyActivityServiceClient: ref.watch(
        amplifyActivityServiceClientProvider,
      ),
    );
