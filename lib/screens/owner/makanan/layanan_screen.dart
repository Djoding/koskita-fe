// lib/screens/owner/makanan/layanan_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kosan_euy/screens/owner/makanan/layanan_makanan/makanan_screen.dart';
import 'package:kosan_euy/screens/owner/makanan/cek_pesanan/owner_cek_pesanan.dart';
import 'package:kosan_euy/screens/settings/setting_screen.dart';
import 'package:kosan_euy/routes/app_pages.dart'; // Import app_pages.dart

class LayananMakananScreen extends StatelessWidget {
  const LayananMakananScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil kostData dari arguments
    final Map<String, dynamic>? kostData =
        Get.arguments as Map<String, dynamic>?;

    // Debug print untuk memastikan data ada
    print('LayananMakananScreen kostData: $kostData');

    return Scaffold(
      backgroundColor: const Color(0xFF9EBFED),
      body: SafeArea(
        child: Column(
          children: [
            // Header - sama seperti DashboardLaundryScreen
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
                        size: 20,
                      ),
                      onPressed: () => Get.back(),
                    ),
                  ),
                  const Spacer(),
                  Column(
                    children: [
                      Text(
                        'Manajemen Catering',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      if (kostData != null)
                        Text(
                          kostData!['nama_kost'] ?? '',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  Row(
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
                            Icons.refresh,
                            color: Colors.black,
                            size: 20,
                          ),
                          onPressed: () {
                            // Refresh functionality jika diperlukan
                            Get.snackbar(
                              'Info',
                              'Data dimuat ulang',
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.settings,
                            color: Colors.black,
                            size: 20, // Ubah dari 28 ke 20 untuk konsistensi
                          ),
                          onPressed: () => Get.to(() => SettingScreen()),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Menu Grid - gunakan style yang sama
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: [
                    _buildMenuCard(
                      'Daftar Catering', // Ubah teks
                      'Kelola penyedia layanan catering', // Ubah subtitle
                      'assets/icon_makanan.png',
                      Colors.orange,
                      () {
                        if (kostData != null) {
                          // Navigasi ke CateringListScreen yang baru
                          Get.toNamed(Routes.cateringList, arguments: kostData);
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
                    _buildMenuCard(
                      'Pesanan Masuk',
                      'Kelola pesanan dari penghuni',
                      'assets/icon_order.png',
                      Colors.green,
                      () {
                        if (kostData != null) {
                          Get.to(
                            () => const OwnerCekPesanan(),
                            arguments: {
                              'kost_data': kostData,
                            }, // Removed catering_filter
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    String title,
    String subtitle,
    String imageAsset, // Ubah dari IconData ke String untuk asset path
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ubah bagian icon untuk menggunakan image asset seperti KostDetailScreen
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                imageAsset,
                width: 50,
                height: 50,
                fit: BoxFit.contain,
                errorBuilder:
                    (context, error, stackTrace) => Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey[300],
                      child: Icon(
                        Icons.broken_image,
                        size: 25,
                        color: Colors.grey[500],
                      ),
                    ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600]),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
