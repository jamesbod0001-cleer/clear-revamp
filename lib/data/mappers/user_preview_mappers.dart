import 'package:cleer/data/amplify_models/ModelProvider.dart' as amplify_model;
import 'package:cleer/domain/models/user/user_preview.dart' as domain;

/// Extensions on the Amplify UserPreview custom type to convert it to the Domain Task entity.
extension UserPreviewToDomainMapper on amplify_model.UserPreview {
  domain.UserPreview toDomain() {
    return domain.UserPreview(
      id: id,
      firstName: firstName,
      lastName: lastName,
    );
  }
}

/// Extensions on the Domain UserPreview entity to convert it back to the Amplify custom type for mutations.
extension UserPreviewToAmplifyMapper on domain.UserPreview {
  amplify_model.UserPreview toAmplify() {
    return amplify_model.UserPreview(
      id: id,
      firstName: firstName,
      lastName: lastName,
    );
  }
}
