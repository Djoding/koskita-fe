import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kosan_euy/screens/penghuni/notification/lihat_status_makanan.dart';

class DetailPesananOwner extends StatelessWidget {
  const DetailPesananOwner({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> pesanan = [
      {
        'image': 'assets/food6.png',
        'nama': 'Indomie Kuah Special',
        'harga': 'Rp 8.000',
      },
      {'image': 'assets/drink5.png', 'nama': 'Es Teh', 'harga': 'Rp 4.000'},
    ];

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
                            Expanded(child: Text('Tanggal Pesanan')),
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
                            Expanded(child: Text('Jam Pengiriman')),
                            Text('11.00 WIB'),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...pesanan.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    item['image']!,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.image,
                                              size: 40,
                                              color: Colors.grey,
                                            ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['nama']!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item['harga']!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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
                              'Rp. 12.000',
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
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
