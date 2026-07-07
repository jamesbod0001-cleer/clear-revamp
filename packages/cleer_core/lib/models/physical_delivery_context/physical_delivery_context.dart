import 'package:cleer_core/models/delivery_details/delivery_details.dart';
import 'package:cleer_core/models/photo/photo.dart';
import 'package:cleer_core/models/physical_delivery_context/physical_delivery_context_enums.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'physical_delivery_context.freezed.dart';

@freezed
abstract class PhysicalDeliveryContext with _$PhysicalDeliveryContext {
  const factory PhysicalDeliveryContext({
    required PhysicalDeliveryContextStatus status,
    List<Photo>? packagingPhotos,
    DeliveryDetails? deliveryDetails,
  }) = _PhysicalDeliveryContext;
}
