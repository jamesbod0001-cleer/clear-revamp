import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_failures.freezed.dart';

@freezed
sealed class PaymentFailure with _$PaymentFailure {
  const factory PaymentFailure.serverError({String? message}) = ServerError;
  const factory PaymentFailure.noInternet() = NoInternet;
  const factory PaymentFailure.unauthorized() = Unauthorized;
  const factory PaymentFailure.notFound() = NotFound;
  const factory PaymentFailure.unexpected() = Unexpected;
}
