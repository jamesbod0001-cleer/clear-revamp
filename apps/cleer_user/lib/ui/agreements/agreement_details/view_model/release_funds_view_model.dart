import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer/domain/use_cases/agreement/agreement_use_case.dart';
import 'package:cleer/domain/use_cases/milestone/milestone_use_case.dart';
import 'package:cleer_core/models/agreement/agreement_enums.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'release_funds_view_model.g.dart';

@riverpod
class ReleaseFundsViewModel extends _$ReleaseFundsViewModel {
  final _log = AmplifyLogger("ReleaseFundsViewModel");

  @override
  FutureOr<void> build(String agreementId) {}

  Future<void> releaseFunds() async {
    _log.info('Attempting to release funds for agreement: $agreementId');

    // Prevent premature disposal when the parent widget unmounts this card
    final keepAliveLink = ref.keepAlive();
    state = const AsyncValue.loading();

    try {
      final agreementResult = await ref
          .read(agreementUseCaseProvider.notifier)
          .getAgreement(agreementId);

      if (agreementResult.isError()) {
        _log.error('Error getting agreement $agreementId');
        state = AsyncValue.error(
          agreementResult.exceptionOrNull()!,
          StackTrace.current,
        );
        return;
      }

      final agreement = agreementResult.getOrNull()!;
      _log.info('Successfully retrieved agreement $agreementId');

      final isMilestone =
          agreement.disbursementType == DisbursementType.milestones;
      final activeMilestoneId = agreement.activeMilestoneId;

      if (isMilestone && activeMilestoneId != null) {
        final milestoneReleaseFundsResult = await ref
            .read(milestoneUseCaseProvider.notifier)
            .releaseFunds(activeMilestoneId);

        if (milestoneReleaseFundsResult.isError()) {
          _log.error('Error releasing funds for milestone $activeMilestoneId');
          state = AsyncValue.error(
            milestoneReleaseFundsResult.exceptionOrNull()!,
            StackTrace.current,
          );
          return;
        }
        _log.info(
          'Successfully released funds for milestone $activeMilestoneId',
        );
      } else {
        final agreementReleaseFundsResult = await ref
            .read(agreementUseCaseProvider.notifier)
            .releaseFunds(agreementId);

        if (agreementReleaseFundsResult.isError()) {
          _log.error('Error releasing funds for agreement $agreementId');
          state = AsyncValue.error(
            agreementReleaseFundsResult.exceptionOrNull()!,
            StackTrace.current,
          );
          return;
        }
        _log.info('Successfully released funds for agreement $agreementId');
      }
    } catch (e, stack) {
      _log.error('Unexpected crash in release funds flow', e);
      state = AsyncValue.error(e, stack);
    } finally {
      // Safely release the provider lock so Riverpod can clean it up
      keepAliveLink.close();
    }
  }
}
