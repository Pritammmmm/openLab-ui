class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class NoInternetException extends ApiException {
  const NoInternetException()
      : super(
          message: 'No internet connection. Please check your network and try again.',
          statusCode: null,
        );
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException()
      : super(
          message: 'Your session has expired. Please sign in again.',
          statusCode: 401,
        );
}

class ServerException extends ApiException {
  const ServerException({String? message})
      : super(
          message: message ?? 'Something went wrong. Please try again later.',
          statusCode: 500,
        );
}

class TimeoutException extends ApiException {
  const TimeoutException()
      : super(
          message: 'Request timed out. Please try again.',
          statusCode: null,
        );
}

class NotFoundException extends ApiException {
  const NotFoundException({String? message})
      : super(
          message: message ?? 'The requested resource was not found.',
          statusCode: 404,
        );
}

class ValidationException extends ApiException {
  final Map<String, dynamic>? errors;

  const ValidationException({String? message, this.errors})
      : super(
          message: message ?? 'Please check your input and try again.',
          statusCode: 422,
        );
}
