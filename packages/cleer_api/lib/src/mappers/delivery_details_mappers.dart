import 'package:cleer_api/src/mappers/photo_mappers.dart';
import 'package:cleer_api/src/models/ModelProvider.dart' as amplify_model;
import 'package:cleer_core/models/delivery_details/delivery_details.dart'
    as domain;
import 'package:cleer_core/models/delivery_details/delivery_details_enums.dart';

/// Extensions on the Amplify DeliveryDetails model to convert it to the Domain Task entity.
extension DeliveryDetailsToDomainMapper on amplify_model.DeliveryDetails {
  domain.DeliveryDetails toDomain() {
    return domain.DeliveryDetails(
      driverPhoneNumber: driverPhoneNumber,
      additionalDetails: additionalDetails,
      photos: photos?.map((photo) => photo.toDomain()).toList(),
      arrangedBy: _mapDeliveryDetailsArrangedByToDomain(arrangedBy!),
    );
  }
}

/// Extensions on the Domain DeliveryDetails entity to convert it back to the Amplify model for mutations.
extension DeliveryDetailsToAmplifyMapper on domain.DeliveryDetails {
  amplify_model.DeliveryDetails toAmplify() {
    return amplify_model.DeliveryDetails(
      driverPhoneNumber: driverPhoneNumber,
      additionalDetails: additionalDetails,
      photos: photos?.map((photo) => photo.toAmplify()).toList(),
      arrangedBy: _mapDeliveryDetailsArrangedByToAmplify(arrangedBy),
    );
  }
}

DeliveryDetailArrangedBy _mapDeliveryDetailsArrangedByToDomain(
  amplify_model.DeliveryDetailsArrangedBy p,
) {
  switch (p) {
    case amplify_model.DeliveryDetailsArrangedBy.VENDOR:
      return DeliveryDetailArrangedBy.vendor;
    case amplify_model.DeliveryDetailsArrangedBy.BUYER:
      return DeliveryDetailArrangedBy.buyer;
  }
}

amplify_model.DeliveryDetailsArrangedBy _mapDeliveryDetailsArrangedByToAmplify(
  DeliveryDetailArrangedBy p,
) {
  switch (p) {
    case DeliveryDetailArrangedBy.vendor:
      return amplify_model.DeliveryDetailsArrangedBy.VENDOR;
    case DeliveryDetailArrangedBy.buyer:
      return amplify_model.DeliveryDetailsArrangedBy.BUYER;
  }
}
