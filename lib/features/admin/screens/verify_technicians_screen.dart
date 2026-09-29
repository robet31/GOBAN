import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../services/database_service.dart';
import '../../../services/notification_service.dart';
import '../../../models/technician_profile.dart';

/// Admin screen to verify pending technician registrations
class VerifyTechniciansScreen extends StatefulWidget {
  const VerifyTechniciansScreen({super.key});

  @override
  State<VerifyTechniciansScreen> createState() =>
      _VerifyTechniciansScreenState();
}

class _VerifyTechniciansScreenState extends State<VerifyTechniciansScreen> {
  List<Map<String, dynamic>> _pendingTechnicians = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPending();
  }

  Future<void> _loadPending() async {
    setState(() => _isLoading = true);
    try {
      final results = await DatabaseService.instance.query(
        '''SELECT tp.*, u.full_name, u.email, u.phone
           FROM technician_profiles tp
           JOIN users u ON tp.id = u.id
           WHERE tp.is_verified = 0
           ORDER BY tp.created_at DESC''',
      );
      setState(() => _pendingTechnicians = results);
    } catch (e) {
      // Handle error
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _approve(String techId) async {
    await DatabaseService.instance.execute(
      'UPDATE technician_profiles SET is_verified = 1 WHERE id = ?',
      [techId],
    );
    await DatabaseService.instance.sync();
    await NotificationService().notifyTechnicianVerified(technicianId: techId);
    _loadPending();
  }

  Future<void> _reject(String techId) async {
    await DatabaseService.instance.execute(
      'DELETE FROM technician_profiles WHERE id = ?',
      [techId],
    );
    await DatabaseService.instance.sync();
    _loadPending();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verifikasi Teknisi')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pendingTechnicians.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle,
                          size: 64, color: AppColors.success),
                      SizedBox(height: 16),
                      Text('Semua teknisi sudah diverifikasi! 🎉'),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadPending,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _pendingTechnicians.length,
                    itemBuilder: (context, index) {
                      final tech = _pendingTechnicians[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor:
                                        AppColors.primary.withAlpha(30),
                                    child: const Icon(Icons.person,
                                        color: AppColors.primary),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          tech['full_name'] ?? 'Unknown',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                        Text(
                                          tech['email'] ?? '',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Shop info
                              if (tech['shop_name'] != null)
                                _infoTile(
                                    Icons.store, 'Toko: ${tech['shop_name']}'),
                              if (tech['address'] != null)
                                _infoTile(Icons.location_on,
                                    'Alamat: ${tech['address']}'),
                              if (tech['phone'] != null)
                                _infoTile(Icons.phone, 'HP: ${tech['phone']}'),
                              const SizedBox(height: 12),
                              // Documents
                              Text('Dokumen:',
                                  style:
                                      Theme.of(context).textTheme.titleSmall),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: [
                                  _docChip('KTP', tech['ktp_url']),
                                  _docChip('SIM', tech['sim_url']),
                                  _docChip('STNK', tech['stnk_url']),
                                  _docChip('Foto Toko', tech['shop_photo_url']),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Actions
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () =>
                                          _reject(tech['id'] as String),
                                      icon: const Icon(Icons.close),
                                      label: const Text('Tolak'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.error,
                                        side: const BorderSide(
                                            color: AppColors.error),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () =>
                                          _approve(tech['id'] as String),
                                      icon: const Icon(Icons.check),
                                      label: const Text('Setujui'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _infoTile(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(text, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _docChip(String label, String? url) {
    return Chip(
      avatar: Icon(
        url != null ? Icons.check_circle : Icons.cancel,
        size: 16,
        color: url != null ? AppColors.success : AppColors.error,
      ),
      label: Text(label, style: const TextStyle(fontSize: 11)),
      visualDensity: VisualDensity.compact,
    );
  }
}
