import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import '../models/stock_model.dart';

abstract class StockLocalDataSource {
  /// Gets the cached list of trending stocks
  Future<List<StockModel>> getLastTrendingStocks();
  
  /// Caches a list of trending stocks
  Future<void> cacheTrendingStocks(List<StockModel> stocks);
  
  /// Gets the cached stock details for a specific symbol
  Future<StockModel> getLastStockDetails(String symbol);
  
  /// Caches stock details for a specific symbol
  Future<void> cacheStockDetails(String symbol, StockModel stock);
  
  /// Gets the cached search results for a specific query
  Future<List<StockModel>> getLastSearchResults(String query);
  
  /// Caches search results for a specific query
  Future<void> cacheSearchResults(String query, List<StockModel> stocks);
  
  /// Get cached stock history
  Future<List<Map<String, dynamic>>> getCachedStockHistory(
    String symbol, {
    required String interval,
    required String range,
  });
  
  /// Cache stock history
  Future<void> cacheStockHistory(
    String symbol, {
    required List<Map<String, dynamic>> history,
    required String interval,
    required String range,
  });
  
  /// Clear all cached data
  Future<void> clearCache();
}

class StockLocalDataSourceImpl implements StockLocalDataSource {
  final SharedPreferences sharedPreferences;
  
  // Cache keys
  static const String _trendingStocksKey = 'TRENDING_STOCKS';
  static const String _stockDetailsPrefix = 'STOCK_DETAILS_';
  static const String _stockHistoryPrefix = 'STOCK_HISTORY_';
  
  // Cache expiration time (in milliseconds)
  static const int _stockHistoryCacheTime = 60 * 60 * 1000; // 1 hour

  StockLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<StockModel>> getLastTrendingStocks() async {
    final jsonString = sharedPreferences.getString(AppConstants.cachedTrendingStocksKey);
    if (jsonString != null) {
      final jsonList = json.decode(jsonString) as List<dynamic>;
      return jsonList.map((item) => StockModel.fromJson(item)).toList();
    } else {
      throw CacheException(message: 'No cached trending stocks found');
    }
  }

  @override
  Future<void> cacheTrendingStocks(List<StockModel> stocks) async {
    final jsonList = stocks.map((stock) => stock.toJson()).toList();
    await sharedPreferences.setString(
      AppConstants.cachedTrendingStocksKey,
      json.encode(jsonList),
    );
  }

  @override
  Future<StockModel> getLastStockDetails(String symbol) async {
    final jsonString = sharedPreferences.getString('${AppConstants.cachedStockDetailsKey}_$symbol');
    if (jsonString != null) {
      return StockModel.fromJson(json.decode(jsonString));
    } else {
      throw CacheException(message: 'No cached details for $symbol found');
    }
  }

  @override
  Future<void> cacheStockDetails(String symbol, StockModel stock) async {
    await sharedPreferences.setString(
      '${AppConstants.cachedStockDetailsKey}_$symbol',
      json.encode(stock.toJson()),
    );
  }

  @override
  Future<List<StockModel>> getLastSearchResults(String query) async {
    final jsonString = sharedPreferences.getString('${AppConstants.cachedSearchResultsKey}_$query');
    if (jsonString != null) {
      final jsonList = json.decode(jsonString) as List<dynamic>;
      return jsonList.map((item) => StockModel.fromJson(item)).toList();
    } else {
      throw CacheException(message: 'No cached search results for $query found');
    }
  }

  @override
  Future<void> cacheSearchResults(String query, List<StockModel> stocks) async {
    final jsonList = stocks.map((stock) => stock.toJson()).toList();
    await sharedPreferences.setString(
      '${AppConstants.cachedSearchResultsKey}_$query',
      json.encode(jsonList),
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getCachedStockHistory(
    String symbol, {
    required String interval,
    required String range,
  }) async {
    try {
      final key = '$_stockHistoryPrefix${symbol}_$interval\_$range';
      final jsonString = sharedPreferences.getString(key);
      
      if (jsonString == null) {
        return [];
      }
      
      final Map<String, dynamic> cachedData = json.decode(jsonString);
      final timestamp = cachedData['timestamp'] as int;
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      
      // Check if cache is expired
      if (currentTime - timestamp > _stockHistoryCacheTime) {
        return [];
      }
      
      final List<dynamic> historyJson = cachedData['data'];
      return historyJson.cast<Map<String, dynamic>>();
    } catch (e) {
      throw CacheException(message: 'Failed to get cached stock history');
    }
  }

  @override
  Future<void> cacheStockHistory(
    String symbol, {
    required List<Map<String, dynamic>> history,
    required String interval,
    required String range,
  }) async {
    try {
      final key = '$_stockHistoryPrefix${symbol}_$interval\_$range';
      final Map<String, dynamic> cacheData = {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'data': history,
      };
      
      await sharedPreferences.setString(
        key,
        json.encode(cacheData),
      );
    } catch (e) {
      throw CacheException(message: 'Failed to cache stock history');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      final keys = sharedPreferences.getKeys();
      
      for (final key in keys) {
        if (key == _trendingStocksKey ||
            key.startsWith(_stockDetailsPrefix) ||
            key.startsWith(_stockHistoryPrefix)) {
          await sharedPreferences.remove(key);
        }
      }
    } catch (e) {
      throw CacheException(message: 'Failed to clear cache');
    }
  }
}
