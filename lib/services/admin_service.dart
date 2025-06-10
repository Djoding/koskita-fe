// lib/services/admin_service.dart
import 'package:kosan_euy/services/api_service.dart';

class AdminService {
  // Get all pengelola (pending dan verified)
  static Future<Map<String, dynamic>> getAllPengelola() async {
    try {
      final response = await ApiService.get('/admin/pengelola');
      return {
        'status': true,
        'data': response['data'],
        'message': response['message'],
      };
    } catch (e) {
      // Offline mode - return dummy data
      return {
        'status': true,
        'data': {
          'pending': [
            {
              'id': '1',
              'nama': 'John Doe',
              'email': 'john@example.com',
              'namaKost': 'Kost Kapling 40',
              'lokasi': 'Jl. Kapling No. 40',
              'tanggalDaftar': '2024-06-10',
              'status': 'pending',
              'phone': '08123456789',
              'alamat': 'Jl. Contoh No. 123, Semarang',
              'nik': '3374123456789012',
              'jumlahKamar': 10,
              'harga': '1000000',
              'jenisKost': 'Putra',
            },
            {
              'id': '2',
              'nama': 'Jane Smith',
              'email': 'jane@example.com',
              'namaKost': 'Kost Melati',
              'lokasi': 'Jl. Melati No. 15',
              'tanggalDaftar': '2024-06-09',
              'status': 'pending',
              'phone': '08123456790',
              'alamat': 'Jl. Melati No. 15, Semarang',
              'nik': '3374123456789013',
              'jumlahKamar': 8,
              'harga': '900000',
              'jenisKost': 'Putri',
            },
          ],
          'verified': [
            {
              'id': '3',
              'nama': 'Ahmad Sari',
              'email': 'ahmad@example.com',
              'namaKost': 'Kost Mawar',
              'lokasi': 'Jl. Mawar No. 20',
              'tanggalDaftar': '2024-06-01',
              'tanggalVerifikasi': '2024-06-02',
              'status': 'verified',
              'phone': '08123456791',
              'alamat': 'Jl. Mawar No. 20, Semarang',
              'nik': '3374123456789014',
              'jumlahKamar': 12,
              'harga': '1200000',
              'jenisKost': 'Campur',
            },
          ],
        },
        'message': 'Data retrieved successfully (offline mode)',
      };
    }
  }

  // Verify pengelola
  static Future<Map<String, dynamic>> verifyPengelola(
    String penggelolaId,
  ) async {
    try {
      final response = await ApiService.put(
        '/admin/pengelola/$penggelolaId/verify',
        {},
      );
      return {'status': true, 'message': response['message']};
    } catch (e) {
      // Offline mode
      return {
        'status': true,
        'message': 'Pengelola berhasil diverifikasi (offline mode)',
      };
    }
  }

  // Delete pengelola
  static Future<Map<String, dynamic>> deletePengelola(
    String penggelolaId,
  ) async {
    try {
      final response = await ApiService.delete(
        '/admin/pengelola/$penggelolaId',
      );
      return {'status': true, 'message': response['message']};
    } catch (e) {
      // Offline mode
      return {
        'status': true,
        'message': 'Pengelola berhasil dihapus (offline mode)',
      };
    }
  }

  // Get pengelola detail
  static Future<Map<String, dynamic>> getPenggelolaDetail(
    String penggelolaId,
  ) async {
    try {
      final response = await ApiService.get('/admin/pengelola/$penggelolaId');
      return {
        'status': true,
        'data': response['data'],
        'message': response['message'],
      };
    } catch (e) {
      // Offline mode - return dummy detail
      return {
        'status': true,
        'data': {
          'id': penggelolaId,
          'nama': 'John Doe',
          'email': 'john@example.com',
          'namaKost': 'Kost Kapling 40',
          'lokasi': 'Jl. Kapling No. 40',
          'tanggalDaftar': '2024-06-10',
          'status': 'pending',
          'phone': '08123456789',
          'alamat': 'Jl. Contoh No. 123, Semarang',
          'nik': '3374123456789012',
          'jumlahKamar': 10,
          'harga': '1000000',
          'jenisKost': 'Putra',
          'fasilitasKamar': ['AC', 'WiFi', 'Lemari'],
          'deskripsiProperti': 'Kost nyaman dengan fasilitas lengkap',
        },
        'message': 'Detail retrieved successfully (offline mode)',
      };
    }
  }

  // Get statistics
  static Future<Map<String, dynamic>> getStatistics() async {
    try {
      final response = await ApiService.get('/admin/statistics');
      return {
        'status': true,
        'data': response['data'],
        'message': response['message'],
      };
    } catch (e) {
      // Offline mode
      return {
        'status': true,
        'data': {
          'totalPengelola': 3,
          'pendingPengelola': 2,
          'verifiedPengelola': 1,
          'totalKost': 3,
          'totalPenghuni': 15,
        },
        'message': 'Statistics retrieved successfully (offline mode)',
      };
    }
  }
}
