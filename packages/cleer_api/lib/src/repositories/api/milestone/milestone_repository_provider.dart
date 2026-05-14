import 'package:cleer_api/src/repositories/api/milestone/amplify_milestone_repository_impl.dart';
import 'package:cleer_api/src/services/api/amplify_milestone_service_client.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'milestone_repository_provider.g.dart';

@riverpod
MilestoneRepository milestoneRepository(Ref ref) =>
    AmplifyMilestoneRepositoryImpl(
      amplifyMilestoneServiceClient: ref.watch(
        amplifyMilestoneServiceClientProvider,
      ),
    );
