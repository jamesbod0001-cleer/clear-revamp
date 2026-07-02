import 'package:cleer/domain/providers/storage/file_url_provider.dart';
import 'package:cleer/ui/agreements/agreement_details/widgets/emphasized_action_card.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:cleer_core/models/photo/photo.dart';
import 'package:cleer_ui/cleer_ui.dart';
import 'package:cleer_ui/widgets/images/app_image.dart';
import 'package:cleer_ui/widgets/images/blur_hash_widget.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ReviewPackagePhotosCard extends ConsumerWidget {
  const ReviewPackagePhotosCard({super.key, required this.agreement});
  final Agreement agreement;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final photos = agreement.physicalDeliveryContext?.packagingPhotos ?? [];

    return EmphasizedActionCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.packagePhotosReady,
            style: context.typo.titleSmall.copyWith(color: context.color.white),
          ),
          Gap(Dimens.spacing.sp4),
          Text(
            l10n.theVendorHasUploadedPhotosShowingTheItemBeforeShipmentReviewThemSoYouKnowExactlyWhatWasSent,
            style: context.typo.bodySmall.copyWith(
              color: context.color.blue200,
            ),
          ),
          Gap(Dimens.spacing.sp12),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              double dimension =
                  (constraints.maxWidth - (Dimens.spacing.sp8 * 2)) / 3;
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
      ),
    );
  }
}

/// Standalone element to isolate Riverpod provider watching
class ReviewPhotoThumbnail extends ConsumerWidget {
  const ReviewPhotoThumbnail({
    super.key,
    required this.photo,
    required this.dimension,
  });

  final Photo photo;
  final double dimension;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photoUrlAsync = ref.watch(fileUrlProvider(photo.key));

    return Container(
      width: dimension,
      height: dimension,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.color.white.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(Dimens.radius.r8),
      ),
      child: photoUrlAsync.when(
        data: (url) => AppImage(
          imageUrl: url,
          blurHash: photo.blurHash ?? '',
          fit: BoxFit.cover,
        ),
        loading: () => BlurHashWidget(hash: photo.blurHash ?? ''),
        error: (_, _) =>
            Center(child: PhosphorIcon(PhosphorIcons.imageBroken())),
      ),
    );
  }
}
