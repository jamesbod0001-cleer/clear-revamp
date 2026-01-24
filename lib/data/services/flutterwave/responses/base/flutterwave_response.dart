import 'package:freezed_annotation/freezed_annotation.dart';

part 'flutterwave_response.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class FlutterwaveResponse<T> {
  final String status;
  final String message;
  final T data;

  FlutterwaveResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory FlutterwaveResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$FlutterwaveResponseFromJson(json, fromJsonT);
}
