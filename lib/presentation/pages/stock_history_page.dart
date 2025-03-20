import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/stock_history_model.dart';
import '../cubits/stock/stock_cubit.dart';
import '../widgets/error_message.dart';
import '../widgets/loading_indicator.dart';

class StockHistoryPage extends StatefulWidget {
  final String symbol;
  
  const StockHistoryPage({
    Key? key,
    required this.symbol,
  }) : super(key: key);

  @override
  State<StockHistoryPage> createState() => _StockHistoryPageState();
}

class _StockHistoryPageState extends State<StockHistoryPage> {
  String _selectedTimeframe = '1D';
  
  @override
  void initState() {
    super.initState();
    _fetchHistoricalData();
  }
  
  void _fetchHistoricalData() {
    final now = DateTime.now();
    DateTime startDate;
    
    switch (_selectedTimeframe) {
      case '1D':
        startDate = now.subtract(const Duration(days: 1));
        break;
      case '1W':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case '1M':
        startDate = now.subtract(const Duration(days: 30));
        break;
      case '3M':
        startDate = now.subtract(const Duration(days: 90));
        break;
      case '1Y':
        startDate = now.subtract(const Duration(days: 365));
        break;
      case 'ALL':
        startDate = now.subtract(const Duration(days: 1825)); // 5 years
        break;
      default:
        startDate = now.subtract(const Duration(days: 30));
    }
    
    // Determine appropriate timeframe based on selected range
    String alpacaTimeframe;
    if (_selectedTimeframe == '1D') {
      alpacaTimeframe = '5Min';
    } else if (_selectedTimeframe == '1W') {
      alpacaTimeframe = '1Hour';
    } else if (_selectedTimeframe == '1M') {
      alpacaTimeframe = '1Day';
    } else {
      alpacaTimeframe = '1Day';
    }
    
    context.read<StockCubit>().fetchAlpacaStockHistory(
      symbol: widget.symbol,
      timeframe: alpacaTimeframe,
      start: startDate,
      end: now,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.symbol} History'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildTimeframeSelector(),
          Expanded(
            child: BlocBuilder<StockCubit, StockState>(
              builder: (context, state) {
                if (state is StockLoading) {
                  return const LoadingIndicator();
                } else if (state is StockError) {
                  // Determine error type based on message content
                  final message = state.message;
                  if (message.contains('internet') || message.contains('network')) {
                    return ErrorMessage.network(
                      message: message,
                      onRetry: _fetchHistoricalData,
                    );
                  } else if (message.contains('rate limit') || message.contains('API rate limit')) {
                    return ErrorMessage.rateLimit(
                      message: message,
                      onRetry: _fetchHistoricalData,
                    );
                  } else {
                    return ErrorMessage(
                      message: message,
                      onRetry: _fetchHistoricalData,
                    );
                  }
                } else if (state is StockHistoryLoaded) {
                  return _buildHistoryChart(state.history);
                }
                return const Center(
                  child: Text('Select a timeframe to view historical data'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTimeframeSelector() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: AppConstants.timeIntervals.keys.map((timeframe) {
            final isSelected = timeframe == _selectedTimeframe;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ChoiceChip(
                label: Text(timeframe),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedTimeframe = timeframe;
                    });
                    _fetchHistoricalData();
                  }
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
  
  Widget _buildHistoryChart(List<StockHistoryModel> history) {
    if (history.isEmpty) {
      return const Center(
        child: Text('No historical data available for this timeframe'),
      );
    }
    
    // Sort history by timestamp
    history.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    // Create line chart data
    final spots = history.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final value = entry.value;
      return FlSpot(index, value.close);
    }).toList();
    
    // Find min and max values for y-axis
    final minY = history.map((e) => e.low).reduce((a, b) => a < b ? a : b);
    final maxY = history.map((e) => e.high).reduce((a, b) => a > b ? a : b);
    final padding = (maxY - minY) * 0.1;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() % (history.length ~/ 5) != 0) {
                          return const SizedBox.shrink();
                        }
                        final index = value.toInt();
                        if (index >= 0 && index < history.length) {
                          final date = history[index].timestamp;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              DateFormat.MMMd().format(date),
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            '\$${value.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      },
                      reservedSize: 40,
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: true),
                minX: 0,
                maxX: (history.length - 1).toDouble(),
                minY: minY - padding,
                maxY: maxY + padding,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildPriceInfo(history),
        ],
      ),
    );
  }
  
  Widget _buildPriceInfo(List<StockHistoryModel> history) {
    final firstPrice = history.first.close;
    final lastPrice = history.last.close;
    final change = lastPrice - firstPrice;
    final percentChange = (change / firstPrice) * 100;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Current Price',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${lastPrice.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Change'),
                Text(
                  '${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)} (${percentChange.toStringAsFixed(2)}%)',
                  style: TextStyle(
                    color: change >= 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Open'),
                Text('\$${history.last.open.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('High'),
                Text('\$${history.last.high.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Low'),
                Text('\$${history.last.low.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Volume'),
                Text('${NumberFormat.compact().format(history.last.volume)}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
