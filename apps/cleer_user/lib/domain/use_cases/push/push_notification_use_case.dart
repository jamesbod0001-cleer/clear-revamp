import 'dart:async';

import 'package:amplify_flutter/amplify_flutter.dart'
    hide PushNotificationMessage, PushNotificationPermissionStatus;
import 'package:cleer/domain/providers/push/foreground_message_provider.dart';
import 'package:cleer/domain/providers/user/user_provider.dart';
import 'package:cleer/domain/use_cases/auth/auth_use_case.dart';
import 'package:cleer/domain/use_cases/user/user_use_case.dart';
import 'package:cleer/routing/pending_route_provider.dart';
import 'package:cleer/ui/auth/auth_state.dart';
import 'package:cleer_api/cleer_api.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'push_notification_use_case.g.dart';

@Riverpod(keepAlive: true)
class PushNotificationUseCase extends _$PushNotificationUseCase {
  late final PushNotificationRepository _repository;
  late final SecureStorageService _storage;
  final _log = AmplifyLogger("PushNotificationUseCase");

  String? _latestToken;

  StreamSubscription<String>? _tokenSub;
  StreamSubscription<PushNotificationMessage>? _foregroundSub;
  StreamSubscription<PushNotificationMessage>? _openedSub;

  @override
  void build() {
    _repository = ref.watch(pushNotificationRepositoryProvider);
    _storage = ref.watch(secureStorageServiceProvider);

    // 🛑 WEB GUARD: Skip all native listener setups if on Chrome
    if (kIsWeb) {
      _log.info('Running on Web. Skipping Push Notification setup.');
      return;
    }

    _setupListeners();
    _checkLaunchNotification();

    // Listen for user profile changes to sync token if we have one
    ref.listen(userProfileProvider, (previous, next) {
      final user = next.asData?.value;

      final authState = ref.read(authUseCaseProvider);
      final isAuthenticated = authState.value?.isAuthenticated ?? false;
      final isAuthLoading = authState.isLoading;

      if (user != null &&
          _latestToken != null &&
          isAuthenticated &&
          !isAuthLoading) {
        _log.info(
          'User profile available and authenticated, syncing pending device token',
        );
        _updateDeviceToken(_latestToken!);
      }
    });

    ref.onDispose(() {
      _tokenSub?.cancel();
      _foregroundSub?.cancel();
      _openedSub?.cancel();
    });
  }


  void _setupListeners() {
    _tokenSub = _repository.onTokenReceived.listen((token) {
      _log.info('Device token received: $token');
      _latestToken = token;
      _updateDeviceToken(token);
    });

    _foregroundSub = _repository.onNotificationReceivedInForeground.listen((
      notification,
    ) {
      _log.info('Foreground notification received: ${notification.title}');
      ref.read(foregroundMessageProvider.notifier).notify(notification);
    });

    _openedSub = _repository.onNotificationOpened.listen((notification) {
      _log.info('Notification opened: ${notification.title}');
      _handleNotificationClick(notification);
    });
  }

  Future<void> _updateDeviceToken(String token) async {
    final user = ref.read(userProfileProvider).value;
    if (user == null) {
      _log.info('User not signed in, skipping token sync');
      return;
    }

    final result = await ref
        .read(userUseCaseProvider.notifier)
        .updateDeviceToken(token);
    result.fold(
      (_) => _log.info('Successfully synced device token'),
      (failure) => _log.error('Failed to sync device token: $failure'),
    );
  }

  void _handleNotificationClick(PushNotificationMessage notification) {
    final data = notification.data;
    final String? route = data['route'] as String?;

    if (route != null) {
      _log.info('Saving pending route from notification: $route');
      ref.read(pendingRouteProvider.notifier).setRoute(route);
    }
  }

  void _checkLaunchNotification() {
    try {
      final launchNotification = _repository.launchNotification;
      if (launchNotification != null) {
        _log.info('App launched from terminated state via notification');
        _handleNotificationClick(launchNotification);
      }
    } catch (e) {
      _log.error('Failed to get launch notification: $e');
    }
  }

  Future<void> requestPermissions() async {
    // 🛑 Guard against UI calls on Web
    if (kIsWeb) {
      _log.info('Web detected: skipping permission request.');
      return;
    }

    final success = await _repository.requestPermissions();
    _log.info('Push permission request success: $success');
  }

  Future<PushNotificationPermissionStatus> getPermissionStatus() async {
    // 🛑 Return a safe default for Web to avoid triggering the native repository
    if (kIsWeb) {
      return PushNotificationPermissionStatus.denied;
    }

    return _repository.getPermissionStatus();
  }

  Future<bool> shouldShowNudge() async {
    // Don't nudge on Web
    if (kIsWeb) return false;

    // Check current status
    final status = await getPermissionStatus();
    if (status == PushNotificationPermissionStatus.granted) return false;

    // Check interval
    final lastNudge = await _storage.getLastNotificationNudgeTime();
    final now = DateTime.now();

    return lastNudge == null || now.difference(lastNudge).inDays >= 3;
  }

  Future<void> markNudgeShown() async {
    await _storage.saveLastNotificationNudgeTime(DateTime.now());
  }
}
