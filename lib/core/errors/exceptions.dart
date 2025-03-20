// Base exception class
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  AppException({
    required this.message,
    this.code,
    this.details,
  });

  @override
  String toString() => 'AppException: $message (Code: $code)';
}

// Network related exceptions
class ServerException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;
  final String? endpoint;

  const ServerException({
    required this.message,
    this.statusCode,
    this.data,
    this.endpoint,
  });

  @override
  String toString() => 'ServerException: $message (Status: $statusCode, Endpoint: $endpoint)';
}

class NetworkException extends AppException {
  NetworkException({
    required String message,
    String? code,
    dynamic details,
  }) : super(
          message: message,
          code: code ?? 'NETWORK_ERROR',
          details: details,
        );
}

class TimeoutException extends AppException {
  TimeoutException({
    required String message,
    String? code,
    dynamic details,
  }) : super(
          message: message,
          code: code ?? 'TIMEOUT_ERROR',
          details: details,
        );
}

class UnauthorizedException extends AppException {
  UnauthorizedException({
    required String message,
    String? code,
    dynamic details,
  }) : super(
          message: message,
          code: code ?? 'UNAUTHORIZED',
          details: details,
        );
}

class ForbiddenException extends AppException {
  ForbiddenException({
    required String message,
    String? code,
    dynamic details,
  }) : super(
          message: message,
          code: code ?? 'FORBIDDEN',
          details: details,
        );
}

class NotFoundException extends AppException {
  NotFoundException({
    required String message,
    String? code,
    dynamic details,
  }) : super(
          message: message,
          code: code ?? 'NOT_FOUND',
          details: details,
        );
}

class RateLimitException extends AppException {
  final int? retryAfterSeconds;
  
  RateLimitException({
    required String message,
    this.retryAfterSeconds,
    String? code,
    dynamic details,
  }) : super(
          message: message,
          code: code ?? 'RATE_LIMIT_EXCEEDED',
          details: details,
        );
        
  @override
  String toString() => 'RateLimitException: $message (Retry after: ${retryAfterSeconds ?? 'unknown'} seconds)';
}

class RequestCancelledException extends AppException {
  RequestCancelledException({
    required String message,
    String? code,
    dynamic details,
  }) : super(
          message: message,
          code: code ?? 'REQUEST_CANCELLED',
          details: details,
        );
}

// Cache related exceptions
class CacheException extends AppException {
  CacheException({
    required String message,
    String? code,
    dynamic details,
  }) : super(
          message: message,
          code: code ?? 'CACHE_ERROR',
          details: details,
        );
}

class AuthException implements Exception {
  final String message;
  final String code;
  
  const AuthException({
    required this.message,
    required this.code,
  });
}

// Validation exceptions
class ValidationException extends AppException {
  ValidationException({
    required String message,
    String? code,
    dynamic details,
  }) : super(
          message: message,
          code: code ?? 'VALIDATION_ERROR',
          details: details,
        );
}
