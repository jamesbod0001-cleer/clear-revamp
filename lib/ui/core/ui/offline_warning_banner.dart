import 'package:cleer/domain/providers/network/network_provider.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class OfflineWarningBanner extends ConsumerWidget {
  const OfflineWarningBanner({super.key, this.margin});

  /// Defaults to EdgeInsets.only(bottom: Dimens.padding.p20)
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(connectionStatusProvider);
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      child: notifier.maybeWhen(
        data: (connectionStatus) {
          if (connectionStatus.isDisconnected) {
            return Container(
              decoration: BoxDecoration(
                color: context.color.warningLight,
                borderRadius: .circular(Dimens.radius.r8),
              ),
              margin: margin ?? .only(bottom: Dimens.padding.p20),
              padding: .symmetric(
                horizontal: Dimens.padding.p12,
                vertical: Dimens.padding.p8,
              ),
              child: Row(
                children: [
                  PhosphorIcon(
                    PhosphorIcons.cloudSlash(.bold),
                    size: Dimens.size.s16,
                    color: context.color.warning,
                  ),
                  Gap(Dimens.spacing.sp6),
                  Text(
                    AppLocalizations.of(
                      context,
                    )!.youreOfflineCheckYourInternetConnection,
                    style: context.typo.bodyMedium.copyWith(
                      color: context.color.warning,
                    ),
                  ),
                ],
              ),
            );
          } else {
            return SizedBox.shrink();
          }
        },
        orElse: () => SizedBox.shrink(),
      ),
    );
  }
}
