import 'dart:async';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer/domain/use_cases/auth/auth_use_case.dart';
import 'package:cleer/ui/auth/auth_state.dart';
import 'package:cleer/utils/riverpod_extensions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cleer_api/cleer_api.dart';
import 'package:cleer_core/models/user/user.dart';
import 'package:cleer_core/cleer_core.dart';

part 'user_provider.g.dart';

@Riverpod(keepAlive: true, retry: noRetry)
class UserProfile extends _$UserProfile {
  StreamSubscription<User>? _updateSub;
  final _log = AmplifyLogger('UserProfile');

  @override
  FutureOr<User?> build() async {
    final authState = ref.watch(authUseCaseProvider).value;
    final userId = authState?.currentUserAuthIdentity?.userId;

    if (userId == null) return null;

    final repository = ref.watch(userRepositoryProvider);

    // Register our self-healing listeners FIRST
    ref.listenForSubscriptionRecovery(
      onSyncRequired: () async {
        _log.info('🔄 Protocol Reconnected: Syncing User Data');
        final result = await repository.getUser(userId);
        result.fold(
          (user) => state = AsyncData(user),
          (failure) => state = AsyncError(failure, StackTrace.current),
        );
      },
      onReconnectRequired: () {
        _log.info('📡 Hardware Online: Restarting User Subscription');
        _setupSubscription(userId);
      },
    );

    // Initial setup of the subscription
    _setupSubscription(userId);

    ref.onDispose(() => _updateSub?.cancel());

    // Initial Fetch
    final result = await repository.getUser(userId);
    return result.getOrThrow();
  }

  void _setupSubscription(String userId) {
    _updateSub?.cancel();
    _updateSub = ref
        .read(userRepositoryProvider)
        .observeUserUpdates(userId)
        .listen(
          (updatedUser) => state = AsyncData(updatedUser),
          onError: (e) => _log.error('❌ User Subscription Error', e),
        );
  }
}
