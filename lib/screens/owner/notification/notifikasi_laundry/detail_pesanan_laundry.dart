import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kosan_euy/screens/owner/notification/notifikasi_laundry/pesanan_dibuat.dart';

class DetailPesananLaundryScreen extends StatelessWidget {
  const DetailPesananLaundryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9EBFED),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 16.0, left: 20.0, right: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
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
                        Icons.arrow_back_ios_new,
                        color: Colors.black,
                        size: 20,
                      ),
                      onPressed: () => Get.back(),
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'Pesanan Masuk',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const Spacer(flex: 2),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'Daftar Pesanan',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 12),
              // Card Laundry
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withAlpha((0.5 * 255).toInt()),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info laundry
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '3 Kg',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(
                                (0.3 * 255).toInt(),
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Layanan: Cuci & Gosok',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'RP 18.000',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/laundry.png',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Divider(color: Colors.white54),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'TOTAL',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
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
              const SizedBox(height: 32),
              Center(
                child: SizedBox(
                  width: 180,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.to(() => const PesananDibuat());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Pesanan Dibuat',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
