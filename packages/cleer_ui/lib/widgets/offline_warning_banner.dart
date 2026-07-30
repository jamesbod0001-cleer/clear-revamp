// import 'package:cleer_ui/l10n/generated/ui_localizations.dart';
// import 'package:cleer_ui/themes/dimensions.dart';
// import 'package:cleer_ui/themes/theme_utils.dart';
// import 'package:flutter/material.dart';
// import 'package:gap/gap.dart';
// import 'package:phosphor_flutter/phosphor_flutter.dart';
//
// class OfflineWarningBanner extends StatelessWidget { // Changed to StatelessWidget
//   const OfflineWarningBanner({
//     super.key,
//     required this.isDisconnected, // Pass the state in
//     this.margin,
//   });
//
//   final bool isDisconnected;
//   final EdgeInsets? margin;
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedSwitcher(
//       duration: const Duration(milliseconds: 300),
//       switchInCurve: Curves.easeInOut,
//       switchOutCurve: Curves.easeInOut,
//       child: isDisconnected
//           ? Container(
//         key: const ValueKey('offline_banner'), // Key for AnimatedSwitcher
//         decoration: BoxDecoration(
//           color: context.color.warningLight,
//           borderRadius: BorderRadius.circular(Dimens.radius.r8),
//         ),
//         margin: margin ?? EdgeInsets.only(bottom: Dimens.padding.p20),
//         padding: EdgeInsets.symmetric(
//           horizontal: Dimens.padding.p12,
//           vertical: Dimens.padding.p8,
//         ),
//         child: Row(
//           children: [
//             PhosphorIcon(
//               PhosphorIcons.cloudSlash(.bold),
//               size: Dimens.size.s16,
//               color: context.color.warning,
//             ),
//             Gap(Dimens.spacing.sp6),
//             Expanded( // Added Expanded to prevent overflow
//               child: Text(
//                 UiLocalizations.of(context)!.youAreOfflineCheckYourInternetConnection,
//                 style: context.typo.bodyMedium.copyWith(
//                   color: context.color.warning,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       )
//           : const SizedBox.shrink(),
//     );
//   }
// }

import 'package:cleer_ui/l10n/generated/ui_localizations.dart';
import 'package:cleer_ui/themes/dimensions.dart';
import 'package:cleer_ui/themes/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class OfflineWarningBanner extends StatelessWidget {
  const OfflineWarningBanner({
    super.key,
    required this.isDisconnected,
    this.isFullWidth = false,
    this.margin,
  });

  final bool isDisconnected;
  final bool isFullWidth;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        child: isDisconnected
            ? Container(
                key: const ValueKey('offline_banner'),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: context.color.warningLight,
                  borderRadius: isFullWidth
                      ? BorderRadius.zero
                      : BorderRadius.circular(Dimens.radius.r8),
                ),
                margin: isFullWidth
                    ? EdgeInsets.zero
                    : (margin ?? EdgeInsets.only(bottom: Dimens.padding.p20)),
                padding: EdgeInsets.symmetric(
                  horizontal: Dimens.padding.p16,
                  vertical: Dimens.padding.p10,
                ),
                child: Row(
                  children: [
                    PhosphorIcon(
                      PhosphorIcons.cloudSlash(.bold),
                      size: Dimens.size.s16,
                      color: context.color.warning,
                    ),
                    Gap(Dimens.spacing.sp8),
                    Expanded(
                      child: Text(
                        UiLocalizations.of(
                          context,
                        )!.youAreOfflineCheckYourInternetConnection,
                        style: context.typo.bodyMedium.copyWith(
                          color: context.color.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
