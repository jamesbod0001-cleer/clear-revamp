import 'package:cleer_core/cleer_core.dart';
import 'package:result_dart/result_dart.dart';

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

  Future<ResultDart<List<StatusHistory>, DataFailure>>
  getMilestoneStatusHistory(String milestoneId);
  Stream<StatusHistory> observeMilestoneStatusHistoryCreates(
    String milestoneId,
  );
}
