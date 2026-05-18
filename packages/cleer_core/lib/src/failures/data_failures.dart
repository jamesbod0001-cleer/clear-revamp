// packages/cleer_core/lib/src/failures/data_failures.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'data_failures.freezed.dart';

@freezed
sealed class DataFailure with _$DataFailure {
  // --- System & Database Errors (Amplify/DynamoDB) ---
  const factory DataFailure.unauthorizedException() = UnauthorizedException;
  const factory DataFailure.notFound() = NotFound;
  const factory DataFailure.conditionalCheckFailed() = ConditionalCheckFailedException;

  // --- Custom Business Logic Errors ---
  const factory DataFailure.selfTransferFailure({String? accountName}) = SelfTransferFailure;

  // --- Payment Specific Errors (Flutterwave Proxy) ---
  const factory DataFailure.insufficientFunds() = InsufficientFunds;
  const factory DataFailure.transactionLimitExceeded() = TransactionLimitExceeded;
  const factory DataFailure.paymentDeclined() = PaymentDeclined;
  const factory DataFailure.verificationFailed() = VerificationFailed;
  const factory DataFailure.invalidCard() = InvalidCard;
  const factory DataFailure.invalidRequest({
    String? message,
    List<PaymentValidationError>? errors,
  }) = InvalidRequest;

  // --- Fallback ---
  const factory DataFailure.unknown({String? code, String? message}) = UnknownDataFailure;
}

@freezed
abstract class PaymentValidationError with _$PaymentValidationError {
  const factory PaymentValidationError({
    required String field,
    required String message,
  }) = _PaymentValidationError;
}