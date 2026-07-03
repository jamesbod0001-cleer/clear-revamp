import 'package:cleer/config/assets.gen.dart';
import 'package:cleer/ui/agreements/agreement_details/view_model/review_delivery_information_view_model.dart';
import 'package:cleer/ui/agreements/agreement_details/widgets/emphasized_action_card.dart';
import 'package:cleer/ui/agreements/agreement_details/widgets/review_photo_thumbnail.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:cleer_ui/cleer_ui.dart';
import 'package:cleer_ui/widgets/buttons/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ReviewDeliveryInformationCard extends ConsumerWidget {
  const ReviewDeliveryInformationCard({super.key, required this.agreement});
  final Agreement agreement;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final deliveryDetails = agreement.physicalDeliveryContext!.deliveryDetails!;
    final photos = deliveryDetails.photos ?? [];

    final state = ref.watch(
      reviewDeliveryInformationViewModelProvider(agreement.id!),
    );
    final viewModel = ref.read(
      reviewDeliveryInformationViewModelProvider(agreement.id!).notifier,
    );

    return EmphasizedActionCard(
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Text(
            l10n.deliveryDetailsShared,
            style: context.typo.titleSmall.copyWith(color: context.color.white),
          ),
          Gap(Dimens.spacing.sp4),
          Text(
            l10n.reviewTheDeliveryContactAndTrackingDetailsSoYouKnowWhoWillBeBringingYourItem,
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
                Text(
                  l10n.driverPhoneNumber,
                  style: context.typo.titleSmall.copyWith(
                    color: context.color.blue200,
                  ),
                ),
                Gap(Dimens.spacing.sp4),
                Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    Text(
                      deliveryDetails.driverPhoneNumber,
                      style: context.typo.titleLarge.copyWith(
                        color: context.color.outline,
                        decoration: .underline,
                        decorationStyle: .dotted,
                        decorationColor: context.color.outline,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        ///TODO: Implement Call
                      },
                      child: Assets.images.callButton.image(
                        height: Dimens.size.s28,
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
                                    Dimens.radius.r40,
                                  ),
                                  color: context.color.blue800.withValues(
                                    alpha: .3,
                                  ),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: Dimens.padding.p10,
                                  vertical: Dimens.padding.p6,
                                ),
                                child: Row(
                                  children: [
                                    PhosphorIcon(
                                      PhosphorIcons.phone(.duotone),
                                      color: context.color.blue100,
                                      size: Dimens.size.s16,
                                    ),
                                    Gap(Dimens.spacing.sp4),
                                    Text(
                                      l10n.call,
                                      style: context.typo.bodyMedium.copyWith(
                                        height: 1,
                                        color: context.color.blue100,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                      ),
                    ),
                  ],
                ),
                Gap(Dimens.spacing.sp25),
                Text(
                  l10n.additionalDetails,
                  style: context.typo.titleSmall.copyWith(
                    color: context.color.blue200,
                  ),
                ),
                Gap(Dimens.spacing.sp8),
                Text(
                  deliveryDetails.additionalDetails ?? '',
                  style: context.typo.bodyLarge.copyWith(
                    color: context.color.outline,
                  ),
                ),
                Gap(Dimens.spacing.sp8),
                Text(
                  deliveryDetails.arrangedBy.name,
                  style: context.typo.bodyMedium.copyWith(
                    color: context.color.outline,
                  ),
                ),

                if (photos.isNotEmpty) ...[
                  Gap(Dimens.spacing.sp8),
                  LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                          double dimension =
                              (constraints.maxWidth -
                                  (Dimens.spacing.sp12 * 2)) /
                              3;
                          return Wrap(
                            spacing: Dimens.spacing.sp8,
                            runSpacing: Dimens.spacing.sp8,
                            children: photos.map((photo) {
                              return ReviewPhotoThumbnail(
                                photo: photo,
                                dimension: dimension,
                              );
                            }).toList(),
                          );
                        },
                  ),
                ],
                Gap(Dimens.spacing.sp24),
                PrimaryButton(
                  onPressed: () => viewModel.confirm(),
                  child: Text(l10n.confirm),
                ),
                Gap(Dimens.spacing.sp12),
                Row(
                  crossAxisAlignment: .start,
                  mainAxisAlignment: .center,
                  children: [
                    PhosphorIcon(
                      PhosphorIcons.sealCheck(.duotone),
                      color: context.color.blue200,
                      size: Dimens.size.s14,
                    ),
                    Gap(Dimens.spacing.sp4),
                    Text(
                      l10n.storedAsDeliveryEvidence,
                      style: context.typo.bodySmall.copyWith(
                        color: context.color.blue200,
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
