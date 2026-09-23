import 'package:cleer/ui/agreements/extensions/agreement_ui_extensions.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:cleer_ui/cleer_ui.dart';
import 'package:cleer_ui/widgets/bottom_sheets/custom_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class ReasonPickerBottomSheet extends StatelessWidget {
  const ReasonPickerBottomSheet({
    super.key,
    required this.reasons,
    this.selectedReason,
  });

  final List<DisputeReason> reasons;
  final DisputeReason? selectedReason;

  static Future<DisputeReason?> show(
    BuildContext context, {
    required List<DisputeReason> reasons,
    DisputeReason? selectedReason,
  }) {
    return CustomBottomSheet.show<DisputeReason>(
      context: context,
      child: ReasonPickerBottomSheet(
        reasons: reasons,
        selectedReason: selectedReason,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.reason, style: context.typo.headlineSmall),
        Gap(Dimens.spacing.sp24),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reasons.length,
          separatorBuilder: (_, _) => Divider(
            color: context.color.outline,
            height: Dimens.size.s1,
            thickness: Dimens.size.s1,
          ),
          itemBuilder: (context, index) {
            final reason = reasons[index];

            return Material(
              color: context.color.transparent,
              child: InkWell(
                onTap: () => context.pop(reason),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimens.padding.p8,
                    vertical: Dimens.padding.p12,
                  ),
                  child: Text(
                    reason.getLabel(context),
                    style: context.typo.bodyLarge.copyWith(
                      color: context.color.grey800,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        Gap(Dimens.spacing.sp24),
      ],
    );
  }
}
