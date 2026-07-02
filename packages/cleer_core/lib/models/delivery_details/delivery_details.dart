import 'package:cleer_core/models/delivery_details/delivery_details_enums.dart';
import 'package:cleer_core/models/photo/photo.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'delivery_details.freezed.dart';

@freezed
abstract class DeliveryDetails with _$DeliveryDetails {
  const factory DeliveryDetails({
    required String driverPhoneNumber,
    String? additionalDetails,
    List<Photo>? photos,
    required DeliveryDetailArrangedBy arrangedBy,
  }) = _DeliveryDetails;
}
