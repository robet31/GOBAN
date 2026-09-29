import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../services/database_service.dart';

/// Admin dashboard with stats cards and management menus
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _totalUsers = 0;
  int _totalOrders = 0;
  int _pendingTechnicians = 0;
  int _pendingLocations = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final db = DatabaseService.instance;
    try {
      final users = await db.query('SELECT COUNT(*) as count FROM users');
      final orders = await db.query('SELECT COUNT(*) as count FROM orders');
      final pendTech = await db.query(
        "SELECT COUNT(*) as count FROM technician_profiles WHERE is_verified = 0",
      );
      final pendLoc = await db.query(
        "SELECT COUNT(*) as count FROM locations WHERE status = 'pending'",
      );

      setState(() {
        _totalUsers = users.first['count'] as int? ?? 0;
        _totalOrders = orders.first['count'] as int? ?? 0;
        _pendingTechnicians = pendTech.first['count'] as int? ?? 0;
        _pendingLocations = pendLoc.first['count'] as int? ?? 0;
      });
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStats,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats grid
              _buildStatsGrid(),
              const SizedBox(height: 32),
              Text(
                'Manajemen',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              // Menu items
              _buildMenuItem(
                icon: Icons.verified_user,
                title: 'Verifikasi Teknisi',
                subtitle: '$_pendingTechnicians menunggu verifikasi',
                color: AppColors.info,
                badge: _pendingTechnicians,
                onTap: () {},
              ),
              _buildMenuItem(
                icon: Icons.location_on,
                title: 'Moderasi Lokasi',
                subtitle: '$_pendingLocations menunggu review',
                color: AppColors.secondary,
                badge: _pendingLocations,
                onTap: () {},
              ),
              _buildMenuItem(
                icon: Icons.receipt_long,
                title: 'Kelola Order',
                subtitle: 'Lihat semua order',
                color: AppColors.primary,
                onTap: () {},
              ),
              _buildMenuItem(
                icon: Icons.people,
                title: 'Kelola User',
                subtitle: 'Ban/Unban pengguna',
                color: AppColors.error,
                onTap: () {},
              ),
              _buildMenuItem(
                icon: Icons.settings,
                title: 'Pengaturan',
                subtitle: 'Harga default, radius pencarian',
                color: AppColors.outline,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _AdminStatCard(
          icon: Icons.people,
          label: 'Total Users',
          value: '$_totalUsers',
          color: AppColors.primary,
        ),
        _AdminStatCard(
          icon: Icons.receipt_long,
          label: 'Total Orders',
          value: '$_totalOrders',
          color: AppColors.info,
        ),
        _AdminStatCard(
          icon: Icons.pending_actions,
          label: 'Teknisi Pending',
          value: '$_pendingTechnicians',
          color: AppColors.warning,
        ),
        _AdminStatCard(
          icon: Icons.location_searching,
          label: 'Lokasi Pending',
          value: '$_pendingLocations',
          color: AppColors.secondary,
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    int? badge,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (badge != null && badge > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$badge',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onTap: onTap,
      ),
    );
  }
}

class _AdminStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _AdminStatCard({
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
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 28),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
