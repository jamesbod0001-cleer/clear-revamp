import 'package:cleer/domain/providers/network/network_provider.dart';
import 'package:cleer_ui/cleer_ui.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AppOfflineBanner extends ConsumerWidget {
  const AppOfflineBanner({
    super.key,
    this.isFullWidth = false,
    this.margin,
  });

  final bool isFullWidth;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDisconnected = ref
        .watch(connectionStatusProvider)
        .maybeWhen(
          data: (status) => status.isDisconnected,
          orElse: () => false,
        );

    return OfflineWarningBanner(
      isDisconnected: isDisconnected,
      isFullWidth: isFullWidth,
      margin: margin,
    );
  }
}
