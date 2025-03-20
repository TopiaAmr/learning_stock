part of 'stock_cubit.dart';

abstract class StockState extends Equatable {
  const StockState();

  @override
  List<Object?> get props => [];
}

class StockInitial extends StockState {}

class StockLoading extends StockState {}

class StockSearching extends StockState {}

class StockSearchEmpty extends StockState {}

class StockError extends StockState {
  final String message;

  const StockError({required this.message});

  @override
  List<Object?> get props => [message];
}

class TrendingStocksLoaded extends StockState {
  final List<StockModel> stocks;

  const TrendingStocksLoaded({required this.stocks});

  @override
  List<Object?> get props => [stocks];
}

class StockDetailsLoaded extends StockState {
  final StockModel stock;

  const StockDetailsLoaded({required this.stock});

  @override
  List<Object?> get props => [stock];
}

class StockSearchResults extends StockState {
  final List<StockModel> stocks;

  const StockSearchResults({required this.stocks});

  @override
  List<Object?> get props => [stocks];
}

class StockHistoryLoaded extends StockState {
  final List<StockHistoryModel> history;

  const StockHistoryLoaded({required this.history});

  @override
  List<Object?> get props => [history];
}
