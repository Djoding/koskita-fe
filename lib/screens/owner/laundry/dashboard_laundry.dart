import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kosan_euy/screens/owner/laundry/cek_semua_pesanan/cek_pesanan_laundry.dart';
import 'package:kosan_euy/screens/owner/laundry/cek_status_laundry/cek_status_laundry.dart';
import 'package:kosan_euy/screens/owner/laundry/layanan_laundry/layanan_laundry.dart';

class DashboardLaundryScreen extends StatelessWidget {
  const DashboardLaundryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_MenuItem> menuItems = [
      _MenuItem(
        label: 'Edit Layanan Laundry',
        image: 'assets/icon_laundry.png',
        onTap: () {
          Get.to(() => const LayananLaundryScreen());
        },
      ),
      _MenuItem(
        label: 'Edit Pembayaran',
        image: 'assets/icon_pembayaran.png',
        onTap: () {},
      ),
      _MenuItem(
        label: 'Edit Status Pesanan',
        image: 'assets/icon_status_pesanan.png',
        onTap: () {
          Get.to(() => const CekStatusLaundryScreen());
        },
      ),
      _MenuItem(
        label: 'Cek semua Pesanan',
        image: 'assets/icon_order.png',
        onTap: () {
          Get.to(() => const CekPesananLaundryScreen());
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
                'Layanan Laundry',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                ),
              ),
            ),
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
          color: Colors.white.withOpacity(0.7),
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
