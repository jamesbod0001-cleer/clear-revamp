import 'dart:async';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer_api/cleer_api.dart';
import 'package:cleer/utils/riverpod_extensions.dart';
import 'package:cleer_core/models/payout_destination/payout_destination.dart';
import 'package:cleer/domain/providers/user/user_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'payout_destination_provider.g.dart';

@Riverpod(keepAlive: true)
class UserPayoutDestinations extends _$UserPayoutDestinations {
  StreamSubscription? _createSub;
  StreamSubscription? _deleteSub;

  final _log = AmplifyLogger('UserPayoutDestinations');

  @override
  FutureOr<List<PayoutDestination>> build() async {
    final userId = ref.watch(
      userProfileProvider.select((user) => user.value?.id),
    );
    if (userId == null) {
      return [];
    }

    final repository = ref.watch(payoutDestinationRepositoryProvider);

    _setupSubscriptions(userId);

    ref.listenForSubscriptionRecovery(
      onSyncRequired: () async {
        _log.info('🔄 Payout Sync: Fetching latest destinations');
        final result = await repository.getPayoutDestinationsByUser(userId);
        state = AsyncData(result.getOrThrow());
      },
      onReconnectRequired: () => _setupSubscriptions(userId),
    );

    ref.onDispose(() {
      _createSub?.cancel();
      _deleteSub?.cancel();
    });

    final result = await repository.getPayoutDestinationsByUser(userId);
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
    });

    _deleteSub = repo.observeUserPayoutDestinationsDeletes(userId).listen((
      deletedItem,
    ) {
      final current = state.value ?? [];
      state = AsyncData(
        current
            .where((item) => item.accountNumber != deletedItem.accountNumber)
            .toList(),
      );
    });
  }
}
