import 'dart:async';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer_api/cleer_api.dart';
import 'package:cleer/utils/riverpod_extensions.dart';
import 'package:cleer_core/models/payout_destination/payout_destination.dart';
import 'package:cleer/domain/providers/user/user_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'payout_destination_provider.g.dart';

@Riverpod(keepAlive: true, retry: noRetry)
class UserPayoutDestinations extends _$UserPayoutDestinations {
  StreamSubscription? _createSub;
  StreamSubscription? _deleteSub;

  final _log = AmplifyLogger('UserPayoutDestinations');

  @override
  FutureOr<List<PayoutDestination>> build() async {
    final repository = ref.watch(payoutDestinationRepositoryProvider);

    ref.listenForSubscriptionRecovery(
      onSyncRequired: () async {
        final userId = ref.read(userProfileProvider).value?.id;
        if (userId == null) return;

        _log.info('🔄 Payout Sync: Fetching latest destinations');
        final result = await repository.getPayoutDestinationsByUser(userId);
        result.fold(
          (list) => state = AsyncData(list),
          (failure) => state = AsyncError(failure, StackTrace.current),
        );
      },
      onReconnectRequired: () {
        final userId = ref.read(userProfileProvider).value?.id;
        if (userId == null) return;
        _setupSubscriptions(userId);
      },
    );

    final user = await ref.watch(userProfileProvider.future);
    if (user == null) {
      return [];
    }

    _setupSubscriptions(user.id);

    ref.onDispose(() {
      _createSub?.cancel();
      _deleteSub?.cancel();
    });

    final result = await repository.getPayoutDestinationsByUser(user.id);
    return result.getOrThrow();
  }

  void _setupSubscriptions(String userId) {
    final repo = ref.read(payoutDestinationRepositoryProvider);

    _createSub?.cancel();
    _deleteSub?.cancel();

    _createSub = repo.observeUserPayoutDestinationsCreates(userId).listen((
      newItem,
    ) {
      final current = state.value ?? [];
      state = AsyncData([...current, newItem]);
    }, onError: (e) => _log.error('❌ Payout Create Subscription Error', e));

    _deleteSub = repo.observeUserPayoutDestinationsDeletes(userId).listen((
      deletedItem,
    ) {
      final current = state.value ?? [];
      state = AsyncData(
        current
            .where((item) => item.accountNumber != deletedItem.accountNumber)
            .toList(),
      );
    }, onError: (e) => _log.error('❌ Payout Delete Subscription Error', e));
  }
}
