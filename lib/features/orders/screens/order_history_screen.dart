import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/enums.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/error_screen.dart';
import '../../../models/order_model.dart';
import '../bloc/order_bloc.dart';
import '../bloc/order_event.dart';

/// Order history list screen
class OrderHistoryScreen extends StatefulWidget {
  final String userId;
  final UserRole role;

  const OrderHistoryScreen({
    super.key,
    required this.userId,
    required this.role,
  });

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OrderBloc>().add(
          OrderLoadHistory(userId: widget.userId, role: widget.role),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Order')),
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state is OrderLoading) {
            return ListView.builder(
              itemCount: 5,
              itemBuilder: (_, __) => const ShimmerCard(),
            );
          }
          if (state is OrderError) {
            return ErrorScreen(
              message: state.message,
              onRetry: () => context.read<OrderBloc>().add(
                    OrderLoadHistory(userId: widget.userId, role: widget.role),
                  ),
            );
          }
          if (state is OrderHistoryLoaded) {
            if (state.orders.isEmpty) {
              return const EmptyState(
                message: 'Belum ada order',
                icon: Icons.receipt_long_outlined,
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<OrderBloc>().add(
                      OrderLoadHistory(
                          userId: widget.userId, role: widget.role),
                    );
              },
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 100),
                itemCount: state.orders.length,
                itemBuilder: (context, index) {
                  return _OrderCard(order: state.orders[index]);
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          context.push(Routes.orderTrackingPath(order.id));
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: service type + status
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
              // Technician/Customer name
              if (order.technicianName != null)
                Row(
                  children: [
                    const Icon(Icons.person,
                        size: 14, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      order.technicianName!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              const SizedBox(height: 4),
              // Price and date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (order.price != null)
                    Text(
                      Formatters.rupiah(order.price!),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.primary,
                          ),
                    ),
                  Text(
                    Formatters.relativeTime(order.createdAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
