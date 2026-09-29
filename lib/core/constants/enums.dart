// Core Constants - Enums
// All enums used across the Goban application

/// User roles in the system
enum UserRole {
  customer,
  technician,
  admin;

  String get label {
    switch (this) {
      case UserRole.customer:
        return 'Customer';
      case UserRole.technician:
        return 'Teknisi';
      case UserRole.admin:
        return 'Admin';
    }
  }

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (e) => e.name == value,
      orElse: () => UserRole.customer,
    );
  }
}

/// Order status flow: waiting → accepted → ongoing → completed
enum OrderStatus {
  waiting,
  accepted,
  ongoing,
  completed,
  cancelled;

  String get label {
    switch (this) {
      case OrderStatus.waiting:
        return 'Menunggu';
      case OrderStatus.accepted:
        return 'Diterima';
      case OrderStatus.ongoing:
        return 'Sedang Dikerjakan';
      case OrderStatus.completed:
        return 'Selesai';
      case OrderStatus.cancelled:
        return 'Dibatalkan';
    }
  }

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => OrderStatus.waiting,
    );
  }
}

/// Payment methods
enum PaymentMethod {
  cash,
  transfer;

  String get label {
    switch (this) {
      case PaymentMethod.cash:
        return 'Tunai';
      case PaymentMethod.transfer:
        return 'Transfer';
    }
  }

  static PaymentMethod fromString(String value) {
    return PaymentMethod.values.firstWhere(
      (e) => e.name == value,
      orElse: () => PaymentMethod.cash,
    );
  }
}

/// Location moderation status
enum LocationStatus {
  pending,
  approved,
  rejected;

  String get label {
    switch (this) {
      case LocationStatus.pending:
        return 'Menunggu Review';
      case LocationStatus.approved:
        return 'Disetujui';
      case LocationStatus.rejected:
        return 'Ditolak';
    }
  }

  static LocationStatus fromString(String value) {
    return LocationStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => LocationStatus.pending,
    );
  }
}

/// Service types offered by technicians
enum ServiceType {
  tambalBan,
  gantiBan,
  gantiOli,
  servisMesin,
  other;

  String get label {
    switch (this) {
      case ServiceType.tambalBan:
        return 'Tambal Ban';
      case ServiceType.gantiBan:
        return 'Ganti Ban';
      case ServiceType.gantiOli:
        return 'Ganti Oli';
      case ServiceType.servisMesin:
        return 'Servis Mesin';
      case ServiceType.other:
        return 'Lainnya';
    }
  }

  /// Default estimated price in Rupiah
  int get defaultPrice {
    switch (this) {
      case ServiceType.tambalBan:
        return 15000;
      case ServiceType.gantiBan:
        return 30000;
      case ServiceType.gantiOli:
        return 45000;
      case ServiceType.servisMesin:
        return 100000;
      case ServiceType.other:
        return 0;
    }
  }

  String get dbValue {
    switch (this) {
      case ServiceType.tambalBan:
        return 'tambal_ban';
      case ServiceType.gantiBan:
        return 'ganti_ban';
      case ServiceType.gantiOli:
        return 'ganti_oli';
      case ServiceType.servisMesin:
        return 'servis_mesin';
      case ServiceType.other:
        return 'other';
    }
  }

  static ServiceType fromDbValue(String value) {
    switch (value) {
      case 'tambal_ban':
        return ServiceType.tambalBan;
      case 'ganti_ban':
        return ServiceType.gantiBan;
      case 'ganti_oli':
        return ServiceType.gantiOli;
      case 'servis_mesin':
        return ServiceType.servisMesin;
      default:
        return ServiceType.other;
    }
  }
}

/// Location categories for UGC
enum LocationCategory {
  tambalBan,
  serviceMotor,
  kedua;

  String get label {
    switch (this) {
      case LocationCategory.tambalBan:
        return 'Tambal Ban';
      case LocationCategory.serviceMotor:
        return 'Service Motor';
      case LocationCategory.kedua:
        return 'Keduanya';
    }
  }

  String get dbValue {
    switch (this) {
      case LocationCategory.tambalBan:
        return 'tambal_ban';
      case LocationCategory.serviceMotor:
        return 'service_motor';
      case LocationCategory.kedua:
        return 'kedua';
    }
  }

  static LocationCategory fromDbValue(String value) {
    switch (value) {
      case 'tambal_ban':
        return LocationCategory.tambalBan;
      case 'service_motor':
        return LocationCategory.serviceMotor;
      case 'kedua':
        return LocationCategory.kedua;
      default:
        return LocationCategory.kedua;
    }
  }
}
