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

class CancelAgreementBottomSheet extends ConsumerWidget {
  const CancelAgreementBottomSheet({
    super.key,
    required this.isFunded,
    required this.onConfirm,
  });

  final bool isFunded;
  final VoidCallback onConfirm;

  static Future<bool?> show(
    BuildContext context, {
    required bool isFunded,
    required VoidCallback onConfirm,
  }) =>
      CustomBottomSheet.show<bool?>(
        context: context,
        isDismissible: true,
        child: CancelAgreementBottomSheet(
          isFunded: isFunded,
          onConfirm: onConfirm,
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        StatusCircleIcon(type: .error),
        Gap(Dimens.spacing.sp48),
        Text(
          l10n.cancelAgreementConfirmationTitle,
          style: context.typo.headlineSmall,
        ),
        Gap(Dimens.spacing.sp12),
        Text(
          isFunded
              ? l10n.cancelAgreementFundedDescription
              : l10n.cancelAgreementUnfundedDescription,
          style: context.typo.bodyMedium.copyWith(
            color: context.color.grey600,
          ),
          textAlign: TextAlign.center,
        ),
        Gap(Dimens.spacing.sp24),
        PrimaryButton.error(
          onPressed: () {
            context.pop();
            onConfirm();
          },
          child: Text(l10n.yesCancel),
        ),
        Gap(Dimens.spacing.sp12),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: context.color.secondary,
          ),
          onPressed: () => context.pop(),
          child: Text(l10n.keepAgreement),
        ),
        Gap(Dimens.spacing.sp20),
      ],
    );
  }
}
