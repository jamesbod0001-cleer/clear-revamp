import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer/domain/failures/data_failures.dart';
import 'package:cleer/domain/providers/user/user_provider.dart';
import 'package:cleer/domain/use_cases/agreement/agreement_use_case.dart';
import 'package:cleer/ui/agreements/accept_agreement/state/accept_agreement_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'accept_agreement_view_model.g.dart';

Duration? retryLogic(int retryCount, Object error) {
  if (error is UnknownDataFailure) {
    if (error.code == 'BackendException') {
      return null;
    }
  }

  if (retryCount >= 3) return null;
  return Duration(milliseconds: 200 * (1 << retryCount));
}

@Riverpod(retry: retryLogic)
class AcceptAgreementViewModel extends _$AcceptAgreementViewModel {
  final _log = AmplifyLogger("AcceptAgreementViewModel");

  @override
  FutureOr<AcceptAgreementState> build(String shortCode) async {
    await ref.watch(userProvider.future);
    final agreementPreviewResult = await ref
        .watch(agreementUseCaseProvider.notifier)
        .getAgreementPreview(shortCode);
    return agreementPreviewResult.fold(
      (agreementPreview) {
        return AcceptAgreementState(agreementPreview: agreementPreview);
      },
      (failure) {
        throw failure;
      },
    );
  }
}
