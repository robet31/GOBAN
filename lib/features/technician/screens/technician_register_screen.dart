import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/enums.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/router/routes.dart';
import '../../../core/utils/validators.dart';
import '../../../features/auth/bloc/auth_bloc.dart';
import '../../../features/auth/bloc/auth_state.dart';
import '../../../services/database_service.dart';
import '../../../services/location_service.dart';
import '../../../services/storage_service.dart';

/// Multi-step technician registration form
class TechnicianRegisterScreen extends StatefulWidget {
  const TechnicianRegisterScreen({super.key});

  @override
  State<TechnicianRegisterScreen> createState() =>
      _TechnicianRegisterScreenState();
}

class _TechnicianRegisterScreenState extends State<TechnicianRegisterScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Step 1: Shop info
  final _shopNameController = TextEditingController();
  final _addressController = TextEditingController();
  LatLng? _shopPosition;

  // Step 2: Services
  final List<String> _selectedServices = [];
  final _priceController = TextEditingController(text: '15000');

  // Step 3: Documents
  String? _ktpUrl;
  String? _simUrl;
  String? _stnkUrl;
  String? _shopPhotoUrl;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPosition();
  }

  Future<void> _loadPosition() async {
    final pos = await LocationService().getCurrentPosition();
    setState(() => _shopPosition = pos);
  }

  Future<String?> _uploadDocument(String label) async {
    try {
      return await StorageService().pickAndUploadFromGallery();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal upload $label')),
        );
      }
      return null;
    }
  }

  Future<void> _submitRegistration() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    if (_shopPosition == null) return;

    setState(() => _isLoading = true);

    try {
      await DatabaseService.instance.execute(
        '''INSERT INTO technician_profiles (id, shop_name, lat, lng, address, services, price_estimate, 
           is_online, is_verified, ktp_url, sim_url, stnk_url, shop_photo_url, created_at)
           VALUES (?, ?, ?, ?, ?, ?, ?, 0, 0, ?, ?, ?, ?, ?)''',
        [
          authState.user.id,
          _shopNameController.text.trim(),
          _shopPosition!.latitude,
          _shopPosition!.longitude,
          _addressController.text.trim(),
          _selectedServices.join(','),
          int.tryParse(_priceController.text) ?? 15000,
          _ktpUrl,
          _simUrl,
          _stnkUrl,
          _shopPhotoUrl,
          DateTime.now().toIso8601String(),
        ],
      );

      await DatabaseService.instance.sync();

      if (mounted) {
        context.go(Routes.technicianDashboard);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mendaftar: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Teknisi')),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 2) {
            setState(() => _currentStep++);
          } else {
            _submitRegistration();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep--);
          }
        },
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : details.onStepContinue,
                    child: _isLoading && _currentStep == 2
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Text(_currentStep == 2 ? 'Kirim' : 'Lanjut'),
                  ),
                ),
                if (_currentStep > 0) ...[
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: details.onStepCancel,
                    child: const Text('Kembali'),
                  ),
                ],
              ],
            ),
          );
        },
        steps: [
          // Step 1: Shop Info
          Step(
            title: const Text('Info Toko'),
            isActive: _currentStep >= 0,
            content: Column(
              children: [
                TextFormField(
                  controller: _shopNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Toko',
                    prefixIcon: Icon(Icons.store),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Alamat',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                ),
                const SizedBox(height: 16),
                // Map pin
                SizedBox(
                  height: 200,
                  child: _shopPosition != null
                      ? FlutterMap(
                          options: MapOptions(
                            initialCenter: _shopPosition!,
                            initialZoom: 15,
                            onTap: (_, latLng) {
                              setState(() => _shopPosition = latLng);
                            },
                          ),
                          children: [
                            TileLayer(urlTemplate: ApiConstants.osmTileUrl),
                            MarkerLayer(markers: [
                              Marker(
                                point: _shopPosition!,
                                child: const Icon(Icons.location_pin,
                                    color: AppColors.primary, size: 40),
                              ),
                            ]),
                          ],
                        )
                      : const Center(child: CircularProgressIndicator()),
                ),
              ],
            ),
          ),
          // Step 2: Services
          Step(
            title: const Text('Layanan & Tarif'),
            isActive: _currentStep >= 1,
            content: Column(
              children: [
                ...ServiceType.values
                    .where((s) => s != ServiceType.other)
                    .map((s) => CheckboxListTile(
                          title: Text(s.label),
                          subtitle: Text('Estimasi ${s.defaultPrice}'),
                          value: _selectedServices.contains(s.dbValue),
                          onChanged: (v) {
                            setState(() {
                              if (v == true) {
                                _selectedServices.add(s.dbValue);
                              } else {
                                _selectedServices.remove(s.dbValue);
                              }
                            });
                          },
                        )),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Harga Dasar (Rp)',
                    prefixIcon: Icon(Icons.payments),
                  ),
                ),
              ],
            ),
          ),
          // Step 3: Documents
          Step(
            title: const Text('Dokumen'),
            isActive: _currentStep >= 2,
            content: Column(
              children: [
                _DocumentUploadTile(
                  label: 'KTP',
                  url: _ktpUrl,
                  onTap: () async {
                    final url = await _uploadDocument('KTP');
                    if (url != null) setState(() => _ktpUrl = url);
                  },
                ),
                _DocumentUploadTile(
                  label: 'SIM',
                  url: _simUrl,
                  onTap: () async {
                    final url = await _uploadDocument('SIM');
                    if (url != null) setState(() => _simUrl = url);
                  },
                ),
                _DocumentUploadTile(
                  label: 'STNK',
                  url: _stnkUrl,
                  onTap: () async {
                    final url = await _uploadDocument('STNK');
                    if (url != null) setState(() => _stnkUrl = url);
                  },
                ),
                _DocumentUploadTile(
                  label: 'Foto Toko',
                  url: _shopPhotoUrl,
                  onTap: () async {
                    final url = await _uploadDocument('Foto Toko');
                    if (url != null) setState(() => _shopPhotoUrl = url);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentUploadTile extends StatelessWidget {
  final String label;
  final String? url;
  final VoidCallback onTap;

  const _DocumentUploadTile({
    required this.label,
    this.url,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: url != null
              ? AppColors.success.withAlpha(20)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          url != null ? Icons.check_circle : Icons.upload_file,
          color: url != null ? AppColors.success : AppColors.outline,
        ),
      ),
      title: Text(label),
      subtitle: Text(url != null ? 'Berhasil diupload' : 'Belum diupload'),
      trailing: TextButton(
        onPressed: onTap,
        child: Text(url != null ? 'Ganti' : 'Upload'),
      ),
    );
  }
}
