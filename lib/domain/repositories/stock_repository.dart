import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../data/models/stock_model.dart';
import '../../data/models/stock_history_model.dart';

abstract class StockRepository {
  /// Get a list of trending stocks
  Future<Either<Failure, List<StockModel>>> getTrendingStocks();
  
  /// Get detailed information for a specific stock
  Future<Either<Failure, StockModel>> getStockDetails(String symbol);
  
  /// Search for stocks by query
  Future<Either<Failure, List<StockModel>>> searchStocks(String query);
  
  /// Get historical data for a stock
  Future<Either<Failure, List<Map<String, dynamic>>>> getStockHistory(
    String symbol, {
    required String interval,
    required String range,
  });
  
  /// Get historical data for a stock from Alpaca API
  Future<Either<Failure, List<StockHistoryModel>>> getAlpacaStockHistory({
    required String symbol,
    required String timeframe,
    required DateTime start,
    required DateTime end,
    int? limit,
  });
  
  /// Get latest quote for a stock from Alpaca API
  Future<Either<Failure, Map<String, dynamic>>> getAlpacaLatestQuote(String symbol);
}
