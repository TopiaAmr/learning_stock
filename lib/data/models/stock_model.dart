import '../../domain/entities/stock.dart';

class StockModel extends Stock {
  const StockModel({
    required String symbol,
    required String name,
    required double price,
    required double change,
    required double changePercent,
    required double open,
    required double high,
    required double low,
    required double previousClose,
    required int volume,
    String? exchange,
    String? industry,
    double? marketCap,
    String? description,
  }) : super(
          symbol: symbol,
          name: name,
          price: price,
          change: change,
          changePercent: changePercent,
          open: open,
          high: high,
          low: low,
          previousClose: previousClose,
          volume: volume,
          exchange: exchange,
          industry: industry,
          marketCap: marketCap,
          description: description,
        );

  factory StockModel.fromJson(Map<String, dynamic> json) {
    return StockModel(
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      change: (json['change'] as num).toDouble(),
      changePercent: (json['changePercent'] as num).toDouble(),
      open: (json['open'] as num).toDouble(),
      high: (json['high'] as num).toDouble(),
      low: (json['low'] as num).toDouble(),
      previousClose: (json['previousClose'] as num).toDouble(),
      volume: json['volume'] as int,
      exchange: json['exchange'] as String?,
      industry: json['industry'] as String?,
      marketCap: json['marketCap'] != null ? (json['marketCap'] as num).toDouble() : null,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'name': name,
      'price': price,
      'change': change,
      'changePercent': changePercent,
      'open': open,
      'high': high,
      'low': low,
      'previousClose': previousClose,
      'volume': volume,
      'exchange': exchange,
      'industry': industry,
      'marketCap': marketCap,
      'description': description,
    };
  }

  // Create a copy of this StockModel with the given fields replaced
  StockModel copyWith({
    String? symbol,
    String? name,
    double? price,
    double? change,
    double? changePercent,
    double? open,
    double? high,
    double? low,
    double? previousClose,
    int? volume,
    String? exchange,
    String? industry,
    double? marketCap,
    String? description,
  }) {
    return StockModel(
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      price: price ?? this.price,
      change: change ?? this.change,
      changePercent: changePercent ?? this.changePercent,
      open: open ?? this.open,
      high: high ?? this.high,
      low: low ?? this.low,
      previousClose: previousClose ?? this.previousClose,
      volume: volume ?? this.volume,
      exchange: exchange ?? this.exchange,
      industry: industry ?? this.industry,
      marketCap: marketCap ?? this.marketCap,
      description: description ?? this.description,
    );
  }
}
