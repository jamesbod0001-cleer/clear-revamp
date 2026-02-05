import 'package:cleer/data/services/flutterwave/models/authorization/authorization_objects.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_charge_request.g.dart';

@JsonSerializable(explicitToJson: true)
class UpdateChargeRequest {
  final Map<String, dynamic>? meta;
  final AuthorizationObject? authorization;

  UpdateChargeRequest({this.meta, this.authorization});

  Map<String, dynamic> toJson() => _$UpdateChargeRequestToJson(this);
}
