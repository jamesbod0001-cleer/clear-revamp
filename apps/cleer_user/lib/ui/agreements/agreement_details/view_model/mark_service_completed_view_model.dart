import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer/domain/use_cases/agreement/agreement_use_case.dart';
import 'package:cleer/domain/use_cases/milestone/milestone_use_case.dart';
import 'package:cleer_core/models/agreement/agreement_enums.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'mark_service_completed_view_model.g.dart';

@riverpod
class MarkServiceCompletedViewModel extends _$MarkServiceCompletedViewModel {
  final _log = AmplifyLogger("MarkServiceCompletedViewModel");

  @override
  FutureOr<void> build(String agreementId) {}

  Future<void> markCompleted() async {
    _log.info(
      'Attempting to mark service as completed for agreement: $agreementId',
    );

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
        final milestoneResult = await ref
            .read(milestoneUseCaseProvider.notifier)
            .getMilestone(activeMilestoneId);

        if (milestoneResult.isError()) {
          _log.error('Error getting milestone $activeMilestoneId');
          state = AsyncValue.error(
            milestoneResult.exceptionOrNull()!,
            StackTrace.current,
          );
          return;
        }

        final milestone = milestoneResult.getOrNull()!;
        _log.info('Successfully retrieved milestone $activeMilestoneId');

        final updateMilestoneResult = await ref
            .read(milestoneUseCaseProvider.notifier)
            .updateMilestone(milestone.copyWith(status: .readyForRelease));

        updateMilestoneResult.fold(
          (updatedMilestone) {
            _log.info(
              'Successfully marked milestone $activeMilestoneId as completed (readyForRelease)',
            );
          },
          (failure) {
            _log.error(
              'Error marking milestone $activeMilestoneId as completed',
              failure,
            );
            state = AsyncValue.error(failure, StackTrace.current);
          },
        );
      } else {
        final updateAgreementResult = await ref
            .read(agreementUseCaseProvider.notifier)
            .updateAgreement(agreement.copyWith(status: .readyForRelease));

        updateAgreementResult.fold(
          (updatedAgreement) {
            _log.info(
              'Successfully marked one-time service as completed for agreement $agreementId',
            );
          },
          (failure) {
            _log.error(
              'Error marking service as completed for agreement $agreementId',
              failure,
            );
            state = AsyncValue.error(failure, StackTrace.current);
          },
        );
      }
    } catch (e, stack) {
      _log.error('Unexpected crash in mark service completed flow', e);
      state = AsyncValue.error(e, stack);
    } finally {
      // Safely release the provider lock so Riverpod can clean it up
      keepAliveLink.close();
    }
  }
}
