import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/router/routes.dart';
import '../../../core/utils/formatters.dart';
import '../../../features/auth/bloc/auth_bloc.dart';
import '../../../features/auth/bloc/auth_event.dart';
import '../../../features/auth/bloc/auth_state.dart';
import '../../../services/database_service.dart';
import '../../orders/bloc/order_bloc.dart';
import '../../orders/bloc/order_event.dart';
import '../../orders/widgets/order_card.dart';

/// Technician dashboard with online toggle and incoming orders
class TechnicianDashboard extends StatefulWidget {
  const TechnicianDashboard({super.key});

  @override
  State<TechnicianDashboard> createState() => _TechnicianDashboardState();
}

class _TechnicianDashboardState extends State<TechnicianDashboard> {
  bool _isOnline = false;
  int _todayOrders = 0;
  int _todayEarnings = 0;
  double _rating = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<OrderBloc>().add(OrderLoadIncoming(authState.user.id));
    }
  }

  Future<void> _loadDashboardData() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final db = DatabaseService.instance;
      try {
        // Load profile
        final profiles = await db.query(
          'SELECT * FROM technician_profiles WHERE id = ?',
          [authState.user.id],
        );
        if (profiles.isNotEmpty) {
          setState(() {
            _isOnline = (profiles.first['is_online'] as int?) == 1;
            _rating = (profiles.first['rating_avg'] as num?)?.toDouble() ?? 0;
          });
        }

        // Load today stats
        final today = DateTime.now().toIso8601String().substring(0, 10);
        final stats = await db.query(
          "SELECT COUNT(*) as count, COALESCE(SUM(price), 0) as total FROM orders WHERE technician_id = ? AND status = 'completed' AND date(completed_at) = ?",
          [authState.user.id, today],
        );
        if (stats.isNotEmpty) {
          setState(() {
            _todayOrders = stats.first['count'] as int? ?? 0;
            _todayEarnings = stats.first['total'] as int? ?? 0;
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data dashboard tidak dapat dimuat.')),
          );
        }
      }
    }
  }

  Future<void> _toggleOnline() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final newStatus = !_isOnline;
      setState(() => _isOnline = newStatus);
      try {
        await DatabaseService.instance.execute(
          'UPDATE technician_profiles SET is_online = ? WHERE id = ?',
          [newStatus ? 1 : 0, authState.user.id],
        );
        await DatabaseService.instance.sync();
      } catch (e) {
        setState(() => _isOnline = !newStatus); // Revert
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Status online tidak dapat diperbarui.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Teknisi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // Navigate to order history
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(const AuthLogoutRequested());
              context.go(Routes.login);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Online toggle
              _buildOnlineToggle(),
              const SizedBox(height: 24),
              // Stats
              _buildStatsRow(),
              const SizedBox(height: 24),
              // Incoming orders header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order Masuk',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Lihat Semua'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              BlocBuilder<OrderBloc, OrderState>(
                builder: (context, state) {
                  if (state is OrderIncomingLoaded && state.orders.isNotEmpty) {
                    return Column(
                      children: state.orders
                          .map(
                            (order) => OrderCard(
                              order: order,
                              showActions: true,
                              onAccept: () {
                                final authState =
                                    context.read<AuthBloc>().state;
                                if (authState is AuthAuthenticated) {
                                  context.read<OrderBloc>().add(OrderAccept(
                                        orderId: order.id,
                                        technicianId: authState.user.id,
                                      ));
                                }
                              },
                              onReject: () => context
                                  .read<OrderBloc>()
                                  .add(OrderReject(order.id)),
                            ),
                          )
                          .toList(),
                    );
                  }
                  return _buildIncomingEmptyState();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIncomingEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            _isOnline ? Icons.hourglass_empty : Icons.wifi_off,
            size: 48,
            color: AppColors.outline,
          ),
          const SizedBox(height: 12),
          Text(
            _isOnline
                ? 'Belum ada order yang sesuai area dan layanan Anda'
                : 'Anda sedang offline. Aktifkan saat siap menerima order lapangan.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
          if (_isOnline) ...[
            const SizedBox(height: 8),
            Text(
              'Status Online tidak menjamin order tersedia. Periksa kembali area dan layanan di profil.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOnlineToggle() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: _isOnline
            ? AppColors.primaryGradient
            : const LinearGradient(
                colors: [AppColors.surfaceVariant, AppColors.surfaceVariant],
              ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: _isOnline ? AppColors.elevatedShadow : null,
      ),
      child: Column(
        children: [
          Text(
            _isOnline ? 'ONLINE' : 'OFFLINE',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: _isOnline ? Colors.white : AppColors.onSurfaceVariant,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 16),
          Transform.scale(
            scale: 1.5,
            child: Switch(
              value: _isOnline,
              onChanged: (_) => _toggleOnline(),
              activeColor: Colors.white,
              activeTrackColor: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isOnline
                ? 'Anda bisa menerima order'
                : 'Aktifkan untuk menerima order',
            style: TextStyle(
              color: _isOnline
                  ? Colors.white.withAlpha(200)
                  : AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.receipt,
            label: 'Order Hari Ini',
            value: '$_todayOrders',
            color: AppColors.info,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.payments,
            label: 'Pendapatan',
            value: Formatters.rupiah(_todayEarnings),
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.star,
            label: 'Rating',
            value: _rating.toStringAsFixed(1),
            color: AppColors.warning,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
