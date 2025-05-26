import 'package:get/get.dart';

class NotifikasiMakananController extends GetxController {
  // Dummy data notifikasi makanan
  final notifikasiList = <Map<String, String>>[
    {
      'title': 'Pesanan Makanan Diterima',
      'message':
          'Pesanan nasi goreng untuk kamar 101 sudah diterima dan sedang diproses.',
      'date': '2024-06-10 09:00',
    },
    {
      'title': 'Pesanan Selesai',
      'message':
          'Pesanan mie ayam untuk kamar 102 sudah selesai dan siap diambil.',
      'date': '2024-06-09 18:30',
    },
    {
      'title': 'Pembatalan Pesanan',
      'message': 'Pesanan soto ayam untuk kamar 103 dibatalkan oleh penghuni.',
      'date': '2024-06-08 12:15',
    },
  ];

  // Fungsi dummy untuk menambah notifikasi
  void addNotifikasi(Map<String, String> notif) {
    notifikasiList.add(notif);
    update();
  }

  // Fungsi dummy untuk menghapus notifikasi
  void removeNotifikasi(int index) {
    notifikasiList.removeAt(index);
    update();
  }
}
