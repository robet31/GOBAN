import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/router/routes.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/error_screen.dart';
import '../../../services/location_service.dart';
import '../bloc/map_bloc.dart';
import '../bloc/map_event.dart';
import '../widgets/pulsing_dot.dart';

/// Main map screen with markers, FAB, and bottom sheet
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    context.read<MapBloc>().add(const MapLoadMarkers());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Goban'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<MapBloc>().add(const MapLoadMarkers()),
          ),
        ],
      ),
      body: BlocBuilder<MapBloc, MapState>(
        builder: (context, state) {
          if (state is MapLoading) {
            return const _MapLoadingState();
          }
          if (state is MapError) {
            return ErrorScreen(
              message: state.message,
              onRetry: () =>
                  context.read<MapBloc>().add(const MapLoadMarkers()),
            );
          }
          if (state is MapLoaded) {
            final bloc = context.read<MapBloc>();
            final filteredMarkers = bloc.getFilteredMarkers(state);
            return Stack(
              children: [
                _buildMap(state, filteredMarkers),
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: _LocationNotice(
                      onUseDeviceLocation: _useDeviceLocation,
                      onManualLocation: _showManualLocationDialog),
                ),
                if (filteredMarkers.isEmpty)
                  const Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Card(
                        child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                                'Tidak ada penyedia pada filter ini. Perluas jarak atau ubah filter untuk melihat pilihan lain.'))),
                  ),
                if (state.selectedMarker != null)
                  _buildMarkerDetailSheet(state.selectedMarker!),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(Routes.addLocation),
        tooltip: 'Tambah titik bengkel',
        icon: const Icon(Icons.add_location_alt),
        label: const Text('Tambah titik'),
      ),
    );
  }

  Future<void> _useDeviceLocation() async {
    final granted = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Gunakan lokasi perangkat?'),
            content: const Text(
                'Lokasi digunakan untuk mengurutkan penyedia terdekat. Anda tetap dapat memasukkan alamat secara manual.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Nanti')),
              ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Lanjutkan')),
            ],
          ),
        ) ??
        false;
    if (!granted) return;
    final position =
        await LocationService().getCurrentPosition(requestPermission: true);
    if (!mounted) return;
    context.read<MapBloc>().add(MapLocationUpdated(position));
    _mapController.move(position, ApiConstants.defaultZoom);
  }

  Future<void> _showManualLocationDialog() async {
    final controller = TextEditingController();
    final address = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Masukkan lokasi'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          decoration:
              const InputDecoration(labelText: 'Kota, alamat, atau patokan'),
          onSubmitted: (value) => Navigator.pop(dialogContext, value),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal')),
          ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, controller.text),
              child: const Text('Gunakan lokasi ini')),
        ],
      ),
    );
    controller.dispose();
    if (address == null || address.trim().isEmpty || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'Lokasi pencarian: ${address.trim()}. Pilih titik pasti saat membuat order.')));
  }

  Widget _buildMap(MapLoaded state, List<MarkerData> markers) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: state.userPosition,
        initialZoom: ApiConstants.defaultZoom,
        onTap: (_, __) {
          // Deselect marker on map tap
          if (state.selectedMarker != null) {
            context.read<MapBloc>().add(const MapFilterChanged(MapFilter()));
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: ApiConstants.osmTileUrl,
          userAgentPackageName: ApiConstants.userAgent,
        ),
        MarkerLayer(
          markers: [
            // User position marker
            Marker(
              point: state.userPosition,
              width: 24,
              height: 24,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withAlpha(80),
                      blurRadius: 10,
                      spreadRadius: 3,
                    ),
                  ],
                ),
              ),
            ),
            // Technician and location markers
            ...markers.map((m) => _buildMarker(m)),
          ],
        ),
      ],
    );
  }

  Marker _buildMarker(MarkerData data) {
    return Marker(
      point: data.position,
      width: 44,
      height: 44,
      child: GestureDetector(
        onTap: () {
          context.read<MapBloc>().add(MapMarkerTapped(data));
        },
        child: data.type == MarkerType.technician
            ? PulsingDot(size: 36, color: AppColors.info)
            : Container(
                decoration: BoxDecoration(
                  color: data.type == MarkerType.crowdsourced
                      ? AppColors.secondary
                      : AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(40),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 22,
                ),
              ),
      ),
    );
  }

  Widget _buildMarkerDetailSheet(MarkerData marker) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppColors.elevatedShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                // Photo placeholder
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withAlpha(40),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: marker.photoUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            marker.photoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.store,
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      : const Icon(Icons.store, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        marker.name,
                        style: Theme.of(context).textTheme.titleLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (marker.rating != null)
                        Row(
                          children: [
                            const Icon(Icons.star,
                                size: 16, color: AppColors.warning),
                            const SizedBox(width: 4),
                            Text(
                              Formatters.rating(
                                marker.rating!,
                                marker.reviewCount ?? 0,
                              ),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                // Close button
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    context
                        .read<MapBloc>()
                        .add(const MapFilterChanged(MapFilter()));
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Info row
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                if (marker.distanceKm != null)
                  _infoChip(
                    Icons.location_on,
                    Formatters.distanceKm(marker.distanceKm!),
                  ),
                if (marker.priceEstimate != null)
                  _infoChip(
                    Icons.payments,
                    'Mulai ${Formatters.rupiah(marker.priceEstimate!)}',
                  ),
                if (marker.isOnline == true)
                  _infoChip(Icons.circle, 'Online', color: AppColors.success),
              ],
            ),
            const SizedBox(height: 16),
            // Services
            if (marker.services != null && marker.services!.isNotEmpty) ...[
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: marker.services!.map((s) {
                  return Chip(
                    label: Text(s, style: const TextStyle(fontSize: 11)),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
            // Order button
            if (marker.type == MarkerType.technician)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.push(
                      Routes.createOrder,
                      extra: marker.technicianProfile,
                    );
                  },
                  icon: const Icon(Icons.shopping_cart),
                  label: const Text('Pesan Sekarang'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, {Color? color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color ?? AppColors.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
        ),
      ],
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _FilterSheet(),
    );
  }
}

class _MapLoadingState extends StatelessWidget {
  const _MapLoadingState();

  @override
  Widget build(BuildContext context) => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Memuat penyedia di sekitar Anda...')
          ],
        ),
      );
}

