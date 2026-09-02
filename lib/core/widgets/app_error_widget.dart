import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class AppErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;

  const AppErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline_rounded,
  });

  bool get _isNoInternet =>
      message.toLowerCase().contains('no internet') ||
      message.toLowerCase().contains('no connection') ||
      message.toLowerCase().contains('check your network');

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isNoInternet)
              Image.asset(
                'assets/images/No Wi-Fi connection available.png',
                width: 180,
                height: 180,
                fit: BoxFit.contain,
              )
            else
              Icon(
                icon,
                size: 56,
                color: AppColors.textMuted,
              ),
            const SizedBox(height: 16),
            Text(
              _isNoInternet
                  ? 'No Internet Connection'
                  : message,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
              textAlign: TextAlign.center,
            ),
            if (_isNoInternet) ...[
              const SizedBox(height: 8),
              Text(
                'Please check your network and try again',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
                textAlign: TextAlign.center,
              ),
            ] else
              ...[],
            if (!_isNoInternet)
              ...[
                const SizedBox(height: 4),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: 160,
                child: OutlinedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try Again'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
