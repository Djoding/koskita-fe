import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kosan_euy/screens/penghuni/notification/detail_reservasi_penghuni.dart';

class PesananKamarPenghuniScreen extends StatelessWidget {
  const PesananKamarPenghuniScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Data dummy
    final List<Map<String, String>> pesanan = [
      {
        'nama': 'Nella Aprilia',
        'tanggal': '10 Desember 2024',
        'status': 'Lunas',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF91B7DE),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.black,
                      ),
                      onPressed: () => Get.back(),
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'Semua  Pesanan Reservasi Kamar',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Section Bulan
            Padding(
              padding: const EdgeInsets.only(left: 24, bottom: 2),
              child: const Text(
                'Desember',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 24, bottom: 12),
              child: const Text(
                '1 item',
                style: TextStyle(color: Color(0xFFE6E6E6), fontSize: 12),
              ),
            ),
            // Card Pesanan
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children:
                    pesanan.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              Get.to(
                                () => const DetailReservasiPenghuniScreen(),
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['nama'] ?? '',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${item['tanggal']} | ${item['status']}',
                                            style: const TextStyle(
                                              color: Color(0xFF9E9E9E),
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.black45,
                                      size: 22,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
