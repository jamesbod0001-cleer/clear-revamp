import 'package:cleer/ui/agreements/create_agreement/models/agreement_type.dart';
import 'package:cleer/ui/agreements/create_agreement/view_model/create_agreement_view_model.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer_ui/cleer_ui.dart';
import 'package:cleer_ui/generated/assets.gen.dart';
import 'package:cleer_ui/widgets/bottom_sheets/custom_bottom_sheet.dart';
import 'package:cleer_ui/widgets/buttons/primary_button.dart';
import 'package:cleer_ui/widgets/menu_section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
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
      releaseDateController.text = formattedReleaseDate;
      return null;
    }, [selectedReleaseDate.value]);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        viewModel.onFormChanged(
          state.value!.formData.copyWith(
            releaseDate: selectedReleaseDate.value,
            description: descriptionController.text,
          ),
        );
      });
      return null;
    }, [selectedReleaseDate.value, descriptionController.text]);

    final formData = state.value?.formData;

    final bool isFormComplete =
        (formData?.disbursementType == .oneTime
            ? (formData?.releaseDate != null)
            : true) &&
        ((formData?.description.isNotEmpty ?? false) &&
            ((formData?.description.length ?? 0) > 2));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        // If didPop is true, the screen is already closing.
        if (didPop) return;

        // If didPop is false, we are on Step 2 or 3.
        // Just move the internal state back.
        viewModel.moveStepBack();
      },
      child: Form(
        onChanged: () {
          viewModel.onFormChanged(
            state.value!.formData.copyWith(
              releaseDate: selectedReleaseDate.value,
              description: descriptionController.text,
            ),
          );
        },
        child: ResponsiveLayout(
          mobile: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: Dimens.mobile.edgeInsetsScreenHorizontal,
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Gap(Dimens.spacing.sp12),
                    MenuSectionHeader(title: l10n.additionalDetails),
                    if (formData?.disbursementType == .oneTime) ...[

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
                        onTap: () => _showDatePickerBottomSheet(
                          context,
                          selectedReleaseDate,
                        ),
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
                    ],
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
                            type == .send
                                ? l10n.whatExactlyAreYouPayingFor
                                : l10n.whatExactlyAreYouReceivingFundsFor,
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
          desktop: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: Dimens.of(context).edgeInsetsScreenHorizontal.copyWith(
                  top: context.isTablet
                      ? Dimens.padding.p20
                      : Dimens.padding.p28,
                  bottom: Dimens.padding.p20,
                ),
                sliver: SliverToBoxAdapter(
                  child: Align(
                    alignment: .centerLeft,
                    child: InkWell(
                      onTap: () => viewModel.moveStepBack(),
                      borderRadius: .circular(Dimens.radius.r4),
                      child: Row(
                        mainAxisSize: .min,
                        children: [
                          PhosphorIcon(
                            PhosphorIcons.arrowLeft(),
                            color: context.color.blue700,
                            size: Dimens.size.s20,
                          ),
                          Gap(Dimens.spacing.sp8),
                          Text(
                            l10n.back,
                            style: context.typo.bodyMedium.copyWith(
                              color: context.color.blue700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: Dimens.of(context).edgeInsetsScreenHorizontal,
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Gap(Dimens.spacing.sp12),
                    MenuSectionHeader(title: l10n.additionalDetails),
                    if (formData?.disbursementType == .oneTime) ...[
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
                        onTap: () => _showDatePickerBottomSheet(
                          context,
                          selectedReleaseDate,
                        ),
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
                    ],

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
                            type == .send
                                ? l10n.whatExactlyAreYouPayingFor
                                : l10n.whatExactlyAreYouReceivingFundsFor,
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
                  padding: Dimens.of(context).edgeInsetsScreenHorizontal
                      .copyWith(bottom: MediaQuery.of(context).padding.bottom),
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
        ),
      ),
    );
  }

  void _showDatePickerBottomSheet(
    BuildContext context,
    ValueNotifier<DateTime?> selectedDate,
  ) =>
      CustomBottomSheet.show<DateTime?>(
        context: context,
        showCancelIcon: true,
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
