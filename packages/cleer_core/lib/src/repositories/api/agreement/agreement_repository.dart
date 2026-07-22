import 'package:cleer_core/cleer_core.dart';
import 'package:cleer_core/models/paginated_list/paginated_list.dart';
import 'package:result_dart/result_dart.dart';

abstract class AgreementRepository {
  Future<ResultDart<Agreement, DataFailure>> getAgreement(String id);
  Future<ResultDart<Agreement, DataFailure>> createAgreement(
    Agreement agreement,
  );
  Future<ResultDart<Agreement, DataFailure>> updateAgreement(
    Agreement agreement, {
    required String currentUserId,
  });

  Future<ResultDart<List<Agreement>, DataFailure>> getUserOngoingAgreements();
  Future<ResultDart<PaginatedList<Agreement>, DataFailure>>
  getUserCompletedAgreements({dynamic nextRequest});
  Stream<Agreement> observeUserAgreementsUpdates();

  Future<ResultDart<List<StatusHistory>, DataFailure>>
  getAgreementStatusHistory(String agreementId);
  Stream<StatusHistory> observeAgreementStatusHistoryCreates(
    String agreementId,
  );

  Future<ResultDart<AgreementPreview, DataFailure>> getAgreementPreview(
    String shortCode,
  );
  Future<ResultDart<String, DataFailure>> joinAgreement(String shortCode);
  Future<ResultDart<Agreement, DataFailure>> releaseFunds(
    String id, {
    required String currentUserId,
  });
}
