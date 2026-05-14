import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_failures.freezed.dart';

@freezed
sealed class PaymentFailure with _$PaymentFailure {
  // 1. Connectivity & System
  const factory PaymentFailure.networkFailure() = NetworkFailure;
  const factory PaymentFailure.serverError({String? message}) = ServerError;

  // 2. Auth & Permissions
  const factory PaymentFailure.unauthorized() = Unauthorized;
  const factory PaymentFailure.invalidApiKey() = InvalidApiKey;

  // 3. User Input / Validation
  const factory PaymentFailure.invalidRequest({
    String? message,
    List<PaymentValidationError>? errors,
  }) = InvalidRequest;
  const factory PaymentFailure.invalidCard() = InvalidCard;

  // 4. Transaction Specifics
  const factory PaymentFailure.insufficientFunds() = InsufficientFunds;
  const factory PaymentFailure.transactionLimitExceeded() =
      TransactionLimitExceeded;
  const factory PaymentFailure.paymentDeclined() = PaymentDeclined;
  const factory PaymentFailure.verificationFailed() =
      VerificationFailed; // OTP/PIN issues

  // 5. Fallback
  const factory PaymentFailure.unknown({String? code, String? message}) =
      UnknownPaymentFailure;
}

@freezed
abstract class PaymentValidationError with _$PaymentValidationError {
  const factory PaymentValidationError({
    required String field,
    required String message,
  }) = _PaymentValidationError;
}
