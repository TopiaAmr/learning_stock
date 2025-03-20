import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/usecase.dart';
import '../entities/stock.dart';
import '../repositories/stock_repository.dart';

class GetTrendingStocks implements UseCase<List<Stock>, NoParams> {
  final StockRepository repository;

  GetTrendingStocks(this.repository);

  @override
  Future<Either<Failure, List<Stock>>> call(NoParams params) {
    return repository.getTrendingStocks();
  }
}
