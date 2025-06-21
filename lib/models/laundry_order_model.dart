// lib/models/laundry_order_model.dart
class LaundryOrder {
  final String pesananId;
  final String userId;
  final String? reservasiId;
  final String laundryId;
  final double totalEstimasi;
  final double? totalFinal;
  final double? beratActual;
  final String status;
  final String? catatan;
  final String? catatanPengelola;
  final DateTime tanggalAntar;
  final DateTime? estimasiSelesai;
  final DateTime? acceptedAt;
  final DateTime? completedAt;
  final DateTime? pickedUpAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final LaundryUser? user;
  final LaundryProvider? laundry;
  final List<LaundryOrderDetail> detailPesanan;
  final LaundryPayment? pembayaran;

  LaundryOrder({
    required this.pesananId,
    required this.userId,
    this.reservasiId,
    required this.laundryId,
    required this.totalEstimasi,
    this.totalFinal,
    this.beratActual,
    required this.status,
    this.catatan,
    this.catatanPengelola,
    required this.tanggalAntar,
    this.estimasiSelesai,
    this.acceptedAt,
    this.completedAt,
    this.pickedUpAt,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.laundry,
    this.detailPesanan = const [],
    this.pembayaran,
  });

  factory LaundryOrder.fromJson(Map<String, dynamic> json) {
    return LaundryOrder(
      pesananId: json['pesanan_id'] ?? '',
      userId: json['user_id'] ?? '',
      reservasiId: json['reservasi_id'],
      laundryId: json['laundry_id'] ?? '',
      totalEstimasi: _parseToDouble(json['total_estimasi']),
      totalFinal: _parseToDouble(json['total_final']),
      beratActual: _parseToDouble(json['berat_actual']),
      status: json['status'] ?? '',
      catatan: json['catatan'],
      catatanPengelola: json['catatan_pengelola'],
      tanggalAntar: DateTime.parse(
        json['tanggal_antar'] ?? DateTime.now().toIso8601String(),
      ),
      estimasiSelesai:
          json['estimasi_selesai'] != null
              ? DateTime.parse(json['estimasi_selesai'])
              : null,
      acceptedAt:
          json['accepted_at'] != null
              ? DateTime.parse(json['accepted_at'])
              : null,
      completedAt:
          json['completed_at'] != null
              ? DateTime.parse(json['completed_at'])
              : null,
      pickedUpAt:
          json['picked_up_at'] != null
              ? DateTime.parse(json['picked_up_at'])
              : null,
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
      user: json['user'] != null ? LaundryUser.fromJson(json['user']) : null,
      laundry:
          json['laundry'] != null
              ? LaundryProvider.fromJson(json['laundry'])
              : null,
      detailPesanan:
          json['detail_pesanan_laundry'] != null
              ? (json['detail_pesanan_laundry'] as List)
                  .map((detail) => LaundryOrderDetail.fromJson(detail))
                  .toList()
              : [],
      pembayaran:
          json['pembayaran'] != null
              ? LaundryPayment.fromJson(json['pembayaran'])
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

class LaundryOrderDetail {
  final String detailId;
  final String pesananId;
  final String layananId;
  final int jumlahSatuan;
  final double hargaPerSatuan;
  final double subtotal;
  final LaundryServiceType? layanan;

  LaundryOrderDetail({
    required this.detailId,
    required this.pesananId,
    required this.layananId,
    required this.jumlahSatuan,
    required this.hargaPerSatuan,
    required this.subtotal,
    this.layanan,
  });

  factory LaundryOrderDetail.fromJson(Map<String, dynamic> json) {
    final hargaPerSatuan = _parseToDouble(json['harga_per_satuan']);
    final jumlahSatuan = _parseToInt(json['jumlah_satuan']);

    return LaundryOrderDetail(
      detailId: json['detail_id'] ?? '',
      pesananId: json['pesanan_id'] ?? '',
      layananId: json['layanan_id'] ?? '',
      jumlahSatuan: jumlahSatuan,
      hargaPerSatuan: hargaPerSatuan,
      subtotal: hargaPerSatuan * jumlahSatuan,
      layanan:
          json['layanan'] != null
              ? LaundryServiceType.fromJson(json['layanan'])
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

class LaundryPayment {
  final String pembayaranId;
  final String pesananId;
  final double jumlah;
  final String metode;
  final String? buktiBayarUrl;
  final String status;
  final DateTime? verifiedAt;
  final DateTime createdAt;

  LaundryPayment({
    required this.pembayaranId,
    required this.pesananId,
    required this.jumlah,
    required this.metode,
    this.buktiBayarUrl,
    required this.status,
    this.verifiedAt,
    required this.createdAt,
  });

  factory LaundryPayment.fromJson(Map<String, dynamic> json) {
    return LaundryPayment(
      pembayaranId: json['pembayaran_id'] ?? '',
      pesananId: json['pesanan_id'] ?? '',
      jumlah: _parseToDouble(json['jumlah']),
      metode: json['metode'] ?? '',
      buktiBayarUrl: json['bukti_bayar_url'] ?? json['bukti_bayar'],
      status: json['status'] ?? '',
      verifiedAt:
          json['verified_at'] != null
              ? DateTime.parse(json['verified_at'])
              : null,
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
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

class LaundryUser {
  final String userId;
  final String? email;
  final String? fullName;
  final String? phone;
  final String? whatsappNumber;

  LaundryUser({
    required this.userId,
    this.email,
    this.fullName,
    this.phone,
    this.whatsappNumber,
  });

  factory LaundryUser.fromJson(Map<String, dynamic> json) {
    return LaundryUser(
      userId: json['user_id'] ?? '',
      email: json['email'],
      fullName: json['full_name'],
      phone: json['phone'],
      whatsappNumber: json['whatsapp_number'],
    );
  }
}

class LaundryProvider {
  final String laundryId;
  final String namaLaundry;
  final String? alamat;
  final String? whatsappNumber;
  final String? qrisImageUrl;
  final bool isPartner;
  final LaundryKost? kost;

  LaundryProvider({
    required this.laundryId,
    required this.namaLaundry,
    this.alamat,
    this.whatsappNumber,
    this.qrisImageUrl,
    required this.isPartner,
    this.kost,
  });

  factory LaundryProvider.fromJson(Map<String, dynamic> json) {
    return LaundryProvider(
      laundryId: json['laundry_id'] ?? '',
      namaLaundry: json['nama_laundry'] ?? '',
      alamat: json['alamat'],
      whatsappNumber: json['whatsapp_number'],
      qrisImageUrl: json['qris_image_url'],
      isPartner: json['is_partner'] ?? false,
      kost: json['kost'] != null ? LaundryKost.fromJson(json['kost']) : null,
    );
  }
}

class LaundryKost {
  final String kostId;
  final String namaKost;
  final String? alamat;

  LaundryKost({required this.kostId, required this.namaKost, this.alamat});

  factory LaundryKost.fromJson(Map<String, dynamic> json) {
    return LaundryKost(
      kostId: json['kost_id'] ?? '',
      namaKost: json['nama_kost'] ?? '',
      alamat: json['alamat'],
    );
  }
}

class LaundryServiceType {
  final String layananId;
  final String namaLayanan;
  final String satuan;

  LaundryServiceType({
    required this.layananId,
    required this.namaLayanan,
    required this.satuan,
  });

  factory LaundryServiceType.fromJson(Map<String, dynamic> json) {
    return LaundryServiceType(
      layananId: json['layanan_id'] ?? '',
      namaLayanan: json['nama_layanan'] ?? '',
      satuan: json['satuan'] ?? '',
    );
  }
}
