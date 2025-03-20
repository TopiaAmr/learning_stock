import 'package:flutter/material.dart';

class ErrorMessage extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final bool isNetworkError;
  final bool isRateLimitError;

  const ErrorMessage({
    Key? key,
    required this.message,
    this.onRetry,
    this.isNetworkError = false,
    this.isRateLimitError = false,
  }) : super(key: key);

  factory ErrorMessage.network({
    required String message,
    VoidCallback? onRetry,
  }) {
    return ErrorMessage(
      message: message,
      onRetry: onRetry,
      isNetworkError: true,
    );
  }

  factory ErrorMessage.rateLimit({
    required String message,
    VoidCallback? onRetry,
  }) {
    return ErrorMessage(
      message: message,
      onRetry: onRetry,
      isRateLimitError: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildErrorIcon(),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: _getErrorColor(context),
                fontWeight: FontWeight.w500,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorIcon() {
    if (isNetworkError) {
      return Icon(
        Icons.signal_wifi_off,
        color: Colors.orange,
        size: 60,
      );
    } else if (isRateLimitError) {
      return Icon(
        Icons.timer_off,
        color: Colors.orange,
        size: 60,
      );
    } else {
      return Icon(
        Icons.error_outline,
        color: Colors.red,
        size: 60,
      );
    }
  }

  Color _getErrorColor(BuildContext context) {
    if (isNetworkError || isRateLimitError) {
      return Colors.orange;
    }
    return Colors.red;
  }
}
