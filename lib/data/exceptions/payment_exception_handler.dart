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
    if (data is Map<String, dynamic> && data.containsKey('message')) {
      return data['message'] as String;
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
