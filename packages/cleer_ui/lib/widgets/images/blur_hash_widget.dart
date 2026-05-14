import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';

class BlurHashWidget extends StatelessWidget {
  final String hash;
  final BoxFit fit;

  const BlurHashWidget({
    super.key,
    required this.hash,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return BlurHash(
      hash: hash,
      imageFit: fit,
      // The duration of the internal fade once the hash decodes
      duration: const Duration(milliseconds: 300),
      // Background color while the hash is being decoded (usually 20-50ms)
      color: Colors.grey[200]!,
    );
  }
}
