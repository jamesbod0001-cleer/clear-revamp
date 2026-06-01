import 'package:cleer/domain/providers/storage/file_url_provider.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:cleer_ui/cleer_ui.dart';
import 'package:cleer_ui/widgets/images/app_image.dart';
import 'package:cleer_ui/widgets/images/blur_hash_widget.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';

class UserProfilePill extends ConsumerWidget {
  final User? profile;
  final VoidCallback? onTap;

  const UserProfilePill({
    this.profile,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = profile == null;

    return Skeletonizer(
      enabled: isLoading,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: ShapeDecoration(
            shape: StadiumBorder(
              side: BorderSide(color: context.color.outline),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Skeleton.leaf(
                child: Container(
                  width: Dimens.size.s40,
                  height: Dimens.size.s40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.color.grayComponent,
                  ),
                  child: ClipOval(
                    child: _buildAvatar(ref, context),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Dimens.padding.p8),
                child: Text(
                  profile?.firstName ?? BoneMock.name,
                  style: context.typo.titleSmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(WidgetRef ref, BuildContext context) {
    if (profile == null) {
      return const SizedBox.shrink();
    }

    if (profile!.profilePicture == null) {
      return CircleAvatar(
        radius: Dimens.radius.r20,
        backgroundColor: const Color(0xFFD6F4E0),
        foregroundColor: context.color.success,
        child: Text(
          "${profile!.firstName[0]}${profile!.lastName[0]}",
        ),
      );
    }

    final profileUrlAsync = ref.watch(
      fileUrlProvider(profile!.profilePicture!.key),
    );

    return profileUrlAsync.when(
      data: (url) => AppImage(
        imageUrl: url,
        blurHash: profile!.profilePicture!.blurHash ?? '',
        fit: BoxFit.cover,
      ),
      loading: () => BlurHashWidget(
        hash: profile!.profilePicture!.blurHash ?? '',
      ),
      error: (_, _) => Center(
        child: PhosphorIcon(
          PhosphorIcons.imageBroken(),
        ),
      ),
    );
  }
}
