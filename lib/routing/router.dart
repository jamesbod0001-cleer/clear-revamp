import 'package:cleer/domain/use_cases/auth/auth_use_case.dart';
import 'package:cleer/routing/go_router_refresh_notifier.dart';
import 'package:cleer/routing/routes.dart';
import 'package:cleer/ui/auth/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'router.g.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

@riverpod
GoRouter router(Ref ref) {
  final authNotifier = ref.watch(goRouterRefreshProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: const SplashRoute().location,
    refreshListenable: authNotifier,
    debugLogDiagnostics: true,
    routes: $appRoutes,
    redirect: (context, state) {
      final authStateValue = ref.read(authUseCaseProvider);
      final authState = authStateValue.value;

      if (authStateValue.isLoading ||
          authState == null ||
          authState is Unknown) {
        return state.uri.path == const SplashRoute().location
            ? null
            : const SplashRoute().location;
      }

      final isAuthenticated = authState.isAuthenticated;
      // Use our new helper
      final isReadyForHome = authState.isFullyAuthenticated;
      final currentPath = state.uri.path;

      final onboardingPath = const OnboardingRoute().location;
      final createPasswordPath = '/create_password';
      final successPath = '/registration_success'; // Your new success screen

      // 1. If not authenticated, keep them in the auth/onboarding loop
      if (!isAuthenticated) {
        final publicRoutes = [
          onboardingPath,
          '/create_account',
          '/verify_phone',
          createPasswordPath,
        ];
        final isPublic = publicRoutes.any(
          (path) => currentPath.startsWith(path),
        );
        return isPublic ? null : onboardingPath;
      }

      // 2. If authenticated BUT registration is not complete
      if (isAuthenticated && !isReadyForHome) {
        // Only allow them to be on the Password or Success screen
        if (currentPath == createPasswordPath || currentPath == successPath) {
          return null;
        }
        // Otherwise, force them back to complete the process
        return successPath;
      }

      // 3. If fully authenticated and ready for home
      if (isReadyForHome) {
        // If they try to go back to login/onboarding/password pages, send them Home
        if (currentPath == const SplashRoute().location ||
            currentPath == onboardingPath ||
            currentPath == createPasswordPath ||
            currentPath == successPath) {
          return HomeRoute().location;
        }
      }

      return null;
    },
  );
}
