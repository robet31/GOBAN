import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../../core/constants/enums.dart';

/// Status badge chip with color based on order status
class StatusBadge extends StatelessWidget {
  final OrderStatus status;
  final double fontSize;

  const StatusBadge({
    super.key,
    required this.status,
    this.fontSize = 12,
  });

  Color get _color {
    switch (status) {
      case OrderStatus.waiting:
        return AppColors.statusWaiting;
      case OrderStatus.accepted:
        return AppColors.statusAccepted;
      case OrderStatus.ongoing:
        return AppColors.statusOngoing;
      case OrderStatus.completed:
        return AppColors.statusCompleted;
      case OrderStatus.cancelled:
        return AppColors.statusCancelled;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _color.withAlpha(100)),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: _color,
        ),
      ),
    );
  }
}
