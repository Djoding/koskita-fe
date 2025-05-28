import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kosan_euy/screens/penghuni/notification/pesanan_laundry_penghuni.dart';
import 'package:kosan_euy/screens/penghuni/notification/pesanan_makanan_penghuni.dart';
import 'pesanan_kamar_penghuni.dart';

class DashboardNotificationPenghuni extends StatelessWidget {
  const DashboardNotificationPenghuni({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FFF6),
      body: Stack(
        children: [
          // Background biru dengan sudut bawah melengkung
          Container(
            height: 170,
            decoration: const BoxDecoration(
              color: Color(0xFF91B7DE),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
          ),
          SafeArea(
            child: Column(
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
                        'Pemberitahuan',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(
                          Icons.notifications_none,
                          color: Colors.white,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Card Notifikasi
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FFF6),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _NotifCard(
                            imageAsset: 'assets/icon_reservasi.png',
                            text: 'Pemberitahuan Layanan Reservasi Kamar',
                            onTap: () {
                              Get.to(() => const PesananKamarPenghuniScreen());
                            },
                          ),
                          const SizedBox(height: 18),
                          _NotifCard(
                            imageAsset: 'assets/icon_makanan.png',
                            text: 'Pemberitahuan Layanan Pemesanan Makan/Minum',
                            onTap: () {
                              Get.to(() => const PesananMakananPenghuni());
                            },
                          ),
                          const SizedBox(height: 18),
                          _NotifCard(
                            imageAsset: 'assets/icon_laundry.png',
                            text: 'Pemberitahuan Layanan Laundry',
                            onTap: () {
                              Get.to(() => const PesananLaundryPenghuni());
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotifCard extends StatelessWidget {
  final String imageAsset;
  final String text;
  final VoidCallback onTap;
  const _NotifCard({
    required this.imageAsset,
    required this.text,
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
            child: Column(
              children: [
                Image.asset(
                  imageAsset,
                  height: 70,
                  fit: BoxFit.contain,
                  errorBuilder:
                      (context, error, stackTrace) =>
                          const Icon(Icons.image, size: 40, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
