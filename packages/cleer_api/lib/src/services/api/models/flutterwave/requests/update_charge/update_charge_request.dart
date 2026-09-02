import 'package:cleer_api/src/services/api/models/flutterwave/models/authorization/authorization_objects.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_charge_request.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class UpdateChargeRequest {
  final Map<String, dynamic>? meta;
  final AuthorizationObject? authorization;

  UpdateChargeRequest({this.meta, this.authorization});

  Map<String, dynamic> toJson() => _$UpdateChargeRequestToJson(this);

  factory UpdateChargeRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateChargeRequestFromJson(json);
}
