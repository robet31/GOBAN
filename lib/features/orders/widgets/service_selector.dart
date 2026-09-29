import 'package:flutter/material.dart';
import '../../../core/constants/enums.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';

/// Service type selector widget for order creation
class ServiceSelector extends StatelessWidget {
  final ServiceType? selected;
  final ValueChanged<ServiceType> onChanged;

  const ServiceSelector({
    super.key,
    this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilih Layanan',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        ...ServiceType.values
            .where((s) => s != ServiceType.other)
            .map((service) => _ServiceTile(
                  service: service,
                  isSelected: selected == service,
                  onTap: () => onChanged(service),
                )),
      ],
    );
  }
}

class _ServiceTile extends StatelessWidget {
  final ServiceType service;
  final bool isSelected;
  final VoidCallback onTap;

  const _ServiceTile({
    required this.service,
    required this.isSelected,
    required this.onTap,
  });

  IconData get _icon {
    switch (service) {
      case ServiceType.tambalBan:
        return Icons.tire_repair;
      case ServiceType.gantiBan:
        return Icons.autorenew;
      case ServiceType.gantiOli:
        return Icons.opacity;
      case ServiceType.servisMesin:
        return Icons.build;
      default:
        return Icons.miscellaneous_services;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withAlpha(15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.outlineVariant,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withAlpha(20)
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _icon,
                  color: isSelected ? AppColors.primary : AppColors.outline,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.label,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.onSurface,
                      ),
                    ),
                    Text(
                      'Estimasi ${Formatters.rupiah(service.defaultPrice)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
