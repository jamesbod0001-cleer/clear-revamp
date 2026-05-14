import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer_ui/themes/dimensions.dart';
import 'package:cleer_ui/themes/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CancelPaymentButton extends StatelessWidget {
  const CancelPaymentButton({super.key, required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: context.color.errorLight,
        foregroundColor: context.color.error,
        side: BorderSide(color: Color(0xFFF5D6DF)),
        minimumSize: .zero,
        padding: .fromLTRB(
          Dimens.padding.p6,
          Dimens.padding.p10,
          Dimens.padding.p8,
          Dimens.padding.p10,
        ),
        textStyle: context.typo.bodyMedium.copyWith(
          height: 1,
          letterSpacing: 0.14,
        ),
        tapTargetSize: .shrinkWrap,
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: .min,
        children: [
          PhosphorIcon(PhosphorIcons.x(.bold), size: Dimens.size.s16),
          Gap(Dimens.spacing.sp8),
          Text(AppLocalizations.of(context)!.cancelPayment),
        ],
      ),
    );
  }
}

class ChangePaymentMethodButton extends StatelessWidget {
  const ChangePaymentMethodButton({super.key, required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: context.color.grayComponent,
        foregroundColor: context.color.blue700,
        side: BorderSide(color: context.color.outline),
        minimumSize: .zero,
        padding: .fromLTRB(
          Dimens.padding.p6,
          Dimens.padding.p10,
          Dimens.padding.p8,
          Dimens.padding.p10,
        ),
        textStyle: context.typo.labelSmall,
        tapTargetSize: .shrinkWrap,
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: .min,
        children: [
          PhosphorIcon(
            PhosphorIcons.arrowsDownUp(.duotone),
            size: Dimens.size.s16,
          ),
          Gap(Dimens.spacing.sp8),
          Text(AppLocalizations.of(context)!.changePaymentMethod),
        ],
      ),
    );
  }
}
