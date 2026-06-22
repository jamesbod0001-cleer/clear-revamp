import 'package:cleer/domain/use_cases/auth/auth_use_case.dart';
import 'package:cleer/routing/pending_route_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:cleer/ui/auth/auth_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'go_router_refresh_notifier.g.dart';

@riverpod
GoRouterRefreshNotifier goRouterRefreshNotifier(Ref ref) =>
    GoRouterRefreshNotifier(ref);

class GoRouterRefreshNotifier extends ChangeNotifier {
  GoRouterRefreshNotifier(Ref ref) {
    ref.listen<AsyncValue<AuthState>>(authUseCaseProvider, (previous, next) {
      // Listen to the auth state and notify listeners only when the auth status changes.
      if (previous?.value != next.value) {
        notifyListeners();
      }
    });

    ref.listen<String?>(pendingRouteProvider, (previous, next) {
      // Listen to the pending route and notify listeners when a new route is set.
      if (next != null && previous != next) {
        notifyListeners();
      }
    });
  }
}
