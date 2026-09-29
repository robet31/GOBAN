/// Form validation utilities
class Validators {
  Validators._();

  /// Validate email address
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email wajib diisi';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format email tidak valid';
    }
    return null;
  }

  /// Validate phone number (Indonesian format)
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nomor HP wajib diisi';
    }
    final cleaned = value.replaceAll(RegExp(r'[^\d+]'), '');
    // Accept: 08xx, +628xx, 628xx
    final phoneRegex = RegExp(r'^(\+62|62|0)8[1-9][0-9]{7,10}$');
    if (!phoneRegex.hasMatch(cleaned)) {
      return 'Nomor HP tidak valid (contoh: 08xxxxxxxxxx)';
    }
    return null;
  }

  /// Validate password
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password wajib diisi';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  /// Validate password confirmation
  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password wajib diisi';
    }
    if (value != password) {
      return 'Password tidak cocok';
    }
    return null;
  }

  /// Validate required field
  static String? required(String? value, [String fieldName = 'Field ini']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName wajib diisi';
    }
    return null;
  }

  /// Validate full name
  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama lengkap wajib diisi';
    }
    if (value.trim().length < 3) {
      return 'Nama minimal 3 karakter';
    }
    return null;
  }

  /// Validate price (must be positive number)
  static String? price(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Harga wajib diisi';
    }
    final parsed = int.tryParse(value.replaceAll(RegExp(r'[^\d]'), ''));
    if (parsed == null || parsed <= 0) {
      return 'Harga harus berupa angka positif';
    }
    return null;
  }

  /// Validate shop name
  static String? shopName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama toko wajib diisi';
    }
    if (value.trim().length < 3) {
      return 'Nama toko minimal 3 karakter';
    }
    return null;
  }

  /// Validate rating (1-5)
  static String? ratingValue(double? value) {
    if (value == null || value == 0) {
      return 'Rating wajib diisi';
    }
    if (value < 1 || value > 5) {
      return 'Rating harus antara 1-5';
    }
    return null;
  }
}
