sealed class AppException implements Exception {
  const AppException(this.message, {this.cause});
  final String message;
  final Object? cause;

  @override
  String toString() => 'AppException: $message${cause != null ? " (cause: $cause)" : ""}';
}

class DatabaseException extends AppException {
  const DatabaseException(super.message, {super.cause});
}

class NetworkException extends AppException {
  const NetworkException(super.message, {super.cause});
}

class AuthException extends AppException {
  const AuthException(super.message, {super.cause});
}

class HealthPermissionException extends AppException {
  const HealthPermissionException(super.message, {super.cause});
}

class HealthReadException extends AppException {
  const HealthReadException(super.message, {super.cause});
}

class SubscriptionException extends AppException {
  const SubscriptionException(super.message, {super.cause});
}

class ValidationException extends AppException {
  const ValidationException(super.message, {this.errors = const []});
  final List<String> errors;
}

class UnknownException extends AppException {
  const UnknownException(super.message, {super.cause});
}
