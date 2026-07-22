import 'package:amplify_flutter/amplify_flutter.dart' hide SignedOutException;
import 'package:cleer/domain/providers/user/user_provider.dart';
import 'package:cleer/ui/agreements/create_agreement/state/create_agreement_state.dart';
import 'package:cleer_api/cleer_api.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:cleer_core/models/recipient_resolution/recipient_resolution.dart';
import 'package:cleer_core/utils/short_code_generator.dart';
import 'package:result_dart/result_dart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'agreement_use_case.g.dart';

@Riverpod(keepAlive: true)
class AgreementUseCase extends _$AgreementUseCase {
  late final AgreementRepository _agreementRepository;
  late final FlutterwaveRepository _flutterwaveRepository;
  late final PayoutDestinationRepository _payoutDestinationRepository;
  late final MilestoneRepository _milestoneRepository;

  final _log = AmplifyLogger("AgreementUseCase");

  @override
  void build() {
    _agreementRepository = ref.watch(agreementRepositoryProvider);
    _flutterwaveRepository = ref.watch(flutterwaveRepositoryProvider);
    _payoutDestinationRepository = ref.watch(
      payoutDestinationRepositoryProvider,
    );
    _milestoneRepository = ref.watch(milestoneRepositoryProvider);
    return;
  }

  Future<ResultDart<Agreement, DataFailure>> updateAgreement(
    Agreement agreement,
  ) async {
    _log.info('Attempting to get user');
    final user = ref.read(userProfileProvider).value;
    if (user == null) {
      _log.error('User state is missing');
      return Failure(DataFailure.notFound());
    }

    _log.info('Updating agreement: $agreement');
    final result = await _agreementRepository.updateAgreement(
      agreement,
      currentUserId: user.id,
    );
    result.fold(
      (agreement) {
        _log.info('Agreement updated: $agreement');
      },
      (failure) {
        _log.error('Error updating agreement', failure);
        throw failure;
      },
    );
    return result;
  }

  Future<ResultDart<RecipientResolution, Object>> resolveRecipientDetails({
    required String accountNumber,
    required String bankCode,
  }) async {
    _log.info('Attempting to get user');
    final user = ref.read(userProfileProvider).value;
    if (user == null) {
      _log.error('User state is missing');
      return Failure(DataFailure.notFound());
    }

    _log.info('Attempting to resolve recipient details');

    final resolveAccountResult = await _flutterwaveRepository.resolveAccount(
      ResolveAccountParams(bankCode: bankCode, accountNumber: accountNumber),
    );

    return await resolveAccountResult.fold(
      (resolvedName) async {
        _log.info('Successfully resolved name via API: $resolvedName');

        /// TODO: Here I will check if this account belongs to the user

        final fullName = "${user.firstName} ${user.lastName}";

        final isMatch = IdentityUtils.isNameMatch(
          userName: fullName,
          bankAccountName: resolvedName,
        );

        if (isMatch) {
          _log.warn("You can't send money to yourself");
          // Throw a custom failure that Cleer can catch and show in the UI
          throw DataFailure.selfTransferFailure(accountName: resolvedName);
        }

        final existingPayoutResult = await _payoutDestinationRepository
            .getPayoutDestination(
              GetPayoutDestinationParams(
                accountNumber: accountNumber,
                bankCode: bankCode,
              ),
            );

        return existingPayoutResult.fold(
          (option) {
            return option.fold(
              () {
                _log.info(
                  'User not found on Cleer. Proceeding as new recipient.',
                );
                return Success(
                  RecipientResolution(
                    accountName: resolvedName, // Use name from Flutterwave
                    accountNumber: accountNumber,
                    bankCode: bankCode,
                    isRegisteredUser: false,
                  ),
                );
              },
              (payout) {
                _log.info(payout.toString());
                if (payout.user != null) {
                  _log.info('User found on Cleer: ${payout.user!.firstName}');
                  if (payout.user!.id == user.id) {
                    _log.warn('User is the same as the initiator');
                    _log.warn("You can't send money to yourself");
                    // Throw a custom failure that Cleer can catch and show in the UI
                    throw DataFailure.selfTransferFailure(
                      accountName: payout.accountName,
                    );
                  }
                } else {
                  _log.info('User not found on Cleer');

                  /// TODO: Maybe we can add a suspicious tag here, for this
                  _log.info(
                    'Payout destination exists for user, resolved name is: ${payout.accountName}',
                  );
                }
                return Success(
                  RecipientResolution(
                    accountName: payout.accountName,
                    accountNumber: payout.accountNumber,
                    bankCode: payout.bankCode,
                    recipient: payout.user, // Link to existing User object
                    isRegisteredUser: payout.user != null,
                    payoutDestination: payout,
                  ),
                );
              },
            );
          },
          (failure) {
            _log.error('Database error checking payout destination', failure);
            return Failure(failure);
          },
        );
      },
      (failure) {
        _log.error('Flutterwave resolve failed', failure);
        return Failure(failure);
      },
    );
  }

