import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DetailReservasiPenghuniScreen extends StatelessWidget {
  const DetailReservasiPenghuniScreen({super.key});

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
                            Expanded(child: Text('Tanggal Masuk')),
                            Text('Senin, 10 Desember 2024'),
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
                            Expanded(child: Text('Tanggal Keluar')),
                            Text('Minggu 10 Desember 2025'),
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
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withAlpha((0.5 * 255).toInt()),
                    ),
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/icon_reservasi.png',
                          height: 90,
                          fit: BoxFit.contain,
                          errorBuilder:
                              (context, error, stackTrace) => const Icon(
                                Icons.image,
                                size: 40,
                                color: Colors.grey,
                              ),
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: Colors.white, thickness: 0.7),
                        const SizedBox(height: 8),
                        Row(
                          children: const [
                            Expanded(
                              child: Text(
                                'TOTAL',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Text(
                              'Rp. 12.000.000',
                              style: TextStyle(
                                color: Colors.white,
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
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
