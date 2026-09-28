import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

enum EvidenceFileType { image, pdf, doc, video, unknown }

extension FileExtensions on String {
  EvidenceFileType get fileType {
    final lower = toLowerCase();
    if (lower.endsWith('.pdf')) return EvidenceFileType.pdf;
    if (lower.endsWith('.doc') ||
        lower.endsWith('.docx') ||
        lower.endsWith('.txt')) {
      return EvidenceFileType.doc;
    }
    if (lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.avi') ||
        lower.endsWith('.mkv')) {
      return EvidenceFileType.video;
    }
    if (lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.heic')) {
      return EvidenceFileType.image;
    }
    return EvidenceFileType.unknown;
  }

  IconData get fileIcon {
    switch (fileType) {
      case EvidenceFileType.pdf:
        return PhosphorIcons.filePdf();
      case EvidenceFileType.doc:
        return PhosphorIcons.fileDoc();
      case EvidenceFileType.video:
        return PhosphorIcons.videoCamera();
      case EvidenceFileType.image:
        return PhosphorIcons.image();
      case EvidenceFileType.unknown:
        return PhosphorIcons.file();
    }
  }
}
