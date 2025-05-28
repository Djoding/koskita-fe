import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kosan_euy/screens/home_screen.dart';
import 'package:kosan_euy/screens/tamu/reservasi/dashboard_reservasi_tamu.dart';
import 'package:kosan_euy/screens/tamu/reservasi/pesanan_kos_tamu.dart';

class DashboardTamuScreen extends StatelessWidget {
  const DashboardTamuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF91B7DE),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
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
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      color: Colors.black,
                      size: 28,
                    ),
                    onPressed: () {
                      Get.to(() => PesananKosTamu());
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            // Judul
            Text(
              'Layanan Manajemen Pada KostKita',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            // Card Layanan
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  // Reservasi kamar
                  _ServiceCard(
                    title: 'Layanan Reservasi kamar',
                    image: 'assets/icon_reservasi.png',
                    enabled: true,
                    onTap: () {
                      Get.to(() => DashboardReservasiTamu());
                    },
                  ),
                  const SizedBox(height: 18),
                  // Pemesanan Makan
                  _ServiceCard(
                    title: 'Layanan Pemesanan Makan',
                    image: 'assets/icon_makanan.png',
                    enabled: false,
                  ),
                  const SizedBox(height: 18),
                  // Laundry
                  _ServiceCard(
                    title: 'Layanan Laundry',
                    image: 'assets/icon_laundry.png',
                    enabled: false,
                  ),
                  const SizedBox(height: 32),
                  // Info & Tombol
                  Column(
                    children: [
                      Text(
                        'Reservasi Anda Telah Selesai?\nsilahkan anda buat akun',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            Get.to(() => HomeScreenPage());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF119DB1),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            'Buat Akun',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final String title;
  final String image;
  final bool enabled;
  final VoidCallback? onTap;

  const _ServiceCard({
    required this.title,
    required this.image,
    this.enabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: enabled ? const Color(0xFFD2E7FA) : const Color(0xFFB0B0B0),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.08 * 255).toInt()),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 30),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Lihat lebih lanjut >',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[700],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Image.asset(
                  image,
                  height: 60,
                  fit: BoxFit.contain,
                  errorBuilder:
                      (context, error, stackTrace) =>
                          const Icon(Icons.image, size: 40, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
