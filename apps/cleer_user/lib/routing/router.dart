import 'package:cleer/domain/use_cases/auth/auth_use_case.dart';
import 'package:cleer/routing/go_router_refresh_notifier.dart';
import 'package:cleer/routing/pending_route_provider.dart';
import 'package:cleer/routing/routes.dart';
import 'package:cleer/ui/auth/auth_state.dart';
import 'package:cleer_ui/utils/keys.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

part 'router.g.dart';

@riverpod
GoRouter router(Ref ref) {
  final authNotifier = ref.watch(goRouterRefreshProvider);

  return GoRouter(
    navigatorKey: cleerNavigatorKey,
    observers: [SentryNavigatorObserver()],
    initialLocation: const SplashRoute().location,
    refreshListenable: authNotifier,
    debugLogDiagnostics: true,
    routes: $appRoutes,
    redirect: (context, state) {
      final authStateValue = ref.read(authUseCaseProvider);
      final authState = authStateValue.value;
      final currentPath = state.uri.path;
      final String? intentPath =
          state.uri.queryParameters['redirect-to'] ??
          state.uri.queryParameters['redirectTo'];

      final pendingRoute = ref.read(pendingRouteProvider);

      final onboardingPath = const OnboardingRoute().location;
      final createPasswordPath = '/create_password';
      final successPath = '/registration_success';

      bool isPublicPath(String path) {
        return path == onboardingPath ||
            path.startsWith('/login') ||
            path.startsWith('/create_account') ||
            path.startsWith('/verify_phone') ||
            path.startsWith(createPasswordPath) ||
            path.startsWith('/a/');
      }

      // --- APP INITIALIZING ---
      if (authStateValue.isLoading ||
          authState == null ||
          authState is Unknown) {
        // ONLY let deep links bypass the Splash screen during loading!
        // This prevents the "Onboarding Flash" if the app remembers an old route.
        if (currentPath.startsWith('/a/')) return null;

        // Force everything else (including onboarding) to wait safely on the Splash screen
        return currentPath == const SplashRoute().location
            ? null
            : const SplashRoute().location;
      }

      final isAuthenticated = authState.isAuthenticated;
      final isReadyForHome = authState.isFullyAuthenticated;

      // --- LOGIC FOR UNAUTHENTICATED USERS ---
      if (!isAuthenticated) {
        if (isPublicPath(currentPath)) {
          return null;
        }
        return onboardingPath;
      }

      // --- LOGIC FOR PARTIALLY AUTHENTICATED USERS (Creating Account) ---
      if (isAuthenticated && !isReadyForHome) {
        if (currentPath == createPasswordPath || currentPath == successPath) {
          return null;
        }

        if (intentPath != null && intentPath.isNotEmpty) {
          return '$successPath?redirectTo=${Uri.encodeComponent(intentPath)}';
        }
        return successPath;
      }

      // --- LOGIC FOR FULLY AUTHENTICATED USERS ---
      if (isReadyForHome) {
        if (pendingRoute != null) {
          Future.microtask(
            () => ref.read(pendingRouteProvider.notifier).consume(),
          );
          return pendingRoute;
        }

        if (currentPath.startsWith('/a/')) {
          return null;
        }

        final isOnGuestPage =
            currentPath == const SplashRoute().location ||
            isPublicPath(currentPath) ||
            currentPath == successPath;

        if (isOnGuestPage) {
          if (intentPath != null && intentPath.isNotEmpty) {
            return intentPath;
          }
          return HomeRoute().location;
        }
      }

      return null;
    },
  );
}
