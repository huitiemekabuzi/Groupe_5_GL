import 'package:flutter/material.dart';
import 'package:ismgl/app/themes/app_theme.dart';

class EmptyState extends StatelessWidget {
  final String    message;
  final IconData  icon;
  final String?   actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: AppTheme.textSecondary.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
