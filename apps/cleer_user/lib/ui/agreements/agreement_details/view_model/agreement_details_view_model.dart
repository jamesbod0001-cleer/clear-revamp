import 'package:cleer/domain/use_cases/agreement/agreement_use_case.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'agreement_details_view_model.g.dart';

@riverpod
class AgreementDetailsViewModel extends _$AgreementDetailsViewModel {
  // final _log = AmplifyLogger("AgreementDetailsViewModel");

  @override
  FutureOr<Agreement> build(String agreementId) async {
    final agreementResult = await ref
        .read(agreementUseCaseProvider.notifier)
        .getAgreement(agreementId);
    return agreementResult.getOrThrow();
  }
}