class _LocationNotice extends StatelessWidget {
  final VoidCallback onUseDeviceLocation;
  final VoidCallback onManualLocation;

  const _LocationNotice(
      {required this.onUseDeviceLocation, required this.onManualLocation});

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(children: [
            const Icon(Icons.location_off_outlined, color: AppColors.secondary),
            const SizedBox(width: 8),
            const Expanded(
                child: Text(
                    'Gunakan lokasi untuk hasil terdekat, atau cari dengan alamat.')),
            IconButton(
                onPressed: onManualLocation,
                tooltip: 'Masukkan lokasi manual',
                icon: const Icon(Icons.edit_location_alt_outlined)),
            IconButton(
                onPressed: onUseDeviceLocation,
                tooltip: 'Gunakan lokasi perangkat',
                icon: const Icon(Icons.my_location)),
          ]),
        ),
      );
}

class _FilterSheet extends StatefulWidget {
  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  double _maxDistance = 10;
  double _minRating = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filter', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),
          Text('Jarak Maksimal: ${_maxDistance.toStringAsFixed(0)} km'),
          Slider(
            value: _maxDistance,
            min: 1,
            max: 20,
            divisions: 19,
            onChanged: (v) => setState(() => _maxDistance = v),
          ),
          const SizedBox(height: 16),
          Text('Rating Minimal: ${_minRating.toStringAsFixed(1)}'),
          Slider(
            value: _minRating,
            min: 0,
            max: 5,
            divisions: 10,
            onChanged: (v) => setState(() => _minRating = v),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.read<MapBloc>().add(MapFilterChanged(MapFilter(
                      maxDistanceKm: _maxDistance,
                      minRating: _minRating > 0 ? _minRating : null,
                    )));
                Navigator.pop(context);
              },
              child: const Text('Terapkan Filter'),
            ),
          ),
        ],
      ),
    );
  }
}
