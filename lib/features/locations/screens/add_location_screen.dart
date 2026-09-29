import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/enums.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../features/auth/bloc/auth_bloc.dart';
import '../../../features/auth/bloc/auth_state.dart';
import '../../../models/location_model.dart';
import '../../../services/database_service.dart';
import '../../../services/location_service.dart';
import '../../../services/storage_service.dart';

/// Add UGC location screen with map pin picker and form
class AddLocationScreen extends StatefulWidget {
  const AddLocationScreen({super.key});

  @override
  State<AddLocationScreen> createState() => _AddLocationScreenState();
}

class _AddLocationScreenState extends State<AddLocationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final MapController _mapController = MapController();

  LocationCategory _category = LocationCategory.tambalBan;
  LatLng? _selectedPosition;
  String? _photoUrl;
  bool _isLoading = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentPosition();
  }

  Future<void> _loadCurrentPosition() async {
    final pos = await LocationService().getCurrentPosition();
    setState(() => _selectedPosition = pos);
  }

  Future<void> _pickAndUploadPhoto() async {
    setState(() => _isUploading = true);
    try {
      final url = await StorageService().pickAndUploadFromGallery();
      if (url != null) {
        setState(() => _photoUrl = url);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal upload foto: $e')),
        );
      }
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _submitLocation() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih lokasi di peta')),
      );
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    setState(() => _isLoading = true);
    try {
      final location = LocationModel(
        name: _nameController.text.trim(),
        lat: _selectedPosition!.latitude,
        lng: _selectedPosition!.longitude,
        category: _category,
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        photoUrl: _photoUrl,
        addedBy: authState.user.id,
        createdAt: DateTime.now(),
      );

      await DatabaseService.instance.execute(
        '''INSERT INTO locations (name, lat, lng, category, address, phone, photo_url, added_by, status, created_at)
           VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'pending', ?)''',
        [
          location.name,
          location.lat,
          location.lng,
          location.category.dbValue,
          location.address,
          location.phone,
          location.photoUrl,
          location.addedBy,
          location.createdAt.toIso8601String(),
        ],
      );

      await DatabaseService.instance.sync();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lokasi berhasil dikirim! Menunggu review admin.'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengirim lokasi: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Lokasi Baru')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Map picker
            SizedBox(
              height: 250,
              child: _selectedPosition != null
                  ? FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _selectedPosition!,
                        initialZoom: 16,
                        onTap: (tapPosition, latLng) {
                          setState(() => _selectedPosition = latLng);
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: ApiConstants.osmTileUrl,
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _selectedPosition!,
                              width: 40,
                              height: 40,
                              child: const Icon(
                                Icons.location_pin,
                                color: AppColors.secondary,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : const Center(child: CircularProgressIndicator()),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Tap peta untuk memilih lokasi',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            // Form
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      validator: (v) => Validators.required(v, 'Nama toko'),
                      decoration: const InputDecoration(
                        labelText: 'Nama Toko / Tempat *',
                        prefixIcon: Icon(Icons.store),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Category selector
                    DropdownButtonFormField<LocationCategory>(
                      value: _category,
                      decoration: const InputDecoration(
                        labelText: 'Kategori *',
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: LocationCategory.values.map((c) {
                        return DropdownMenuItem(
                          value: c,
                          child: Text(c.label),
                        );
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _category = v);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Alamat (opsional)',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'No. Telepon (opsional)',
                        prefixIcon: Icon(Icons.phone),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Photo upload
                    GestureDetector(
                      onTap: _isUploading ? null : _pickAndUploadPhoto,
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.outlineVariant),
                        ),
                        child: _isUploading
                            ? const Center(child: CircularProgressIndicator())
                            : _photoUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      _photoUrl!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.camera_alt,
                                          color: AppColors.outline, size: 32),
                                      SizedBox(height: 8),
                                      Text('Tambah Foto (opsional)'),
                                    ],
                                  ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Submit
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _submitLocation,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.send),
                        label: const Text('Kirim untuk Review'),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