  Future<ResultDart<Agreement, DataFailure>> initiateAgreement(
    CreateAgreementFormData formData,
  ) async {
    _log.info('Initiating agreement...');

    _log.info('Attempting to get user/initiator');
    final initiator = ref.read(userProfileProvider).value;
    if (initiator == null) {
      _log.error('User state is missing during update');
      return Failure(DataFailure.notFound());
    }

    PayoutDestination? payoutDestination;

    if (formData.initiatorRole == .sender) {
      _log.info('Initiator is sender');
      if (formData.recipientResolution!.payoutDestination != null) {
        _log.info('Using existing payout destination');
        payoutDestination = formData.recipientResolution!.payoutDestination!;
      } else {
        _log.info('Creating new payout destination');
        final recipientResolution = formData.recipientResolution!;

        final payoutDestinationResult = await _payoutDestinationRepository
            .createPayoutDestination(
              PayoutDestination(
                accountNumber: recipientResolution.accountNumber,
                bankCode: recipientResolution.bankCode,
                bankName: formData.recipientBank!.name,
                accountName: recipientResolution.accountName,
              ),
            );
        if (payoutDestinationResult.isError()) {
          final failure = payoutDestinationResult.exceptionOrNull();
          _log.error('Error creating payout destination', failure);
          return Failure(failure!);
        }
        _log.info('Successfully created payout destination');
        payoutDestination = payoutDestinationResult.getOrThrow();
      }
    } else {
      _log.info('Initiator is recipient');
      payoutDestination = formData.payoutDestination;
    }

    User? sender = formData.initiatorRole == .sender ? initiator : null;
    User? recipient = formData.initiatorRole == .recipient
        ? initiator
        : payoutDestination?.user;

    Agreement agreement = Agreement(
      id: null,
      shortCode: ShortCodeGenerator.generate(),
      amount: double.parse(formData.amount),
      currency: 'NGN',
      disbursementType: formData.disbursementType!,
      category: formData.category!,
      expectedReleaseDate: formData.disbursementType == .milestones
          ? null
          : formData.releaseDate,
      description: formData.description,
      payoutDestination: payoutDestination,
      initiatorRole: formData.initiatorRole,
      status: .draft,
      initiator: initiator,
      sender: sender,
      recipient: recipient,
      participants: [
        if (sender != null) sender.id,
        if (recipient != null) recipient.id,
      ],
      lastUpdatedBy: initiator.id,
    );
    _log.info('Attempting to create agreement');
    final result = await _agreementRepository.createAgreement(agreement);

    return await result.fold(
      (createdAgreement) async {
        _log.info('Successfully created agreement');
        // createdAgreement = createdAgreement.copyWith(status: .awaitingFunding);
        if (createdAgreement.initiatorRole == .recipient) {
          _log.info(createdAgreement.createdAt.toString());
          await _agreementRepository.updateAgreement(
            createdAgreement.copyWith(status: .awaitingFunding),
            currentUserId: initiator.id,
          );
        }
        if (createdAgreement.disbursementType == .milestones) {
          List<Milestone> milestones = formData.milestones!
              .asMap()
              .map((index, milestone) {
                return MapEntry(
                  index,
                  Milestone(
                    id: null,
                    order: index,
                    name: milestone.name,
                    amount: milestone.amount,
                    status: .pending,
                    expectedReleaseDate: milestone.releaseDate!,
                    agreement: createdAgreement,
                    participants: createdAgreement.participants,
                    lastUpdatedBy: initiator.id,
                  ),
                );
              })
              .values
              .toList();
          final createMilestoneTasks = milestones.map((milestone) async {
            final result = await _milestoneRepository.createMilestone(
              milestone,
            );
            return result.fold(
              (milestone) {
                _log.info('Successfully created milestone: ${milestone.order}');
                return Success(milestone);
              },
              (failure) {
                _log.error('Error creating milestone', failure);
                return Failure(failure);
              },
            );
          });
          await Future.wait(createMilestoneTasks);
        }
        return Success(createdAgreement);
      },
      (failure) {
        _log.error('Error creating agreement', failure);
        return Failure(failure);
      },
    );
  }

  Future<ResultDart<Agreement, DataFailure>> getAgreement(String id) async {
    _log.info('Attempting to get agreement');
    final result = await _agreementRepository.getAgreement(id);
    result.fold(
      (agreement) {
        _log.info('Successfully retrieved agreement');
      },
      (failure) {
        _log.error('Error retrieving agreement', failure);
        return Failure(failure);
      },
    );
    return result;
  }

