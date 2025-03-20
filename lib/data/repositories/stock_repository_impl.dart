import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/repositories/stock_repository.dart';
import '../datasources/stock_local_data_source.dart';
import '../datasources/stock_remote_data_source.dart';
import '../models/stock_model.dart';
import '../models/stock_history_model.dart';

class StockRepositoryImpl implements StockRepository {
  final StockRemoteDataSource remoteDataSource;
  final StockLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  StockRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<StockModel>>> getTrendingStocks() async {
    if (await networkInfo.isConnected) {
      try {
        // Use Alpaca API to get trending stocks
        final stockHistory = await remoteDataSource.getAlpacaStockHistory(
          symbol: 'SPY,AAPL,MSFT,GOOGL,AMZN,META,TSLA,NVDA,JPM,V',
          timeframe: '1Day',
          start: DateTime.now().subtract(const Duration(days: 7)),
          end: DateTime.now().subtract(const Duration(minutes: 30)),
        );
        
        // Create stock models from the history data
        final stocks = _createStockModelsFromHistory(stockHistory);
        
        // Cache the trending stocks
        await localDataSource.cacheTrendingStocks(stocks);
        
        return Right(stocks);
      } on ServerException catch (e) {
        return Left(ServerFailure(
          message: e.message,
          statusCode: e.statusCode,
          endpoint: e.endpoint,
        ));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message));
      } on TimeoutException catch (e) {
        return Left(TimeoutFailure(message: e.message));
      } on RateLimitException catch (e) {
        return Left(RateLimitFailure(
          message: e.message,
          retryAfterSeconds: e.retryAfterSeconds,
        ));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      try {
        final localStocks = await localDataSource.getLastTrendingStocks();
        return Right(localStocks);
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  @override
  Future<Either<Failure, StockModel>> getStockDetails(String symbol) async {
    if (await networkInfo.isConnected) {
      try {
        // Use Alpaca API to get stock details
        final quote = await remoteDataSource.getAlpacaLatestQuote(symbol);
        final stockHistory = await remoteDataSource.getAlpacaStockHistory(
          symbol: symbol,
          timeframe: '1Day',
          start: DateTime.now().subtract(const Duration(days: 7)),
          end: DateTime.now().subtract(const Duration(minutes: 30)),
        );
        
        // Create a stock model from the quote and history data
        final stock = _createStockModelFromQuote(symbol, quote, stockHistory);
        
        // Cache the stock details
        await localDataSource.cacheStockDetails(symbol, stock);
        
        return Right(stock);
      } on ServerException catch (e) {
        return Left(ServerFailure(
          message: e.message,
          statusCode: e.statusCode,
          endpoint: e.endpoint,
        ));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message));
      } on TimeoutException catch (e) {
        return Left(TimeoutFailure(message: e.message));
      } on RateLimitException catch (e) {
        return Left(RateLimitFailure(
          message: e.message,
          retryAfterSeconds: e.retryAfterSeconds,
        ));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      try {
        final localStock = await localDataSource.getLastStockDetails(symbol);
        return Right(localStock);
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  @override
  Future<Either<Failure, List<StockModel>>> searchStocks(String query) async {
    if (await networkInfo.isConnected) {
      try {
        // Use Alpaca API to search for stocks
        // Since Alpaca doesn't have a direct search endpoint, we'll use a predefined list of popular stocks
        // and filter them by the query
        final symbols = 'AAPL,MSFT,GOOGL,AMZN,META,TSLA,NVDA,JPM,V,WMT,DIS,NFLX,PYPL,INTC,AMD,BA,GS,XOM,CVX,PFE';
        final stockHistory = await remoteDataSource.getAlpacaStockHistory(
          symbol: symbols,
          timeframe: '1Day',
          start: DateTime.now().subtract(const Duration(days: 1)),
          end: DateTime.now(),
        );
        
        // Create stock models from the history data
        final allStocks = _createStockModelsFromHistory(stockHistory);
        
        // Filter stocks by query
        final filteredStocks = allStocks.where((stock) => 
          stock.symbol.toLowerCase().contains(query.toLowerCase()) || 
          stock.name.toLowerCase().contains(query.toLowerCase())
        ).toList();
        
        // Cache the search results
        await localDataSource.cacheSearchResults(query, filteredStocks);
        
        return Right(filteredStocks);
      } on ServerException catch (e) {
        return Left(ServerFailure(
          message: e.message,
          statusCode: e.statusCode,
          endpoint: e.endpoint,
        ));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message));
      } on TimeoutException catch (e) {
        return Left(TimeoutFailure(message: e.message));
      } on RateLimitException catch (e) {
        return Left(RateLimitFailure(
          message: e.message,
          retryAfterSeconds: e.retryAfterSeconds,
        ));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      try {
        final localStocks = await localDataSource.getLastSearchResults(query);
        return Right(localStocks);
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }
  
  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getStockHistory(
    String symbol, {
    required String interval,
    required String range,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final historyData = await remoteDataSource.getStockHistory(
          symbol,
          interval: interval,
          range: range,
        );
        
        return Right(historyData);
      } on ServerException catch (e) {
        return Left(ServerFailure(
          message: e.message,
          statusCode: e.statusCode,
          endpoint: e.endpoint,
        ));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message));
      } on TimeoutException catch (e) {
        return Left(TimeoutFailure(message: e.message));
      } on RateLimitException catch (e) {
        return Left(RateLimitFailure(
          message: e.message,
          retryAfterSeconds: e.retryAfterSeconds,
        ));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      try {
        final cachedHistory = await localDataSource.getCachedStockHistory(
          symbol,
          interval: interval,
          range: range,
        );
        return Right(cachedHistory);
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  @override
  Future<Either<Failure, List<StockHistoryModel>>> getAlpacaStockHistory({
    required String symbol,
    required String timeframe,
    required DateTime start,
    required DateTime end,
    int? limit,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final historyData = await remoteDataSource.getAlpacaStockHistory(
          symbol: symbol,
          timeframe: timeframe,
          start: start,
          end: end,
          limit: limit,
        );
        
        return Right(historyData);
      } on ServerException catch (e) {
        return Left(ServerFailure(
          message: e.message,
          statusCode: e.statusCode,
          endpoint: e.endpoint,
        ));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message));
      } on TimeoutException catch (e) {
        return Left(TimeoutFailure(message: e.message));
      } on RateLimitException catch (e) {
        return Left(RateLimitFailure(
          message: e.message,
          retryAfterSeconds: e.retryAfterSeconds,
        ));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
  }
  
  @override
  Future<Either<Failure, Map<String, dynamic>>> getAlpacaLatestQuote(String symbol) async {
    if (await networkInfo.isConnected) {
      try {
        final quote = await remoteDataSource.getAlpacaLatestQuote(symbol);
        return Right(quote);
      } on ServerException catch (e) {
        return Left(ServerFailure(
          message: e.message,
          statusCode: e.statusCode,
          endpoint: e.endpoint,
        ));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message));
      } on TimeoutException catch (e) {
        return Left(TimeoutFailure(message: e.message));
      } on RateLimitException catch (e) {
        return Left(RateLimitFailure(
          message: e.message,
          retryAfterSeconds: e.retryAfterSeconds,
        ));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
  }
  
  // Helper method to create stock models from history data
  List<StockModel> _createStockModelsFromHistory(List<StockHistoryModel> historyData) {
    final stocksMap = <String, StockModel>{};
    
    for (var item in historyData) {
      final symbol = item.symbol;
      
      if (!stocksMap.containsKey(symbol)) {
        stocksMap[symbol] = StockModel(
          symbol: symbol,
          name: _getCompanyNameForSymbol(symbol),
          price: item.close,
          change: 0.0,
          changePercent: 0.0,
          volume: item.volume.toInt(),
          open: item.open,
          high: item.high,
          low: item.low,
          previousClose: item.close,
        );
      }
    }
    
    return stocksMap.values.toList();
  }
  
  // Helper method to create a stock model from quote and history data
  StockModel _createStockModelFromQuote(String symbol, Map<String, dynamic> quote, List<StockHistoryModel> history) {
    // Extract price from the latest quote
    final latestPrice = quote['p'] != null 
        ? (quote['p'] as num).toDouble() 
        : (history.isNotEmpty ? history.last.close : 0.0);
    
    // Get previous close from history or use latest price as fallback
    final previousClose = history.isNotEmpty ? history.first.close : latestPrice;
    
    // Calculate change and percent change
    final change = latestPrice - previousClose;
    final changePercent = previousClose > 0 ? (change / previousClose) * 100 : 0.0;
    
    return StockModel(
      symbol: symbol,
      name: _getCompanyNameForSymbol(symbol),
      price: latestPrice,
      change: change,
      changePercent: changePercent,
      volume: quote['s'] != null ? (quote['s'] as num).toInt() : 0,
      open: history.isNotEmpty ? history.first.open : 0.0,
      high: history.isNotEmpty ? history.first.high : 0.0,
      low: history.isNotEmpty ? history.first.low : 0.0,
      previousClose: previousClose,
    );
  }
  
  // Helper method to get company name for a symbol
  String _getCompanyNameForSymbol(String symbol) {
    final companyNames = {
      'AAPL': 'Apple Inc.',
      'MSFT': 'Microsoft Corporation',
      'GOOGL': 'Alphabet Inc.',
      'AMZN': 'Amazon.com Inc.',
      'META': 'Meta Platforms Inc.',
      'TSLA': 'Tesla Inc.',
      'NVDA': 'NVIDIA Corporation',
      'JPM': 'JPMorgan Chase & Co.',
      'V': 'Visa Inc.',
      'WMT': 'Walmart Inc.',
      'DIS': 'The Walt Disney Company',
      'NFLX': 'Netflix Inc.',
      'PYPL': 'PayPal Holdings Inc.',
      'INTC': 'Intel Corporation',
      'AMD': 'Advanced Micro Devices Inc.',
      'BA': 'Boeing Co.',
      'GS': 'Goldman Sachs Group Inc.',
      'XOM': 'Exxon Mobil Corporation',
      'CVX': 'Chevron Corporation',
      'PFE': 'Pfizer Inc.',
      'SPY': 'SPDR S&P 500 ETF Trust',
    };
    
    return companyNames[symbol] ?? 'Unknown Company';
  }
}
