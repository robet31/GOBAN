import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Screen shown after technician submits registration, waiting for admin verification
class VerificationPendingScreen extends StatelessWidget {
  const VerificationPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated hourglass icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.warning.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.hourglass_top,
                size: 60,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Menunggu Verifikasi',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Akun Anda sedang diverifikasi oleh admin.\n'
              'Proses ini biasanya memakan waktu 1x24 jam.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // What we check
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kami akan memverifikasi:',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 12),
                  _checkItem(context, 'Data diri & KTP'),
                  _checkItem(context, 'SIM & STNK'),
                  _checkItem(context, 'Informasi toko/layanan'),
                  _checkItem(context, 'Kelayakan profil'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Anda akan menerima notifikasi push ketika\nakun sudah diverifikasi.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _checkItem(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline,
              size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
