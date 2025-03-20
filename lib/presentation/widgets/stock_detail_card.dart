import 'package:flutter/material.dart';
import '../../domain/entities/stock.dart';

class StockDetailCard extends StatelessWidget {
  final Stock stock;

  const StockDetailCard({
    Key? key,
    required this.stock,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPositive = stock.change >= 0;
    final changeColor = isPositive ? Colors.green : Colors.red;
    final changeIcon = isPositive ? Icons.arrow_upward : Icons.arrow_downward;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stock name and symbol
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
                color: Colors.grey[600],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Current price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${stock.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      changeIcon,
                      color: changeColor,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${isPositive ? '+' : ''}${stock.change.toStringAsFixed(2)} (${stock.changePercent.toStringAsFixed(2)}%)',
                      style: TextStyle(
                        color: changeColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
