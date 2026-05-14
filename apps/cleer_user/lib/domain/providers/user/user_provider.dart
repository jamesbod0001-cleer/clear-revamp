import 'dart:async';

import 'package:cleer/domain/use_cases/auth/auth_use_case.dart';
import 'package:cleer/ui/auth/auth_state.dart';
import 'package:cleer/utils/riverpod_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cleer_api/cleer_api.dart';
import 'package:cleer_core/models/user/user.dart';
import 'package:cleer_core/cleer_core.dart';

part 'user_provider.g.dart';

@Riverpod(keepAlive: true)
class UserProfile extends _$UserProfile {
  StreamSubscription<User>? _updateSub;

  @override
  FutureOr<User?> build() async {
    final authState = ref.watch(authUseCaseProvider).value;
    final userId = authState?.currentUserAuthIdentity?.userId;

    if (userId == null) return null;

    final repository = ref.watch(userRepositoryProvider);

    // Initial setup of the subscription
    _setupSubscription(userId);

    // Register our self-healing listeners
    ref.listenForSubscriptionRecovery(
      onSyncRequired: () async {
        debugPrint('🔄 Protocol Reconnected: Syncing User Data');
        final result = await repository.getUser(userId);
        state = AsyncData(result.getOrNull());
      },
      onReconnectRequired: () {
        debugPrint('📡 Hardware Online: Restarting User Subscription');
        _setupSubscription(userId);
      },
    );

    ref.onDispose(() => _updateSub?.cancel());

    // Initial Fetch
    final result = await repository.getUser(userId);
    return result.getOrNull();
  }

  void _setupSubscription(String userId) {
    _updateSub?.cancel();
    _updateSub = ref
        .read(userRepositoryProvider)
        .observeUserUpdates(userId)
        .listen((updatedUser) {
          state = AsyncData(updatedUser);
        });
  }
}
