import 'package:cleer/domain/providers/storage/file_url_provider.dart';
import 'package:cleer_core/models/photo/photo.dart';
import 'package:cleer_ui/cleer_ui.dart';
import 'package:cleer_ui/widgets/images/app_image.dart';
import 'package:cleer_ui/widgets/images/blur_hash_widget.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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
