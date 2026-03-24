import 'package:cleer/data/amplify_models/ModelProvider.dart' as amplify_model;
import 'package:cleer/data/mappers/photo_mappers.dart';
import 'package:cleer/domain/models/user/user.dart' as domain;

/// Extensions on the Amplify User model to convert it to the Domain Task entity.
extension UserToDomainMapper on amplify_model.User {
  domain.User toDomain() {
    return domain.User(
      id: id,
      identityId: identityId ?? '',
      phoneNumber: phoneNumber,
      firstName: firstName,
      lastName: lastName,
      email: email,
      profilePicture: profilePicture?.toDomain(),
      flutterwaveCustomerId: flutterwaveCustomerId,
      flutterwavePaymentMethodIds: flutterwavePaymentMethodIds ?? [],
      createdAt: createdAt?.getDateTimeInUtc(),
    );
  }
}

/// Extensions on the Domain User entity to convert it back to the Amplify model for mutations.
extension UserToAmplifyMapper on domain.User {
  amplify_model.User toAmplify() {
    return amplify_model.User(
      id: id,
      identityId: identityId,
      phoneNumber: phoneNumber,
      firstName: firstName,
      lastName: lastName,
      email: email,
      profilePicture: profilePicture?.toAmplify(),
      flutterwaveCustomerId: flutterwaveCustomerId,
      flutterwavePaymentMethodIds: flutterwavePaymentMethodIds,
    );
  }
}
