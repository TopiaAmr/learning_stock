import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../errors/exceptions.dart';
import 'package:logger/logger.dart';

class ApiClient {
  final Dio _dio;
  final Logger _logger = Logger();

  ApiClient() : _dio = Dio() {
    _dio.options.baseUrl = AppConstants.baseUrl;
    

    // Add interceptors for logging, authentication, etc.
    _dio.interceptors.add(LogInterceptor(
      requestBody: kDebugMode,
      responseBody: kDebugMode,
      logPrint: (object) {
        if (kDebugMode) {
          _logger.d(object);
        }
      },
    ));
  }

  // Add auth token to headers
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // Clear auth token
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  // GET request
  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      _handleError(e, endpoint: endpoint);
    } catch (e) {
      throw ServerException(
        message: e.toString(),
        endpoint: endpoint,
      );
    }
  }

  // POST request
  Future<dynamic> post(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      _handleError(e, endpoint: endpoint);
    } catch (e) {
      throw ServerException(
        message: e.toString(),
        endpoint: endpoint,
      );
    }
  }

  // PUT request
  Future<dynamic> put(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      _handleError(e, endpoint: endpoint);
    } catch (e) {
      throw ServerException(
        message: e.toString(),
        endpoint: endpoint,
      );
    }
  }

  // DELETE request
  Future<dynamic> delete(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      _handleError(e, endpoint: endpoint);
    } catch (e) {
      throw ServerException(
        message: e.toString(),
        endpoint: endpoint,
      );
    }
  }

  // Handle Dio errors
  Never _handleError(DioException e, {String? endpoint}) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw TimeoutException(
          message: 'Connection timed out',
          details: {'endpoint': endpoint},
        );
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;
        
        if (statusCode == 401) {
          throw UnauthorizedException(
            message: _extractErrorMessage(responseData) ?? 'Unauthorized',
            details: responseData,
          );
        } else if (statusCode == 403) {
          throw ForbiddenException(
            message: _extractErrorMessage(responseData) ?? 'Forbidden',
            details: responseData,
          );
        } else if (statusCode == 404) {
          throw NotFoundException(
            message: _extractErrorMessage(responseData) ?? 'Not found',
            details: responseData,
          );
        } else if (statusCode == 429) {
          // Rate limit exceeded
          final retryAfter = _extractRetryAfterSeconds(e.response?.headers);
          throw RateLimitException(
            message: _extractErrorMessage(responseData) ?? 'Rate limit exceeded',
            retryAfterSeconds: retryAfter,
            details: responseData,
          );
        } else {
          throw ServerException(
            message: _extractErrorMessage(responseData) ?? 'Server error',
            statusCode: statusCode,
            data: responseData,
            endpoint: endpoint,
          );
        }
      case DioExceptionType.cancel:
        throw RequestCancelledException(message: 'Request cancelled');
      case DioExceptionType.connectionError:
        throw NetworkException(
          message: 'No internet connection',
          details: {'endpoint': endpoint},
        );
      default:
        throw ServerException(
          message: e.message ?? 'Something went wrong',
          statusCode: e.response?.statusCode,
          data: e.response?.data,
          endpoint: endpoint,
        );
    }
  }
  
  // Helper method to extract error message from response data
  String? _extractErrorMessage(dynamic responseData) {
    if (responseData == null) return null;
    
    if (responseData is Map) {
      // Try common error message fields
      return responseData['message'] ?? 
             responseData['error_message'] ?? 
             responseData['error'] ?? 
             responseData['error_description'];
    }
    
    return responseData.toString();
  }
  
  // Helper method to extract retry-after header
  int? _extractRetryAfterSeconds(Headers? headers) {
    if (headers == null) return null;
    
    final retryAfter = headers.value('retry-after');
    if (retryAfter == null) return null;
    
    // Try to parse as integer (seconds)
    try {
      return int.parse(retryAfter);
    } catch (_) {
      // If not an integer, it might be a HTTP date
      try {
        final date = DateTime.parse(retryAfter);
        final now = DateTime.now();
        return date.difference(now).inSeconds;
      } catch (_) {
        return null;
      }
    }
  }
}
