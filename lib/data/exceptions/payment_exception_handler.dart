import 'package:dio/dio.dart';
import 'package:cleer/domain/failures/payment_failures.dart';

class PaymentExceptionHandler {
  PaymentExceptionHandler._();

  static PaymentFailure handleException(Object e) {
    // Extract normalized code and message directly from the exception type
    final (code, message) = switch (e) {
      DioException e => (
        e.response?.statusCode?.toString() ?? e.type.name,
        _extractDioMessage(e),
      ),
      _ => ("UnknownException", e.toString()),
    };

    // Map based on the normalized code
    switch (code) {
      case "401":
        return const PaymentFailure.unauthorized();
      case "connectionError":
      case "connectionTimeout":
      case "receiveTimeout":
        return const PaymentFailure.noInternet();
      case "403":
        return PaymentFailure.serverError(
          message: "Access forbidden: $message",
        );
      case "404":
        return const PaymentFailure.notFound();
      default:
        return PaymentFailure.serverError(message: message);
    }
  }

  /// Extracts the specific error message from the Flutterwave JSON response body
  static String _extractDioMessage(DioException e) {
    final data = e.response?.data;

    if (data is Map<String, dynamic>) {
      // 1. Try to get the top-level 'message' (Standard FW format)
      if (data['message'] != null && data['message'].toString().isNotEmpty) {
        return data['message'].toString();
      }

      // 2. Try to get nested error message if it exists (Common in v4)
      if (data['error'] is Map && data['error']['message'] != null) {
        return data['error']['message'].toString();
      }

      // 3. Check for validation_errors array (Specific field errors)
      if (data['validation_errors'] is List && (data['validation_errors'] as List).isNotEmpty) {
        final firstError = data['validation_errors'][0];
        if (firstError is Map && firstError['message'] != null) {
          return firstError['message'].toString();
        }
      }
    }

    return e.message ?? "An unexpected payment error occurred.";
  }

  static PaymentFailure handleGenericException(dynamic e) {
    if (e is DioException) {
      return handleException(e);
    } else {
      return const PaymentFailure.unexpected();
    }
  }
}
