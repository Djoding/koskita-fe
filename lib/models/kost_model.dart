class KostModel {
  final String kostId;
  final String pengelolaId;
  final String namaKost;
  final String alamat;
  final String? gmapsLink;
  final String? deskripsi;
  final int totalKamar;
  final String? dayaListrik;
  final String? sumberAir;
  final String? wifiSpeed;
  final int kapasitasParkirMotor;
  final int kapasitasParkirMobil;
  final int kapasitasParkirSepeda;
  final double? biayaTambahan;
  final String? jamSurvey;
  final List<String> fotoKost;
  final String? qrisImage;
  final Map<String, dynamic>? rekeningInfo;
  final bool isApproved;
  final String tipeId;
  final double hargaBulanan;
  final double? deposit;
  final double hargaFinal;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? totalOccupiedRooms;
  final int? availableRooms;

  // Related models
  final PengelolaModel? pengelola;
  final TipeKamarModel? tipe;
  final List<FasilitasModel>? fasilitas;
  final List<PeraturanModel>? peraturan;

  KostModel({
    required this.kostId,
    required this.pengelolaId,
    required this.namaKost,
    required this.alamat,
    this.gmapsLink,
    this.deskripsi,
    required this.totalKamar,
    this.dayaListrik,
    this.sumberAir,
    this.wifiSpeed,
    this.kapasitasParkirMotor = 0,
    this.kapasitasParkirMobil = 0,
    this.kapasitasParkirSepeda = 0,
    this.biayaTambahan,
    this.jamSurvey,
    this.fotoKost = const [],
    this.qrisImage,
    this.rekeningInfo,
    this.isApproved = false,
    required this.tipeId,
    required this.hargaBulanan,
    this.deposit,
    required this.hargaFinal,
    required this.createdAt,
    required this.updatedAt,
    this.totalOccupiedRooms,
    this.availableRooms,
    this.pengelola,
    this.tipe,
    this.fasilitas,
    this.peraturan,
  });

  factory KostModel.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse int
    int? _safeParseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    // Helper function to safely parse double
    double? _safeParseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return KostModel(
      kostId: json['kost_id'] ?? '',
      pengelolaId: json['pengelola_id'] ?? '',
      namaKost: json['nama_kost'] ?? '',
      alamat: json['alamat'] ?? '',
      gmapsLink: json['gmaps_link'],
      deskripsi: json['deskripsi'],
      totalKamar: _safeParseInt(json['total_kamar']) ?? 0,
      dayaListrik: json['daya_listrik'],
      sumberAir: json['sumber_air'],
      wifiSpeed: json['wifi_speed'],
      kapasitasParkirMotor: _safeParseInt(json['kapasitas_parkir_motor']) ?? 0,
      kapasitasParkirMobil: _safeParseInt(json['kapasitas_parkir_mobil']) ?? 0,
      kapasitasParkirSepeda:
          _safeParseInt(json['kapasitas_parkir_sepeda']) ?? 0,
      biayaTambahan: _safeParseDouble(json['biaya_tambahan']),
      jamSurvey: json['jam_survey'],
      fotoKost:
          json['foto_kost'] != null ? List<String>.from(json['foto_kost']) : [],
      qrisImage: json['qris_image'],
      rekeningInfo: json['rekening_info'],
      isApproved: json['is_approved'] ?? false,
      tipeId: json['tipe_id'] ?? '',
      hargaBulanan: _safeParseDouble(json['harga_bulanan']) ?? 0.0,
      deposit: _safeParseDouble(json['deposit']),
      hargaFinal: _safeParseDouble(json['harga_final']) ?? 0.0,
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
      totalOccupiedRooms: _safeParseInt(json['total_occupied_rooms']),
      availableRooms: _safeParseInt(json['available_rooms']),
      pengelola:
          json['pengelola'] != null
              ? PengelolaModel.fromJson(json['pengelola'])
              : null,
      tipe: json['tipe'] != null ? TipeKamarModel.fromJson(json['tipe']) : null,
      fasilitas:
          json['kost_fasilitas'] != null
              ? (json['kost_fasilitas'] as List)
                  .map((f) => FasilitasModel.fromJson(f['fasilitas']))
                  .toList()
              : null,
      peraturan:
          json['kost_peraturan'] != null
              ? (json['kost_peraturan'] as List)
                  .map((p) => PeraturanModel.fromJson(p['peraturan']))
                  .toList()
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kost_id': kostId,
      'pengelola_id': pengelolaId,
      'nama_kost': namaKost,
      'alamat': alamat,
      'gmaps_link': gmapsLink,
      'deskripsi': deskripsi,
      'total_kamar': totalKamar,
      'daya_listrik': dayaListrik,
      'sumber_air': sumberAir,
      'wifi_speed': wifiSpeed,
      'kapasitas_parkir_motor': kapasitasParkirMotor,
      'kapasitas_parkir_mobil': kapasitasParkirMobil,
      'kapasitas_parkir_sepeda': kapasitasParkirSepeda,
      'biaya_tambahan': biayaTambahan,
      'jam_survey': jamSurvey,
      'foto_kost': fotoKost,
      'qris_image': qrisImage,
      'rekening_info': rekeningInfo,
      'is_approved': isApproved,
      'tipe_id': tipeId,
      'harga_bulanan': hargaBulanan,
      'deposit': deposit,
      'harga_final': hargaFinal,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class PengelolaModel {
  final String fullName;
  final String? phone;
  final String? whatsappNumber;

  PengelolaModel({required this.fullName, this.phone, this.whatsappNumber});

  factory PengelolaModel.fromJson(Map<String, dynamic> json) {
    return PengelolaModel(
      fullName: json['full_name'] ?? '',
      phone: json['phone'],
      whatsappNumber: json['whatsapp_number'],
    );
  }
}

class TipeKamarModel {
  final String namaTipe;
  final String? ukuran;
  final int kapasitas;

  TipeKamarModel({
    required this.namaTipe,
    this.ukuran,
    required this.kapasitas,
  });

  factory TipeKamarModel.fromJson(Map<String, dynamic> json) {
    return TipeKamarModel(
      namaTipe: json['nama_tipe'] ?? '',
      ukuran: json['ukuran'],
      kapasitas: json['kapasitas'] ?? 1,
    );
  }
}

class FasilitasModel {
  final String fasilitasId;
  final String namaFasilitas;
  final String kategori;
  final String? icon;

  FasilitasModel({
    required this.fasilitasId,
    required this.namaFasilitas,
    required this.kategori,
    this.icon,
  });

  factory FasilitasModel.fromJson(Map<String, dynamic> json) {
    return FasilitasModel(
      fasilitasId: json['fasilitas_id'] ?? '',
      namaFasilitas: json['nama_fasilitas'] ?? '',
      kategori: json['kategori'] ?? '',
      icon: json['icon'],
    );
  }
}

class PeraturanModel {
  final String peraturanId;
  final String namaPeraturan;
  final String kategori;
  final String? icon;
  final String? keteranganTambahan;

  PeraturanModel({
    required this.peraturanId,
    required this.namaPeraturan,
    required this.kategori,
    this.icon,
    this.keteranganTambahan,
  });

  factory PeraturanModel.fromJson(Map<String, dynamic> json) {
    return PeraturanModel(
      peraturanId: json['peraturan_id'] ?? '',
      namaPeraturan: json['nama_peraturan'] ?? '',
      kategori: json['kategori'] ?? '',
      icon: json['icon'],
      keteranganTambahan: json['keterangan_tambahan'],
    );
  }
}
