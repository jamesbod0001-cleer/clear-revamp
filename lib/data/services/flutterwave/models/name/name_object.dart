import 'package:freezed_annotation/freezed_annotation.dart';

part 'name_object.g.dart';

@JsonSerializable()
class NameObject {
  final String first;
  final String? middle;
  final String last;

  NameObject({required this.first, this.middle, required this.last});

  factory NameObject.fromJson(Map<String, dynamic> json) =>
      _$NameObjectFromJson(json);
  Map<String, dynamic> toJson() => _$NameObjectToJson(this);
}