  Future<ResultDart<Agreement, DataFailure>> processFundingSuccess(
    String id,
  ) async {
    _log.info('Attempting to get user');
    final user = ref.read(userProfileProvider).value;
    if (user == null) {
      _log.error('User state is missing');
      return Failure(DataFailure.notFound());
    }

    _log.info('Attempting to process funding success');
    final agreementResult = await _agreementRepository.getAgreement(id);
    if (agreementResult.isError()) {
      _log.error(
        'Error retrieving agreement',
        agreementResult.exceptionOrNull(),
      );
      return Failure(agreementResult.exceptionOrNull()!);
    }

    final agreement = agreementResult.getOrNull()!;

    // IDEMPOTENCY CHECK: Did the webhook already do this? Or is the agreement already in a terminal state?
    if ([
      AgreementStatus.awaitingRecipient,
      AgreementStatus.funded,
      AgreementStatus.inProgress,
      AgreementStatus.cancelled,
      AgreementStatus.rejected,
    ].contains(agreement.status)) {
      _log.info('Agreement already advanced by webhook. Returning success.');
      return Success(agreement);
    }

    // HANDLE SENDER SCENARIO (Only one step)
    if (agreement.initiatorRole == InitiatorRole.sender &&
        agreement.status == .draft) {
      final updated = agreement.copyWith(status: .awaitingRecipient);
      return await _agreementRepository.updateAgreement(
        updated,
        currentUserId: user.id,
      );
    }

    // HANDLE RECIPIENT SCENARIO (The Two-Step Tracker Requirement)
    if (agreement.initiatorRole == InitiatorRole.recipient &&
        agreement.status == .awaitingFunding) {
      // Hit the 'Funded' state so the tracker picks it up
      _log.info('Transitioning to FUNDED for status tracker');
      final fundedAgreement = agreement.copyWith(status: .funded);
      final fundedResult = await _agreementRepository.updateAgreement(
        fundedAgreement,
        currentUserId: user.id,
      );

      if (fundedResult.isError()) {
        _log.error(
          'Error updating agreement to funded',
          fundedResult.exceptionOrNull(),
        );
        return Failure(fundedResult.exceptionOrNull()!);
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
      final inProgressResult = await _agreementRepository.updateAgreement(
        inProgressAgreement,
        currentUserId: user.id,
      );

      if (inProgressResult.isError()) {
        _log.error(
          'Error updating agreement to in progress',
          inProgressResult.exceptionOrNull(),
        );
        return Failure(inProgressResult.exceptionOrNull()!);
      }

      // Activate the First Milestone
      if (inProgressAgreement.disbursementType == DisbursementType.milestones) {
        _log.info('Activating first milestone');
        final milestonesResult = await _milestoneRepository
            .getMilestonesByAgreement(inProgressAgreement.id!);

        if (milestonesResult.isError()) {
          _log.error(
            'Error retrieving milestones',
            milestonesResult.exceptionOrNull(),
          );
          return Failure(milestonesResult.exceptionOrNull()!);
        }

        final milestones = milestonesResult.getOrNull()!;
        final firstMilestone = milestones
            .where((m) => m.order == 0)
            .firstOrNull;

        if (firstMilestone == null) {
          return Failure(DataFailure.unknown(message: 'No milestones found'));
        }

        final updatedMilestone = firstMilestone.copyWith(status: .inProgress);
        final milestoneResult = await _milestoneRepository.updateMilestone(
          updatedMilestone,
          currentUserId: user.id,
        );

        if (milestoneResult.isError()) {
          _log.error(
            'Error updating milestone to in progress',
            milestoneResult.exceptionOrNull(),
          );
          return Failure(milestoneResult.exceptionOrNull()!);
        }
      }
      // Success! Everything was tracked and advanced properly.
      return Success(inProgressResult.getOrNull()!);
    }

    return Failure(DataFailure.unknown(message: 'Invalid agreement status'));
  }

  Future<ResultDart<AgreementPreview, DataFailure>> getAgreementPreview(
    String shortCode,
  ) async {
    _log.info('Attempting to get agreement preview');
    final result = await _agreementRepository.getAgreementPreview(shortCode);
    result.fold(
      (agreementPreview) {
        _log.info('Successfully retrieved agreement preview');
      },
      (failure) {
        _log.error('Error retrieving agreement preview', failure);
        throw failure;
      },
    );
    return result;
  }

  Future<ResultDart<String, DataFailure>> joinAgreement(
    String shortCode,
  ) async {
    _log.info('Attempting to join agreement');
    final result = await _agreementRepository.joinAgreement(shortCode);
    result.fold(
      (agreementPreview) {
        _log.info('Successfully joined agreement');
      },
      (failure) {
        _log.error('Error joining agreement', failure);
        throw failure;
      },
    );
    return result;
  }

  Future<ResultDart<Agreement, DataFailure>> releaseFunds(String id) async {
    _log.info('Attempting to get user');
    final user = ref.read(userProfileProvider).value;
    if (user == null) {
      _log.error('User state is missing');
      return Failure(DataFailure.notFound());
    }

    _log.info('Attempting to release funds for agreement: $id');
    final result = await _agreementRepository.releaseFunds(
      id,
      currentUserId: user.id,
    );
    result.fold(
      (agreement) {
        _log.info('Successfully released funds for agreement');
      },
      (failure) {
        _log.error('Error releasing funds for agreement', failure);
        return Failure(failure);
      },
    );
    return result;
  }
}
