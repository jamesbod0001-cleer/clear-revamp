import 'dart:io';

import 'package:cleer/config/assets.gen.dart';
import 'package:cleer/ui/agreements/agreement_details/view_model/share_delivery_information_view_model.dart';
import 'package:cleer/ui/agreements/agreement_details/widgets/emphasized_action_card.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:cleer_ui/cleer_ui.dart';
import 'package:cleer_ui/widgets/buttons/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ShareDeliveryInformationCard extends HookConsumerWidget {
  const ShareDeliveryInformationCard({super.key, required this.agreement});
  final Agreement agreement;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    int limit = 4;

    final state = ref.watch(
      shareDeliveryInformationViewModelProvider(agreement.id!),
    );
    final viewModel = ref.read(
      shareDeliveryInformationViewModelProvider(agreement.id!).notifier,
    );
    final evidenceImages = state.requireValue.formData.evidenceImages;

    final TextEditingController driverPhoneNumberController =
        useTextEditingController();
    final TextEditingController deliveryInformationController =
        useTextEditingController();
    final arrangedBy = useState<DeliveryDetailArrangedBy?>(null);

    final pickAndProcessEvidenceImagesCommand =
        viewModel.pickAndProcessEvidenceImages;
    useEffect(() {
      void listener() {
        if (pickAndProcessEvidenceImagesCommand.errors.value != null) {
          debugPrint(
            "Command Error: ${pickAndProcessEvidenceImagesCommand.errors.value?.error}",
          );
        }
      }

      pickAndProcessEvidenceImagesCommand.errors.addListener(listener);
      return () =>
          pickAndProcessEvidenceImagesCommand.errors.removeListener(listener);
    }, [pickAndProcessEvidenceImagesCommand]);

    return Form(
      onChanged: () {
        viewModel.onFormChanged(
          state.value!.formData.copyWith(
            driverPhoneNumber: driverPhoneNumberController.text,
            deliveryInformation: deliveryInformationController.text,
            arrangedBy: arrangedBy.value,
          ),
        );
      },
      child: EmphasizedActionCard(
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Text(
              l10n.shareDeliveryInformation,
              style: context.typo.titleSmall.copyWith(
                color: context.color.white,
              ),
            ),
            Gap(Dimens.spacing.sp4),
            Text(
              l10n.shareHowTheItemIsBeingDeliveredSoTheBuyerKnowsWhoToExpect,
              style: context.typo.bodySmall.copyWith(
                color: context.color.blue200,
              ),
            ),
            Gap(Dimens.spacing.sp24),
            if (state.isLoading)
              Padding(
                padding: EdgeInsets.symmetric(vertical: Dimens.padding.p20),
                child: const Center(child: CircularProgressIndicator()),
              )
            else
              Column(
                crossAxisAlignment: .start,
                children: [
                  PhoneNumberTextFormField(
                    controller: driverPhoneNumberController,
                    variant: .dark,
                    labelText: l10n.driverPhoneNumber,
                  ),
                  Gap(Dimens.spacing.sp20),
                  CustomTextAreaFormField(
                    controller: deliveryInformationController,
                    variant: .dark,
                    label: Column(
                      mainAxisSize: .min,
                      crossAxisAlignment: .start,
                      children: [
                        Text(
                          l10n.deliveryInformation,
                          style: context.typo.bodyMedium.copyWith(
                            color: context.color.outline,
                          ),
                        ),
                        Gap(Dimens.spacing.sp4),
                        Text(
                          l10n.tellTheBuyerAnythingTheyShouldKnowAboutTheDeliveryEg,
                          style: context.typo.bodySmall.copyWith(
                            color: context.color.blue200,
                          ),
                        ),
                      ],
                    ),
                    footer: ValueListenableBuilder(
                      valueListenable:
                          pickAndProcessEvidenceImagesCommand.isRunning,
                      builder: (context, bool isRunning, child) {
                        return Padding(
                          padding: EdgeInsets.only(
                            left: Dimens.padding.p8,
                            bottom: Dimens.padding.p8,
                            right: Dimens.padding.p8,
                          ),
                          child: Column(
                            crossAxisAlignment: .start,
                            mainAxisAlignment: .end,
                            children: [
                              Wrap(
                                runSpacing: Dimens.spacing.sp8,
                                crossAxisAlignment: .end,
                                children: [
                                  if (evidenceImages.length < limit)
                                    Padding(
                                      padding: EdgeInsets.only(
                                        right: Dimens.padding.p24,
                                      ),
                                      child: Material(
                                        clipBehavior: .antiAlias,
                                        color: context.color.secondary,
                                        borderRadius: .circular(
                                          Dimens.radius.r100,
                                        ),
                                        child: InkWell(
                                          onTap: !isRunning
                                              ? () =>
                                                    pickAndProcessEvidenceImagesCommand
                                                        .run(limit)
                                              : null,
                                          child: Padding(
                                            padding: .symmetric(
                                              horizontal: Dimens.padding.p8,
                                              vertical: Dimens.padding.p4,
                                            ),
                                            child: Row(
                                              mainAxisSize: .min,
                                              children: [
                                                PhosphorIcon(
                                                  PhosphorIcons.plus(.bold),
                                                  color: context.color.blue200,
                                                  size: Dimens.size.s16,
                                                ),
                                                Gap(Dimens.spacing.sp4),
                                                Text(
                                                  l10n.attachPhotoEvidence,
                                                  style: context.typo.bodySmall
                                                      .copyWith(
                                                        color: context
                                                            .color
                                                            .blue200,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                  ...List.generate(evidenceImages.length, (
                                    int index,
                                  ) {
                                    final image = evidenceImages.elementAt(
                                      index,
                                    );
                                    return Row(
                                      mainAxisSize: .min,
                                      children: [
                                        Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            Container(
                                              width: 32,
                                              height: 32,
                                              clipBehavior: Clip.antiAlias,
                                              decoration: BoxDecoration(
                                                color: context.color.white
                                                    .withValues(alpha: .08),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      Dimens.radius.r8,
                                                    ),
                                              ),
                                              child: Image.file(
                                                File(image.file.path),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            if (!isRunning) ...[
                                              Positioned(
                                                top: -7,
                                                right: -7,
                                                child: PhosphorIcon(
                                                  PhosphorIcons.circle(.fill),
                                                  color:
                                                      context.color.background,
                                                  size: Dimens.size.s24,
                                                ),
                                              ),
                                              Positioned(
                                                top: -7,
                                                right: -7,
                                                child: GestureDetector(
                                                  onTap: () => viewModel
                                                      .removeImage(index),
                                                  child: PhosphorIcon(
                                                    PhosphorIcons.xCircle(
                                                      .fill,
                                                    ),
                                                    color: context.color.error,
                                                    size: Dimens.size.s24,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        if (evidenceImages.length !=
                                            (index + 1))
                                          Gap(Dimens.spacing.sp8),
                                      ],
                                    );
                                  }),
                                ],
                              ),
                              if (isRunning) ...[
                                Gap(Dimens.spacing.sp2),
                                LinearProgressIndicator(
                                  borderRadius: .circular(Dimens.radius.r100),
                                  minHeight: Dimens.size.s2,
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Gap(Dimens.spacing.sp20),
                  Text(
                    l10n.deliveryArrangedBy,
                    style: context.typo.bodyMedium.copyWith(
                      color: context.color.outline,
                    ),
                  ),
                  Gap(Dimens.spacing.sp4),
                  Row(
                    children: [
                      Row(
                        children: [
                          SizedBox.square(
                            dimension: Dimens.size.s24,
                            child: Checkbox(
                              tristate: false,
                              side: BorderSide(
                                color: context.color.background,
                                width: Dimens.size.s2,
                              ),
                              materialTapTargetSize: .shrinkWrap,
                              visualDensity: .compact,
                              value: arrangedBy.value == .vendor,
                              onChanged: (isSelected) {
                                arrangedBy.value = isSelected == true
                                    ? .vendor
                                    : null;
                                viewModel.onFormChanged(
                                  state.value!.formData.copyWith(
                                    arrangedBy: isSelected == true
                                        ? .vendor
                                        : null,
                                  ),
                                );
                              },
                            ),
                          ),
                          Gap(Dimens.spacing.sp4),
                          Text(
                            l10n.me,
                            style: context.typo.bodySmall.copyWith(
                              color: context.color.blue200,
                            ),
                          ),
                        ],
                      ),
                      Gap(Dimens.spacing.sp32),
                      Row(
                        children: [
                          SizedBox.square(
                            dimension: Dimens.size.s24,
                            child: Checkbox(
                              tristate: false,
                              side: BorderSide(
                                color: context.color.background,
                                width: Dimens.size.s2,
                              ),
                              materialTapTargetSize: .shrinkWrap,
                              visualDensity: .compact,
                              value: arrangedBy.value == .buyer,
                              onChanged: (isSelected) {
                                arrangedBy.value = isSelected == true
                                    ? .buyer
                                    : null;
                                viewModel.onFormChanged(
                                  state.value!.formData.copyWith(
                                    arrangedBy: isSelected == true
                                        ? .buyer
                                        : null,
                                  ),
                                );
                              },
                            ),
                          ),
                          Gap(Dimens.spacing.sp4),
                          Text(
                            l10n.theBuyer,
                            style: context.typo.bodySmall.copyWith(
                              color: context.color.blue200,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Gap(Dimens.spacing.sp24),
                  Row(
                    children: [
                      Expanded(
                        flex: 245,
                        child: ValueListenableBuilder(
                          valueListenable:
                              pickAndProcessEvidenceImagesCommand.isRunning,
                          builder: (context, bool isRunning, child) {
                            return PrimaryButton(
                              onPressed:
                                  state.requireValue.formData.isValid &&
                                      !isRunning
                                  ? () => viewModel.shareDeliveryDetails()
                                  : null,
                              child: Text(l10n.shareDeliveryDetails),
                            );
                          },
                        ),
                      ),
                      Gap(Dimens.spacing.sp12),
                      Expanded(
                        flex: 68,
                        child: GestureDetector(
                          onTap: () => viewModel.skip(),
                          child: Assets.images.skipButton.image(
                            height: Dimens.mobile.buttonMinimumSize.height,
                            frameBuilder:
                                (
                                  context,
                                  frameChild,
                                  frame,
                                  wasSynchronouslyLoaded,
                                ) {
                                  if (wasSynchronouslyLoaded || frame != null) {
                                    return frameChild;
                                  }
                                  return Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                        Dimens.radius.r8,
                                      ),
                                      color: context.color.blue800.withValues(
                                        alpha: .3,
                                      ),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: Dimens.padding.p20,
                                      vertical: Dimens.padding.p14,
                                    ),
                                    child: Text(
                                      l10n.skip,
                                      style: context.typo.labelSmall.copyWith(
                                        color: context.color.blue100,
                                      ),
                                    ),
                                  );
                                },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
