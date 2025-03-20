import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  // API related constants
  static const String baseUrl = 'https://api.example.com';
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  // Alpaca API
  static const String alpacaBaseUrl = 'https://data.alpaca.markets/v2';
  static String alpacaApiKeyId = dotenv.env['ALPACA_API_KEY_ID'] ?? "";
  static String alpacaApiSecretKey = dotenv.env['ALPACA_API_SECRET_KEY'] ?? "";

  // Local storage keys
  static const String tokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String cachedTrendingStocksKey = 'CACHED_TRENDING_STOCKS';
  static const String cachedStockDetailsKey = 'CACHED_STOCK_DETAILS';
  static const String cachedSearchResultsKey = 'CACHED_SEARCH_RESULTS';
  static const String usersKey = 'users';
  static const String currentUserKey = 'current_user';

  // Data Timeframes
  static const Map<String, String> timeIntervals = {
    '1D': '1 Day',
    '1W': '1 Week',
    '1M': '1 Month',
    '3M': '3 Months',
    '1Y': '1 Year',
    'ALL': 'All Time',
  };

  // App settings
  static const String appName = 'Learning Stock';
  static const String appVersion = '1.0.0';

  // Routes
  static const String homeRoute = '/home';
  static const String loginRoute = '/login';
  static const String stockDetailRoute = '/stock-detail';
  static const String portfolioRoute = '/portfolio';
  static const String settingsRoute = '/settings';
}
