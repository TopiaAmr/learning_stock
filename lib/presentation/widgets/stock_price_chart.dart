import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/stock.dart';
import '../cubits/stock/stock_cubit.dart';
import 'loading_indicator.dart';
import 'error_message.dart';

class StockPriceChart extends StatefulWidget {
  final String symbol;

  const StockPriceChart({
    Key? key,
    required this.symbol,
  }) : super(key: key);

  @override
  State<StockPriceChart> createState() => _StockPriceChartState();
}

class _StockPriceChartState extends State<StockPriceChart> {
  // Sample data for demonstration
  // In a real app, this would come from an API
  final List<FlSpot> _dummySpots = [
    const FlSpot(0, 100),
    const FlSpot(1, 102),
    const FlSpot(2, 101),
    const FlSpot(3, 103),
    const FlSpot(4, 105),
    const FlSpot(5, 104),
    const FlSpot(6, 107),
    const FlSpot(7, 108),
    const FlSpot(8, 106),
    const FlSpot(9, 110),
  ];

  String _selectedInterval = '1d';
  final List<String> _intervals = ['1d', '1w', '1m', '3m', '1y'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Interval selector
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _intervals.length,
            itemBuilder: (context, index) {
              final interval = _intervals[index];
              final isSelected = interval == _selectedInterval;
              
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(interval),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedInterval = interval;
                      });
                      // In a real app, we would fetch new data here
                    }
                  },
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Chart
        Expanded(
          child: _buildChart(),
        ),
      ],
    );
  }

  Widget _buildChart() {
    // In a real app, we would check for loading/error states here
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 2,
          verticalInterval: 1,
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                // In a real app, we would show dates here
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 8.0,
                  child: Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 2,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 8.0,
                  child: Text(
                    '\$${value.toInt()}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1),
        ),
        minX: 0,
        maxX: 9,
        minY: 95,
        maxY: 115,
        lineBarsData: [
          LineChartBarData(
            spots: _dummySpots,
            isCurved: true,
            color: Theme.of(context).primaryColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(
              show: false,
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).primaryColor.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }
}
