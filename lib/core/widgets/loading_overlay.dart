import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Full screen loading overlay
class LoadingOverlay extends StatelessWidget {
  final String? message;

  const LoadingOverlay({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withAlpha(100),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppColors.elevatedShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color: AppColors.primary,
              ),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(
                  message!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Show loading overlay as a dialog
  static Future<void> show(BuildContext context, {String? message}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => LoadingOverlay(message: message),
    );
  }

  /// Hide loading overlay
  static void hide(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}
