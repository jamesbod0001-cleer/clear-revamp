import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer/domain/use_cases/agreement/agreement_use_case.dart';
import 'package:cleer/domain/use_cases/milestone/milestone_use_case.dart';
import 'package:cleer_core/cleer_core.dart';
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
    final agreementPreviewResult = await ref
        .read(agreementUseCaseProvider.notifier)
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

  Future<Agreement> _joinAndGetAgreement() async {
    final joinAgreementResult = await ref
        .read(agreementUseCaseProvider.notifier)
        .joinAgreement(shortCode);
    return joinAgreementResult.fold(
      (agreementId) async {
        _log.info('Successfully joined agreement: $agreementId');
        final agreementResult = await ref
            .read(agreementUseCaseProvider.notifier)
            .getAgreement(agreementId);
        if (agreementResult.isError()) {
          _log.error(
            'Error retrieving agreement',
            agreementResult.exceptionOrNull(),
          );
          throw agreementResult.exceptionOrNull()!;
        }
        final agreement = agreementResult.getOrNull()!;
        return agreement;
      },
      (failure) {
        _log.error('Error joining agreement', failure);
        throw failure;
      },
    );
  }

  Future<void> acceptAgreementAsRecipient() async {
    state = AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final agreement = await _joinAndGetAgreement();
      if (agreement.initiatorRole == InitiatorRole.sender &&
          agreement.status == AgreementStatus.awaitingRecipient) {
        // Hit the 'Funded' state so the tracker picks it up
        _log.info('Transitioning to FUNDED for status tracker');
        final fundedAgreement = agreement.copyWith(status: .funded);
        final fundedResult = await ref
            .read(agreementUseCaseProvider.notifier)
            .updateAgreement(fundedAgreement);

        if (fundedResult.isError()) {
          _log.error(
            'Error updating agreement to funded',
            fundedResult.exceptionOrNull(),
          );
          throw fundedResult.exceptionOrNull()!;
        }

        // Immediately advance to 'In Progress'
        _log.info('Transitioning to IN_PROGRESS');

        // Initialize the delivery context if it's physical goods
        PhysicalDeliveryContext? initialDeliveryContext;
        if (agreement.category == .physicalGoods) {
          initialDeliveryContext = PhysicalDeliveryContext(
            status: PhysicalDeliveryContextStatus.awaitingPackaging,
          );
        }

        final inProgressAgreement = fundedResult.getOrNull()!.copyWith(
          status: .inProgress,
          physicalDeliveryContext: initialDeliveryContext,
        );
        final inProgressResult = await ref
            .read(agreementUseCaseProvider.notifier)
            .updateAgreement(inProgressAgreement);

        if (inProgressResult.isError()) {
          _log.error(
            'Error updating agreement to in progress',
            inProgressResult.exceptionOrNull(),
          );
          throw inProgressResult.exceptionOrNull()!;
        }

        // Activate the First Milestone
        if (inProgressAgreement.disbursementType ==
            DisbursementType.milestones) {
          _log.info('Activating first milestone');
          final milestonesResult = await ref
              .read(milestoneUseCaseProvider.notifier)
              .getMilestonesByAgreement(inProgressAgreement.id!);

          if (milestonesResult.isError()) {
            _log.error(
              'Error retrieving milestones',
              milestonesResult.exceptionOrNull(),
            );
            throw milestonesResult.exceptionOrNull()!;
          }

          final milestones = milestonesResult.getOrNull()!;
          final firstMilestone = milestones
              .where((m) => m.order == 0)
              .firstOrNull;

          if (firstMilestone == null) {
            throw DataFailure.unknown(message: 'No milestones found');
          }

          final updatedMilestone = firstMilestone.copyWith(status: .inProgress);
          final milestoneResult = await ref
              .read(milestoneUseCaseProvider.notifier)
              .updateMilestone(updatedMilestone);

          if (milestoneResult.isError()) {
            _log.error(
              'Error updating milestone to in progress',
              milestoneResult.exceptionOrNull(),
            );
            return throw milestoneResult.exceptionOrNull()!;
          }
        }
        // Success! Everything was tracked and advanced properly.
        return state.value!.copyWith(
          agreement: inProgressResult.getOrNull()!,
          currentStep: .success,
        );
      }
      throw DataFailure.unknown(message: 'Invalid agreement status');
    });
  }

  Future<void> acceptAgreementAsSender() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final agreement = await _joinAndGetAgreement();

      return state.value!.copyWith(
        agreement: agreement,
        currentStep: AcceptAgreementStep.payment,
      );
    });
  }

  /// Pure function to evaluate if the current user is legally allowed to accept the agreement.
  /// Returns a String error message if they are not eligible, or null if they are.
  EligibilityErrorType? getEligibilityError(
    User? user,
    AgreementPreview? preview,
  ) {
    // If no user or preview, no errors. Guests can click buttons to trigger the login flow!
    if (user == null || preview == null) return null;

    // You cannot accept your own agreement
    if (preview.initiator?.id == user.id) {
      return EligibilityErrorType.cannotAcceptOwn;
    }

    // Logic if the initiator was the SENDER
    if (preview.initiatorRole == InitiatorRole.sender) {
      if (preview.recipient != null) {
        return user.id == preview.recipient!.id
            ? null
            : EligibilityErrorType.notTheRecipient;
      } else {
        return IdentityUtils.isNameMatch(
              userName: user.fullName,
              bankAccountName: preview.recipientAccountName ?? '',
            )
            ? null
            : EligibilityErrorType.nameMismatch;
      }
    }

    // Logic if the initiator was the RECIPIENT
    if (preview.initiatorRole == InitiatorRole.recipient) {
      if (preview.sender != null && preview.sender!.id != user.id) {
        return EligibilityErrorType.doesNotBelongToYou;
      }
    }
    return null;
  }

  void goToSuccessStep(Agreement updatedAgreement) {
    if (state.value != null) {
      state = AsyncValue.data(
        state.value!.copyWith(
          agreement: updatedAgreement,
          currentStep: AcceptAgreementStep.success,
        ),
      );
    }
  }

  Future<void> declineAgreement() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final agreement = await _joinAndGetAgreement();
      final updateResult = await ref
          .read(agreementUseCaseProvider.notifier)
          .updateAgreement(agreement.copyWith(status: .rejected));
      return updateResult.fold(
        (updatedAgreement) {
          return state.value!.copyWith(agreement: updatedAgreement);
        },
        (failure) {
          throw failure;
        },
      );
    });
  }
}
