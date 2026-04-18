import 'package:cleer/data/repositories/api/milestone/amplify_milestone_repository_impl.dart';
import 'package:cleer/data/services/api/amplify_milestone_service_client.dart';
import 'package:cleer/domain/models/milestone/milestone.dart';
import 'package:cleer/domain/models/status_history/status_history.dart';
import 'package:result_dart/result_dart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cleer/domain/failures/data_failures.dart';

part 'milestone_repository.g.dart';

@riverpod
MilestoneRepository milestoneRepository(Ref ref) =>
    AmplifyMilestoneRepositoryImpl(
      amplifyMilestoneServiceClient: ref.watch(
        amplifyMilestoneServiceClientProvider,
      ),
    );

abstract class MilestoneRepository {
  Future<ResultDart<List<Milestone>, DataFailure>> getMilestonesByAgreement(
    String agreementId,
  );
  Future<ResultDart<Milestone, DataFailure>> createMilestone(
    Milestone milestone,
  );
  Future<ResultDart<Milestone, DataFailure>> updateMilestone(
    Milestone milestone, {
    required String currentUserId,
  });

  Stream<Milestone> observeAgreementMilestonesUpdates(String agreementId);

  Future<ResultDart<List<StatusHistory>, DataFailure>> getMilestoneStatusHistory(String milestoneId);
  Stream<StatusHistory> observeMilestoneStatusHistoryCreates(String milestoneId);
}
