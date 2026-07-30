import 'package:cleer/domain/providers/network/network_provider.dart';
import 'package:cleer_ui/cleer_ui.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AppOfflineBannerWrapper extends ConsumerWidget {
  const AppOfflineBannerWrapper({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDisconnected = ref.watch(connectionStatusProvider).maybeWhen(
          data: (status) => status.isDisconnected,
          orElse: () => false,
        );

    if (!isDisconnected) {
      return child;
    }

    return Column(
      children: [
        const SafeArea(
          bottom: false,
          child: OfflineWarningBanner(
            isDisconnected: true,
            isFullWidth: true,
          ),
        ),
        Expanded(
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: child,
          ),
        ),
      ],
    );
  }
}
