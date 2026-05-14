import 'package:cleer/config/assets.gen.dart';
import 'package:cleer_core/models/payout_destination/payout_destination.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer_ui/themes/dimensions.dart';
import 'package:cleer_ui/themes/theme.dart';
import 'package:cleer_ui/themes/theme_utils.dart';
import 'package:cleer/ui/profile/payout_destination/widgets/remove_bank_account_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class PayoutDestinationCard extends StatelessWidget {
  const PayoutDestinationCard({
    super.key,
    required this.payoutDestination,
    this.action,
    this.showRemove = true,
  });
  final PayoutDestination payoutDestination;
  final Widget? action;
  final bool showRemove;

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
                    payoutDestination.accountName,
                    style: context.typo.bodyMedium.copyWith(
                      fontWeight: AppFontWeights.regular,
                      color: context.color.grey800,
                    ),
                  ),
                  Text(
                    payoutDestination.accountNumber,
                    style: context.typo.bodyMedium.copyWith(
                      color: context.color.grey800,
                    ),
                  ),
                  Text(
                    payoutDestination.bankName,
                    style: context.typo.bodyMedium.copyWith(
                      fontWeight: AppFontWeights.regular,
                      color: context.color.grey600,
                    ),
                  ),
                ],
              ),
            ),

            Column(
              mainAxisAlignment: action != null || showRemove == true
                  ? .spaceBetween
                  : .center,
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
                ?action,
                if (action == null && showRemove)
                  Visibility(
                    visible: false,
                    child: GestureDetector(
                      onTap: () => RemoveBankAccountBottomSheet.show(
                        context,
                        payoutDestination,
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.remove,
                        style: context.typo.bodyLink.copyWith(
                          color: context.color.error,
                          decorationColor: context.color.error,
                        ),
                      ),
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
