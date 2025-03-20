import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../../data/models/stock_history_model.dart';
import '../repositories/stock_repository.dart';

class AlpacaHistoryParams {
  final String symbol;
  final String timeframe;
  final DateTime start;
  final DateTime end;
  final int? limit;

  AlpacaHistoryParams({
    required this.symbol,
    required this.timeframe,
    required this.start,
    required this.end,
    this.limit,
  });
}

class GetAlpacaStockHistory implements UseCase<List<StockHistoryModel>, AlpacaHistoryParams> {
  final StockRepository repository;

  GetAlpacaStockHistory(this.repository);

  @override
  Future<Either<Failure, List<StockHistoryModel>>> call(AlpacaHistoryParams params) async {
    return await repository.getAlpacaStockHistory(
      symbol: params.symbol,
      timeframe: params.timeframe,
      start: params.start,
      end: params.end,
      limit: params.limit,
    );
  }
}
