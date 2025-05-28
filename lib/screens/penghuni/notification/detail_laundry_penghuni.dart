import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kosan_euy/screens/penghuni/notification/lihat_status_laundry.dart';

class DetailLaundryPenghuniScreen extends StatelessWidget {
  const DetailLaundryPenghuniScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF91B7DE),
      body: SafeArea(
        child: SingleChildScrollView(
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
                      'Pesanan',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    const Spacer(flex: 2),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              // Informasi Pemesan
              Padding(
                padding: const EdgeInsets.only(left: 24, bottom: 8),
                child: const Text(
                  'Informasi Pemesan',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((0.06 * 255).toInt()),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Expanded(child: Text('No Referensi')),
                            Text(
                              '12345',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: const [
                            Expanded(child: Text('Tanggal Pemesanan')),
                            Text('Selasa, 24 Juni 2025'),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: const [
                            Expanded(child: Text('Jam Pemesanan')),
                            Text('10.00 WIB'),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: const [
                            Expanded(child: Text('Tanggal Pengiriman')),
                            Text('Jumat, 27 Juni 2025'),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: const [
                            Expanded(child: Text('Jam Pengiriman')),
                            Text('17.00 WIB'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Daftar Pesanan
              Padding(
                padding: const EdgeInsets.only(left: 24, bottom: 8),
                child: const Text(
                  'Daftar Pesanan',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((0.06 * 255).toInt()),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    '3 Kg',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Layanan: Cuci & Gosok',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Rp 18.000',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                'assets/laundry.png',
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) => const Icon(
                                      Icons.image,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(thickness: 1),
                        const SizedBox(height: 8),
                        Row(
                          children: const [
                            Expanded(
                              child: Text(
                                'TOTAL',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Text(
                              'Rp. 20.000',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Tombol
              Center(
                child: SizedBox(
                  width: 260,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.to(() => const LihatStatusLaundry());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF119DB1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Lihat Status Pesanan',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
