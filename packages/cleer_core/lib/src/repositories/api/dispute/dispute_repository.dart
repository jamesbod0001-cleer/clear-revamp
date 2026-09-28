import 'package:cleer_core/cleer_core.dart';
import 'package:result_dart/result_dart.dart';

abstract class DisputeRepository {
  Future<ResultDart<Dispute, DataFailure>> createDispute(Dispute dispute);
  Future<ResultDart<Dispute, DataFailure>> getDispute(String disputeId);
  Future<ResultDart<List<Dispute>, DataFailure>> getDisputesByAgreement(
    String agreementId,
  );
  Stream<Dispute> observeAgreementDisputeUpdates(String agreementId);
  Future<ResultDart<List<StatusHistory>, DataFailure>> getDisputeStatusHistory(
    String disputeId,
  );
  Stream<StatusHistory> observeDisputeStatusHistoryCreates(String disputeId);
}
