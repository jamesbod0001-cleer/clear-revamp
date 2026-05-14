import 'package:dio/dio.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:flutter/foundation.dart';

class FlutterwaveExceptionHandler {
  FlutterwaveExceptionHandler._();

  static PaymentFailure handleException(DioException e) {
    debugPrint(e.response.toString());
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const PaymentFailure.networkFailure();
      case DioExceptionType.badResponse:
        return _handleBadResponse(e.response);
      case DioExceptionType.cancel:
      case DioExceptionType.unknown:
      default:
        return PaymentFailure.unknown(message: e.message);
    }
  }

  static PaymentFailure _handleBadResponse(Response? response) {
    final data = response?.data;
    if (data is! Map<String, dynamic>) {
      return const PaymentFailure.serverError();
    }

    final errorData = data['error'] as Map<String, dynamic>?;
    final String? code =
        errorData?['code']?.toString() ?? data['code']?.toString();
    final String? message =
        errorData?['message']?.toString() ?? data['message']?.toString();

    // --- NEW: Parsing Validation Errors ---
    List<PaymentValidationError>? validationErrors;
    if (errorData != null && errorData.containsKey('validation_errors')) {
      final list = errorData['validation_errors'] as List;
      validationErrors = list.map((item) {
        return PaymentValidationError(
          field: item['field_name']?.toString() ?? 'unknown',
          message: item['message']?.toString() ?? 'invalid',
        );
      }).toList();
    }

    // Map specific code to failure
    return _mapCodeToFailure(code ?? '', message, validationErrors);
  }

  static PaymentFailure _mapCodeToFailure(
    String code,
    String? message,
    List<PaymentValidationError>? validationErrors,
  ) {
    switch (code) {
      // --- Insufficient Funds ---
      case "0307": // Payout: Insufficient Balance
      case "1130400": // Amount below minimum
        return const PaymentFailure.insufficientFunds();

      // --- Limits ---
      case "0301": // Transfer amount exceeds limit
      case "0302": // Transfer amount below limit
      case "0303": // Monthly limit
      case "0304": // Daily limit
        return const PaymentFailure.transactionLimitExceeded();

      // --- Auth / Security ---
      case "10401": // Unauthorized
      case "10403": // Forbidden
        return const PaymentFailure.unauthorized();

      // --- Verification (OTP/PIN) ---
      case "1121400": // Invalid Authorization (PIN/OTP)
      case "1122400": // Failed to validate existing charge
        return const PaymentFailure.verificationFailed();

      // --- Card Specifics ---
      case "1118400": // Invalid card number
      case "1134422": // Card Expired
      case "1135422": // Year out of range
      case "1136422": // Month out of range
        return const PaymentFailure.invalidCard();

      // --- Declined / Failed Transactions ---
      case "1140400": // Charge not successful
      case "1105500": // Charge failed
      case "0309": // Transfer failed
      case "0312": // Rejected recipient
        return const PaymentFailure.paymentDeclined();

      // --- Validation Errors ---
      case "10400": // Request not valid
      case "10422": // Unprocessable entity
      case "1101422": // Customer not found
      case "0313": // Invalid Bank Code
        return PaymentFailure.invalidRequest(
          message: message,
          errors: validationErrors,
        );

      // --- Server / System ---
      case "10500": // Internal Server Error
      case "10503": // Timeout
      case "0306": // Payout creation failed (timeout)
      case "0308": // Service Unavailable
        return const PaymentFailure.serverError();

      default:
        return PaymentFailure.unknown(code: code, message: message);
    }
  }
}
