// lib/models/catering_order_model.dart
class CateringOrder {
  final String pesananId;
  final String userId;
  final String? reservasiId;
  final double totalHarga;
  final String status;
  final String? catatan;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User? user;
  final List<CateringOrderDetail> detailPesanan;
  final CateringPayment? pembayaran;

  CateringOrder({
    required this.pesananId,
    required this.userId,
    this.reservasiId,
    required this.totalHarga,
    required this.status,
    this.catatan,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.detailPesanan = const [],
    this.pembayaran,
  });

  factory CateringOrder.fromJson(Map<String, dynamic> json) {
    return CateringOrder(
      pesananId: json['pesanan_id'] ?? '',
      userId: json['user_id'] ?? '',
      reservasiId: json['reservasi_id'],
      // Perbaikan: Handle string to double conversion
      totalHarga: _parseToDouble(json['total_harga']),
      status: json['status'] ?? '',
      catatan: json['catatan'],
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      detailPesanan:
          json['detail_pesanan'] != null
              ? (json['detail_pesanan'] as List)
                  .map((detail) => CateringOrderDetail.fromJson(detail))
                  .toList()
              : [],
      pembayaran:
          json['pembayaran'] != null
              ? CateringPayment.fromJson(json['pembayaran'])
              : null,
    );
  }

  // Helper method untuk convert string/int/double ke double
  static double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }
}

class CateringOrderDetail {
  final String detailId;
  final String pesananId;
  final String menuId;
  final int jumlahPorsi;
  final double hargaSatuan;
  final double subtotal;
  final CateringMenu? menu;

  CateringOrderDetail({
    required this.detailId,
    required this.pesananId,
    required this.menuId,
    required this.jumlahPorsi,
    required this.hargaSatuan,
    required this.subtotal,
    this.menu,
  });

  factory CateringOrderDetail.fromJson(Map<String, dynamic> json) {
    // Perbaikan: Handle string to double conversion
    final hargaSatuan = _parseToDouble(json['harga_satuan']);
    final jumlahPorsi = _parseToInt(json['jumlah_porsi']);

    return CateringOrderDetail(
      detailId: json['detail_id'] ?? '',
      pesananId: json['pesanan_id'] ?? '',
      menuId: json['menu_id'] ?? '',
      jumlahPorsi: jumlahPorsi,
      hargaSatuan: hargaSatuan,
      subtotal: hargaSatuan * jumlahPorsi,
      menu: json['menu'] != null ? CateringMenu.fromJson(json['menu']) : null,
    );
  }

  // Helper methods
  static double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  static int _parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }
}

class CateringPayment {
  final String pembayaranId;
  final String pesananId;
  final double jumlah;
  final String metode;
  final String? buktiBayarUrl;
  final String status;
  final DateTime? verifiedAt;

  CateringPayment({
    required this.pembayaranId,
    required this.pesananId,
    required this.jumlah,
    required this.metode,
    this.buktiBayarUrl,
    required this.status,
    this.verifiedAt,
  });

  factory CateringPayment.fromJson(Map<String, dynamic> json) {
    return CateringPayment(
      pembayaranId: json['pembayaran_id'] ?? '',
      pesananId: json['pesanan_id'] ?? '',
      // Perbaikan: Handle string to double conversion
      jumlah: _parseToDouble(json['jumlah']),
      metode: json['metode'] ?? '',
      buktiBayarUrl: json['bukti_bayar'],
      status: json['status'] ?? '',
      verifiedAt:
          json['verified_at'] != null
              ? DateTime.parse(json['verified_at'])
              : null,
    );
  }

  static double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }
}

class User {
  final String userId;
  final String? email;
  final String? fullName;
  final String? phone;
  final String? whatsappNumber;

  User({
    required this.userId,
    this.email,
    this.fullName,
    this.phone,
    this.whatsappNumber,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'] ?? '',
      email: json['email'],
      fullName: json['full_name'],
      phone: json['phone'],
      whatsappNumber: json['whatsapp_number'],
    );
  }
}

class CateringMenu {
  final String menuId;
  final String cateringId;
  final String namaMenu;
  final String kategori;
  final double harga;
  final String? fotoMenuUrl;
  final bool isAvailable;

  CateringMenu({
    required this.menuId,
    required this.cateringId,
    required this.namaMenu,
    required this.kategori,
    required this.harga,
    this.fotoMenuUrl,
    required this.isAvailable,
  });

  factory CateringMenu.fromJson(Map<String, dynamic> json) {
    return CateringMenu(
      menuId: json['menu_id'] ?? '',
      cateringId: json['catering_id'] ?? '',
      namaMenu: json['nama_menu'] ?? '',
      kategori: json['kategori'] ?? '',
      // Perbaikan: Handle string to double conversion
      harga: _parseToDouble(json['harga']),
      fotoMenuUrl: json['foto_menu'],
      isAvailable: json['is_available'] ?? true,
    );
  }

  static double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }
}
