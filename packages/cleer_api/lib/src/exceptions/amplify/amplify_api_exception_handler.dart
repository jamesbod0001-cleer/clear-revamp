import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer_api/src/exceptions/backend_exception.dart';
import 'package:cleer_core/cleer_core.dart';

class AmplifyApiExceptionHandler {
  AmplifyApiExceptionHandler._();

  static DataFailure handleException(Object e) {
    // 1. Extract the code and message based on the exception type
    final (code, message) = switch (e) {
      ApiException e => (e.runtimeTypeName, e.message),
      BackendException e => (e.code ?? "BackendException", e.message),
      _ => ("UnknownException", e.toString()),
    };

    // 2. Check for standard AWS / AppSync / DynamoDB errors
    switch (code) {
      case "UnauthorizedException":
      case "NotAuthorizedException":
        return const DataFailure.unauthorizedException();
      case "NotFound":
        return const DataFailure.notFound();
      case "DynamoDB:ConditionalCheckFailedException":
        return const DataFailure.conditionalCheckFailed();
    }

    // 3. Check for Flutterwave Specific Codes coming through the Proxy
    return _mapFlutterwaveCodeToFailure(code, message);
  }

  static DataFailure handleGenericException(dynamic e) {
    if (e is ApiException || e is BackendException) {
      return handleException(e);
    } else {
      return DataFailure.unknown(message: e.toString());
    }
  }

  /// Replaces the old Dio interceptor logic. 
  /// AppSync/Lambda will forward the Flutterwave code here.
  static DataFailure _mapFlutterwaveCodeToFailure(String code, String message) {
    switch (code) {
    // --- Insufficient Funds ---
      case "0307": // Payout: Insufficient Balance
      case "1130400": // Amount below minimum
        return const DataFailure.insufficientFunds();

    // --- Limits ---
      case "0301": // Transfer amount exceeds limit
      case "0302": // Transfer amount below limit
      case "0303": // Monthly limit
      case "0304": // Daily limit
        return const DataFailure.transactionLimitExceeded();

    // --- Auth / Security ---
      case "10401": // Unauthorized
      case "10403": // Forbidden
        return const DataFailure.unauthorizedException();

    // --- Verification (OTP/PIN) ---
      case "1121400": // Invalid Authorization (PIN/OTP)
      case "1122400": // Failed to validate existing charge
        return const DataFailure.verificationFailed();

    // --- Card Specifics ---
      case "1118400": // Invalid card number
      case "1134422": // Card Expired
      case "1135422": // Year out of range
      case "1136422": // Month out of range
        return const DataFailure.invalidCard();

    // --- Declined / Failed Transactions ---
      case "1140400": // Charge not successful
      case "1105500": // Charge failed
      case "0309": // Transfer failed
      case "0312": // Rejected recipient
        return const DataFailure.paymentDeclined();

    // --- Validation Errors ---
      case "10400": // Request not valid
      case "10422": // Unprocessable entity
      case "1101422": // Customer not found
      case "0313": // Invalid Bank Code
        return DataFailure.invalidRequest(message: message);

    // --- Server / System ---
      case "10500": // Internal Server Error
      case "10503": // Timeout
      case "0306": // Payout creation failed (timeout)
      case "0308": // Service Unavailable
      // Maps nicely to the generic unknown wrapper
        return DataFailure.unknown(code: code, message: "Server Error: $message");

      default:
        return DataFailure.unknown(code: code, message: message);
    }
  }
}