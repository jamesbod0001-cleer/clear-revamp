import 'package:cleer/data/repositories/api/agreement/amplify_agreement_repository_impl.dart';
import 'package:cleer/data/services/api/amplify_agreement_service_client.dart';
import 'package:cleer/domain/models/agreement/agreement.dart';
import 'package:cleer/domain/models/agreement/agreement_preview.dart';
import 'package:cleer/domain/models/paginated_list/paginated_list.dart';
import 'package:result_dart/result_dart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cleer/domain/failures/data_failures.dart';

part 'agreement_repository.g.dart';

@riverpod
AgreementRepository agreementRepository(Ref ref) =>
    AmplifyAgreementRepositoryImpl(
      amplifyAgreementServiceClient: ref.watch(
        amplifyAgreementServiceClientProvider,
      ),
    );

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
  Future<ResultDart<PaginatedList<Agreement>, DataFailure>> getUserCompletedAgreements({dynamic nextRequest});
  Stream<Agreement> observeUserAgreementsCreates();
  Stream<Agreement> observeUserAgreementsUpdates();

  Future<ResultDart<AgreementPreview, DataFailure>> getAgreementPreview(String shortCode);
}
