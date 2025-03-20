import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/usecase.dart';
import '../entities/stock.dart';
import '../repositories/stock_repository.dart';

class SearchStocks implements UseCase<List<Stock>, SearchStocksParams> {
  final StockRepository repository;

  SearchStocks(this.repository);

  @override
  Future<Either<Failure, List<Stock>>> call(SearchStocksParams params) {
    return repository.searchStocks(params.query);
  }
}

class SearchStocksParams extends Equatable {
  final String query;

  const SearchStocksParams({required this.query});

  @override
  List<Object?> get props => [query];
}
