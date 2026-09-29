import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/enums.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/technician_profile.dart';
import '../../../services/location_service.dart';
import '../../../services/geocoding_service.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import '../bloc/order_bloc.dart';
import '../bloc/order_event.dart';

/// Create order screen with service selection and location confirmation
class CreateOrderScreen extends StatefulWidget {
  final TechnicianProfile? technician;

  const CreateOrderScreen({super.key, this.technician});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  ServiceType _selectedService = ServiceType.tambalBan;
  PaymentMethod _paymentMethod = PaymentMethod.cash;
  final _descriptionController = TextEditingController();
  final _manualAddressController = TextEditingController();
  String? _customerAddress;
  double? _customerLat;
  double? _customerLng;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    final pos = await LocationService().getCurrentPosition();
    final address = await GeocodingService().reverseGeocode(
      pos.latitude,
      pos.longitude,
    );
    setState(() {
      _customerLat = pos.latitude;
      _customerLng = pos.longitude;
      _customerAddress = address;
    });
  }

  Future<void> _useDeviceLocation() async {
    setState(() => _isLoading = true);
    final position =
        await LocationService().getCurrentPosition(requestPermission: true);
    final address = await GeocodingService()
        .reverseGeocode(position.latitude, position.longitude);
    if (mounted) {
      setState(() {
        _customerLat = position.latitude;
        _customerLng = position.longitude;
        _customerAddress = address;
        _isLoading = false;
      });
    }
  }

  void _createOrder() {
    if (_customerLat == null || _customerLng == null) return;
    if (widget.technician == null) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    setState(() => _isLoading = true);

    context.read<OrderBloc>().add(OrderCreate(
          customerId: authState.user.id,
          technicianId: widget.technician!.id,
          serviceType: _selectedService.dbValue,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          customerLat: _customerLat!,
          customerLng: _customerLng!,
          customerAddress: _customerAddress,
          price: _selectedService.defaultPrice,
          paymentMethod: _paymentMethod,
        ));
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _manualAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Order')),
      body: BlocListener<OrderBloc, OrderState>(
        listener: (context, state) {
          if (state is OrderCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Order berhasil dibuat!'),
                backgroundColor: AppColors.success,
              ),
            );
            context.go(Routes.orderTrackingPath(state.order.id));
          } else if (state is OrderError) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Technician info
              if (widget.technician != null) _buildTechnicianCard(),
              const SizedBox(height: 24),
              // Service selection
              Text(
                'Pilih Layanan',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              ...ServiceType.values
                  .where((s) => s != ServiceType.other)
                  .map((s) => _buildServiceOption(s)),
              const SizedBox(height: 24),
              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Detail Kerusakan (opsional)',
                  hintText: 'Contoh: ban depan bocor, lokasi di pinggir jalan',
                  prefixIcon: Icon(Icons.description),
                ),
              ),
              const SizedBox(height: 24),
              // Location
              Text(
                'Lokasi Anda',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _customerAddress ?? 'Mencari lokasi...',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _useDeviceLocation,
                icon: const Icon(Icons.my_location),
                label: const Text('Gunakan lokasi perangkat'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _manualAddressController,
                onChanged: (value) {
                  if (value.trim().isNotEmpty) {
                    _customerAddress = value.trim();
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Atau isi alamat/patokan manual',
                  hintText: 'Contoh: depan minimarket, Jalan Merdeka 12',
                  prefixIcon: Icon(Icons.edit_location_alt_outlined),
                ),
              ),
              const SizedBox(height: 24),
              // Payment
              Text(
                'Metode Pembayaran',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _PaymentOptionCard(
                      icon: Icons.money,
                      label: 'Tunai',
                      isSelected: _paymentMethod == PaymentMethod.cash,
                      onTap: () =>
                          setState(() => _paymentMethod = PaymentMethod.cash),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PaymentOptionCard(
                      icon: Icons.account_balance,
                      label: 'Transfer',
                      isSelected: _paymentMethod == PaymentMethod.transfer,
                      onTap: () => setState(
                          () => _paymentMethod = PaymentMethod.transfer),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Summary
              _buildSummary(),
              const SizedBox(height: 16),
              // Order button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createOrder,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Pesan Sekarang',
                          style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTechnicianCard() {
    final tech = widget.technician!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(40),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tech.shopName ?? 'Teknisi',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: AppColors.warning),
                    const SizedBox(width: 4),
                    Text(
                      '${tech.ratingAvg.toStringAsFixed(1)} · ${Formatters.orderCount(tech.totalOrders)}',
                      style: TextStyle(
                        color: Colors.white.withAlpha(200),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceOption(ServiceType service) {
    final isSelected = _selectedService == service;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => setState(() => _selectedService = service),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withAlpha(15)
                : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.outlineVariant,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: isSelected ? AppColors.primary : AppColors.outline,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    service.label,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      color:
                          isSelected ? AppColors.primary : AppColors.onSurface,
                    ),
                  ),
                ],
              ),
              Text(
                Formatters.rupiah(service.defaultPrice),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.primary : AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _summaryRow('Layanan', _selectedService.label),
          const Divider(),
          _summaryRow('Estimasi jasa dasar',
              Formatters.rupiah(_selectedService.defaultPrice)),
          const Divider(),
          _summaryRow('Biaya panggilan', 'Dikonfirmasi sebelum order diterima'),
          const Divider(),
          _summaryRow('Pembayaran', _paymentMethod.label),
          const SizedBox(height: 12),
          const Text(
              'Sparepart tidak termasuk estimasi ini. Sparepart disediakan mitra/teknisi dan hanya dipasang setelah detail serta harga disetujui.',
              style: TextStyle(color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.primary,
                ),
          ),
        ],
      ),
    );
  }
}

class _PaymentOptionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentOptionCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withAlpha(15)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                color: isSelected ? AppColors.primary : AppColors.outline,
                size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.primary : AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
