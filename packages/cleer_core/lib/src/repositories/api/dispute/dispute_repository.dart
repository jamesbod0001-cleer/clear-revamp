import 'package:cleer_core/cleer_core.dart';
import 'package:result_dart/result_dart.dart';

abstract class DisputeRepository {
  Future<ResultDart<Dispute, DataFailure>> createDispute(Dispute dispute);
  Future<ResultDart<Dispute, DataFailure>> getDispute(String disputeId);
}
