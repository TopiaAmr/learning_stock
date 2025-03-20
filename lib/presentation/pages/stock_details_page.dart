import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/stock_model.dart';
import '../cubits/stock/stock_cubit.dart';
import '../widgets/error_message.dart';
import '../widgets/loading_indicator.dart';
import 'stock_history_page.dart';

class StockDetailsPage extends StatefulWidget {
  final String symbol;

  const StockDetailsPage({
    Key? key,
    required this.symbol,
  }) : super(key: key);

  @override
  State<StockDetailsPage> createState() => _StockDetailsPageState();
}

class _StockDetailsPageState extends State<StockDetailsPage> {
  @override
  void initState() {
    super.initState();
    _loadStockDetails();
  }

  void _loadStockDetails() {
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
            // Determine error type based on message content
            final message = state.message;
            if (message.contains('internet') || message.contains('network')) {
              return ErrorMessage.network(
                message: message,
                onRetry: _loadStockDetails,
              );
            } else if (message.contains('rate limit') || message.contains('API rate limit')) {
              return ErrorMessage.rateLimit(
                message: message,
                onRetry: _loadStockDetails,
              );
            } else {
              return ErrorMessage(
                message: message,
                onRetry: _loadStockDetails,
              );
            }
          } else if (state is StockDetailsLoaded) {
            return _buildStockDetails(context, state.stock);
          }
          return const Center(
            child: Text('No stock details available'),
          );
        },
      ),
    );
  }

  Widget _buildStockDetails(BuildContext context, StockModel stock) {
    return RefreshIndicator(
      onRefresh: () async {
        _loadStockDetails();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(stock),
            const SizedBox(height: 24),
            _buildPriceSection(stock),
            const SizedBox(height: 24),
            _buildCompanyInfo(stock),
            const SizedBox(height: 24),
            _buildActionButtons(context, stock),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(StockModel stock) {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              stock.symbol.substring(0, 1),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stock.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                stock.symbol,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSection(StockModel stock) {
    final isPositive = stock.changePercent >= 0;
    final changeColor = isPositive ? Colors.green : Colors.red;
    final changeIcon = isPositive ? Icons.arrow_upward : Icons.arrow_downward;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Price',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '\$${stock.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: changeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        changeIcon,
                        size: 16,
                        color: changeColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${stock.changePercent.toStringAsFixed(2)}%',
                        style: TextStyle(
                          color: changeColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPriceInfo('Open', '\$${stock.open.toStringAsFixed(2)}'),
                _buildPriceInfo('High', '\$${stock.high.toStringAsFixed(2)}'),
                _buildPriceInfo('Low', '\$${stock.low.toStringAsFixed(2)}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCompanyInfo(StockModel stock) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Company Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Exchange', stock.exchange ?? 'N/A'),
            const SizedBox(height: 8),
            _buildInfoRow('Industry', stock.industry ?? 'N/A'),
            const SizedBox(height: 8),
            _buildInfoRow('Market Cap', stock.marketCap != null ? '\$${_formatMarketCap(stock.marketCap)}' : 'N/A'),
            const SizedBox(height: 8),
            _buildInfoRow('Volume', '${stock.volume}'),
            const SizedBox(height: 16),
            const Text(
              'About',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              stock.description ?? 'No description available',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatMarketCap(double? marketCap) {
    if (marketCap == null) return 'N/A';
    
    if (marketCap >= 1000000000000) {
      return '${(marketCap / 1000000000000).toStringAsFixed(2)}T';
    } else if (marketCap >= 1000000000) {
      return '${(marketCap / 1000000000).toStringAsFixed(2)}B';
    } else if (marketCap >= 1000000) {
      return '${(marketCap / 1000000).toStringAsFixed(2)}M';
    } else {
      return marketCap.toStringAsFixed(2);
    }
  }

  Widget _buildActionButtons(BuildContext context, StockModel stock) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          context,
          'View History',
          Icons.show_chart,
          Colors.blue,
          () => _navigateToStockHistory(context, stock),
        ),
        _buildActionButton(
          context,
          'Buy',
          Icons.shopping_cart,
          Colors.green,
          () => _showBuyDialog(context, stock),
        ),
        _buildActionButton(
          context,
          'Add to Watchlist',
          Icons.bookmark_border,
          Colors.orange,
          () => _addToWatchlist(context, stock),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, color: Colors.white),
          label: Text(
            label,
            style: const TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  void _navigateToStockHistory(BuildContext context, StockModel stock) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StockHistoryPage(symbol: stock.symbol),
      ),
    );
  }

  void _showBuyDialog(BuildContext context, StockModel stock) {
    // Implement buy functionality
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Buy ${stock.symbol}'),
        content: const Text('Trading functionality will be implemented soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _addToWatchlist(BuildContext context, StockModel stock) {
    // Implement watchlist functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${stock.symbol} added to watchlist'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
