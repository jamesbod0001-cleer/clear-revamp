import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer/domain/use_cases/flutterwave/flutterwave_use_case.dart';
import 'package:cleer/domain/use_cases/payout_destination/payout_destination_use_case.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:cleer/domain/providers/user/user_provider.dart';
import 'package:command_it/command_it.dart';
import 'package:result_dart/result_dart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'payout_destination_view_model.g.dart';

@riverpod
class PayoutDestinationViewModel extends _$PayoutDestinationViewModel {
  final _log = AmplifyLogger("PayoutDestinationViewModel");

  // 1. ADD THESE TO TRACK LIVE INPUT
  String? _targetBankCode;
  String? _targetAccountNumber;

  void updateResolutionTargets(String? bankCode, String? accountNumber) {
    _targetBankCode = bankCode;
    _targetAccountNumber = accountNumber;
  }

  @override
  void build() {
    resolveAccountForPayoutDestinationCommand =
        Command.createAsync<ResolveAccountParams, String>(
          _resolveAccountForPayoutDestination,
          errorFilter: const LocalErrorFilter(),
          initialValue: '',
        );
    createPayoutDestinationCommand =
        Command.createAsync<PayoutDestination, PayoutDestination?>(
          _createPayoutDestination,
          errorFilter: const LocalErrorFilter(),
          initialValue: null,
        );
    deletePayoutDestinationCommand =
        Command.createAsync<PayoutDestination, PayoutDestination?>(
          _deletePayoutDestination,
          errorFilter: const LocalErrorFilter(),
          initialValue: null,
        );
  }

  late Command<ResolveAccountParams, String>
  resolveAccountForPayoutDestinationCommand;
  late Command<PayoutDestination, PayoutDestination?>
  createPayoutDestinationCommand;
  late Command<PayoutDestination, PayoutDestination?>
  deletePayoutDestinationCommand;

  Future<String> _resolveAccountForPayoutDestination(
    ResolveAccountParams params,
  ) async {
    final user = ref.read(userProfileProvider).value;
    if (user == null) throw DataFailure.notFound();

    // 2. THE SELF-HEALING LOOP
    while (true) {
      final bankCode = _targetBankCode;
      final accountNumber = _targetAccountNumber;

      // Safety exit if they deleted the input
      if (bankCode == null ||
          accountNumber == null ||
          accountNumber.length != 10) {
        return '';
      }

      // Wait 500ms before hitting Flutterwave
      await Future.delayed(const Duration(milliseconds: 500));

      // Did the user type a new number while we waited?
      if (_targetBankCode != bankCode ||
          _targetAccountNumber != accountNumber) {
        _log.info('Input changed during debounce. Looping.');
        continue;
      }

      // Hit the API using the safely captured variables
      final result = await ref
          .read(flutterwaveUseCaseProvider.notifier)
          .resolveAccount(
            ResolveAccountParams(
              bankCode: bankCode,
              accountNumber: accountNumber,
            ),
          );

      // Did the user type a new number while the API was loading?
      if (_targetBankCode != bankCode ||
          _targetAccountNumber != accountNumber) {
        _log.info('Input changed during API call. Silently looping.');
        continue;
      }

      // 4. Safe to process and return
      return result.fold(
        (resolveAccountName) {
          final fullName = "${user.firstName} ${user.lastName}";
          final isMatch = IdentityUtils.isNameMatch(
            userName: fullName,
            bankAccountName: resolveAccountName,
          );

          if (!isMatch) {
            _log.warn(
              "Name Mismatch: App ($fullName) vs Bank ($resolveAccountName)",
            );
            throw DataFailure.unknown(
              message:
                  "The resolved account name '$resolveAccountName' does not match your profile name. Please use an account in your name.",
            );
          }

          _log.info("Account verified: $resolveAccountName");
          return resolveAccountName;
        },
        (failure) {
          _log.error("Error resolving account: $failure");
          throw failure;
        },
      );
    }
  }

  // Future<String> _resolveAccountForPayoutDestination(
  //   ResolveAccountParams params,
  // ) async {
  //   final user = ref.read(userProfileProvider).value;
  //   if (user == null) throw DataFailure.notFound();
  //   final result = await ref
  //       .read(flutterwaveUseCaseProvider.notifier)
  //       .resolveAccount(params);
  //   return result.fold(
  //     (resolveAccountName) {
  //       final fullName = "${user.firstName} ${user.lastName}";
  //
  //       final isMatch = IdentityUtils.isNameMatch(
  //         userName: fullName,
  //         bankAccountName: resolveAccountName,
  //       );
  //
  //       if (!isMatch) {
  //         _log.warn(
  //           "Name Mismatch: App ($fullName) vs Bank ($resolveAccountName)",
  //         );
  //         // Throw a custom failure that Cleer can catch and show in the UI
  //         throw DataFailure.unknown(
  //           message:
  //               "The resolved account name '$resolveAccountName' does not match your profile name. Please use an account in your name.",
  //         );
  //       }
  //
  //       _log.info("Account verified: $resolveAccountName");
  //       return resolveAccountName;
  //     },
  //     (failure) {
  //       _log.error("Error resolving account: $failure");
  //       throw failure;
  //     },
  //   );
  // }

  Future<PayoutDestination?> _createPayoutDestination(
    PayoutDestination payoutDestination,
  ) async {
    final user = ref.read(userProfileProvider).value;
    if (user == null) throw DataFailure.notFound();
    _log.info("Creating payout destination");
    late ResultDart<PayoutDestination, DataFailure> result;
    if (AppConfig.isLive) {
      result = await ref
          .read(payoutDestinationUseCaseProvider.notifier)
          .createPayoutDestination(payoutDestination.copyWith(user: user));
    } else {
      result = await ref
          .read(payoutDestinationUseCaseProvider.notifier)
          .createPayoutDestination(
            payoutDestination.copyWith(
              user: user,
              accountName: '${user.firstName} ${user.lastName}',
            ),
          );
    }

    return result.fold(
      (payoutDestination) {
        _log.info("Payout destination created: $payoutDestination");
        return payoutDestination;
      },
      (failure) {
        _log.error("Error creating payout destination: $failure");
        throw failure;
      },
    );
  }

  Future<PayoutDestination?> _deletePayoutDestination(
    PayoutDestination payoutDestination,
  ) async {
    _log.info("Deleting payout destination");
    final result = await ref
        .read(payoutDestinationUseCaseProvider.notifier)
        .deletePayoutDestination(payoutDestination);
    return result.fold(
      (payoutDestination) {
        _log.info("Payout destination deleted: $payoutDestination");
        return payoutDestination;
      },
      (failure) {
        _log.error("Error deleting payout destination: $failure");
        throw failure;
      },
    );
  }
}
