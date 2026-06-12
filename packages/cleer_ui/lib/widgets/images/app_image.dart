import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:octo_image/octo_image.dart';
import 'package:cleer_ui/widgets/images/app_octo_sets.dart';

class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    required this.imageUrl,
    required this.blurHash,
    this.width,
    this.height,
    required this.fit,
  });

  final String imageUrl;
  final String blurHash;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return OctoImage.fromSet(
      image: CachedNetworkImageProvider(imageUrl),
      octoSet: AppOctoSets.blurHash(blurHash, fit: fit),
      width: width,
      height: height,
      fit: fit,
    );
  }
}
