import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/enums.dart';
import '../../../services/database_service.dart';
import '../../../services/notification_service.dart';

/// Admin screen to moderate UGC locations
class ModerateLocationsScreen extends StatefulWidget {
  const ModerateLocationsScreen({super.key});

  @override
  State<ModerateLocationsScreen> createState() =>
      _ModerateLocationsScreenState();
}

class _ModerateLocationsScreenState extends State<ModerateLocationsScreen> {
  List<Map<String, dynamic>> _pendingLocations = [];
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
        '''SELECT l.*, u.full_name as added_by_name
           FROM locations l
           JOIN users u ON l.added_by = u.id
           WHERE l.status = 'pending'
           ORDER BY l.created_at DESC''',
      );
      setState(() => _pendingLocations = results);
    } catch (e) {
      // Handle error
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _approve(int locationId, String addedBy, String name) async {
    await DatabaseService.instance.execute(
      "UPDATE locations SET status = 'approved' WHERE id = ?",
      [locationId],
    );
    await DatabaseService.instance.sync();
    await NotificationService().notifyLocationApproved(
      userId: addedBy,
      locationName: name,
    );
    _loadPending();
  }

  Future<void> _reject(int locationId) async {
    await DatabaseService.instance.execute(
      "UPDATE locations SET status = 'rejected' WHERE id = ?",
      [locationId],
    );
    await DatabaseService.instance.sync();
    _loadPending();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Moderasi Lokasi')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pendingLocations.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle,
                          size: 64, color: AppColors.success),
                      SizedBox(height: 16),
                      Text('Semua lokasi sudah direview! 📍'),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadPending,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _pendingLocations.length,
                    itemBuilder: (context, index) {
                      final loc = _pendingLocations[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Photo
                              if (loc['photo_url'] != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    loc['photo_url'] as String,
                                    height: 150,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const SizedBox.shrink(),
                                  ),
                                ),
                              if (loc['photo_url'] != null)
                                const SizedBox(height: 12),
                              // Name
                              Text(
                                loc['name'] ?? 'Unknown',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              // Category
                              Chip(
                                label: Text(
                                  LocationCategory.fromDbValue(
                                          loc['category'] as String? ?? '')
                                      .label,
                                  style: const TextStyle(fontSize: 11),
                                ),
                                visualDensity: VisualDensity.compact,
                              ),
                              if (loc['address'] != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on,
                                        size: 14,
                                        color: AppColors.onSurfaceVariant),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        loc['address'] as String,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 4),
                              Text(
                                'Ditambahkan oleh: ${loc['added_by_name'] ?? 'Unknown'}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 16),
                              // Actions
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () =>
                                          _reject(loc['id'] as int),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.error,
                                        side: const BorderSide(
                                            color: AppColors.error),
                                      ),
                                      child: const Text('Tolak'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => _approve(
                                        loc['id'] as int,
                                        loc['added_by'] as String,
                                        loc['name'] as String,
                                      ),
                                      child: const Text('Setujui'),
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
}
