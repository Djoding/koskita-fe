import 'package:flutter/cupertino.dart';

import 'api_service.dart';

class KostService {

  // Login
  static Future<Map<String, dynamic>> createKost(Map<String, dynamic> formData) async {
    try {
      final response = await ApiService.post('/kost/create', {
        'namaPemilik': formData['namaPemilik'],
        'namaKost': formData['namaKost'],
        'lokasi': formData['lokasi'],
        'jenisKost': formData['jenisKost'],
        'jumlahKamar': formData['jumlahKamar'],
        'harga': formData['harga'],
        'fasilitasKamar': formData['fasilitasKamar'],
        'fasilitasKamarMandi': formData['fasilitasKamarMandi'],
        'kebijakanProperti': formData['kebijakanProperti'],
        'kebijakanFasilitas': formData['kebijakanFasilitas'],
        'deskripsiProperti': formData['deskripsiProperti'],
        'informasiJarak': formData['informasiJarak'],
        'images': formData['imageUrls'],
      });
      debugPrint("RESPONSE ${response}");

      if (response['status']) {
        return {
          'status' : true,
          'message' : response['message']
        };
      }

      return {
        'status' : false,
        'message' : response['message']
      };
    } catch (e) {
      print('Error creating kost: $e');
      return {
        'status' : false,
        'message' : e.toString()
      };
    }
  }

  static Future<Map<String, dynamic>> getDataKost() async {
    try {
      final response = await ApiService.get('/kost/');
      debugPrint("RESPONSE GET DATA KOST ${response}");
      if (response['status']) {
        return {
          'status' : true,
          'data' : response['data'],
          'message' : response['message']
        };
      }

      return {
        'status' : false,
        'message' : response['message']
      };
    } catch (e) {
      print("Error get data kost ${e}");
      return {
        'status' : false,
        'message' : e.toString()
      };
    }
  }
}