import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/stock.dart';
import '../cubits/stock/stock_cubit.dart';
import '../widgets/error_message.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/stock_price_chart.dart';
import '../widgets/stock_detail_card.dart';

class StockDetailPage extends StatefulWidget {
  final String symbol;

  const StockDetailPage({
    Key? key,
    required this.symbol,
  }) : super(key: key);

  @override
  State<StockDetailPage> createState() => _StockDetailPageState();
}

class _StockDetailPageState extends State<StockDetailPage> {
  @override
  void initState() {
    super.initState();
    // Load stock details when the page is initialized
    context.read<StockCubit>().fetchStockDetails(widget.symbol);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.symbol),
        centerTitle: true,
      ),
      body: BlocBuilder<StockCubit, StockState>(
        builder: (context, state) {
          if (state is StockLoading) {
            return const LoadingIndicator();
          } else if (state is StockError) {
            return ErrorMessage(message: state.message);
          } else if (state is StockDetailsLoaded) {
            return _buildStockDetails(state.stock);
          } else {
            return const Center(
              child: Text('No stock details available'),
            );
          }
        },
      ),
    );
  }

  Widget _buildStockDetails(Stock stock) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stock header with current price and change
          StockDetailCard(stock: stock),
          
          const SizedBox(height: 24),
          
          // Price chart
          const Text(
            'Price History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 250,
            child: StockPriceChart(symbol: stock.symbol),
          ),
          
          const SizedBox(height: 24),
          
          // Stock details
          const Text(
            'Stock Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildDetailRow('Open', '\$${stock.open}'),
          _buildDetailRow('High', '\$${stock.high}'),
          _buildDetailRow('Low', '\$${stock.low}'),
          _buildDetailRow('Previous Close', '\$${stock.previousClose}'),
          _buildDetailRow('Volume', '${stock.volume}'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
