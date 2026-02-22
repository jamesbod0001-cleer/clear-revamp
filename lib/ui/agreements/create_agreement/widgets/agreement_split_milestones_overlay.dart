import 'package:cleer/ui/agreements/create_agreement/models/agreement_type.dart';
import 'package:cleer/ui/agreements/create_agreement/state/create_agreement_state.dart';
import 'package:cleer/ui/agreements/create_agreement/view_model/create_agreement_view_model.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:cleer/ui/core/themes/theme.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:cleer/ui/core/ui/bottom_sheets/custom_bottom_sheet.dart';
import 'package:cleer/ui/core/ui/buttons/primary_button.dart';
import 'package:cleer/ui/core/ui/custom_text_form_field.dart';
import 'package:cleer/utils/text_input_formatters/decimal_thousands_formatter.dart';
import 'package:cleer/utils/validators/common_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AgreementSplitMilestonesOverlay extends HookConsumerWidget {
  const AgreementSplitMilestonesOverlay({super.key, required this.type});

  final AgreementType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final state = ref.watch(createAgreementViewModelProvider(type));
    final viewModel = ref.read(createAgreementViewModelProvider(type).notifier);
    final formData = state.value?.formData;

    final String amount =
        '${l10n.nairaSign} ${NumberFormat('#,###.##').format(double.parse(formData?.amount ?? '0'))}';

    final milestones = useState<List<MilestoneDraft>>(
      formData?.milestones ??
          [
            MilestoneDraft(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
            ),
          ],
    );
    final totalAmount = double.tryParse(formData?.amount ?? '0') ?? 0.0;
    final allocatedAmount = milestones.value.fold(
      0.0,
      (sum, m) => sum + m.amount,
    );
    final remainingAmount = totalAmount - allocatedAmount;

    bool isFormValid() {
      // 1. Check Amount Overflow
      if (allocatedAmount > totalAmount) return false;

      // 2. Exact Match Check (Usually required for Escrow)
      if (allocatedAmount != totalAmount) return false;

      for (int i = 0; i < milestones.value.length; i++) {
        final current = milestones.value[i];

        // Basic required fields
        if (current.name.isEmpty ||
            current.amount <= 0 ||
            current.releaseDate == null) {
          return false;
        }

        // SEQUENTIAL DATE CHECK
        if (i > 0) {
          final previous = milestones.value[i - 1];
          // Milestone 2 must be AFTER Milestone 1
          if (current.releaseDate!.isBefore(previous.releaseDate!) ||
              current.releaseDate!.isAtSameMomentAs(previous.releaseDate!)) {
            return false;
          }
        }
      }
      return true;
    }

    return Scaffold(
      appBar: AppBar(
        titleSpacing: Dimens.padding.p18,
        titleTextStyle: context.typo.headlineSmall,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: .start,
          children: [
            IconButton(
              style: IconButton.styleFrom(
                padding: .zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                minimumSize: Size.zero,
              ),
              onPressed: () {
                context.pop();
              },
              icon: PhosphorIcon(
                PhosphorIcons.x(.bold),
                color: context.color.grey600,
              ),
            ),
            Gap(Dimens.spacing.sp24),
            Text(l10n.splitAmountIntoMilestones(amount)),
            Gap(Dimens.spacing.sp24),
            Row(
              key: ValueKey(remainingAmount),
              children: [
                Text(
                  "${l10n.remaining}:",
                  style: context.typo.bodyMedium.copyWith(
                    fontWeight: AppFontWeights.regular,
                    color: context.color.grey600,
                  ),
                ),
                Gap(Dimens.spacing.sp4),
                Material(
                  color: context.color.blue100,
                  borderRadius: .circular(Dimens.radius.r40),
                  child: Padding(
                    padding: .symmetric(
                      horizontal: Dimens.padding.p8,
                      vertical: Dimens.padding.p2,
                    ),
                    child: Text(
                      "${l10n.nairaSign} ${NumberFormat('#,###.##').format(remainingAmount)}",
                      style: context.typo.bodyMedium.copyWith(
                        color: context.color.grey800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        toolbarHeight: 179,
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: Dimens.mobile.edgeInsetsScreenHorizontal,
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final MilestoneDraft milestone = milestones.value[index];
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index != milestones.value.length - 1
                        ? Dimens.padding.p24
                        : Dimens.padding.p0,
                  ),
                  child: MilestoneItemCard(
                    key: ValueKey(milestone.id),
                    milestone: milestone,
                    previousMilestone: index != 0
                        ? milestones.value.elementAtOrNull(index - 1)
                        : null,
                    onChanged: (updatedMilestone) {
                      milestones.value = milestones.value
                          .map(
                            (m) => m.id == milestone.id ? updatedMilestone : m,
                          )
                          .toList();
                    },
                    onDelete: milestones.value.length > 1
                        ? () {
                            milestones.value = milestones.value
                                .where((m) => m.id != milestone.id)
                                .toList();
                          }
                        : null,
                  ),
                );
              }, childCount: milestones.value.length),
            ),
          ),
          SliverToBoxAdapter(
            child: Visibility(
              visible: !(allocatedAmount == totalAmount),
              child: Padding(
                padding: Dimens.mobile.edgeInsetsScreenHorizontal.copyWith(
                  top: Dimens.padding.p24,
                ),
                child: Align(
                  alignment: .centerLeft,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: context.color.blue700,
                      padding: .symmetric(vertical: Dimens.padding.p8),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      minimumSize: Size.zero,
                      textStyle: context.typo.bodyLink.copyWith(
                        color: context.color.blue700,
                        decorationColor: context.color.blue700,
                      ),
                    ),
                    onPressed: () {
                      milestones.value = [
                        ...milestones.value,
                        MilestoneDraft(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                        ),
                      ];
                    },
                    child: Row(
                      mainAxisSize: .min,
                      children: [
                        PhosphorIcon(
                          PhosphorIcons.plus(),
                          color: context.color.blue700,
                          size: Dimens.size.s20,
                        ),
                        Gap(Dimens.spacing.sp5),
                        Text(l10n.addMilestone),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: Dimens.mobile.edgeInsetsScreenHorizontal.copyWith(
                bottom: MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                mainAxisAlignment: .end,
                children: [
                  Visibility(
                    visible: allocatedAmount > totalAmount,
                    child: Container(
                      margin: .only(top: Dimens.padding.p24),
                      padding: .all(Dimens.padding.p8),
                      decoration: BoxDecoration(
                        color: context.color.errorLight,
                        borderRadius: .circular(Dimens.radius.r8),
                      ),
                      child: Row(
                        children: [
                          PhosphorIcon(
                            PhosphorIcons.warning(.duotone),
                            color: context.color.error,
                            size: Dimens.size.s16,
                          ),
                          Gap(Dimens.spacing.sp12),
                          Text(
                            l10n.milestonesTotalExceeded(amount),
                            style: context.typo.bodyMedium.copyWith(
                              color: context.color.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Gap(Dimens.spacing.sp24),
                  PrimaryButton(
                    onPressed: isFormValid()
                        ? () {
                            viewModel.onFormChanged(
                              formData!.copyWith(milestones: milestones.value),
                            );
                            viewModel.moveToNextStep();
                            context.pop();
                          }
                        : null,
                    child: Text(l10n.next),
                  ),
                  Gap(Dimens.spacing.sp20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MilestoneItemCard extends HookWidget {
  const MilestoneItemCard({
    super.key,
    required this.milestone,
    this.previousMilestone,
    required this.onChanged,
    this.onDelete,
  });
  final MilestoneDraft milestone;
  final MilestoneDraft? previousMilestone;
  final ValueChanged<MilestoneDraft> onChanged;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final TextEditingController nameController = useTextEditingController(
      text: milestone.name,
    );
    final TextEditingController amountController = useTextEditingController(
      text: NumberFormat('#,###.##').format(milestone.amount),
    );
    final ValueNotifier<DateTime?> selectedReleaseDate = useState<DateTime?>(
      milestone.releaseDate,
    );
    String formatDateTime(DateTime? date) =>
        date != null ? DateFormat('dd-MM-yyyy').format(date) : '';

    final TextEditingController releaseDateController =
        useTextEditingController(
          text: formatDateTime(selectedReleaseDate.value),
        );

    void notifyParent() {
      onChanged(
        milestone.copyWith(
          name: nameController.text,
          amount:
              double.tryParse(amountController.text.replaceAll(',', '')) ?? 0.0,
          releaseDate: selectedReleaseDate.value,
        ),
      );
    }

    final dateFieldKey = useMemoized(() => GlobalKey<FormFieldState>());

    return Form(
      onChanged: notifyParent,
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .start,
        children: [
          Divider(
            color: context.color.outline,
            height: Dimens.size.s1,
            thickness: Dimens.size.s1,
          ),
          Gap(Dimens.spacing.sp24),
          CustomTextFormField(
            controller: nameController,
            labelText: l10n.milestoneName,
            validator: (name) =>
                commonValidator(value: name, fieldName: 'Milestone Name'),
          ),
          Gap(Dimens.spacing.sp16),
          Row(
            crossAxisAlignment: .start,
            children: [
              Expanded(
                flex: 162,
                child: CustomTextFormField(
                  controller: amountController,
                  labelText: l10n.milestoneAmount,
                  textInputType: TextInputType.number,
                  inputFormatters: [DecimalThousandsFormatter()],
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(right: Dimens.padding.p8),
                    child: Text(
                      l10n.nairaSign,
                      style: context.typo.bodyLarge.copyWith(
                        color: context.color.grey600,
                      ),
                    ),
                  ),
                  validator: (value) {
                    final amountStr = value?.replaceAll(',', '') ?? '';
                    final amount = double.tryParse(amountStr);
                    if (amountStr.isEmpty) return l10n.fieldRequired('amount');
                    if (amount == null || amount <= 0) {
                      return l10n.mustBeGreaterThanZero;
                    }
                    return null;
                  },
                ),
              ),
              Gap(Dimens.spacing.sp8),
              Expanded(
                flex: 187,
                child: Column(
                  mainAxisSize: .min,
                  children: [
                    CustomTextFormField(
                      fieldKey: dateFieldKey,
                      controller: releaseDateController,
                      labelText: l10n.releaseDate,
                      readOnly: false,
                      suffixIcon: IconButton(
                        onPressed: () => _pickDate(
                          context,
                          selectedReleaseDate,
                          releaseDateController,
                          notifyParent,
                          dateFieldKey,
                        ),
                        icon: PhosphorIcon(
                          PhosphorIcons.calendarDot(.duotone),
                          color: context.color.blue700,
                        ),
                      ),
                      onTap: () => _pickDate(
                        context,
                        selectedReleaseDate,
                        releaseDateController,
                        notifyParent,
                        dateFieldKey,
                      ),
                      validator: (value) {
                        final date = selectedReleaseDate.value;
                        if (date == null) {
                          return l10n.fieldRequired('release date');
                        }

                        if (previousMilestone?.releaseDate != null) {
                          // Simple "After" check: date must be after previous milestone
                          if (!date.isAfter(previousMilestone!.releaseDate!)) {
                            return l10n.invalidReleaseDate;
                          }
                        }
                        return null;
                      },
                    ),
                    Text(
                      l10n.expectedFundsReleaseDeadline,
                      style: context.typo.bodySmall.copyWith(
                        color: context.color.grey600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: context.color.error,
              padding: .symmetric(vertical: Dimens.padding.p8),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              minimumSize: Size.zero,
              textStyle: context.typo.bodyLink.copyWith(
                color: context.color.error,
                decorationColor: onDelete != null
                    ? context.color.error
                    : context.color.grey600,
              ),
            ),
            onPressed: onDelete,
            child: Row(
              mainAxisSize: .min,
              children: [
                PhosphorIcon(
                  PhosphorIcons.trash(.duotone),
                  size: Dimens.size.s16,
                ),
                Gap(Dimens.spacing.sp5),
                Text(l10n.removeMilestone),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate(
    BuildContext context,
    ValueNotifier<DateTime?> state,
    TextEditingController controller,
    VoidCallback onUpdated,
    GlobalKey<FormFieldState> fieldKey,
  ) async {
    final picked = await CustomBottomSheet.show<DateTime?>(
      context: context,
      showCancelIcon: true,
      child: DatePickerDialog(
        insetPadding: EdgeInsets.only(bottom: Dimens.padding.p24),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 60)),
        initialDate: state.value ?? DateTime.now(),
      ),
    );

    if (picked != null) {
      state.value = picked;
      controller.text = DateFormat('dd-MM-yyyy').format(picked);

      // Explicitly notify parent since Form.onChanged doesn't always
      // detect controller.text changes made programmatically
      onUpdated();
      fieldKey.currentState?.validate();
    }
  }
}
