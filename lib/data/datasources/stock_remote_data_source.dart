import '../../core/errors/exceptions.dart';
import '../../core/network/api_client.dart';
import '../../core/network/alpaca_api_client.dart';
import '../models/stock_model.dart';
import '../models/stock_history_model.dart';

abstract class StockRemoteDataSource {
  /// Get a list of trending stocks from the API
  Future<List<StockModel>> getTrendingStocks();
  
  /// Get detailed information for a specific stock from the API
  Future<StockModel> getStockDetails(String symbol);
  
  /// Search for stocks by query from the API
  Future<List<StockModel>> searchStocks(String query);
  
  /// Get historical data for a stock from the API
  Future<List<Map<String, dynamic>>> getStockHistory(
    String symbol, {
    required String interval,
    required String range,
  });
  
  /// Get historical data for a stock from Alpaca API
  Future<List<StockHistoryModel>> getAlpacaStockHistory({
    required String symbol,
    required String timeframe,
    required DateTime start,
    required DateTime end,
    int? limit,
  });
  
  /// Get latest quote for a stock from Alpaca API
  Future<Map<String, dynamic>> getAlpacaLatestQuote(String symbol);
}

class StockRemoteDataSourceImpl implements StockRemoteDataSource {
  final ApiClient apiClient;
  final AlpacaApiClient alpacaApiClient;

  StockRemoteDataSourceImpl({
    required this.apiClient,
    required this.alpacaApiClient,
  });

  @override
  Future<List<StockModel>> getTrendingStocks() async {
    try {
      final response = await apiClient.get('/trending');
      
      if (response == null) {
        throw ServerException(message: 'Failed to get trending stocks');
      }
      
      final List<dynamic> stocksJson = response['stocks'];
      return stocksJson
          .map((json) => StockModel.fromJson(json))
          .toList();
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<StockModel> getStockDetails(String symbol) async {
    try {
      final response = await apiClient.get('/stock/$symbol');
      
      if (response == null) {
        throw ServerException(message: 'Failed to get stock details');
      }
      
      return StockModel.fromJson(response);
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<StockModel>> searchStocks(String query) async {
    try {
      final response = await apiClient.get(
        '/search',
        queryParameters: {'q': query},
      );
      
      if (response == null) {
        throw ServerException(message: 'Failed to search stocks');
      }
      
      final List<dynamic> stocksJson = response['results'];
      return stocksJson
          .map((json) => StockModel.fromJson(json))
          .toList();
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getStockHistory(
    String symbol, {
    required String interval,
    required String range,
  }) async {
    try {
      final response = await apiClient.get(
        '/stock/$symbol/history',
        queryParameters: {
          'interval': interval,
          'range': range,
        },
      );
      
      if (response == null) {
        throw ServerException(message: 'Failed to get stock history');
      }
      
      final List<dynamic> historyJson = response['history'];
      return historyJson.cast<Map<String, dynamic>>();
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }
  
  @override
  Future<List<StockHistoryModel>> getAlpacaStockHistory({
    required String symbol,
    required String timeframe,
    required DateTime start,
    required DateTime end,
    int? limit,
  }) async {
    try {
      final response = await alpacaApiClient.getHistoricalBars(
        symbol: symbol,
        timeframe: timeframe,
        start: start,
        end: end,
        limit: limit,
      );
      
      if (response['bars'] == null) {
        throw ServerException(message: 'Failed to get stock history from Alpaca API');
      }
      
      final Map<String, dynamic> barsMap = response['bars'] as Map<String, dynamic>;
      final List<StockHistoryModel> result = [];
      
      // Process each symbol's bars
      barsMap.forEach((symbolKey, barsList) {
        if (barsList is List) {
          for (var bar in barsList) {
            if (bar is Map<String, dynamic>) {
              // Add the symbol to each bar data
              bar['symbol'] = symbolKey;
              result.add(StockHistoryModel.fromJson(bar));
            }
          }
        }
      });
      
      return result;
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }
  
  @override
  Future<Map<String, dynamic>> getAlpacaLatestQuote(String symbol) async {
    try {
      final response = await alpacaApiClient.getLatestQuote(symbol);
      
      if (response['quotes'] == null) {
        throw ServerException(message: 'Failed to get latest quote from Alpaca API');
      }
      
      final quotes = response['quotes'] as Map<String, dynamic>;
      if (!quotes.containsKey(symbol)) {
        throw ServerException(message: 'No quote data available for $symbol');
      }
      
      return quotes[symbol];
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }
}
