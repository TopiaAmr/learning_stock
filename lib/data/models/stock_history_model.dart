import '../../domain/entities/stock_history.dart';

class StockHistoryModel extends StockHistory {
  const StockHistoryModel({
    required String symbol,
    required DateTime timestamp,
    required double open,
    required double high,
    required double low,
    required double close,
    required double volume,
    double? adjustedClose,
  }) : super(
    symbol: symbol,
    timestamp: timestamp,
    open: open,
    high: high,
    low: low,
    close: close,
    volume: volume,
    adjustedClose: adjustedClose,
  );

  factory StockHistoryModel.fromJson(Map<String, dynamic> json) {
    return StockHistoryModel(
      symbol: json['symbol'] ?? 'UNKNOWN',
      timestamp: DateTime.parse(json['t']),
      open: (json['o'] as num).toDouble(),
      high: (json['h'] as num).toDouble(),
      low: (json['l'] as num).toDouble(),
      close: (json['c'] as num).toDouble(),
      volume: (json['v'] as num).toDouble(),
      adjustedClose: json['vw'] != null 
          ? (json['vw'] as num).toDouble() 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      't': timestamp.toIso8601String(),
      'o': open,
      'h': high,
      'l': low,
      'c': close,
      'v': volume,
      'vw': adjustedClose,
    };
  }
}
