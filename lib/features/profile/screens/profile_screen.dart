import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/router/routes.dart';
import '../../../features/auth/bloc/auth_bloc.dart';
import '../../../features/auth/bloc/auth_event.dart';
import '../../../features/auth/bloc/auth_state.dart';

/// User profile screen
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit profile
            },
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) {
            return const Center(child: CircularProgressIndicator());
          }
          final user = state.user;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Avatar
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: user.avatarUrl != null
                      ? ClipOval(
                          child: Image.network(
                            user.avatarUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _buildInitials(user.fullName),
                          ),
                        )
                      : _buildInitials(user.fullName),
                ),
                const SizedBox(height: 16),
                Text(
                  user.fullName,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user.role.label,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Info tiles
                _buildInfoTile(context, Icons.email, 'Email', user.email),
                if (user.phone != null)
                  _buildInfoTile(context, Icons.phone, 'No. HP', user.phone!),
                _buildInfoTile(
                  context,
                  Icons.calendar_today,
                  'Bergabung',
                  '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
                ),
                const SizedBox(height: 32),
                // Actions
                _buildActionTile(
                  context,
                  icon: Icons.storefront_outlined,
                  title: 'Daftarkan usaha atau jadi teknisi',
                  onTap: () => context.push(Routes.technicianRegister),
                ),
                _buildActionTile(
                  context,
                  icon: Icons.notifications_outlined,
                  title: 'Notifikasi',
                  onTap: () {},
                ),
                _buildActionTile(
                  context,
                  icon: Icons.help_outline,
                  title: 'Bantuan',
                  onTap: () {},
                ),
                _buildActionTile(
                  context,
                  icon: Icons.info_outline,
                  title: 'Tentang Goban',
                  onTap: () {},
                ),
                const SizedBox(height: 16),
                // Logout
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.read<AuthBloc>().add(const AuthLogoutRequested());
                      context.go(Routes.login);
                    },
                    icon: const Icon(Icons.logout, color: AppColors.error),
                    label: const Text(
                      'Keluar',
                      style: TextStyle(color: AppColors.error),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInitials(String name) {
    final initials = name
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();
    return Center(
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.onSurfaceVariant),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: onTap,
    );
  }
}
