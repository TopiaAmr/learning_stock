import 'package:equatable/equatable.dart';

class Stock extends Equatable {
  final String symbol;
  final String name;
  final double price;
  final double change;
  final double changePercent;
  final double open;
  final double high;
  final double low;
  final double previousClose;
  final int volume;
  final String? exchange;
  final String? industry;
  final double? marketCap;
  final String? description;

  const Stock({
    required this.symbol,
    required this.name,
    required this.price,
    required this.change,
    required this.changePercent,
    required this.open,
    required this.high,
    required this.low,
    required this.previousClose,
    required this.volume,
    this.exchange,
    this.industry,
    this.marketCap,
    this.description,
  });

  @override
  List<Object?> get props => [
        symbol,
        name,
        price,
        change,
        changePercent,
        open,
        high,
        low,
        previousClose,
        volume,
        exchange,
        industry,
        marketCap,
        description,
      ];
}
