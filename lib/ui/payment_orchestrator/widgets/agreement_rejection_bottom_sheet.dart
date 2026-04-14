import 'package:cleer/domain/models/agreement/agreement.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:cleer/ui/core/ui/bottom_sheets/custom_bottom_sheet.dart';
import 'package:cleer/ui/core/ui/buttons/primary_button.dart';
import 'package:cleer/ui/core/ui/status_circle_icon.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AgreementRejectionBottomSheet extends ConsumerWidget {
  const AgreementRejectionBottomSheet({
    super.key,
    required this.onConfirm,
    required this.agreement,
  });

  final Agreement agreement;
  final VoidCallback onConfirm;

  static Future<void> show(
    BuildContext context, {
    required Agreement agreement,
    required VoidCallback onConfirm,
  }) => CustomBottomSheet.show<void>(
    context: context,
    isDismissible: true,
    child: AgreementRejectionBottomSheet(
      onConfirm: onConfirm,
      agreement: agreement,
    ),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final isSender = agreement.initiatorRole == .sender;
    final title = isSender ? l10n.cancelAgreement : l10n.declineAgreement;
    final description = isSender
        ? l10n.cancellingThisPaymentWillCancelTheEntireAgreement
        : l10n.cancellingThisPaymentWillDeclineThisAgreement;

    return Column(
      mainAxisSize: .min,
      children: [
        StatusCircleIcon(type: .error),
        Gap(Dimens.spacing.sp48),
        Text('$title?', style: context.typo.headlineSmall),
        Gap(Dimens.spacing.sp12),
        Text(
          description,
          style: context.typo.bodyMedium.copyWith(color: context.color.grey600),
          textAlign: .center,
        ),
        Gap(Dimens.spacing.sp24),
        PrimaryButton(
          onPressed: () => context.pop(),
          child: Text(l10n.continuePayment),
        ),
        Gap(Dimens.spacing.sp12),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: context.color.error),
          onPressed: () {
            context.pop();
            onConfirm();
          },
          child: Text(title),
        ),
        Gap(Dimens.spacing.sp20),
      ],
    );
  }
}
