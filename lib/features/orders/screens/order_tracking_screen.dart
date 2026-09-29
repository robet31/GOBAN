import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/enums.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/error_screen.dart';
import '../../../models/order_model.dart';
import '../bloc/order_bloc.dart';
import '../bloc/order_event.dart';

/// Order tracking screen with live technician position on map
class OrderTrackingScreen extends StatefulWidget {
  final String orderId;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    context.read<OrderBloc>().add(OrderLoadDetail(widget.orderId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tracking Order')),
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state is OrderLoading) {
            return const Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text('Memuat status order...')
            ]));
          }
          if (state is OrderDetailLoaded) {
            return _buildContent(state.order);
          }
          if (state is OrderError) {
            return ErrorScreen(
                message: state.message,
                onRetry: () => context
                    .read<OrderBloc>()
                    .add(OrderLoadDetail(widget.orderId)));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(OrderModel order) {
    final customerPos = LatLng(order.customerLat, order.customerLng);

    return Column(
      children: [
        // Map section
        Expanded(
          flex: 3,
          child: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: customerPos,
                  initialZoom: 15,
                ),
                children: [
                  TileLayer(urlTemplate: ApiConstants.osmTileUrl),
                  MarkerLayer(
                    markers: [
                      // Customer marker
                      Marker(
                        point: customerPos,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_pin,
                          color: AppColors.primary,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: Row(
                    children: [
                      StatusBadge(status: order.status),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _statusMessage(order),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Positioned(
                left: 16,
                bottom: 16,
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Text('Lokasi teknisi belum dibagikan secara live'),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Info panel
        Expanded(
          flex: 2,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Technician info
                  if (order.technicianName != null) ...[
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.primary.withAlpha(30),
                          child: order.technicianAvatar != null
                              ? ClipOval(
                                  child: Image.network(
                                    order.technicianAvatar!,
                                    fit: BoxFit.cover,
                                    width: 48,
                                    height: 48,
                                  ),
                                )
                              : Text(
                                  order.technicianName![0].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.technicianName!,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              if (order.technicianRating != null)
                                Row(
                                  children: [
                                    const Icon(Icons.star,
                                        size: 14, color: AppColors.warning),
                                    const SizedBox(width: 4),
                                    Text(
                                      order.technicianRating!
                                          .toStringAsFixed(1),
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        // Contact buttons
                        if (order.technicianPhone != null) ...[
                          IconButton(
                            onPressed: () {
                              // Open phone
                            },
                            icon: const Icon(Icons.phone,
                                color: AppColors.primary),
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.primary.withAlpha(20),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        IconButton(
                          onPressed: () {
                            // Open chat
                          },
                          icon:
                              const Icon(Icons.chat, color: AppColors.primary),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.primary.withAlpha(20),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                  ],
                  // Order details
                  Text('Perjalanan order',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  _buildTimeline(context, order),
                  const Divider(height: 28),
                  _detailRow(context, 'Layanan', order.serviceLabel),
                  if (order.price != null)
                    _detailRow(
                      context,
                      'Harga',
                      Formatters.rupiah(order.price!),
                    ),
                  if (order.distanceKm != null)
                    _detailRow(
                      context,
                      'Jarak',
                      Formatters.distanceKm(order.distanceKm!),
                    ),
                  if (order.paymentMethod != null)
                    _detailRow(
                      context,
                      'Pembayaran',
                      order.paymentMethod!.label,
                    ),
                  if (order.customerAddress != null)
                    _detailRow(
                      context,
                      'Lokasi',
                      order.customerAddress!,
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _detailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.onSurfaceVariant),
          ),
          Flexible(
            child: Text(
              value,
              style: Theme.of(context).textTheme.titleSmall,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  String _statusMessage(OrderModel order) {
    switch (order.status) {
      case OrderStatus.waiting:
        return 'Mencari teknisi terdekat...';
      case OrderStatus.accepted:
        return 'Teknisi sedang menuju lokasi Anda';
      case OrderStatus.ongoing:
        return 'Servis sedang dikerjakan';
      case OrderStatus.completed:
        return 'Servis selesai!';
      case OrderStatus.cancelled:
        return 'Order dibatalkan';
    }
  }

  Widget _buildTimeline(BuildContext context, OrderModel order) {
    final steps = [
      OrderStatus.waiting,
      OrderStatus.accepted,
      OrderStatus.ongoing,
      OrderStatus.completed
    ];
    final currentIndex = steps.indexOf(order.status);
    return Column(
      children: steps.map((status) {
        final index = steps.indexOf(status);
        final reached = currentIndex >= index;
        final timestamp = status == OrderStatus.accepted
            ? order.acceptedAt
            : status == OrderStatus.completed
                ? order.completedAt
                : index == 0
                    ? order.createdAt
                    : null;
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(reached ? Icons.check_circle : Icons.radio_button_unchecked,
              color: reached ? AppColors.primary : AppColors.outline, size: 20),
          const SizedBox(width: 8),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(timestamp == null
                ? status.label
                : '${status.label} · ${Formatters.dateTimeIndonesian(timestamp)}'),
          )),
        ]);
      }).toList(),
    );
  }
}
