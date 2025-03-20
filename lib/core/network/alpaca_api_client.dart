import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../errors/exceptions.dart';

class AlpacaApiClient {
  final Dio dio;

  AlpacaApiClient({required this.dio}) {
    dio.options.baseUrl = AppConstants.alpacaBaseUrl;
    dio.options.connectTimeout = Duration(
      milliseconds: AppConstants.connectionTimeout,
    );
    dio.options.receiveTimeout = Duration(
      milliseconds: AppConstants.receiveTimeout,
    );
    dio.options.headers = {
      'APCA-API-KEY-ID': AppConstants.alpacaApiKeyId,
      'APCA-API-SECRET-KEY': AppConstants.alpacaApiSecretKey,
    };

    // Add logging interceptor in debug mode
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
          error: true,
        ),
      );
    }
  }

  /// Get historical bars (OHLCV) for a specific symbol
  Future<Map<String, dynamic>> getHistoricalBars({
    required String symbol,
    required String timeframe,
    required DateTime start,
    required DateTime end,
    int? limit,
    String adjustment = 'raw', // Options: raw, split, dividend, all
  }) async {
    final endpoint = '/stocks/bars';
    try {
      final response = await dio.get(
        endpoint,
        queryParameters: {
          'symbols': symbol,
          'timeframe': timeframe,
          'start': start.toUtc().toIso8601String(),
          'end': end.subtract(const Duration(hours: 1)).toUtc().toIso8601String(),
          'limit': limit ?? 1000,
          'adjustment': adjustment,
          'feed': 'sip',
          'sort': 'asc',
        },
        data: {},
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw ServerException(
          message: 'Failed to fetch historical data',
          statusCode: response.statusCode,
          endpoint: endpoint,
        );
      }
    } on DioException catch (e) {
      _handleDioError(
        e,
        endpoint: endpoint,
        context: 'historical data for $symbol',
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to fetch historical data: ${e.toString()}',
        endpoint: endpoint,
      );
    }
  }

  /// Get latest quote for a specific symbol
  Future<Map<String, dynamic>> getLatestQuote(String symbol) async {
    final endpoint = '/stocks/quotes/latest';
    try {
      final response = await dio.get(
        endpoint,
        queryParameters: {'symbols': symbol},
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw ServerException(
          message: 'Failed to fetch latest quote',
          statusCode: response.statusCode,
          endpoint: endpoint,
        );
      }
    } on DioException catch (e) {
      _handleDioError(
        e,
        endpoint: endpoint,
        context: 'latest quote for $symbol',
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to fetch latest quote: ${e.toString()}',
        endpoint: endpoint,
      );
    }
  }

  /// Handle Dio errors with appropriate exception types
  Never _handleDioError(
    DioException e, {
    required String endpoint,
    String? context,
  }) {
    final statusCode = e.response?.statusCode;
    final responseData = e.response?.data;
    final errorContext = context != null ? ' when fetching $context' : '';

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw TimeoutException(
          message: 'Connection timed out$errorContext',
          details: {'endpoint': endpoint},
        );

      case DioExceptionType.badResponse:
        if (statusCode == 401) {
          throw UnauthorizedException(
            message: 'API key is invalid or expired$errorContext',
            details: responseData,
          );
        } else if (statusCode == 403) {
          throw ForbiddenException(
            message: 'Access denied$errorContext',
            details: responseData,
          );
        } else if (statusCode == 404) {
          throw NotFoundException(
            message: 'Resource not found$errorContext',
            details: responseData,
          );
        } else if (statusCode == 429) {
          // Rate limit exceeded
          final retryAfter = _extractRetryAfterSeconds(e.response?.headers);
          throw RateLimitException(
            message:
                'Alpaca API rate limit exceeded$errorContext. Please try again later.',
            retryAfterSeconds: retryAfter,
            details: responseData,
          );
        } else {
          throw ServerException(
            message:
                _extractErrorMessage(responseData) ??
                'Server error$errorContext',
            statusCode: statusCode,
            data: responseData,
            endpoint: endpoint,
          );
        }

      case DioExceptionType.cancel:
        throw RequestCancelledException(
          message: 'Request cancelled$errorContext',
        );

      case DioExceptionType.connectionError:
        throw NetworkException(
          message: 'No internet connection$errorContext',
          details: {'endpoint': endpoint},
        );

      default:
        throw ServerException(
          message: e.message ?? 'Something went wrong$errorContext',
          statusCode: statusCode,
          data: responseData,
          endpoint: endpoint,
        );
    }
  }

  // Helper method to extract error message from response data
  String? _extractErrorMessage(dynamic responseData) {
    if (responseData == null) return null;

    if (responseData is Map) {
      // Try common error message fields in Alpaca API responses
      if (responseData.containsKey('message')) {
        return responseData['message'];
      }

      if (responseData.containsKey('error')) {
        return responseData['error'];
      }
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
