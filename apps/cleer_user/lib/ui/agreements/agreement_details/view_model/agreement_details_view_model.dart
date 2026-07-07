import 'package:cleer/domain/providers/agreement/agreement_provider.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'agreement_details_view_model.g.dart';

@riverpod
class AgreementDetailsViewModel extends _$AgreementDetailsViewModel {
  // final _log = AmplifyLogger("AgreementDetailsViewModel");

  @override
  FutureOr<Agreement> build(String agreementId) async {
    return ref.watch(agreementDetailsProvider(agreementId).future);
  }
}
