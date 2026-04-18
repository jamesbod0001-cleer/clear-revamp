import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

// In Riverpod 3.0, you MUST use the 'base' keyword because ProviderObserver is 'base'
base class CleerSentryObserver extends ProviderObserver {

  @override
  void providerDidFail(
      ProviderObserverContext context, // Riverpod 3.0 uses this single context object
      Object error,
      StackTrace stackTrace,
      ) {
    Sentry.captureException(
      error,
      stackTrace: stackTrace,
      withScope: (scope) {
        // Tag the error with the name of the failing provider
        scope.setTag('provider', context.provider.name ?? context.provider.runtimeType.toString());

        // In Sentry Dart/Flutter, we use 'setContexts' (plural) to add custom data objects
        scope.setContexts('riverpod', {
          'provider_name': context.provider.name,
          'provider_type': context.provider.runtimeType.toString(),
        });
      },
    );
  }
}