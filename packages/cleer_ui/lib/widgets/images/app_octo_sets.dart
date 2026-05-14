import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:octo_image/octo_image.dart';

class AppOctoSets {
  static OctoSet blurHash(String hash, {BoxFit fit = BoxFit.cover}) {
    return OctoSet(
      placeholderBuilder: (context) => SizedBox.expand(
        child: Image(image: BlurHashImage(hash), fit: fit),
      ),
      errorBuilder: OctoError.placeholderWithErrorIcon((context) {
        return SizedBox.expand(
          child: Image(image: BlurHashImage(hash), fit: fit),
        );
      }, iconColor: Colors.red),
    );
  }
}
