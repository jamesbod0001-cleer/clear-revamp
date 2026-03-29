import 'package:cleer/domain/use_cases/auth/auth_use_case.dart';
import 'package:cleer/routing/go_router_refresh_notifier.dart';
import 'package:cleer/routing/routes.dart';
import 'package:cleer/ui/auth/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

part 'router.g.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

@riverpod
GoRouter router(Ref ref) {
  final authNotifier = ref.watch(goRouterRefreshProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    observers: [
      SentryNavigatorObserver(),
    ],
    initialLocation: const SplashRoute().location,
    refreshListenable: authNotifier,
    debugLogDiagnostics: true,
    routes: $appRoutes,
    redirect: (context, state) {
      final authStateValue = ref.read(authUseCaseProvider);
      final authState = authStateValue.value;
      final currentPath = state.uri.path;

      // Capture any redirect intent from the query parameters
      final String? intentPath = state.uri.queryParameters['redirectTo'];

      if (authStateValue.isLoading ||
          authState == null ||
          authState is Unknown) {
        return currentPath == const SplashRoute().location
            ? null
            : const SplashRoute().location;
      }

      final isAuthenticated = authState.isAuthenticated;
      final isReadyForHome = authState.isFullyAuthenticated;

      final onboardingPath = const OnboardingRoute().location;
      final createPasswordPath = '/create_password';
      final successPath = '/registration_success';

      // --- LOGIC FOR UNAUTHENTICATED USERS ---
      if (!isAuthenticated) {
        // ALLOWED paths for guests.
        final isPublicRoute = currentPath == onboardingPath ||
            currentPath.startsWith('/login') ||
            currentPath.startsWith('/create_account') ||
            currentPath.startsWith('/verify_phone') ||
            currentPath.startsWith(createPasswordPath) ||
            currentPath.startsWith('/a/'); // Allow guests to get to accept agreement

        if (isPublicRoute) {
          return null; // Let them proceed to the public route without interference
        } else {
          // Catch-all: If they try to go to /home or /profile unauthenticated, send to onboarding
          return onboardingPath;
        }
      }

      // --- LOGIC FOR PARTIALLY AUTHENTICATED USERS (Creating Account) ---
      if (isAuthenticated && !isReadyForHome) {
        // Only allow them to be on the Password or Success screen
        if (currentPath == createPasswordPath || currentPath == successPath) {
          return null; // Let them finish creating their account
        }
        return successPath; // Force them back to complete the process
      }

      // --- LOGIC FOR FULLY AUTHENTICATED USERS ---
      if (isReadyForHome) {
        // If they are on a "guest" page (login, onboarding, splash, success), we need to move them.
        final isOnGuestPage = currentPath == const SplashRoute().location ||
            currentPath == onboardingPath ||
            currentPath == createPasswordPath ||
            currentPath == successPath ||
            currentPath.startsWith('/login') ||
            currentPath.startsWith('/create_account');

        if (isOnGuestPage) {
          // THE FIX: If they have an intent to view an agreement, go there!
          if (intentPath != null && intentPath.isNotEmpty) {
            return intentPath;
          }
          // Otherwise, default to Home
          return HomeRoute().location;
        }

        // If they are on /a/shortCode and are signed in, let them stay there!
        if (currentPath.startsWith('/a/')) {
          return null;
        }
      }

      return null;
    },
  );
}
