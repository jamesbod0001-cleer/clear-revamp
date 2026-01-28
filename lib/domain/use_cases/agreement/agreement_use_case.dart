import 'package:amplify_flutter/amplify_flutter.dart' hide SignedOutException;
import 'package:cleer/data/repositories/api/payout_destination/payout_destination_repository.dart';
import 'package:cleer/data/repositories/flutterwave/flutterwave_repository.dart';
import 'package:cleer/domain/models/recipient_resolution/recipient_resolution.dart';
import 'package:cleer/domain/use_cases/flutterwave/params/resolve_account_params.dart';
import 'package:cleer/domain/use_cases/payout_destination/params/get_payout_destination_params.dart';
import 'package:result_dart/result_dart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'agreement_use_case.g.dart';

@Riverpod(keepAlive: true)
class AgreementUseCase extends _$AgreementUseCase {
  late final FlutterwaveRepository _flutterwaveRepository;
  late final PayoutDestinationRepository _payoutDestinationRepository;

  final _log = AmplifyLogger("AgreementUseCase");

  @override
  void build() {
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
                    isRegisteredUser: true,
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
}
