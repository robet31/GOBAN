import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/constants/enums.dart';
import '../../../models/order_model.dart';
import '../../../services/payment_service.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import '../bloc/order_bloc.dart';
import '../bloc/order_event.dart';
import '../widgets/review_form.dart';

/// Payment confirmation and review screen
class PaymentScreen extends StatefulWidget {
  final String orderId;

  const PaymentScreen({super.key, required this.orderId});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isConfirmed = false;
  bool _isSubmitting = false;
  bool _isPaying = false;
  String? _checkoutUrl;

  @override
  void initState() {
    super.initState();
    context.read<OrderBloc>().add(OrderLoadDetail(widget.orderId));
  }

  Future<void> _processIpaymuPayment(OrderModel order) async {
    setState(() => _isPaying = true);

    try {
      final authState = context.read<AuthBloc>().state;
      String customerName = 'Customer GOBAN';
      String customerEmail = 'customer@goban.my.id';
      String customerPhone = '08123456789';

      if (authState is AuthAuthenticated) {
        customerName = authState.user.fullName;
        customerEmail = authState.user.email;
        customerPhone = authState.user.phone ?? '08123456789';
      }

      final url = await PaymentService.instance.createCheckoutSession(
        orderId: order.id,
        amount: order.price ?? 15000,
        customerName: customerName,
        customerPhone: customerPhone,
        customerEmail: customerEmail,
      );

      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        setState(() {
          _checkoutUrl = url;
          _isPaying = false;
        });
      } else {
        throw Exception('Tidak dapat membuka link pembayaran di peramban');
      }
    } catch (e) {
      setState(() => _isPaying = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat pembayaran: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pembayaran')),
      body: BlocConsumer<OrderBloc, OrderState>(
        listener: (context, state) {
          if (state is OrderReviewSubmitted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Review berhasil dikirim.'),
                backgroundColor: AppColors.success,
              ),
            );
            context.pop();
          } else if (state is OrderError && _isSubmitting) {
            setState(() => _isSubmitting = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, state) {
          if (state is OrderLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is OrderDetailLoaded) {
            return _buildContent(state.order);
          }
          if (state is OrderError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  state.message,
                  style: const TextStyle(color: AppColors.error),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(OrderModel order) {
    final isTransfer = order.paymentMethod == PaymentMethod.transfer;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Payment summary card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Text(
                  'Total Pembayaran',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  order.price != null ? Formatters.rupiah(order.price!) : '-',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.paymentMethod?.label ?? 'Tunai',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Detail breakdown
          Text(
            'Rincian',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          _detailRow('Layanan', order.serviceLabel),
          if (order.technicianName != null)
            _detailRow('Teknisi', order.technicianName!),
          if (order.distanceKm != null)
            _detailRow('Jarak', Formatters.distanceKm(order.distanceKm!)),
          _detailRow('Waktu', Formatters.dateTimeIndonesian(order.createdAt)),
          const Divider(height: 24),
          _detailRow(
            'Total',
            order.price != null ? Formatters.rupiah(order.price!) : '-',
            isBold: true,
          ),
          const SizedBox(height: 32),
          // Confirm payment button
          if (!_isConfirmed) ...[
            if (isTransfer) ...[
              if (_checkoutUrl == null) ...[
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed:
                        _isPaying ? null : () => _processIpaymuPayment(order),
                    icon: _isPaying
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.payment),
                    label: Text(
                      _isPaying
                          ? 'Membuat Tagihan...'
                          : 'Bayar Sekarang (iPaymu)',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ] else ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary.withAlpha(40)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.hourglass_empty,
                          color: AppColors.primary, size: 40),
                      const SizedBox(height: 12),
                      const Text(
                        'Menunggu Pembayaran iPaymu',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Halaman pembayaran telah dibuka di peramban Anda. Silakan lakukan pembayaran simulasi.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                final uri = Uri.parse(_checkoutUrl!);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri,
                                      mode: LaunchMode.externalApplication);
                                }
                              },
                              child: const Text('Buka Ulang Link'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() => _isConfirmed = true);
                              },
                              child: const Text('Saya Sudah Bayar'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ] else ...[
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() => _isConfirmed = true);
                  },
                  child: const Text(
                    'Konfirmasi Pembayaran',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ] else ...[
            // Show review form after confirmation
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.success.withAlpha(10),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.success.withAlpha(40)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle,
                      color: AppColors.success, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Pembayaran dikonfirmasi!',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.success,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ReviewForm(
              isLoading: _isSubmitting,
              onSubmit: (rating, comment) {
                final authState = context.read<AuthBloc>().state;
                if (authState is! AuthAuthenticated) return;
                setState(() => _isSubmitting = true);
                context.read<OrderBloc>().add(OrderSubmitReview(
                      orderId: order.id,
                      reviewerId: authState.user.id,
                      rating: rating,
                      comment: comment,
                    ));
              },
            ),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isBold
                ? Theme.of(context).textTheme.titleMedium
                : Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: isBold
                ? Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                    )
                : Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
