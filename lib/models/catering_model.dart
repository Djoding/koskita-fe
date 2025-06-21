import 'package:kosan_euy/services/api_service.dart';

class CateringMenuItem {
  final String menuId;
  final String cateringId;
  final String namaMenu;
  final String kategori;
  final double harga;
  final String? fotoMenu;
  final String? fotoMenuUrl;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;

  CateringMenuItem({
    required this.menuId,
    required this.cateringId,
    required this.namaMenu,
    required this.kategori,
    required this.harga,
    this.fotoMenu,
    this.fotoMenuUrl,
    required this.isAvailable,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CateringMenuItem.fromJson(Map<String, dynamic> json) {
    double safeParseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    String? rawFotoMenu = json['foto_menu'];
    String? fullFotoMenuUrl;
    if (rawFotoMenu != null && rawFotoMenu.isNotEmpty) {
      if (rawFotoMenu.startsWith('http')) {
        fullFotoMenuUrl = rawFotoMenu;
      } else {
        fullFotoMenuUrl =
            '${ApiService.baseUrl.replaceFirst('/api/v1/', '')}$rawFotoMenu';
      }
    }

    return CateringMenuItem(
      menuId: json['menu_id'] ?? '',
      cateringId: json['catering_id'] ?? '',
      namaMenu: json['nama_menu'] ?? '',
      kategori: json['kategori'] ?? '',
      harga: safeParseDouble(json['harga']),
      fotoMenu: rawFotoMenu,
      fotoMenuUrl: fullFotoMenuUrl,
      isAvailable: json['is_available'] ?? true,
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menu_id': menuId,
      'catering_id': cateringId,
      'nama_menu': namaMenu,
      'kategori': kategori,
      'harga': harga,
      'foto_menu': fotoMenu,
      'is_available': isAvailable,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class Catering {
  final String cateringId;
  final String kostId;
  final String namaCatering;
  final String alamat;
  final String? whatsappNumber;
  final String? qrisImage;
  final String? qrisImageUrl;
  final Map<String, dynamic>? rekeningInfo;
  final bool isPartner;
  final bool isActive;
  final int menuCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Catering({
    required this.cateringId,
    required this.kostId,
    required this.namaCatering,
    required this.alamat,
    this.whatsappNumber,
    this.qrisImage,
    this.qrisImageUrl,
    this.rekeningInfo,
    required this.isPartner,
    required this.isActive,
    required this.menuCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Catering.fromJson(Map<String, dynamic> json) {
    String? rawQrisImage = json['qris_image'];
    String? fullQrisImageUrl;
    if (rawQrisImage != null && rawQrisImage.isNotEmpty) {
      if (rawQrisImage.startsWith('http')) {
        fullQrisImageUrl = rawQrisImage;
      } else {
        fullQrisImageUrl =
            ApiService.baseUrl.replaceFirst('/api/v1/', '') + rawQrisImage;
      }
    }

    return Catering(
      cateringId: json['catering_id'] ?? '',
      kostId: json['kost_id'] ?? '',
      namaCatering: json['nama_catering'] ?? '',
      alamat: json['alamat'] ?? '',
      whatsappNumber: json['whatsapp_number'],
      qrisImage: rawQrisImage,
      qrisImageUrl: fullQrisImageUrl,
      rekeningInfo: json['rekening_info'],
      isPartner: json['is_partner'] ?? false,
      isActive: json['is_active'] ?? true,
      menuCount: json['menu_count'] ?? 0,
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
