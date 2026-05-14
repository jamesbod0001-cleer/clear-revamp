/// A universal exception for when the backend returns a "Success" 200 OK
/// but with GraphQL errors inside.
class BackendException implements Exception {
  final String message;
  final String? code; // e.g., "LimitExceededException"
  final String? recoverySuggestion;

  BackendException(this.message, {this.code, this.recoverySuggestion});

  @override
  String toString() => 'BackendException: $message';
}
