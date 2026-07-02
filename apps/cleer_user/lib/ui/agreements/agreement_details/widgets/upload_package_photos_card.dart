import 'dart:io';

import 'package:cleer/config/assets.gen.dart';
import 'package:cleer/ui/agreements/agreement_details/view_model/upload_package_photos_view_model.dart';
import 'package:cleer/ui/agreements/agreement_details/widgets/emphasized_action_card.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:cleer_ui/themes/dimensions.dart';
import 'package:cleer_ui/themes/theme_utils.dart';
import 'package:cleer_ui/widgets/buttons/primary_button.dart';
import 'package:command_it/command_it.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class UploadPackagePhotosCard extends HookConsumerWidget {
  const UploadPackagePhotosCard({super.key, required this.agreement});

  final Agreement agreement;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    int limit = 4;

    final state = ref.watch(
      uploadPackagePhotosViewModelProvider(agreement.id!),
    );
    final viewModel = ref.read(
      uploadPackagePhotosViewModelProvider(agreement.id!).notifier,
    );
    final selectedImages = state.requireValue.selectedImages;

    final pickAndProcessImagesCommand = viewModel.pickAndProcessImages;
    useEffect(() {
      void listener() {
        if (pickAndProcessImagesCommand.errors.value != null) {
          debugPrint(
            "Command Error: ${pickAndProcessImagesCommand.errors.value?.error}",
          );
        }
      }

      pickAndProcessImagesCommand.errors.addListener(listener);
      return () => pickAndProcessImagesCommand.errors.removeListener(listener);
    }, [pickAndProcessImagesCommand]);

    return EmphasizedActionCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.uploadPackagePhotos,
            style: context.typo.titleSmall.copyWith(color: context.color.white),
          ),
          Gap(Dimens.spacing.sp4),
          Text(
            l10n.takeClearPhotosBeforeHandingThePackageToTheDeliveryServiceThesePhotosMayBeUsedIfThereIsEverADispute,
            style: context.typo.bodySmall.copyWith(
              color: context.color.blue200,
            ),
          ),
          Gap(Dimens.spacing.sp12),

          if (state.isLoading)
            Padding(
              padding: EdgeInsets.symmetric(vertical: Dimens.padding.p20),
              child: const Center(child: CircularProgressIndicator()),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    double dimension =
                        (constraints.maxWidth - (Dimens.spacing.sp8 * 2)) / 3;
                    return Wrap(
                      spacing: Dimens.spacing.sp8,
                      runSpacing: Dimens.spacing.sp8,
                      children: [
                        ...List.generate(selectedImages.length, (int index) {
                          final image = selectedImages.elementAt(index);
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: dimension,
                                height: dimension,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  color: context.color.white.withValues(
                                    alpha: .08,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    Dimens.radius.r8,
                                  ),
                                ),
                                child: Image.file(
                                  File(image.file.path),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: -6,
                                right: -6,
                                child: PhosphorIcon(
                                  PhosphorIcons.circle(.fill),
                                  color: context.color.background,
                                  size: Dimens.size.s24,
                                ),
                              ),
                              Positioned(
                                top: -6,
                                right: -6,
                                child: GestureDetector(
                                  onTap: () => viewModel.removeImage(index),
                                  child: PhosphorIcon(
                                    PhosphorIcons.xCircle(.fill),
                                    color: context.color.error,
                                    size: Dimens.size.s24,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                        if (selectedImages.length < limit)
                          AddPhotoPlaceHolder(
                            limit: limit - selectedImages.length,
                            pickAndProcessImagesCommand:
                                pickAndProcessImagesCommand,
                            dimension: dimension,
                          ),
                      ],
                    );
                  },
                ),
                Gap(Dimens.spacing.sp12),
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: Dimens.padding.p2),
                      child: PhosphorIcon(
                        PhosphorIcons.info(.duotone),
                        color: context.color.blue200,
                        size: Dimens.size.s14,
                      ),
                    ),
                    Gap(Dimens.spacing.sp4),
                    Text(
                      l10n.avoidBlurryOrDarkPhotos,
                      style: context.typo.bodySmall.copyWith(
                        color: context.color.blue200,
                      ),
                    ),
                  ],
                ),
                Gap(Dimens.spacing.sp12),
                Row(
                  children: [
                    Expanded(
                      flex: 245,
                      child: ValueListenableBuilder(
                        valueListenable: pickAndProcessImagesCommand.isRunning,
                        builder: (context, bool isRunning, child) {
                          return PrimaryButton(
                            onPressed: selectedImages.isNotEmpty && !isRunning
                                ? () => viewModel.saveAndContinue()
                                : null,
                            child: Text(l10n.saveAndContinue),
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
    );
  }
}

class AddPhotoPlaceHolder extends StatelessWidget {
  const AddPhotoPlaceHolder({
    super.key,
    required this.limit,
    required this.pickAndProcessImagesCommand,
    required this.dimension,
  });

  final int limit;
  final Command<int, void> pickAndProcessImagesCommand;
  final double dimension;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: () => pickAndProcessImagesCommand.run(limit),
      child: Container(
        width: dimension,
        height: dimension,
        decoration: BoxDecoration(
          color: context.color.white.withValues(alpha: .08),
          borderRadius: .circular(Dimens.radius.r8),
        ),
        alignment: .center,
        child: DottedBorder(
          options: RoundedRectDottedBorderOptions(
            radius: .circular(Dimens.radius.r8),
            dashPattern: const [4, 4],
            color: context.color.white.withValues(alpha: 0.25),
            strokeWidth: Dimens.size.s2,
          ),
          child: ValueListenableBuilder(
            valueListenable: pickAndProcessImagesCommand.isRunning,
            builder: (context, bool isRunning, child) {
              if (isRunning) {
                return const Center(child: CircularProgressIndicator());
              }
              return Column(
                crossAxisAlignment: .stretch,
                mainAxisAlignment: .center,
                children: [
                  PhosphorIcon(
                    PhosphorIcons.plus(),
                    color: context.color.white.withValues(alpha: .70),
                    size: Dimens.size.s22,
                  ),
                  Gap(Dimens.spacing.sp4),
                  Center(
                    child: Text(
                      l10n.addPhoto,
                      style: context.typo.bodySmall.copyWith(
                        color: context.color.white.withValues(alpha: .70),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
