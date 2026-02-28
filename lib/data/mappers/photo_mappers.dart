import 'package:cleer/domain/models/photo/photo.dart' as domain;
import 'package:cleer/data/amplify_models/ModelProvider.dart' as amplify;

extension PhotoToDomainMapper on amplify.Photo {
  domain.Photo toDomain() {
    return domain.Photo(
      key: key,
      blurHash: blurHash,
      width: width,
      height: height,
      altText: altText,
    );
  }
}

extension PhotoToAmplifyMapper on domain.Photo {
  amplify.Photo toAmplify() {
    return amplify.Photo(
      key: key,
      blurHash: blurHash,
      width: width,
      height: height,
      altText: altText,
    );
  }
}
