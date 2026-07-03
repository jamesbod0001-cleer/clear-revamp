import 'package:cleer_core/cleer_core.dart';
import 'package:cleer_core/models/process_image_result/process_image_result.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'share_delivery_information_state.freezed.dart';

@freezed
abstract class ShareDeliveryInformationState
    with _$ShareDeliveryInformationState {
  const factory ShareDeliveryInformationState({
    required ShareDeliveryInformationFormData formData,
  }) = _ShareDeliveryInformationState;
}

@freezed
abstract class ShareDeliveryInformationFormData
    with _$ShareDeliveryInformationFormData {
  const factory ShareDeliveryInformationFormData({
    @Default('') String driverPhoneNumber,
    @Default('') String deliveryInformation,
    @Default([]) List<ProcessImageDomainResult> evidenceImages,
    DeliveryDetailArrangedBy? arrangedBy,
  }) = _ShareDeliveryInformationFormData;

  factory ShareDeliveryInformationFormData.empty() =>
      const ShareDeliveryInformationFormData();
}
