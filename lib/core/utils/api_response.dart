import 'package:equatable/equatable.dart';

enum ApiStatus { initial, loading, success, error }

class ApiResponse<T> extends Equatable {
  final ApiStatus status;
  final T? data;
  final String? message;
  final String? errorCode;

  const ApiResponse._({
    required this.status,
    this.data,
    this.message,
    this.errorCode,
  });

  // Initial state
  const ApiResponse.initial() : this._(status: ApiStatus.initial);

  // Loading state
  const ApiResponse.loading() : this._(status: ApiStatus.loading);

  // Success state with data
  const ApiResponse.success(T data)
      : this._(
          status: ApiStatus.success,
          data: data,
        );

  // Error state with message
  const ApiResponse.error({
    required String message,
    String? errorCode,
  }) : this._(
          status: ApiStatus.error,
          message: message,
          errorCode: errorCode,
        );

  bool get isInitial => status == ApiStatus.initial;
  bool get isLoading => status == ApiStatus.loading;
  bool get isSuccess => status == ApiStatus.success;
  bool get isError => status == ApiStatus.error;

  @override
  List<Object?> get props => [status, data, message, errorCode];
}
