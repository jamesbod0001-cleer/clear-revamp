import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer/domain/providers/agreement/agreement_provider.dart';
import 'package:cleer/domain/use_cases/agreement/agreement_use_case.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'agreement_details_view_model.g.dart';

@riverpod
class AgreementDetailsViewModel extends _$AgreementDetailsViewModel {
  final _log = AmplifyLogger("AgreementDetailsViewModel");

  @override
  FutureOr<Agreement> build(String agreementId) async {
    return ref.watch(agreementDetailsProvider(agreementId).future);
  }

  Future<bool> cancelAgreement() async {
    final currentAgreement = state.value;
    if (currentAgreement == null) return false;

    final keepAliveLink = ref.keepAlive();
    state = const AsyncValue.loading();

    try {
      _log.info('Cancelling agreement ${currentAgreement.id}');
      final updatedAgreement = currentAgreement.copyWith(
        status: AgreementStatus.cancelled,
      );

      final result = await ref
          .read(agreementUseCaseProvider.notifier)
          .updateAgreement(updatedAgreement);

      final success = result.fold(
        (agreement) {
          _log.info('Successfully cancelled agreement: ${agreement.id}');
          return true;
        },
        (failure) {
          _log.error('Error cancelling agreement', failure);
          state = AsyncValue.error(failure, StackTrace.current);
          return false;
        },
      );
      return success;
    } catch (e, stack) {
      _log.error('Unexpected error cancelling agreement', e);
      state = AsyncValue.error(e, stack);
      return false;
    } finally {
      keepAliveLink.close();
    }
  }
}
