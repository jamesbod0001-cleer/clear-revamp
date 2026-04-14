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

class CancelAgreementBottomSheet extends ConsumerWidget {
  const CancelAgreementBottomSheet({
    super.key,
    required this.onCancelAgreement,
    required this.agreement,
  });

  final Agreement agreement;
  final VoidCallback onCancelAgreement;

  static Future<void> show(
    BuildContext context, {
    required Agreement agreement,
    required VoidCallback onCancelAgreement,
  }) => CustomBottomSheet.show<void>(
    context: context,
    isDismissible: true,
    child: CancelAgreementBottomSheet(
      onCancelAgreement: onCancelAgreement,
      agreement: agreement,
    ),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: .min,
      children: [
        StatusCircleIcon(type: .error),
        Gap(Dimens.spacing.sp48),
        Text(
          '${agreement.initiatorRole == .sender ? l10n.cancelAgreement : l10n.declineAgreement}?',
          style: context.typo.headlineSmall,
        ),
        Gap(Dimens.spacing.sp12),
        Text(
          agreement.initiatorRole == .sender
              ? l10n.cancellingThisPaymentWillCancelTheEntireAgreement
              : l10n.cancellingThisPaymentWillDeclineThisAgreement,
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
            onCancelAgreement();
          },
          child: Text(l10n.cancelAgreement),
        ),
        Gap(Dimens.spacing.sp20),
      ],
    );
  }
}
