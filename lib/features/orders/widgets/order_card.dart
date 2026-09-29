import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/constants/enums.dart';
import '../../../models/order_model.dart';

/// Order card widget for lists
class OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onTap;
  final bool showActions;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const OrderCard({
    super.key,
    required this.order,
    this.onTap,
    this.showActions = false,
    this.onAccept,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      order.serviceLabel,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  StatusBadge(status: order.status),
                ],
              ),
              const SizedBox(height: 8),
              // Customer/Technician info
              if (order.customerName != null)
                _infoRow(context, Icons.person, order.customerName!),
              if (order.technicianName != null)
                _infoRow(context, Icons.build, order.technicianName!),
              if (order.customerAddress != null)
                _infoRow(context, Icons.location_on, order.customerAddress!,
                    maxLines: 1),
              const SizedBox(height: 8),
              // Price and date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (order.price != null)
                    Text(
                      Formatters.rupiah(order.price!),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  Text(
                    Formatters.relativeTime(order.createdAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              // Action buttons for technician
              if (showActions && order.status == OrderStatus.waiting) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onReject,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                        ),
                        child: const Text('Tolak'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onAccept,
                        child: const Text('Terima'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(
    BuildContext context,
    IconData icon,
    String text, {
    int maxLines = 2,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
