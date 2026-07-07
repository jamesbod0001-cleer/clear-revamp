import 'package:cleer/domain/providers/storage/file_url_provider.dart';
import 'package:cleer_core/models/photo/photo.dart';
import 'package:cleer_ui/cleer_ui.dart';
import 'package:cleer_ui/widgets/images/app_image.dart';
import 'package:cleer_ui/widgets/images/blur_hash_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class PhotoViewerDialog extends HookConsumerWidget {
  const PhotoViewerDialog({
    super.key,
    required this.photos,
    required this.initialIndex,
  });

  final List<Photo> photos;
  final int initialIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Starts the PageView at the exact photo the user tapped
    final pageController = usePageController(initialPage: initialIndex);

    return Dialog(
      backgroundColor: context.color.white,
      insetPadding: EdgeInsets.all(Dimens.padding.p16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimens.radius.r8),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          // Restricts the dialog height to 75% of the screen like the Figma design
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        child: Stack(
          children: [
            PageView.builder(
              controller: pageController,
              itemCount: photos.length,
              itemBuilder: (context, index) {
                return _FullSizePhotoView(photo: photos[index]);
              },
            ),
            Positioned(
              right: 0,
              child: IconButton(
                icon: PhosphorIcon(
                  PhosphorIcons.x(),
                  color: context.color.grey600,
                ),
                onPressed: () => context.pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Private widget to ensure we only fetch the URL/Image when the page is built
class _FullSizePhotoView extends ConsumerWidget {
  const _FullSizePhotoView({required this.photo});

  final Photo photo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photoUrlAsync = ref.watch(fileUrlProvider(photo.key));

    return Padding(
      padding: EdgeInsets.only(
        top: Dimens.padding.p40,
        bottom: Dimens.padding.p16,
        left: Dimens.padding.p16,
        right: Dimens.padding.p16,
      ),
      child: photoUrlAsync.when(
        data: (url) => AppImage(
          imageUrl: url,
          blurHash: photo.blurHash ?? '',
          fit: BoxFit.contain,
        ),
        loading: () => BlurHashWidget(hash: photo.blurHash ?? ''),
        error: (_, _) =>
            Center(child: PhosphorIcon(PhosphorIcons.imageBroken())),
      ),
    );
  }
}
