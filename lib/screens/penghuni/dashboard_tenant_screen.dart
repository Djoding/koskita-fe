import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kosan_euy/screens/penghuni/laundry/laundry_penghuni.dart';
import 'package:kosan_euy/screens/penghuni/makanan/menu_makanan.dart';
import 'package:kosan_euy/screens/penghuni/notification/dashboard_notification_penghuni.dart';
import 'package:kosan_euy/screens/penghuni/reservasi/dashboard_reservasi.dart';
import 'package:kosan_euy/screens/settings/setting_screen.dart';

class DashboardTenantScreen extends StatelessWidget {
  const DashboardTenantScreen({super.key});

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
                    IconButton(
                      icon: const Icon(
                        Icons.notifications_none,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Get.to(() => const DashboardNotificationPenghuni());
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white),
                      onPressed: () {
                        Get.to(() => const SettingScreen());
                      },
                    ),
                  ],
                ),
              ),
              // Profile
              Padding(
                padding: const EdgeInsets.only(left: 32, top: 8, bottom: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.person,
                      color: Color(0xFF5B6C8E),
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Yena Anggraeni',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Penghuni Kost Kapling40',
                          style: TextStyle(
                            color: Color(0xFFE6E6E6),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Riwayat Pemesanan
              Padding(
                padding: const EdgeInsets.only(left: 24, top: 16, bottom: 8),
                child: const Text(
                  'Riwayat Pemesanan',
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
                  decoration: BoxDecoration(
                    color: const Color(0xFF91B7DE),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(0.7)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            'assets/kapling40.png',
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => const Icon(
                                  Icons.image,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Kost Kapling40',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                '1 Mei 2024 - 1 Mei 2025',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Jalan hj Umayah II, Citereup Bandung',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Layanan Manajemen
              Padding(
                padding: const EdgeInsets.only(left: 24, top: 24, bottom: 8),
                child: const Text(
                  'Layanan Manajemen Pada KostKita',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
              // Card Layanan
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _LayananCard(
                      title: 'Layanan Reservasi kamar',
                      imageAsset: 'assets/icon_reservasi.png',
                      onTap: () {
                        Get.to(() => DashboardReservasiScreen());
                      },
                    ),
                    const SizedBox(height: 12),
                    _LayananCard(
                      title: 'Layanan Pemesanan Makan',
                      imageAsset: 'assets/icon_makanan.png',
                      onTap: () {
                        Get.to(() => const MenuMakanan());
                      },
                    ),
                    const SizedBox(height: 12),
                    _LayananCard(
                      title: 'Layanan Laundry',
                      imageAsset: 'assets/icon_laundry.png',
                      onTap: () {
                        Get.to(() => const LaundryPenghuni());
                      },
                    ),
                  ],
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

class _LayananCard extends StatelessWidget {
  final String title;
  final String imageAsset;
  final VoidCallback onTap;
  const _LayananCard({
    required this.title,
    required this.imageAsset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFD6E7F8),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Color(0xFF5B6C8E),
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Image.asset(
                        imageAsset,
                        fit: BoxFit.contain,
                        errorBuilder:
                            (context, error, stackTrace) => const Icon(
                              Icons.image,
                              size: 40,
                              color: Colors.grey,
                            ),
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [
                    SizedBox(height: 40),
                    Text(
                      'Lihat lebih detail >',
                      style: TextStyle(
                        color: Color(0xFF5B6C8E),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
