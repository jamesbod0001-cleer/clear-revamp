import 'package:freezed_annotation/freezed_annotation.dart';

part 'cof_object.g.dart';

@JsonSerializable()
class COFObject {
  final bool enabled;
  @JsonKey(name: 'agreement_id')
  final String? agreementId;
  @JsonKey(name: 'trace_id')
  final String? traceId;

  COFObject({required this.enabled, this.agreementId, this.traceId});

  factory COFObject.fromJson(Map<String, dynamic> json) =>
      _$COFObjectFromJson(json);
  Map<String, dynamic> toJson() => _$COFObjectToJson(this);
}
