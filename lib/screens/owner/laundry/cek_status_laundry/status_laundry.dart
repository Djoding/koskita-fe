import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kosan_euy/screens/owner/laundry/cek_status_laundry/edit_status_laundry.dart';

class StatusLaundryScreen extends StatelessWidget {
  const StatusLaundryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Data dummy status laundry
    final List<Map<String, dynamic>> statusList = [
      {'text': 'Pesanan Anda telah diterima', 'active': true, 'done': true},
      {
        'text': 'Sedang menyiapkan pesanan laundry Anda',
        'active': true,
        'done': true,
      },
      {'text': 'Pesanan Anda siap diantar', 'active': true, 'done': true},
      {'text': 'Pesanan segera tiba!', 'active': true, 'done': true},
      {
        'text': 'Pesanan telah diantar',
        'active': true,
        'done': false,
        'highlight': true,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF91B7DE),
      body: SafeArea(
        child: Column(
          children: [
            // Header back
            Padding(
              padding: const EdgeInsets.only(
                top: 24,
                left: 16,
                right: 16,
                bottom: 16,
              ),
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
                ],
              ),
            ),
            // Card utama
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 12),
                            // Garis tipis di atas
                            Container(
                              width: 60,
                              height: 6,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE6E6E6),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(height: 18),
                            // Info laundry
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18.0,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE6E6E6),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.asset(
                                        'assets/icon_laundry.png',
                                        fit: BoxFit.contain,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                                  Icons.image,
                                                  size: 32,
                                                  color: Colors.grey,
                                                ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: const [
                                        Text(
                                          'Pemesanan Layanan   Laundry',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                            color: Colors.black,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Pemesanan, Selasa 6 Mei 2025',
                                          style: TextStyle(
                                            color: Color(0xFF9E9E9E),
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Status waktu
                            const Text(
                              '1 menit',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 28,
                                color: Color(0xFF232323),
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'SEDANG DIANTAR',
                              style: TextStyle(
                                color: Color(0xFF9E9E9E),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Timeline status
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18.0,
                              ),
                              child: Column(
                                children: List.generate(statusList.length, (i) {
                                  final item = statusList[i];
                                  final isLast = i == statusList.length - 1;
                                  return Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        children: [
                                          Container(
                                            width: 20,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              color:
                                                  item['highlight'] == true
                                                      ? const Color(0xFFFF7A00)
                                                      : const Color(0xFFFFA726),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              item['done'] == true
                                                  ? Icons.check
                                                  : Icons
                                                      .radio_button_unchecked,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                          if (!isLast)
                                            Container(
                                              width: 2,
                                              height: 28,
                                              color: const Color(0xFFFFA726),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            top: 2.0,
                                          ),
                                          child: Text(
                                            item['text'],
                                            style: TextStyle(
                                              color:
                                                  item['highlight'] == true
                                                      ? const Color(0xFFFF7A00)
                                                      : const Color(0xFF9E9E9E),
                                              fontWeight:
                                                  item['highlight'] == true
                                                      ? FontWeight.w700
                                                      : FontWeight.normal,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Tombol Edit
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () {
                            Get.to(() => const EditStatusLaundryScreen());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF119DB0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Edit',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
