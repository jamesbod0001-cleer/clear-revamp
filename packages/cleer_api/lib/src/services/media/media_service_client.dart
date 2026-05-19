import 'package:cleer_api/src/services/media/models/process_image/process_image_request.dart';
import 'package:cleer_api/src/services/media/models/process_image/process_image_result.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:blurhash_dart/blurhash_dart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'media_service_client.g.dart';

@riverpod
MediaServiceClient mediaServiceClient(Ref ref) => MediaServiceClient();

class MediaServiceClient {
  final ImagePicker _imagePicker = ImagePicker();

  /// Step 1: Just pick the file from the gallery
  Future<XFile?> pickImageFromGallery() async {
    return await _imagePicker.pickImage(source: ImageSource.gallery);
  }

  /// Step 2: The "Heavy Lifting"
  Future<ProcessImageResult> processImage(ProcessImageRequest request) async {
    XFile resultFile;
    Uint8List compressedBytesForWorker;

    if (kIsWeb) {
      // 1. Web Compression (Compress First!)
      final originalBytes = await request.originalFile.readAsBytes();
      compressedBytesForWorker = await FlutterImageCompress.compressWithList(
        originalBytes,
        minWidth: request.width,
        minHeight: request.height,
        quality: request.quality,
        format: CompressFormat.jpeg,
      );

      resultFile = XFile.fromData(
        compressedBytesForWorker,
        mimeType: 'image/jpeg',
        name: request.originalFile.name,
      );
    } else {
      // 1. Mobile Native Compression (Compress First!)
      final tempDir = await getTemporaryDirectory();
      final targetPath =
          "${tempDir.path}/comp_${DateTime.now().microsecondsSinceEpoch}.jpg";

      final compressedXFile = await FlutterImageCompress.compressAndGetFile(
        request.originalFile.path,
        targetPath,
        minWidth: request.width,
        minHeight: request.height,
        quality: request.quality,
        format: CompressFormat.jpeg,
      );

      if (compressedXFile == null) throw Exception("Compression failed");
      resultFile = compressedXFile;

      // Read the newly tiny, compressed file into bytes for the worker
      compressedBytesForWorker = await resultFile.readAsBytes();
    }

    // 2. Extract metadata and BlurHash from the TINY compressed bytes
    final imageData = await compute(
      _blurHashAndMetadataWorker,
      compressedBytesForWorker,
    );

    return ProcessImageResult(
      file: resultFile,
      blurHash: imageData.hash,
      width: imageData.width,
      height: imageData.height,
      fileSize: await resultFile.length(),
    );
  }
}

/// Consolidated Worker: Decodes ONCE, returns Metadata + BlurHash
/// Using a 32px width for BlurHash is significantly faster and looks the same.
({String hash, int width, int height}) _blurHashAndMetadataWorker(
  Uint8List bytes,
) {
  final image = img.decodeImage(bytes);
  if (image == null) return (hash: "", width: 0, height: 0);

  final tinyImage = img.copyResize(image, width: 32);
  final hash = BlurHash.encode(tinyImage, numCompX: 4, numCompY: 3).hash;

  return (hash: hash, width: image.width, height: image.height);
}
