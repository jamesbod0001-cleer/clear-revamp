import 'package:cleer/config/assets.gen.dart';
import 'package:cleer/domain/models/agreement/agreement_enums.dart';
import 'package:cleer/ui/agreements/create_agreement/models/agreement_type.dart';
import 'package:cleer/ui/agreements/create_agreement/view_model/create_agreement_view_model.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:cleer/ui/core/themes/theme.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:cleer/ui/core/ui/bottom_sheets/custom_bottom_sheet.dart';
import 'package:cleer/ui/core/ui/buttons/primary_button.dart';
import 'package:cleer/ui/core/ui/custom_text_form_field.dart';
import 'package:cleer/ui/profile/profile/widgets/profile_section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AdditionalDetailsStep extends HookConsumerWidget {
  const AdditionalDetailsStep({super.key, required this.type});

  final AgreementType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final state = ref.watch(createAgreementViewModelProvider(type));
    final viewModel = ref.read(createAgreementViewModelProvider(type).notifier);

    final ValueNotifier<AgreementCategory?> selectedCategory =
        useState<AgreementCategory?>(state.value?.formData.category);
    final categoryController = useTextEditingController(
      text: selectedCategory.value?.label,
    );
    final ValueNotifier<DateTime?> selectedReleaseDate = useState<DateTime?>(
      state.value?.formData.releaseDate,
    );
    String formattedReleaseDate = selectedReleaseDate.value != null
        ? DateFormat('dd-MM-yyyy').format(selectedReleaseDate.value!)
        : '';
    final releaseDateController = useTextEditingController(
      text: formattedReleaseDate,
    );
    final TextEditingController descriptionController =
        useTextEditingController(text: state.value?.formData.description);

    useEffect(() {
      categoryController.text = selectedCategory.value?.label ?? '';
      return null;
    }, [selectedCategory.value]);

    useEffect(() {
      releaseDateController.text = formattedReleaseDate;
      return null;
    }, [selectedReleaseDate.value]);

    useEffect(
      () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          viewModel.onFormChanged(
            state.value!.formData.copyWith(
              category: selectedCategory.value,
              releaseDate: selectedReleaseDate.value,
              description: descriptionController.text,
            ),
          );
        });
        return null;
      },
      [
        selectedCategory.value,
        selectedReleaseDate.value,
        descriptionController.text,
      ],
    );

    final formData = state.value?.formData;

    final bool isFormComplete =
        (formData?.category != null) &&
        (formData?.releaseDate != null) &&
        ((formData?.description.isNotEmpty ?? false) &&
            ((formData?.description.length ?? 0) > 2));

    return Form(
      onChanged: () {
        viewModel.onFormChanged(
          state.value!.formData.copyWith(
            category: selectedCategory.value,
            releaseDate: selectedReleaseDate.value,
            description: descriptionController.text,
          ),
        );
      },
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: Dimens.mobile.edgeInsetsScreenHorizontal,
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Gap(Dimens.spacing.sp12),
                ProfileSectionHeader(title: l10n.additionalDetails),
                CustomTextFormField(
                  controller: categoryController,
                  labelText: l10n.paymentCategory,
                  readOnly: true,
                  onTap: () =>
                      _showCategoryPickerBottomSheet(context, selectedCategory),
                  suffixIcon: IconButton(
                    onPressed: () => _showCategoryPickerBottomSheet(
                      context,
                      selectedCategory,
                    ),
                    icon: PhosphorIcon(
                      PhosphorIcons.caretDown(),
                      color: context.color.blue700,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.fieldRequired('payment category');
                    }
                    return null;
                  },
                ),
                Gap(Dimens.spacing.sp20),
                CustomTextFormField(
                  controller: releaseDateController,
                  labelText: l10n.releaseDate,
                  readOnly: true,
                  suffixIcon: IconButton(
                    onPressed: () => _showDatePickerBottomSheet(
                      context,
                      selectedReleaseDate,
                    ),
                    icon: PhosphorIcon(
                      PhosphorIcons.calendarDot(.duotone),
                      color: context.color.blue700,
                    ),
                  ),
                  onTap: () =>
                      _showDatePickerBottomSheet(context, selectedReleaseDate),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.fieldRequired('release date');
                    }
                    return null;
                  },
                ),
                Gap(Dimens.spacing.sp4),
                Text(
                  l10n.expectedFundsReleaseDeadline,
                  style: context.typo.bodyMedium.copyWith(
                    fontWeight: AppFontWeights.regular,
                    color: context.color.grey600,
                  ),
                ),
                Gap(Dimens.spacing.sp20),
                CustomTextFormField(
                  controller: descriptionController,
                  label: Column(
                    crossAxisAlignment: .start,
                    children: [
                      Text(
                        l10n.description,
                        style: context.typo.bodyMedium.copyWith(
                          color: context.color.grey600,
                        ),
                      ),
                      Gap(Dimens.spacing.sp4),
                      Text(
                        l10n.whatExactlyAreYouPayingFor,
                        style: context.typo.bodyMedium.copyWith(
                          fontWeight: AppFontWeights.regular,
                          color: context.color.grey600,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 6,
                  minLines: 6,
                  maxLength: 500,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.fieldRequired('description');
                    }
                    if (value.length <= 2) {
                      return l10n.fieldTooShort('Description', 3);
                    }
                    return null;
                  },
                ),
              ]),
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
                  Gap(Dimens.spacing.sp40),
                  Material(
                    borderRadius: .circular(Dimens.radius.r8),
                    color: context.color.infoLight,
                    child: Padding(
                      padding: .fromLTRB(
                        Dimens.padding.p12,
                        Dimens.padding.p8,
                        Dimens.padding.p8,
                        Dimens.padding.p8,
                      ),
                      child: Row(
                        children: [
                          Assets.images.shield.image(
                            width: Dimens.size.s23,
                            height: Dimens.size.s32,
                          ),
                          Gap(Dimens.spacing.sp16),
                          Expanded(
                            child: Text(
                              l10n.fundsWillBeHeldSafelyAndOnlyReleasedWhenYouConfirmDelivery,
                              style: context.typo.bodyMedium.copyWith(
                                color: context.color.blue800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Gap(Dimens.spacing.sp20),
                  PrimaryButton(
                    onPressed: isFormComplete
                        ? () => viewModel.moveToNextStep()
                        : null,
                    child: Text(l10n.reviewDetails),
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

  void _showCategoryPickerBottomSheet(
    BuildContext context,
    ValueNotifier<AgreementCategory?> selectedCategory,
  ) =>
      CustomBottomSheet.show(
        context: context,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.selectCategory,
              style: context.typo.headlineSmall,
            ),
            Gap(Dimens.spacing.sp24),
            ListView.separated(
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                final category = AgreementCategory.values[index];
                return Column(
                  crossAxisAlignment: .stretch,
                  children: [
                    if (index == 0)
                      Divider(
                        color: context.color.outline,
                        height: Dimens.size.s1,
                        thickness: Dimens.size.s1,
                      ),
                    Material(
                      color: context.color.transparent,
                      child: InkWell(
                        onTap: () => context.pop(category),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: Dimens.padding.p8,
                            vertical: Dimens.padding.p12,
                          ),
                          child: Column(
                            crossAxisAlignment: .start,
                            children: [
                              Text(
                                category.label,
                                style: context.typo.bodyLarge.copyWith(
                                  color: context.color.grey800,
                                ),
                              ),
                              Text(
                                category.examples,
                                style: context.typo.bodyMedium.copyWith(
                                  color: context.color.grey600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (index == AgreementCategory.values.length - 1)
                      Divider(
                        color: context.color.outline,
                        height: Dimens.size.s1,
                        thickness: Dimens.size.s1,
                      ),
                  ],
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return Divider(
                  color: context.color.outline,
                  height: Dimens.size.s1,
                  thickness: Dimens.size.s1,
                );
              },
              itemCount: AgreementCategory.values.length,
            ),
          ],
        ),
      ).then((value) {
        if (value != null) {
          selectedCategory.value = value;
        }
      });

  void _showDatePickerBottomSheet(
    BuildContext context,
    ValueNotifier<DateTime?> selectedDate,
  ) =>
      CustomBottomSheet.show<DateTime?>(
        context: context,
        showCancelIcon: false,
        child: DatePickerDialog(
          insetPadding: .only(bottom: Dimens.padding.p24),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(Duration(days: 60)),
          initialDate: selectedDate.value,
        ),
      ).then((value) {
        if (value != null) {
          selectedDate.value = value;
        }
      });
}
