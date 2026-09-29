import 'package:intl/intl.dart';

/// Formatting utilities for Indonesian locale
class Formatters {
  Formatters._();

  /// Format number as Indonesian Rupiah currency
  /// Example: 15000 → "Rp 15.000"
  static String rupiah(int amount) {
    final formatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  /// Format price range
  /// Example: "Rp 15.000 - Rp 30.000"
  static String rupiahRange(int min, int max) {
    return '${rupiah(min)} - ${rupiah(max)}';
  }

  /// Format distance in km
  /// Example: 2.345 → "2.3 km"
  static String distanceKm(double km) {
    if (km < 1) {
      return '${(km * 1000).round()} m';
    }
    return '${km.toStringAsFixed(1)} km';
  }

  /// Format date as Indonesian format
  /// Example: "24 Mei 2024"
  static String dateIndonesian(DateTime date) {
    final formatter = DateFormat('d MMMM yyyy', 'id');
    return formatter.format(date);
  }

  /// Format date and time
  /// Example: "24 Mei 2024, 14:30"
  static String dateTimeIndonesian(DateTime date) {
    final formatter = DateFormat('d MMMM yyyy, HH:mm', 'id');
    return formatter.format(date);
  }

  /// Format time only
  /// Example: "14:30"
  static String timeOnly(DateTime date) {
    final formatter = DateFormat('HH:mm', 'id');
    return formatter.format(date);
  }

  /// Format relative time
  /// Example: "5 menit lalu", "2 jam lalu", "Kemarin"
  static String relativeTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) {
      return 'Baru saja';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} menit lalu';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} jam lalu';
    } else if (diff.inDays == 1) {
      return 'Kemarin';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} hari lalu';
    } else if (diff.inDays < 30) {
      return '${(diff.inDays / 7).floor()} minggu lalu';
    } else {
      return dateIndonesian(date);
    }
  }

  /// Format ETA in minutes
  /// Example: 5.2 → "5 menit"
  static String etaMinutes(double minutes) {
    if (minutes < 1) {
      return '< 1 menit';
    } else if (minutes < 60) {
      return '${minutes.round()} menit';
    } else {
      final hours = (minutes / 60).floor();
      final mins = (minutes % 60).round();
      return '$hours jam $mins menit';
    }
  }

  /// Format rating with review count
  /// Example: "4.5 (30 ulasan)"
  static String rating(double avg, int count) {
    return '${avg.toStringAsFixed(1)} ($count ulasan)';
  }

  /// Format phone number for display
  /// Example: "081234567890" → "0812-3456-7890"
  static String phoneNumber(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length >= 12) {
      return '${cleaned.substring(0, 4)}-${cleaned.substring(4, 8)}-${cleaned.substring(8)}';
    } else if (cleaned.length >= 10) {
      return '${cleaned.substring(0, 4)}-${cleaned.substring(4, 7)}-${cleaned.substring(7)}';
    }
    return phone;
  }

  /// Format order count
  /// Example: 50 → "50x order"
  static String orderCount(int count) {
    return '${count}x order';
  }
}
