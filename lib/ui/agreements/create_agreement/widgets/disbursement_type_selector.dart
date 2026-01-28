import 'package:cleer/domain/models/agreement/agreement_enums.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:cleer/ui/core/themes/theme.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class DisbursementTypeSelector extends StatelessWidget {
  const DisbursementTypeSelector({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  final DisbursementType? selectedType;
  final ValueChanged<DisbursementType?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return RadioGroup<DisbursementType?>(
      groupValue: selectedType,
      onChanged: onChanged,
      child: Column(
        children: [
          _DisbursementTypeTile(
            type: DisbursementType.oneTime,
            groupValue: selectedType,
            title: l10n.oneTimeRelease,
            subtitle: l10n
                .bestForPhysicalGoodsOrSimpleServicesWherePaymentIsReleasedOnceAfterDelivery,
            onChanged: onChanged,
          ),
          Gap(Dimens.spacing.sp12),
          _DisbursementTypeTile(
            type: DisbursementType.milestones,
            groupValue: selectedType,
            title: l10n.milestonePayments,
            subtitle:
                l10n.bestForLargeJobsOrLongProjectsPayInStagesAsWorkIsCompleted,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _DisbursementTypeTile extends StatelessWidget {
  final DisbursementType type;
  final DisbursementType? groupValue;
  final String title;
  final String subtitle;
  final ValueChanged<DisbursementType?> onChanged;

  const _DisbursementTypeTile({
    required this.type,
    required this.groupValue,
    required this.title,
    required this.subtitle,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = type == groupValue;

    return GestureDetector(
      onTap: () => onChanged(type),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.all(Dimens.padding.p12),
        decoration: BoxDecoration(
          color: isSelected
              ? context.color.blue100
              : context.color.grayComponent,
          borderRadius: BorderRadius.circular(
            isSelected ? Dimens.radius.r12 : Dimens.radius.r8,
          ),
          border: Border.all(
            color: isSelected ? context.color.blue700 : context.color.outline,
          ),
        ),
        child: Row(
          children: [
            SizedBox.square(
              dimension: Dimens.size.s24,
              child: Radio<DisbursementType?>(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                activeColor: context.color.blue700,
                fillColor: WidgetStatePropertyAll(
                  isSelected ? context.color.blue700 : context.color.blue200,
                ),
                value: type,
              ),
            ),
            Gap(Dimens.spacing.sp8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: context.typo.bodyLarge),
                  Gap(Dimens.spacing.sp4),
                  Text(
                    subtitle,
                    style: context.typo.bodyMedium.copyWith(
                      fontWeight: AppFontWeights.regular,
                      color: context.color.grey600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
