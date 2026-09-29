import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// First-use explanation shown before authentication.
class OnboardingScreen extends StatefulWidget {
  final Future<void> Function()? onComplete;

  const OnboardingScreen({super.key, this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  var _page = 0;

  static const _pages = [
    (
      icon: Icons.map_outlined,
      title: 'Cari bengkel di sekitar Anda',
      body:
          'Temukan bengkel dan teknisi aktif berdasarkan lokasi atau alamat yang Anda masukkan.',
    ),
    (
      icon: Icons.emergency_outlined,
      title: 'Bantuan darurat yang dapat dilacak',
      body:
          'Minta bantuan saat diperlukan dan ikuti status order tanpa menebak langkah berikutnya.',
    ),
    (
      icon: Icons.receipt_long_outlined,
      title: 'Setujui biaya dengan jelas',
      body:
          'Biaya jasa dan sparepart tambahan ditampilkan untuk persetujuan sebelum pekerjaan dilanjutkan.',
    ),
  ];

  Future<void> _complete() async {
    await widget.onComplete?.call();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _pages.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                    onPressed: _complete, child: const Text('Lewati')),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (page) => setState(() => _page = page),
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return Semantics(
                      label: 'Onboarding ${index + 1} dari ${_pages.length}',
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(page.icon, color: AppColors.primary, size: 72),
                          const SizedBox(height: 32),
                          Text(page.title,
                              style: Theme.of(context).textTheme.headlineMedium,
                              textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          Text(page.body,
                              style: Theme.of(context).textTheme.bodyLarge,
                              textAlign: TextAlign.center),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                    _pages.length,
                    (index) => Container(
                          width: index == _page ? 24 : 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: index == _page
                                ? AppColors.primary
                                : AppColors.outlineVariant,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        )),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isLast
                      ? _complete
                      : () => _controller.nextPage(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                          ),
                  child: Text(isLast ? 'Mulai' : 'Berikutnya'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
