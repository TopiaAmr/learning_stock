import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/usecase.dart';
import '../entities/stock.dart';
import '../repositories/stock_repository.dart';

class GetStockDetails implements UseCase<Stock, StockDetailsParams> {
  final StockRepository repository;

  GetStockDetails(this.repository);

  @override
  Future<Either<Failure, Stock>> call(StockDetailsParams params) {
    return repository.getStockDetails(params.symbol);
  }
}

class StockDetailsParams extends Equatable {
  final String symbol;

  const StockDetailsParams({required this.symbol});

  @override
  List<Object?> get props => [symbol];
}
