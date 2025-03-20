import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/auth/auth_cubit.dart';
import '../cubits/auth/auth_state.dart';
import '../cubits/stock/stock_cubit.dart';
import '../widgets/stock_list_item.dart';
import '../widgets/error_message.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/search_bar_widget.dart';
import 'login_page.dart';
import 'stock_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Load trending stocks when the page is initialized
    context.read<StockCubit>().loadTrendingStocks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Stock'),
        centerTitle: true,
        actions: [
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              if (state is Authenticated) {
                return PopupMenuButton(
                  icon: const Icon(Icons.account_circle),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Text('Hello, ${state.user.name}'),
                      enabled: false,
                    ),
                    PopupMenuItem(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Balance:'),
                          Text(
                            '\$${state.user.balance.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      enabled: false,
                    ),
                    PopupMenuItem(
                      value: 'add_funds',
                      child: const Text('Add Funds'),
                    ),
                    const PopupMenuItem(
                      value: 'sign_out',
                      child: Text('Sign Out'),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'sign_out') {
                      context.read<AuthCubit>().signOut();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                        (route) => false,
                      );
                    } else if (value == 'add_funds') {
                      _showAddFundsDialog(context, state.user.email, state.user.balance);
                    }
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchBarWidget(
              onSearch: (query) {
                context.read<StockCubit>().searchForStocks(query);
              },
            ),
          ),
          
          // Stock list
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
                      onRetry: () => context.read<StockCubit>().loadTrendingStocks(),
                    );
                  } else if (message.contains('rate limit') || message.contains('API rate limit')) {
                    return ErrorMessage.rateLimit(
                      message: message,
                      onRetry: () => context.read<StockCubit>().loadTrendingStocks(),
                    );
                  } else {
                    return ErrorMessage(
                      message: message,
                      onRetry: () => context.read<StockCubit>().loadTrendingStocks(),
                    );
                  }
                } else if (state is TrendingStocksLoaded) {
                  return _buildStockList(state.stocks);
                } else if (state is StockSearchResults) {
                  return _buildStockList(state.stocks);
                } else if (state is StockSearchEmpty) {
                  return const Center(
                    child: Text('No stocks found matching your search'),
                  );
                } else {
                  return const Center(
                    child: Text('Search for stocks or view trending stocks'),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockList(stocks) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: stocks.length,
      itemBuilder: (context, index) {
        final stock = stocks[index];
        return StockListItem(
          stock: stock,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StockDetailPage(symbol: stock.symbol),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddFundsDialog(BuildContext context, String email, double currentBalance) {
    final TextEditingController amountController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Funds'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current Balance: \$${currentBalance.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Amount to Add (\$)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              if (amountController.text.isNotEmpty) {
                try {
                  final amountToAdd = double.parse(amountController.text);
                  if (amountToAdd > 0) {
                    final newBalance = currentBalance + amountToAdd;
                    context.read<AuthCubit>().updateBalance(
                          email: email,
                          newBalance: newBalance,
                        );
                    Navigator.pop(context);
                  }
                } catch (_) {
                  // Invalid number format
                }
              }
            },
            child: const Text('ADD'),
          ),
        ],
      ),
    );
  }
}
