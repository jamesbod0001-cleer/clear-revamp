import 'dart:async';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer_api/cleer_api.dart';
import 'package:cleer/domain/providers/user/user_provider.dart';
import 'package:cleer/utils/riverpod_extensions.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:cleer_core/models/activity/activity.dart';
import 'package:cleer_core/models/paginated_list/paginated_list.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'activity_provider.g.dart';

@Riverpod(keepAlive: true)
class UserActivities extends _$UserActivities {
  StreamSubscription? _createSub;
  final _log = AmplifyLogger('UserActivities');

  @override
  FutureOr<PaginatedList<Activity>> build() async {
    final user = await ref.watch(userProfileProvider.future);
    if (user == null) {
      return PaginatedList(items: [], hasNextPage: false);
    }

    final repository = ref.watch(activityRepositoryProvider);

    // Initial setup for Real-time Creation
    _setupSubscription(user.id);

    // The "Self-Healing" Listener for Offline/Online Recovery
    ref.listenForSubscriptionRecovery(
      onSyncRequired: () async {
        _log.info('🔄 Activities Sync: Fetching latest list');
        // When internet returns, fetch page 1 to grab anything missed while offline
        final result = await repository.getUserActivities(userId: user.id);
        state = AsyncData(result.getOrThrow());
      },
      onReconnectRequired: () {
        _log.info('📡 Activities Recovery: Restarting Stream');
        _setupSubscription(user.id);
      },
    );

    ref.onDispose(() => _createSub?.cancel());

    // Initial Fetch (Page 1)
    final result = await repository.getUserActivities(userId: user.id);
    return result.getOrThrow();
  }

  void _setupSubscription(String userId) {
    _createSub?.cancel();
    _createSub = ref
        .read(activityRepositoryProvider)
        .observeUserActivityCreates(userId: userId)
        .listen(_handleNewActivity);
  }

  void _handleNewActivity(Activity newActivity) {
    final currentList = state.value;
    if (currentList == null) return;

    // Guard: Prevent duplicates if a network fetch and stream event arrive at the exact same time
    final exists = currentList.items.any((a) => a.id == newActivity.id);
    if (exists) return;

    // Prepend the new activity to the top of the list
    final newItems = [newActivity, ...currentList.items];

    // Ensure strict chronological sorting (Newest first)
    newItems.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));

    // Update state while preserving pagination tokens
    state = AsyncData(
      currentList.copyWith(items: newItems),
    );
  }

  /// Called by the UI when the user scrolls to the bottom of the feed
  Future<void> loadMore() async {
    final currentList = state.value;

    // Guard: If we are already loading, or there's no next page, do nothing
    if (currentList == null || !currentList.hasNextPage || currentList.nextRequest == null) {
      return;
    }

    final user = await ref.read(userProfileProvider.future);
    if (user == null) return;

    final repository = ref.read(activityRepositoryProvider);

    final result = await repository.getUserActivities(
      userId: user.id,
      nextRequest: currentList.nextRequest, // Pass the token to Amplify
    );

    if (result.isSuccess()) {
      final nextPage = result.getOrThrow();

      // Append the new page to the bottom of the existing items
      state = AsyncData(
        PaginatedList(
          items: [...currentList.items, ...nextPage.items],
          hasNextPage: nextPage.hasNextPage,
          nextRequest: nextPage.nextRequest,
        ),
      );
    }
  }
}