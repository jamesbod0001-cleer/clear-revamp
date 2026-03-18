import 'package:amplify_flutter/amplify_flutter.dart' hide SignedOutException;
import 'package:cleer/data/repositories/api/agreement/agreement_repository.dart';
import 'package:cleer/data/repositories/api/milestone/milestone_repository.dart';
import 'package:cleer/data/repositories/api/payout_destination/payout_destination_repository.dart';
import 'package:cleer/data/repositories/flutterwave/flutterwave_repository.dart';
import 'package:cleer/domain/failures/data_failures.dart';
import 'package:cleer/domain/models/user/user.dart';
import 'package:cleer/domain/models/agreement/agreement.dart';
import 'package:cleer/domain/models/agreement/agreement_enums.dart';
import 'package:cleer/domain/models/milestone/milestone.dart';
import 'package:cleer/domain/models/payout_destination/payout_destination.dart';
import 'package:cleer/domain/models/recipient_resolution/recipient_resolution.dart';
import 'package:cleer/domain/providers/user/user_provider.dart';
import 'package:cleer/domain/use_cases/flutterwave/params/resolve_account_params.dart';
import 'package:cleer/domain/use_cases/payout_destination/params/get_payout_destination_params.dart';
import 'package:cleer/ui/agreements/create_agreement/state/create_agreement_state.dart';
import 'package:cleer/utils/short_code_generator.dart';
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
    final user = ref.read(userProvider).value;
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

  /// TODO I will remove this from here later
  bool _isNameMatch({
    required String userName,
    required String resolveAccountName,
  }) {
    // 1. Normalize both strings: lowercase and remove extra whitespace
    final userTokens = userName
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((t) => t.length > 1)
        .toSet();
    final bankTokens = resolveAccountName
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((t) => t.length > 1)
        .toSet();

    // 2. Check if all parts of the User's name are present in the Bank's name
    // We use .every to ensure the User's First AND Last names are both there.
    return userTokens.every((token) => bankTokens.contains(token));
  }

  Future<ResultDart<RecipientResolution, Object>> resolveRecipientDetails({
    required String accountNumber,
    required String bankCode,
  }) async {
    _log.info('Attempting to get user');
    final user = ref.read(userProvider).value;
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

        final isMatch = _isNameMatch(
          userName: fullName,
          resolveAccountName: resolvedName,
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
    final initiator = ref.read(userProvider).value;
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

    _log.info('Here: Creating agreement');

    User? sender = formData.initiatorRole == .sender ? initiator : null;
    User? recipient = formData.initiatorRole == .recipient ? initiator : payoutDestination?.user;

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
      (agreement) async {
        _log.info('Successfully created agreement');
        if (agreement.disbursementType == .milestones) {
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
                    agreement: agreement,
                    participants: agreement.participants,
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
        return Success(agreement);
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

  Future<ResultDart<Agreement, DataFailure>> markAgreementAsFunded(
    String id,
  ) async {
    _log.info('Attempting to get user');
    final user = ref.read(userProvider).value;
    if (user == null) {
      _log.error('User state is missing');
      return Failure(DataFailure.notFound());
    }

    _log.info('Attempting to mark agreement as funded');
    final agreementResult = await _agreementRepository.getAgreement(id);
    return await agreementResult.fold(
      (agreement) async {
        _log.info('Successfully retrieved agreement');

        // 1. NEW IDEMPOTENCY CHECK: Did the webhook already do this?
        if (agreement.status == AgreementStatus.awaitingRecipient ||
            agreement.status == AgreementStatus.funded ||
            agreement.status == AgreementStatus.inProgress) {
          _log.info('Agreement already advanced by webhook. Returning success.');
          return Success(agreement);
        }

        late AgreementStatus updatedStatus;
        if (agreement.initiatorRole == InitiatorRole.sender &&
            agreement.status == .draft) {
          updatedStatus = .awaitingRecipient;
        } else if (agreement.initiatorRole == InitiatorRole.recipient &&
            agreement.status == .awaitingFunding) {
          updatedStatus = .funded;
        } else {
          _log.error('Invalid agreement status for funding');
          _log.error('Agreement current status: ${agreement.status}');
          return Failure(DataFailure.notFound());
        }
        final updatedAgreement = agreement.copyWith(status: updatedStatus);
        _log.info('Attempting to update agreement');
        final updateResult = await _agreementRepository.updateAgreement(
          updatedAgreement,
          currentUserId: user.id,
        );
        return await updateResult.fold(
          (updatedAgreement) async {
            _log.info('Successfully updated agreement');
            if (updatedAgreement.status == .funded) {
              _log.info(
                'Updating agreement to in progress because it is funded already',
              );

              /// TODO: meaning I need to take it to in progress immediately
              updatedAgreement = updatedAgreement.copyWith(status: .inProgress);
              final result = await _agreementRepository.updateAgreement(
                updatedAgreement,
                currentUserId: user.id,
              );
              if (updatedAgreement.disbursementType ==
                  DisbursementType.milestones) {
                _log.info('Updating first milestone to in progress');

                /// TODO: It should update the first milestone to in progress
                final milestonesResult = await _milestoneRepository
                    .getMilestonesByAgreement(updatedAgreement.id!);
                return await milestonesResult.fold(
                  (milestones) async {
                    final firstMilestone = milestones.where(
                      (milestone) => milestone.order == 0,
                    );
                    if (firstMilestone.isEmpty) {
                      _log.error('No milestones found for agreement');
                      return Failure(
                        DataFailure.unknown(message: 'No milestones found'),
                      );
                    } else {
                      final firstMilestoneToUpdate = firstMilestone.first;
                      final updatedMilestone = firstMilestoneToUpdate.copyWith(
                        status: .inProgress,
                      );
                      final result = await _milestoneRepository.updateMilestone(
                        updatedMilestone,
                        currentUserId: user.id,
                      );
                      return await result.fold(
                        (updatedMilestone) {
                          _log.info('Successfully updated milestone');
                          return Success(updatedAgreement);
                        },
                        (failure) {
                          _log.error('Error updating milestone', failure);
                          return Failure(failure);
                        },
                      );
                    }
                  },
                  (failure) {
                    _log.error('Error retrieving milestones', failure);
                    return Failure(failure);
                  },
                );
              }
              return await result.fold(
                (updatedAgreement) {
                  _log.info('Successfully updated agreement');
                  return Success(updatedAgreement);
                },
                (failure) {
                  _log.error('Error updating agreement', failure);
                  return Failure(failure);
                },
              );
            }
            return Success(updatedAgreement);
          },
          (failure) {
            _log.error('Error updating agreement', failure);
            return Failure(failure);
          },
        );
      },
      (failure) {
        _log.error('Error retrieving agreement', failure);
        return Failure(failure);
      },
    );
  }
}
