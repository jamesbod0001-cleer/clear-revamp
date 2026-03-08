import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer/domain/failures/data_failures.dart';
import 'package:cleer/domain/models/payout_destination/payout_destination.dart';
import 'package:cleer/domain/providers/user/user_provider.dart';
import 'package:cleer/domain/use_cases/flutterwave/flutterwave_use_case.dart';
import 'package:cleer/domain/use_cases/flutterwave/params/resolve_account_params.dart';
import 'package:cleer/domain/use_cases/payout_destination/payout_destination_use_case.dart';
import 'package:command_it/command_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'payout_destination_view_model.g.dart';

@riverpod
class PayoutDestinationViewModel extends _$PayoutDestinationViewModel {
  final _log = AmplifyLogger("PayoutDestinationViewModel");

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
  late Command<PayoutDestination, PayoutDestination?> deletePayoutDestinationCommand;

  Future<String> _resolveAccountForPayoutDestination(
    ResolveAccountParams params,
  ) async {
    final user = ref.read(userProvider).value;
    if (user == null) throw DataFailure.notFound();
    final result = await ref
        .read(flutterwaveUseCaseProvider.notifier)
        .resolveAccount(params);
    return result.fold(
      (resolveAccountName) {
        final fullName = "${user.firstName} ${user.lastName}";

        final isMatch = _isNameMatch(
          userName: fullName,
          resolveAccountName: resolveAccountName,
        );

        if (!isMatch) {
          _log.warn(
            "Name Mismatch: App ($fullName) vs Bank ($resolveAccountName)",
          );
          // Throw a custom failure that Cleer can catch and show in the UI
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

  Future<PayoutDestination?> _createPayoutDestination(
    PayoutDestination payoutDestination,
  ) async {
    final user = ref.read(userProvider).value;
    if (user == null) throw DataFailure.notFound();
    _log.info("Creating payout destination");
    final result = await ref
        .read(payoutDestinationUseCaseProvider.notifier)
        .createPayoutDestination(
          payoutDestination.copyWith(
            user: user,

            /// TODO: Come back and fix this when the flutterwave is active
            accountName: '${user.firstName} ${user.lastName}',
          ),
        );
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
