import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/usecase.dart';
import '../../../data/models/stock_model.dart';
import '../../../data/models/stock_history_model.dart';
import '../../../domain/usecases/get_stock_details.dart';
import '../../../domain/usecases/get_trending_stocks.dart';
import '../../../domain/usecases/search_stocks.dart';
import '../../../domain/usecases/get_alpaca_stock_history.dart';

part 'stock_state.dart';

class StockCubit extends Cubit<StockState> {
  final GetTrendingStocks getTrendingStocks;
  final GetStockDetails getStockDetails;
  final SearchStocks searchStocks;
  final GetAlpacaStockHistory getAlpacaStockHistory;

  StockCubit({
    required this.getTrendingStocks,
    required this.getStockDetails,
    required this.searchStocks,
    required this.getAlpacaStockHistory,
  }) : super(StockInitial());

  Future<void> loadTrendingStocks() async {
    emit(StockLoading());
    final result = await getTrendingStocks(NoParams());
    
    result.fold(
      (failure) => emit(StockError(message: _mapFailureToMessage(failure))),
      (stocks) {
        final stockModels = stocks.map((stock) => stock as StockModel).toList();
        emit(TrendingStocksLoaded(stocks: stockModels));
      },
    );
  }

  Future<void> fetchStockDetails(String symbol) async {
    emit(StockLoading());
    
    final result = await getStockDetails(StockDetailsParams(symbol: symbol));
    
    result.fold(
      (failure) => emit(StockError(message: _mapFailureToMessage(failure))),
      (stock) => emit(StockDetailsLoaded(stock: stock as StockModel)),
    );
  }

  Future<void> searchForStocks(String query) async {
    if (query.isEmpty) {
      emit(StockSearchEmpty());
      return;
    }
    
    emit(StockSearching());
    
    final result = await searchStocks(SearchStocksParams(query: query));
    
    result.fold(
      (failure) => emit(StockError(message: _mapFailureToMessage(failure))),
      (stocks) {
        final stockModels = stocks.map((stock) => stock as StockModel).toList();
        emit(StockSearchResults(stocks: stockModels));
      },
    );
  }
  
  Future<void> fetchAlpacaStockHistory({
    required String symbol,
    required String timeframe,
    required DateTime start,
    required DateTime end,
    int? limit,
  }) async {
    emit(StockLoading());
    final result = await getAlpacaStockHistory(
      AlpacaHistoryParams(
        symbol: symbol,
        timeframe: timeframe,
        start: start,
        end: end,
        limit: limit,
      ),
    );
    result.fold(
      (failure) => emit(StockError(message: _mapFailureToMessage(failure))),
      (history) => emit(StockHistoryLoaded(history: history)),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      final statusCode = failure.statusCode;
      if (statusCode != null) {
        if (statusCode >= 500) {
          return 'Server error occurred (${failure.statusCode}). Please try again later.';
        } else if (statusCode == 404) {
          return 'The requested resource was not found. Please check your input and try again.';
        } else if (statusCode == 401 || statusCode == 403) {
          return 'Authentication error. Please check your credentials or login again.';
        }
      }
      return failure.message;
    } else if (failure is NetworkFailure) {
      return 'No internet connection. Please check your network settings and try again.';
    } else if (failure is TimeoutFailure) {
      return 'Request timed out. Please try again later when the network is more stable.';
    } else if (failure is RateLimitFailure) {
      final retryAfter = failure.retryAfterSeconds;
      if (retryAfter != null && retryAfter > 0) {
        return 'API rate limit exceeded. Please try again after ${retryAfter} seconds.';
      }
      return 'API rate limit exceeded. Please try again later.';
    } else if (failure is CacheFailure) {
      return 'Could not retrieve cached data. Please try again with an internet connection.';
    } else if (failure is AuthFailure || failure is AuthenticationFailure) {
      return 'Authentication failed. Please log in again.';
    } else {
      return failure.message.isNotEmpty 
          ? failure.message 
          : 'Unexpected error occurred. Please try again.';
    }
  }
}
