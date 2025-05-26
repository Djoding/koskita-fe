import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kosan_euy/screens/owner/makanan/pembayaran/add_metode_pembayaran.dart';
import 'package:kosan_euy/screens/owner/makanan/pembayaran/edit_metode_pembayaran.dart';

class MetodePembayaranScreen extends StatelessWidget {
  const MetodePembayaranScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> paymentMethods = [
      {'name': 'OVO', 'image': 'assets/ovo.png'},
      {'name': 'DANA', 'image': 'assets/dana.png'},
      {'name': 'GoPay', 'image': 'assets/gopay.png'},
      {'name': 'ShopeePay', 'image': 'assets/shopee_pay.png'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF91B7DE),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              // Header with back and add buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, color: Colors.black),
                      onPressed: () {
                        Get.to(() => const AddMetodePembayaranScreen());
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Title
              const Text(
                'Pilih Metode Pembayaran\nDibawah Ini...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 32),
              // Payment methods list
              Expanded(
                child: ListView.builder(
                  itemCount: paymentMethods.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Image.asset(
                          paymentMethods[index]['image']!,
                          height: 35,
                          fit: BoxFit.contain,
                          errorBuilder:
                              (context, error, stackTrace) => Text(
                                paymentMethods[index]['name']!,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Edit button
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.to(() => const EditMetodePembayaranScreen());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF119DB0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Edit',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
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
