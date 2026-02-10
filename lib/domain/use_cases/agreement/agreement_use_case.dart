import 'package:amplify_flutter/amplify_flutter.dart' hide SignedOutException;
import 'package:cleer/data/repositories/api/agreement/agreement_repository.dart';
import 'package:cleer/data/repositories/api/payout_destination/payout_destination_repository.dart';
import 'package:cleer/data/repositories/flutterwave/flutterwave_repository.dart';
import 'package:cleer/domain/failures/data_failures.dart';
import 'package:cleer/domain/models/agreement/agreement.dart';
import 'package:cleer/domain/models/agreement/agreement_enums.dart';
import 'package:cleer/domain/models/payout_destination/payout_destination.dart';
import 'package:cleer/domain/models/recipient_resolution/recipient_resolution.dart';
import 'package:cleer/domain/providers/user/user_provider.dart';
import 'package:cleer/domain/use_cases/flutterwave/params/resolve_account_params.dart';
import 'package:cleer/domain/use_cases/payout_destination/params/get_payout_destination_params.dart';
import 'package:cleer/ui/agreements/create_agreement/state/create_agreement_state.dart';
import 'package:result_dart/result_dart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'agreement_use_case.g.dart';

@Riverpod(keepAlive: true)
class AgreementUseCase extends _$AgreementUseCase {
  late final AgreementRepository _agreementRepository;
  late final FlutterwaveRepository _flutterwaveRepository;
  late final PayoutDestinationRepository _payoutDestinationRepository;

  final _log = AmplifyLogger("AgreementUseCase");

  @override
  void build() {
    _agreementRepository = ref.watch(agreementRepositoryProvider);
    _flutterwaveRepository = ref.watch(flutterwaveRepositoryProvider);
    _payoutDestinationRepository = ref.watch(
      payoutDestinationRepositoryProvider,
    );
    return;
  }

  Future<ResultDart<RecipientResolution, Object>> resolveRecipientDetails({
    required String accountNumber,
    required String bankCode,
  }) async {
    _log.info('Attempting to resolve recipient details');

    final resolveAccountResult = await _flutterwaveRepository.resolveAccount(
      ResolveAccountParams(bankCode: bankCode, accountNumber: accountNumber),
    );

    return await resolveAccountResult.fold(
      (resolvedName) async {
        _log.info('Successfully resolved name via API: $resolvedName');

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
                _log.info('User found on Cleer: ${payout.accountName}');
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

    if (formData.recipientResolution!.isRegisteredUser) {
      _log.info('User is already registered');
      payoutDestination = formData.recipientResolution!.payoutDestination!;
    } else {
      _log.info('User is not registered');
      final recipientResolution = formData.recipientResolution!;
      switch (formData.initiatorRole) {
        case InitiatorRole.sender:
          _log.info('Creating payout destination - initiator is sender');
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
        case InitiatorRole.recipient:
          _log.info('Creating payout destination - initiator is recipient');
          // TODO: Handle this case.
          throw UnimplementedError();
      }
    }

    Agreement agreement = Agreement(
      id: null,
      amount: double.parse(formData.amount),
      currency: 'NGN',
      disbursementType: formData.disbursementType!,
      category: formData.category!,
      expectedReleaseDate: formData.releaseDate!,
      description: formData.description,
      payoutDestination: payoutDestination,
      initiatorRole: formData.initiatorRole,
      status: .draft,
      initiator: initiator,
      sender: formData.initiatorRole == InitiatorRole.sender ? initiator : null,
      recipient: formData.initiatorRole == InitiatorRole.recipient
          ? initiator
          : null,
    );
    _log.info('Attempting to create agreement');
    final result = await _agreementRepository.createAgreement(agreement);

    return result.fold(
      (agreement) {
        _log.info('Successfully created agreement');
        return Success(agreement);
      },
      (failure) {
        _log.error('Error creating agreement', failure);
        return Failure(failure);
      },
    );
  }
}
