import 'package:cleer/domain/providers/network/network_provider.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer_ui/cleer_ui.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

extension ErrorUIExtensions on Object {
  Widget toErrorState(
    WidgetRef ref, {
    required VoidCallback onRetry,
    AppErrorStateVariant variant = AppErrorStateVariant.page,
  }) {
    final context = ref.context;
    final l10n = AppLocalizations.of(context)!;
    final isHardwareOffline = ref.watch(isOfflineProvider);
    
    // Determine if it's a network related error
    final isNetworkError = toString().toLowerCase().contains('network') || 
                          toString().toLowerCase().contains('connectivity');

    final showOfflineUI = isHardwareOffline || isNetworkError;

    return AppErrorState(
      isOffline: showOfflineUI,
      onRetry: onRetry,
      variant: variant,
      message: showOfflineUI
          ? l10n.pleaseCheckYourInternetConnectionAndTryAgain
          : l10n.unknownExceptionMessage,
      retryText: l10n.refresh,
    );
  }
}

extension AsyncValueErrorUI on AsyncValue {
  Widget whenError(
    WidgetRef ref, {
    required VoidCallback onRetry,
    AppErrorStateVariant variant = AppErrorStateVariant.page,
  }) {
    return maybeWhen(
      error: (error, stack) => error.toErrorState(
        ref,
        onRetry: onRetry,
        variant: variant,
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}
