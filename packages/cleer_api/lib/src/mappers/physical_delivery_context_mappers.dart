import 'package:cleer_api/src/mappers/delivery_details_mappers.dart';
import 'package:cleer_api/src/mappers/photo_mappers.dart';
import 'package:cleer_api/src/models/ModelProvider.dart' as amplify_model;
import 'package:cleer_core/models/physical_delivery_context/physical_delivery_context.dart'
    as domain;
import 'package:cleer_core/models/physical_delivery_context/physical_delivery_context_enums.dart';

/// Extensions on the Amplify PhysicalDeliveryContext model to convert it to the Domain Task entity.
extension PhysicalDeliveryContextToDomainMapper
    on amplify_model.PhysicalDeliveryContext {
  domain.PhysicalDeliveryContext toDomain() {
    return domain.PhysicalDeliveryContext(
      status: _mapPhysicalDeliveryContextStatusToDomain(status!),
      packagingPhotos: packagingPhotos
          ?.map((photo) => photo.toDomain())
          .toList(),
      deliveryDetails: deliveryDetails?.toDomain(),
    );
  }
}

/// Extensions on the Domain PhysicalDeliveryContext entity to convert it back to the Amplify model for mutations.
extension PhysicalDeliveryContextToAmplifyMapper
    on domain.PhysicalDeliveryContext {
  amplify_model.PhysicalDeliveryContext toAmplify() {
    return amplify_model.PhysicalDeliveryContext(
      status: _mapPhysicalDeliveryContextStatusToAmplify(status),
      packagingPhotos: packagingPhotos
          ?.map((photo) => photo.toAmplify())
          .toList(),
      deliveryDetails: deliveryDetails?.toAmplify(),
    );
  }
}

PhysicalDeliveryContextStatus _mapPhysicalDeliveryContextStatusToDomain(
  amplify_model.PhysicalDeliveryContextStatus p,
) {
  switch (p) {
    case amplify_model.PhysicalDeliveryContextStatus.AWAITING_PACKAGING:
      return PhysicalDeliveryContextStatus.awaitingPackaging;
    case amplify_model.PhysicalDeliveryContextStatus.AWAITING_DISPATCH:
      return PhysicalDeliveryContextStatus.awaitingDispatch;
    case amplify_model
        .PhysicalDeliveryContextStatus
        .AWAITING_BUYER_ACKNOWLEDGEMENT:
      return PhysicalDeliveryContextStatus.awaitingBuyerAcknowledgement;
    case amplify_model.PhysicalDeliveryContextStatus.IN_TRANSIT:
      return PhysicalDeliveryContextStatus.inTransit;
  }
}

amplify_model.PhysicalDeliveryContextStatus
_mapPhysicalDeliveryContextStatusToAmplify(PhysicalDeliveryContextStatus p) {
  switch (p) {
    case PhysicalDeliveryContextStatus.awaitingPackaging:
      return amplify_model.PhysicalDeliveryContextStatus.AWAITING_PACKAGING;
    case PhysicalDeliveryContextStatus.awaitingDispatch:
      return amplify_model.PhysicalDeliveryContextStatus.AWAITING_DISPATCH;
    case PhysicalDeliveryContextStatus.awaitingBuyerAcknowledgement:
      return amplify_model
          .PhysicalDeliveryContextStatus
          .AWAITING_BUYER_ACKNOWLEDGEMENT;
    case PhysicalDeliveryContextStatus.inTransit:
      return amplify_model.PhysicalDeliveryContextStatus.IN_TRANSIT;
  }
}
