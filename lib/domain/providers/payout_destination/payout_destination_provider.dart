import 'package:cleer/data/repositories/api/payout_destination/payout_destination_repository.dart';
import 'package:cleer/domain/models/payout_destination/payout_destination.dart';
import 'package:cleer/domain/providers/user/user_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'payout_destination_provider.g.dart';

@Riverpod(keepAlive: true)
class UserPayoutDestinations extends _$UserPayoutDestinations {
  @override
  FutureOr<List<PayoutDestination>> build() async {
    // 1. Watch the user. If the user logs out, this provider will react.
    final user = ref.watch(userProvider).value;
    if (user == null) return [];

    final repository = ref.watch(payoutDestinationRepositoryProvider);

    // 2. Set up the real-time listeners
    final createSub = repository
        .observeUserPayoutDestinationsCreates(user.id)
        .listen((newItem) {
      final currentList = state.value ?? [];
      // Updating 'state' here is what actually triggers the UI to rebuild
      state = AsyncData([...currentList, newItem]);
    });

    final deleteSub = repository
        .observeUserPayoutDestinationsDeletes(user.id)
        .listen((deletedItem) {
      final currentList = state.value ?? [];
      state = AsyncData(
        currentList.where((item) => item.accountNumber != deletedItem.accountNumber).toList(),
      );
    });

    // 3. Clean up when the provider is disposed (or when the user changes)
    ref.onDispose(() {
      createSub.cancel();
      deleteSub.cancel();
    });

    // 4. Return the initial fetch
    final result = await repository.getPayoutDestinationsByUser(user.id);
    return result.getOrThrow();
  }
}