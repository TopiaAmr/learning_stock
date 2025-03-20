import 'package:equatable/equatable.dart';

// Base failure class
abstract class Failure extends Equatable {
  final String message;
  final String? code;
  final dynamic details;

  const Failure({
    required this.message,
    this.code,
    this.details,
  });

  @override
  List<Object?> get props => [message, code, details];
}

// Server failures
class ServerFailure extends Failure {
  final int? statusCode;
  final String? endpoint;

  const ServerFailure({
    required String message,
    this.statusCode,
    this.endpoint,
    String? code,
    dynamic details,
  }) : super(
          message: message,
          code: code ?? 'SERVER_ERROR',
          details: details,
        );
        
  @override
  List<Object?> get props => [...super.props, statusCode, endpoint];
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    required String message,
    String? code,
    dynamic details,
  }) : super(
          message: message,
          code: code ?? 'NETWORK_ERROR',
          details: details,
        );
}

class TimeoutFailure extends Failure {
  const TimeoutFailure({
    required String message,
    String? code,
    dynamic details,
  }) : super(
          message: message,
          code: code ?? 'TIMEOUT_ERROR',
          details: details,
        );
}

class RateLimitFailure extends Failure {
  final int? retryAfterSeconds;
  
  const RateLimitFailure({
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
  List<Object?> get props => [...super.props, retryAfterSeconds];
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure({
    required String message,
    String? code,
    dynamic details,
  }) : super(
          message: message,
          code: code ?? 'AUTHENTICATION_ERROR',
          details: details,
        );
}

// Cache failures
class CacheFailure extends Failure {
  const CacheFailure({String message = 'Cache failure'}) : super(message: message);
}

class AuthFailure extends Failure {
  const AuthFailure({String message = 'Authentication failure'}) : super(message: message);
}

// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure({
    required String message,
    String? code,
    dynamic details,
  }) : super(
          message: message,
          code: code ?? 'VALIDATION_ERROR',
          details: details,
        );
}
