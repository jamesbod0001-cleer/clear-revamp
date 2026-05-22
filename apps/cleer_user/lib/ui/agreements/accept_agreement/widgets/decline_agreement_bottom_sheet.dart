import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer_ui/themes/dimensions.dart';
import 'package:cleer_ui/themes/theme_utils.dart';
import 'package:cleer_ui/widgets/bottom_sheets/custom_bottom_sheet.dart';
import 'package:cleer_ui/widgets/buttons/primary_button.dart';
import 'package:cleer_ui/widgets/status_circle_icon.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DeclineAgreementBottomSheet extends ConsumerWidget {
  const DeclineAgreementBottomSheet({super.key, required this.onConfirm});

  final VoidCallback onConfirm;

  static Future<bool?> show(
    BuildContext context, {
    required VoidCallback onConfirm,
  }) => CustomBottomSheet.show<bool?>(
    context: context,
    isDismissible: true,
    child: DeclineAgreementBottomSheet(onConfirm: onConfirm),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: .min,
      children: [
        StatusCircleIcon(type: .error),
        Gap(Dimens.spacing.sp48),
        Text('${l10n.declineAgreement}?', style: context.typo.headlineSmall),
        Gap(Dimens.spacing.sp12),
        Text(
          l10n.areYouSureYouWantToDeclineThisAgreement,
          style: context.typo.bodyMedium.copyWith(color: context.color.grey600),
          textAlign: .center,
        ),
        Gap(Dimens.spacing.sp24),
        PrimaryButton.error(
          onPressed: onConfirm,
          child: Text(l10n.yesDecline),
        ),
        Gap(Dimens.spacing.sp12),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: context.color.secondary),
          onPressed: () => context.pop(),
          child: Text(l10n.close),
        ),
        Gap(Dimens.spacing.sp20),
      ],
    );
  }
}
