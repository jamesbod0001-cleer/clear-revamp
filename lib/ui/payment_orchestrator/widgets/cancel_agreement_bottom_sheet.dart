import 'package:cleer/config/assets.gen.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:cleer/ui/core/ui/bottom_sheets/custom_bottom_sheet.dart';
import 'package:cleer/ui/core/ui/buttons/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class CancelAgreementBottomSheet extends StatelessWidget {
  const CancelAgreementBottomSheet({
    super.key,
    required this.onCancelAgreement,
  });

  final VoidCallback onCancelAgreement;

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onCancelAgreement,
  }) => CustomBottomSheet.show<void>(
    context: context,
    isDismissible: true,
    child: CancelAgreementBottomSheet(onCancelAgreement: onCancelAgreement),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: .min,
      children: [
        Container(
          width: Dimens.size.s100,
          height: Dimens.size.s100,
          alignment: .center,
          decoration: BoxDecoration(
            color: Color(0xFFF11010).withValues(alpha: .07),
            shape: BoxShape.circle,
            border: .all(
              color: Color(0xFF933B3B).withValues(alpha: .1),
              width: Dimens.size.s2,
            ),
          ),
          child: Assets.images.x.image(height: Dimens.size.s60),
        ),
        Gap(Dimens.spacing.sp48),
        Text('${l10n.cancelAgreement}?', style: context.typo.headlineSmall),
        Gap(Dimens.spacing.sp12),
        Text(
          l10n.cancellingThisPaymentWillCancelTheEntireAgreement,
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
          onPressed: (){
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
