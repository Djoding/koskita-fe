// lib/screens/owner/makanan/layanan_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kosan_euy/screens/owner/makanan/layanan_makanan/makanan_screen.dart';
import 'package:kosan_euy/screens/owner/makanan/cek_pesanan/owner_cek_pesanan.dart';

class LayananMakananScreen extends StatelessWidget {
  const LayananMakananScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil kostData dari arguments
    final Map<String, dynamic>? kostData =
        Get.arguments as Map<String, dynamic>?;

    // Debug print untuk memastikan data ada
    print('LayananMakananScreen kostData: $kostData');

    final List<_MenuItem> menuItems = [
      _MenuItem(
        label: 'Edit Layanan Makanan/Minuman',
        image: 'assets/icon_makanan.png',
        onTap: () {
          // Pastikan kostData diteruskan ke FoodListScreen
          if (kostData != null) {
            Get.to(
              () => const FoodListScreen(),
              arguments: kostData, // Teruskan kostData
            );
          } else {
            Get.snackbar(
              'Error',
              'Data kost tidak ditemukan. Kembali ke detail kost.',
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        },
      ),
      _MenuItem(
        label: 'Pesanan Masuk',
        image: 'assets/icon_order.png',
        onTap: () {
          // Pastikan kostData diteruskan ke OwnerCekPesanan
          if (kostData != null) {
            Get.to(
              () => const OwnerCekPesanan(),
              arguments: kostData, // Teruskan kostData
            );
          } else {
            Get.snackbar(
              'Error',
              'Data kost tidak ditemukan. Kembali ke detail kost.',
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        },
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF91B7DE),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16.0, left: 16.0),
              child: Container(
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
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                'Layanan Pemesanan Makanan/Minuman',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                ),
              ),
            ),

            // Debug info - tampilkan nama kost jika ada
            if (kostData != null) ...[
              const SizedBox(height: 16),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Kost: ${kostData['nama_kost'] ?? 'Unknown'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 24,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1,
                  children:
                      menuItems.map((item) => _MenuCard(item: item)).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  final String label;
  final String image;
  final VoidCallback onTap;
  _MenuItem({required this.label, required this.image, required this.onTap});
}

class _MenuCard extends StatelessWidget {
  final _MenuItem item;
  const _MenuCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withAlpha((0.7 * 255).toInt()),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 70,
              height: 70,
              child: Image.asset(
                item.image,
                fit: BoxFit.contain,
                errorBuilder:
                    (context, error, stackTrace) =>
                        const Icon(Icons.image, size: 60, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: Text(
                item.label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
