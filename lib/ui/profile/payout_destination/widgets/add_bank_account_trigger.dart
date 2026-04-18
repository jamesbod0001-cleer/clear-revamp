import 'package:cleer/config/assets.gen.dart';
import 'package:cleer/domain/models/payout_destination/payout_destination.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:cleer/ui/profile/payout_destination/widgets/add_bank_account_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

enum _AddAccountType { button, card }

class AddBankAccountTrigger extends StatelessWidget {
  const AddBankAccountTrigger.button({super.key, this.onResult})
    : _type = _AddAccountType.button;

  const AddBankAccountTrigger.card({super.key, this.onResult})
    : _type = _AddAccountType.card;

  final _AddAccountType _type;
  final ValueChanged<PayoutDestination>? onResult;

  @override
  Widget build(BuildContext context) {
    return switch (_type) {
      _AddAccountType.button => _AddBankAccountButton(
        onTap: () => _handleTap(context),
      ),
      _AddAccountType.card => _AddBankAccountCard(
        onTap: () => _handleTap(context),
      ),
    };
  }

  Future<void> _handleTap(BuildContext context) async {
    final result = await AddBankAccountBottomSheet.show(context);
    if (result != null && onResult != null) {
      onResult!(result);
    }
  }
}

class _AddBankAccountCard extends StatelessWidget {
  const _AddBankAccountCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: .all(Dimens.padding.p8),
        decoration: BoxDecoration(
          color: context.color.grayComponent,
          borderRadius: BorderRadius.circular(Dimens.radius.r8),
          border: Border.all(color: context.color.outline),
        ),
        child: Column(
          mainAxisSize: .min,
          children: [
            Gap(9.5),
            Assets.images.bank.image(
              width: Dimens.size.s23,
              height: Dimens.size.s23,
            ),
            Gap(Dimens.spacing.sp8),
            IgnorePointer(child: _AddBankAccountButton(onTap: onTap)),
            Gap(9.5),
          ],
        ),
      ),
    );
  }
}

class _AddBankAccountButton extends StatelessWidget {
  const _AddBankAccountButton({required this.onTap});
  final VoidCallback onTap;

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
      onPressed: onTap,
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
