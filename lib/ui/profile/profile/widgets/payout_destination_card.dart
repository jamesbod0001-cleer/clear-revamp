import 'package:cleer/config/assets.gen.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:cleer/ui/core/themes/theme.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class PayoutDestinationCard extends StatelessWidget {
  const PayoutDestinationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.color.grayComponent,
        borderRadius: BorderRadius.circular(Dimens.radius.r8),
        border: Border.all(color: context.color.outline),
      ),
      padding: .all(Dimens.padding.p8),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Assets.images.bank.image(
              width: Dimens.size.s32,
              height: Dimens.size.s32,
            ),
            Gap(Dimens.spacing.sp8),

            Expanded(
              child: Column(
                crossAxisAlignment: .start,
                spacing: Dimens.spacing.sp4,
                children: [
                  Text(
                    'CELESTINE EZIAMACHUKWU DAVID',
                    style: context.typo.bodyMedium.copyWith(
                      fontWeight: AppFontWeights.regular,
                      color: context.color.grey800,
                    ),
                  ),
                  Text(
                    '2026884938',
                    style: context.typo.bodyMedium.copyWith(
                      color: context.color.grey800,
                    ),
                  ),
                  Text(
                    'Kuda Bank',
                    style: context.typo.bodyMedium.copyWith(
                      fontWeight: AppFontWeights.regular,
                      color: context.color.grey600,
                    ),
                  ),
                ],
              ),
            ),

            Column(
              mainAxisAlignment: .spaceBetween,
              crossAxisAlignment: .end,
              children: [
                Container(
                  width: Dimens.size.s38,
                  height: Dimens.size.s38,
                  decoration: BoxDecoration(
                    color: context.color.primaryBlue,
                    borderRadius: .circular(Dimens.radius.r12),
                  ),
                ),
                Text(
                  AppLocalizations.of(context)!.edit,
                  style: context.typo.bodyLink.copyWith(
                    color: context.color.blue700,
                    decorationColor: context.color.blue700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AddBankAccountButton extends StatelessWidget {
  const AddBankAccountButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: context.color.transparent,
        foregroundColor: context.color.blue700,
        minimumSize: Size(0, 0),
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: () {},
      child: Row(
        mainAxisSize: .min,
        children: [
          PhosphorIcon(
            PhosphorIcons.plus(),
            size: Dimens.size.s16,
            color: context.color.blue700,
          ),
          Gap(Dimens.spacing.sp5),
          Text(
            AppLocalizations.of(context)!.addBankAccount,
            style: context.typo.bodyLink.copyWith(
              color: context.color.blue700,
              decorationColor: context.color.blue700,
            ),
          ),
        ],
      ),
    );
  }
}
