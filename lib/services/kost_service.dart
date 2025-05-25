import 'package:flutter/cupertino.dart';

import 'api_service.dart';

class KostService {
  // Login
  static Future<Map<String, dynamic>> createKost(
    Map<String, dynamic> formData,
  ) async {
    // try {
    //   final response = await ApiService.post('/kost/create', {
    //     'namaPemilik': formData['namaPemilik'],
    //     'namaKost': formData['namaKost'],
    //     'lokasi': formData['lokasi'],
    //     'jenisKost': formData['jenisKost'],
    //     'jumlahKamar': formData['jumlahKamar'],
    //     'harga': formData['harga'],
    //     'fasilitasKamar': formData['fasilitasKamar'],
    //     'fasilitasKamarMandi': formData['fasilitasKamarMandi'],
    //     'kebijakanProperti': formData['kebijakanProperti'],
    //     'kebijakanFasilitas': formData['kebijakanFasilitas'],
    //     'deskripsiProperti': formData['deskripsiProperti'],
    //     'informasiJarak': formData['informasiJarak'],
    //     'images': formData['imageUrls'],
    //   });
    //   debugPrint("RESPONSE $response");
    //   if (response['status']) {
    //     return {'status': true, 'message': response['message']};
    //   }
    //   return {'status': false, 'message': response['message']};
    // } catch (e) {
    //   debugPrint('Error creating kost: $e');
    //   return {'status': false, 'message': e.toString()};
    // }
    // --- SLICING UI: return dummy ---
    return {'status': true, 'message': 'Dummy kost created'};
  }

  static Future<Map<String, dynamic>> getDataKost() async {
    // try {
    //   final response = await ApiService.get('/kost/');
    //   debugPrint("RESPONSE GET DATA KOST $response");
    //   if (response['status']) {
    //     return {
    //       'status': true,
    //       'data': response['data'],
    //       'message': response['message'],
    //     };
    //   }
    //   return {'status': false, 'message': response['message']};
    // } catch (e) {
    //   debugPrint("Error get data kost $e");
    //   return {'status': false, 'message': e.toString()};
    // }
    // --- SLICING UI: return dummy ---
    return {
      'status': true,
      'data': [
        {
          'namaKost': 'Kost Mawar',
          'lokasi': 'Jl. Mawar No. 1',
          'jumlahKamar': 10,
          'harga': 1000000,
        },
        {
          'namaKost': 'Kost Melati',
          'lokasi': 'Jl. Melati No. 2',
          'jumlahKamar': 8,
          'harga': 900000,
        },
      ],
      'message': 'Dummy data for slicing',
    };
  }
}
