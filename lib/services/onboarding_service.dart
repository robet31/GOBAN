import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Stores only the first-use completion flag; session routing remains in AuthBloc.
class OnboardingService {
  static const _completionKey = 'onboarding_completed';
  final FlutterSecureStorage _storage;

  OnboardingService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<bool> get isCompleted async =>
      await _storage.read(key: _completionKey) == 'true';

  Future<void> complete() => _storage.write(key: _completionKey, value: 'true');
}
